//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation
import Combine

final class APIRepresentative: ObservableObject {
    // private static let baseURLString = "https://apptelemetry.io/api/v1/"
    private static let baseURLString = "http://localhost:8080/api/v1/"
    private static let userTokenStandardsKey = "org.breakthesystem.telemetry.viewer.userToken"
    
    init() {
        if let encodedUserToken = UserDefaults.standard.data(forKey: APIRepresentative.userTokenStandardsKey),
           let userToken = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: encodedUserToken) {
            self.userToken = userToken
            getUserInformation()
            getApps()
        }
    }
    
    @Published var registrationStatus: RegistrationStatus?
    
    @Published var userToken: UserToken? {
        didSet {
            let encodedUserToken = try! JSONEncoder.telemetryEncoder.encode(userToken)
            UserDefaults.standard.setValue(encodedUserToken, forKey: APIRepresentative.userTokenStandardsKey)
            
            userNotLoggedIn = userToken == nil
        }
    }
    
    @Published var requests = Set<AnyCancellable>()
    
    @Published var user: OrganizationUser?
    @Published var userNotLoggedIn: Bool = true
    
    @Published var apps: [TelemetryApp] = [MockData.app1, MockData.app2]
    
    @Published var signals: [TelemetryApp: [Signal]] = [:]
    @Published var insightGroups: [TelemetryApp: [InsightGroup]] = [:]
    @Published var insightData: [UUID: InsightDataTransferObject] = [:]
    @Published var insightHistoricalData: [UUID: [InsightHistoricalData]] = [:]
}

extension APIRepresentative {
    func login(loginRequestBody: LoginRequestBody, callback: @escaping (Bool) -> ()) {
        let url = urlForPath("users", "login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: data) {
                    DispatchQueue.main.async {
                        self.userToken = decodedResponse
                        
                        self.getUserInformation()
                        self.getApps()
                        
                        callback(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback(false)
                    }
                }
            }
        }.resume()
    }
    
    func logout() {
        userToken = nil
        apps = []
        user = nil
    }
    
    func getRegistrationStatus() {
        let url = urlForPath("users", "registrationStatus")
        var request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                let decodedData = try! JSONDecoder.telemetryDecoder.decode([String: RegistrationStatus].self, from: data)
                
                DispatchQueue.main.async {
                    self.registrationStatus = decodedData["registrationStatus"]
                }
            }
        }.resume()
    }
    
    func register(registrationRequestBody: RegistrationRequestBody, callback: @escaping (Bool) -> ()) {
        let url = urlForPath("users", "register")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(registrationRequestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                callback((response as! HTTPURLResponse).statusCode == 200)
            }
        }.resume()
    }
    
    func getUserInformation() {
        let url = urlForPath("users", "me")
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .validateStatusCode({ (200..<300).contains($0) })
            .map(\.data)
            .decode(type: OrganizationUser.self, decoder: JSONDecoder.telemetryDecoder)
//            .assign(to: \.user, on: self)
            .sink(receiveCompletion: { error in
                switch error {
                case .finished:
                    break
                case .failure(_):
                    self.logout()
                    print(error)
                }
            }, receiveValue: { organizationUser in
                DispatchQueue.main.async { self.user = organizationUser }
            })
            .store(in: &requests)
    }
    
    func getApps() {
        let url = urlForPath("apps")
        
        self.get(url) { (result: Result<[TelemetryApp], TransferError>) in
            switch result {
            case .success(let apps):
                self.apps = apps
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func create(appNamed name: String) {
        let url = urlForPath("apps")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(["name": name])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func update(app: TelemetryApp, newName: String) {
        let url = urlForPath("apps", app.id.uuidString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(["name": newName])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(TelemetryApp.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getApps()
                }
                
            }
        }.resume()
    }
    
    func delete(app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getApps()
            }
        }.resume()
    }
    
    func getSignals(for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "signals")
        
        self.get(url) { (result: Result<[Signal], TransferError>) in
            switch result {
            case .success(let signals):
                self.signals[app] = signals
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func getInsightGroups(for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        
        self.get(url) { (result: Result<[InsightGroup], TransferError>) in
            switch result {
            case .success(let foundInsightGroups):
                self.insightGroups[app] = foundInsightGroups
            case .failure(let error):
                self.handleError(error)
            }
        }
        
    }
    
    func create(insightGroupNamed: String, for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = ["title": insightGroupNamed]
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func delete(insightGroup: InsightGroup, in app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func getInsightData(for insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(InsightDataTransferObject.self, from: data)
                
                DispatchQueue.main.async {
                    self.insightData[decodedResponse.id] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func getInsightHistoricalData(for insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString, "historicaldata")
        
        // Set an empty value to show we're loading
        if insightHistoricalData[insight.id] == nil {
            insightHistoricalData[insight.id] = []
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                guard let decodedResponse = try? JSONDecoder.telemetryDecoder.decode([InsightHistoricalData].self, from: data) else { return }
                
                DispatchQueue.main.async {
                    self.insightHistoricalData[insight.id] = decodedResponse
                }
                
            }
        }.resume()
    }
    
    func create(insightWith requestBody: InsightCreateRequestBody, in insightGroup: InsightGroup, for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
    
    func update(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, with insightUpdateRequestBody: InsightUpdateRequestBody) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder.telemetryEncoder.encode(insightUpdateRequestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                let decodedResponse = try! JSONDecoder.telemetryDecoder.decode(InsightDataTransferObject.self, from: data)
                print(decodedResponse)
                
                DispatchQueue.main.async {
                    self.getInsightGroups(for: app)
                }
                
            }
        }.resume()
    }
    
    func delete(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.getInsightGroups(for: app)
            }
        }.resume()
    }
}


// MARK: - Generic Methods
extension APIRepresentative {
    /// Generate an API URL for the given Path
    ///
    /// Path should be supplied as a series of strings, e.g.
    ///
    ///     urlForPath("api", "v1", "exhibitors")
    ///
    /// In DEBUG configuration, this method will print out the generated URL.
    func urlForPath(_ path: String..., appendTrailingSlash: Bool = false) -> URL {
        let url = URL(string: APIRepresentative.baseURLString + path.joined(separator: "/") + "/")!

        
        #if DEBUG
        print("🌍", url)
        #endif
        
        return url
    }
    
    /// Given a URL, generate a URLRequest instance with included authentication headers
    func authenticatedURLRequest(for url: URL, httpMethod: String, httpBody: Data? = nil, contentType: String = "application/json; charset=utf-8") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        if let httpBody = httpBody {
            request.httpBody = httpBody
        }
        
        return request
    }
    
    func get<Output: Decodable>(_ url: URL, defaultValue: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        let request = self.authenticatedURLRequest(for: url, httpMethod: "GET")
        runTask(with: request, completion: completion)
    }
    
    func post<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, defaultValue: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        var request = self.authenticatedURLRequest(for: url, httpMethod: "POST")
        request.httpBody = try? JSONEncoder.telemetryEncoder.encode(data)
        runTask(with: request, completion: completion)
    }
    
    private func runTask<Output: Decodable>(with request: URLRequest, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
        if let httpBody = request.httpBody {
            print("➡️", httpBody.prettyPrintedJSONString ?? String(data: httpBody, encoding: .utf8) ?? "Undecodable")
        }
        #endif
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    #if DEBUG
                    print("⬅️", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
                    #endif
                    
                    do {
                        let decoded = try JSONDecoder.telemetryDecoder.decode(Output.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        if let decodedErrorMessage = try? JSONDecoder.telemetryDecoder.decode(ServerErrorMessage.self, from: data) {
                            completion(.failure(TransferError.serverError(message: decodedErrorMessage.detail)))
                        } else {
                            completion(.failure(.decodeFailed))
                        }
                    }
                } else if error != nil {
                    completion(.failure(.transferFailed))
                } else {
                    print("Unknown result: no data and no error!")
                }
            }
        }.resume()
    }
    
    private func handleError(_ error: TransferError) {
        print("🛑", error, error.localizedDescription)
    }
}
