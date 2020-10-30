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
    
    @Published var registrationStatus: RegistrationStatus?
    
    @Published var userToken: UserToken? {
        didSet {
            let encodedUserToken = try! JSONEncoder.telemetryEncoder.encode(userToken)
            UserDefaults.standard.setValue(encodedUserToken, forKey: APIRepresentative.userTokenStandardsKey)
            
            userNotLoggedIn = userToken == nil
        }
    }
    
    @Published var requests = Set<AnyCancellable>()
    
    @Published var user: UserDataTransferObject?
    @Published var userNotLoggedIn: Bool = true
    
    @Published var apps: [TelemetryApp] = [MockData.app1, MockData.app2]
    
    @Published var signals: [TelemetryApp: [Signal]] = [:]
    @Published var insightGroups: [TelemetryApp: [InsightGroup]] = [:]
    @Published var insightData: [UUID: InsightDataTransferObject] = [:]
    
    @Published var lexiconSignalTypes: [TelemetryApp: [LexiconSignalType]] = [:]
    @Published var lexiconPayloadKeys: [TelemetryApp: [LexiconPayloadKey]] = [:]
    
    @Published var betaRequests: [BetaRequestEmail] = []
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
    
    func getRegistrationStatus(callback: ((Result<[String: RegistrationStatus], TransferError>) -> ())? = nil) {
        let url = urlForPath("users", "registrationStatus")
        
        self.get(url) { (result: Result<[String: RegistrationStatus], TransferError>) in
            switch result {
            case .success(let decodedData):
                DispatchQueue.main.async {
                    self.registrationStatus = decodedData["registrationStatus"]
                }
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func register(registrationRequestBody: RegistrationRequestBody, callback: @escaping (Bool) -> ()) {
        let url = urlForPath("users", "register")
        
        self.post(registrationRequestBody, to: url) { (result: Result<UserDataTransferObject, TransferError>) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    callback(true)
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func getUserInformation(callback: ((Result<UserDataTransferObject, TransferError>) -> ())? = nil) {
        let url = urlForPath("users", "me")
        
        self.get(url) { (result: Result<UserDataTransferObject, TransferError>) in
            switch result {
            case .success(let userDTO):
                DispatchQueue.main.async {
                    self.user = userDTO
                }
            case .failure(let error):
                self.handleError(error)
                self.logout()
            }
            
            callback?(result)
        }
    }
    
    func updatePassword(with passwordChangeRequest: PasswordChangeRequestBody, callback: ((Result<UserDataTransferObject, TransferError>) -> ())? = nil) {
        let url = urlForPath("users", "updatePassword")
        
        self.post(passwordChangeRequest, to: url) { (result: Result<UserDataTransferObject, TransferError>) in
            switch result {
            case .success(let userDTO):
                DispatchQueue.main.async {
                    self.user = userDTO
                    self.logout()
                }
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func getApps(callback: ((Result<[TelemetryApp], TransferError>) -> ())? = nil) {
        let url = urlForPath("apps")
        
        self.get(url) { (result: Result<[TelemetryApp], TransferError>) in
            switch result {
            case .success(let apps):
                self.apps = apps
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func create(appNamed name: String, callback: ((Result<TelemetryApp, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps")
        
        self.post(["name": name], to: url) { (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }
    
    func update(app: TelemetryApp, newName: String, callback: ((Result<TelemetryApp, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString)
        
        self.patch(["name": newName], to: url) { (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }
    
    func delete(app: TelemetryApp, callback: ((Result<String, TransferError>) -> ())? = nil)  {
        let url = urlForPath("apps", app.id.uuidString)
        
        self.delete(url) { (result: Result<String, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }
    
    func getSignals(for app: TelemetryApp, callback: ((Result<[Signal], TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "signals")
        
        self.get(url) { (result: Result<[Signal], TransferError>) in
            switch result {
            case .success(let signals):
                self.signals[app] = signals
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func getInsightGroups(for app: TelemetryApp, callback: ((Result<[InsightGroup], TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        
        self.get(url) { (result: Result<[InsightGroup], TransferError>) in
            switch result {
            case .success(let foundInsightGroups):
                self.insightGroups[app] = foundInsightGroups
                
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
        
    }
    
    func create(insightGroupNamed: String, for app: TelemetryApp, callback: ((Result<InsightGroup, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")
        
        self.post(["title": insightGroupNamed], to: url) { (result: Result<InsightGroup, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }
    
    func delete(insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<InsightGroup, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString)
        
        self.delete(url) { (result: Result<InsightGroup, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }
    
    func getInsightData(for insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<InsightDataTransferObject, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)
        
        self.get(url) { (result: Result<InsightDataTransferObject, TransferError>) in
            if let insightDTO = try? result.get() {
                DispatchQueue.main.async {
                    self.insightData[insightDTO.id] = insightDTO
                }
                callback?(result)
            }
        }
    }
    
    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroup: InsightGroup, for app: TelemetryApp, callback: ((Result<String, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights")
        
        self.post(requestBody, to: url) { (result: Result<String, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }
    
    func update(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, with insightUpdateRequestBody: InsightDefinitionRequestBody, callback: ((Result<String, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)
        
        self.patch(insightUpdateRequestBody, to: url) { (result: Result<String, TransferError>) in
            self.getInsightData(for: insight, in: insightGroup, in: app)
            callback?(result)
        }
    }
    
    func delete(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<String, TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)
        
        self.delete(url) { (result: Result<String, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }
    
    func getBetaRequests(callback: ((Result<[BetaRequestEmail], TransferError>) -> ())? = nil) {
        let url = urlForPath("betarequests")
        
        self.get(url) { (result: Result<[BetaRequestEmail], TransferError>) in
            switch result {
            case .success(let betaRequests):
                self.betaRequests = betaRequests
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func getSignalTypes(for app: TelemetryApp, callback: ((Result<[LexiconSignalType], TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "lexicon", "signaltypes")
        
        self.get(url) { (result: Result<[LexiconSignalType], TransferError>) in
            switch result {
            case .success(let lexiconItems):
                self.lexiconSignalTypes[app] = lexiconItems
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
    }
    
    func getPayloadKeys(for app: TelemetryApp, callback: ((Result<[LexiconPayloadKey], TransferError>) -> ())? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "lexicon", "payloadkeys")
        
        self.get(url) { (result: Result<[LexiconPayloadKey], TransferError>) in
            switch result {
            case .success(let lexiconItems):
                self.lexiconPayloadKeys[app] = lexiconItems
            case .failure(let error):
                self.handleError(error)
            }
            
            callback?(result)
        }
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
    
    func patch<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, defaultValue: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        var request = self.authenticatedURLRequest(for: url, httpMethod: "PATCH")
        request.httpBody = try? JSONEncoder.telemetryEncoder.encode(data)
        runTask(with: request, completion: completion)
    }
    
    func delete<Output: Decodable>(_ url: URL, defaultValue: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        let request = self.authenticatedURLRequest(for: url, httpMethod: "DELETE")
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
                            print("🛑 \(decodedErrorMessage.detail)")
                        } else {
                            print("🛑 Decode Failed")
                            completion(.failure(.decodeFailed))
                        }
                    }
                } else if error != nil {
                    print("🛑 Transfer Failed")
                    completion(.failure(.transferFailed))
                } else {
                    print("🛑 Unknown result: no data and no error!")
                }
            }
        }.resume()
    }
    
    private func handleError(_ error: TransferError) {
        
    }
}
