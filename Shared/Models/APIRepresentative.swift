//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation
import Combine

final class APIRepresentative: ObservableObject {
    private static let baseURLString = "https://apptelemetry.io/api/v1/"
    // private static let baseURLString = "http://localhost:8080/api/v1/"
    private static let userTokenStandardsKey = "org.breakthesystem.telemetry.viewer.userToken"
    
    init() {
        if let encodedUserToken = UserDefaults.standard.data(forKey: APIRepresentative.userTokenStandardsKey),
           let userToken = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: encodedUserToken) {
            self.userToken = userToken
            getUserInformation()
            getApps()
        }
    }
    
    @Published var userToken: UserToken? {
        didSet {
            let encodedUserToken = try! JSONEncoder().encode(userToken)
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
    func login(loginRequestBody: LoginRequestBody, callback: @escaping () -> ()) {
        let url = urlForPath("users", "login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback()
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: data) {
                    DispatchQueue.main.async {
                        self.userToken = decodedResponse
                        
                        self.getUserInformation()
                        self.getApps()
                    }
                } else {
                    fatalError("Could not decode a user token")
                }
            }
        }.resume()
    }
    
    func logout() {
        userToken = nil
        apps = []
        user = nil
    }
    
    func register(registrationRequestBody: RegistrationRequestBody, callback: @escaping () -> ()) {
        let url = urlForPath("users", "register")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(registrationRequestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback()
            
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                
                if let decodedResponse = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: data) {
                    print(decodedResponse)
                }
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
        fetch(url, defaultValue: [], setterKeyPath: \.apps)
    }
    
    func create(appNamed name: String) {
        let url = urlForPath("apps")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONEncoder().encode(["name": name])
        
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
        request.httpBody = try! JSONEncoder().encode(["name": newName])
        
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
        fetch(url, defaultValue: [Signal]()) { self.signals[app] = $0 }
    }
    
    func getInsightGroups(for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        fetch(url, defaultValue: [InsightGroup]()) { self.insightGroups[app] = $0 }
    }
    
    func create(insightGroupNamed: String, for app: TelemetryApp) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        
        let requestBody = ["title": insightGroupNamed]
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
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
        
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                self.getInsightGroups(for: app)
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
    func urlForPath(_ path: String...) -> URL {
        let url = URL(string: APIRepresentative.baseURLString + path.joined(separator: "/") + "/")!
        
        print(url)
        
        return url
    }
    
    func authenticatedURLRequest(for url: URL, contentType: String = "application/json; charset=utf-8") -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(userToken?.bearerTokenAuthString, forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Downloading
extension APIRepresentative {
    func fetch<T: Decodable>(_ url: URL, defaultValue: T, setterKeyPath: ReferenceWritableKeyPath<APIRepresentative, T>) {
        let request = authenticatedURLRequest(for: url)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .validateStatusCode({ (200..<300).contains($0) })
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder.telemetryDecoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .assign(to: setterKeyPath, on: self)
            .store(in: &requests)
    }
    
    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
        let request = authenticatedURLRequest(for: url)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .retry(1)
            .validateStatusCode({ (200..<300).contains($0) })
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder.telemetryDecoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
}

// MARK: - Uploading
extension APIRepresentative {
    enum UploadError: Error {
        case uploadFailed
        case decodeFailed
    }
    
    func upload<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, httpMethod: String = "POST", contentType: String = "application/json", completion: @escaping (Result<Output, UploadError>) -> Void) {
        var request = authenticatedURLRequest(for: url)
        request.httpBody = try? JSONEncoder.telemetryEncoder.encode(data)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decoded = try JSONDecoder.telemetryDecoder.decode(Output.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(.decodeFailed))
                    }
                } else if error != nil {
                    completion(.failure(.uploadFailed))
                } else {
                    print("Unknown result: no data and no error!")
                }
            }
        }.resume()
    }
}
