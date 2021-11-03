//
//  APIClient.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Combine
import Foundation
import SwiftUI
import DataTransferObjects

public final class APIClient: ObservableObject {
    public enum ApiVersion: String {
        case v1
        case v2
    }

    private static let baseURLString =
        ProcessInfo.processInfo.environment["API_URL"] == "local"
            ? "http://localhost:8080/api/"
            : "https://telemetrydeck.com/api/"
    private static let userTokenStandardsKey = "org.breakthesystem.telemetry.viewer.userToken"

    private let userDefaults = UserDefaults(suiteName: "group.org.breakthesystem.telemetry.shared")

    public init() {
        // Old storage location for user token, if its in there, remove it afterwards
        if let encodedUserToken = UserDefaults.standard.data(forKey: APIClient.userTokenStandardsKey),
           let userToken = try? JSONDecoder.druidDecoder.decode(UserTokenDTO.self, from: encodedUserToken)
        {
            self.userToken = userToken
            getUserInformation()
            UserDefaults.standard.removeObject(forKey: APIClient.userTokenStandardsKey)
        }
        
        // New storage location for user token, shared with widgets
        if let encodedUserToken = userDefaults?.data(forKey: APIClient.userTokenStandardsKey),
           let userToken = try? JSONDecoder.druidDecoder.decode(UserTokenDTO.self, from: encodedUserToken)
        {
            self.userToken = userToken
            getUserInformation()
        }
    }

    @Published public var registrationStatus: RegistrationStatus?

    @Published public var userToken: UserTokenDTO? {
        didSet {
            let encodedUserToken = try! JSONEncoder.druidEncoder.encode(userToken)
            userDefaults?.set(encodedUserToken, forKey: APIClient.userTokenStandardsKey)

            userNotLoggedIn = userToken == nil
        }
    }

    /// The beginning of the time window. If nil, defaults to current Date minus 30 days
    @Published public var timeWindowBeginning: Date? = nil

    /// The end of the currently displayed time window. If nil, defaults to date()
    @Published public var timeWindowEnd: Date? = nil

    @Published public var user: DTOv1.UserDTO?
    @Published public var userNotLoggedIn: Bool = true
    @Published public var userLoginFailed: Bool = false

    @Published public var totalNumberOfSignals: Int = 0
    @Published public var numberOfSignalsThisMonth: Int = 0

    @Published public var betaRequests: [BetaRequestEmailDTO] = []
    @Published public var organizationAdminListEntries: [OrganizationAdminListEntry] = []
    @Published public var insightQueryAdminListEntries: [DTOv1.InsightDTO] = []
    @Published public var insightQueryAdminAggregate: DTOv1.Aggregate?
    @Published public var appAdminSignalCounts: [DTOv1.AppAdminEntry] = []

    @Published public var organizationUsers: [DTOv1.UserDTO] = []
    @Published public var organizationJoinRequests: [DTOv1.OrganizationJoinRequest] = []

    @Published public var needsDecisionForMarketingEmails: Bool = false
}

public extension APIClient {
    func login(loginRequestBody: LoginRequestBody, callback: @escaping (Bool) -> Void) {
        let url = urlForPath("users", "login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))

                if let decodedResponse = try? JSONDecoder.druidDecoder.decode(UserTokenDTO.self, from: data) {
                    DispatchQueue.main.async {
                        self.userToken = decodedResponse

                        self.getUserInformation()

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
        #warning("TODO: Send NSNotification or similar on logout")
        userToken = nil
        user = nil
    }

    func getRegistrationStatus(callback: ((Result<[String: RegistrationStatus], TransferError>) -> Void)? = nil) {
        let url = urlForPath("users", "registrationStatus")

        get(url) { [unowned self] (result: Result<[String: RegistrationStatus], TransferError>) in
            switch result {
            case let .success(decodedData):
                self.registrationStatus = decodedData["registrationStatus"]
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func register(registrationRequestBody: DTOv1.RegistrationRequestBody, callback: @escaping (Result<DTOv1.UserDTO, TransferError>) -> Void) {
        let url = urlForPath("users", "register")

        post(registrationRequestBody, to: url) { [unowned self] (result: Result<DTOv1.UserDTO, TransferError>) in
            switch result {
            case .success:
                break
            case let .failure(error):
                self.handleError(error)
            }

            callback(result)
        }
    }

    func joinOrganization(with organizationJoinRequest: DTOv1.OrganizationJoinRequestDTO, callback: ((Result<DTOv1.UserDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", "join")

        post(organizationJoinRequest, to: url) { (result: Result<DTOv1.UserDTO, TransferError>) in
            callback?(result)
        }
    }

    func getOrganizationJoinRequest(with registrationCode: String, callback: @escaping (Result<DTOv1.OrganizationJoinRequest, TransferError>) -> Void) {
        let url = urlForPath("organization", "joinRequests", registrationCode)

        get(url) { (result: Result<DTOv1.OrganizationJoinRequest, TransferError>) in
            callback(result)
        }
    }

    func requestPasswordReset(with email: String, callback: @escaping (Result<[String: String], TransferError>) -> Void) {
        let url = urlForPath("users", "resetPassword", "request")
        post(["email": email], to: url) { (result: Result<[String: String], TransferError>) in
            callback(result)
        }
    }

    func confirmPasswordReset(with request: RequestPasswordResetRequestBody, callback: @escaping (Result<[String: String], TransferError>) -> Void) {
        let url = urlForPath("users", "resetPassword", "confirm")
        post(request, to: url) { (result: Result<[String: String], TransferError>) in
            callback(result)
        }
    }

    func getUserInformation(callback: ((Result<DTOv1.UserDTO, TransferError>) -> Void)? = nil) {
        userLoginFailed = false

        let url = urlForPath("users", "me")

        get(url) { [unowned self] (result: Result<DTOv1.UserDTO, TransferError>) in
            switch result {
            case let .success(userDTO):
                #warning("TODO: Send NSNotification or similar on user login")
                DispatchQueue.main.async {
                    self.user = userDTO
                    if self.user?.receiveMarketingEmails == nil {
                        needsDecisionForMarketingEmails = true
                    }
                }
            case let .failure(error):
                userLoginFailed = true
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func updatePassword(with passwordChangeRequest: PasswordChangeRequestBody, callback: ((Result<DTOv1.UserDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("users", "updatePassword")

        post(passwordChangeRequest, to: url) { [unowned self] (result: Result<DTOv1.UserDTO, TransferError>) in
            switch result {
            case let .success(userDTO):
                DispatchQueue.main.async {
                    self.user = userDTO
                    self.logout()
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func updateUser(with dto: DTOv1.UserDTO, callback: ((Result<DTOv1.UserDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("users", "updateUser")

        post(dto, to: url) { [unowned self] (result: Result<DTOv1.UserDTO, TransferError>) in
            switch result {
            case let .success(userDTO):
                DispatchQueue.main.async {
                    self.user = userDTO
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getOrganizationAdminEntries(callback: ((Result<[OrganizationAdminListEntry], TransferError>) -> Void)? = nil) {
        let url = urlForPath("organizationadmin")

        get(url) { [unowned self] (result: Result<[OrganizationAdminListEntry], TransferError>) in
            switch result {
            case let .success(orgListEntries):
                self.organizationAdminListEntries = orgListEntries
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getInsightQueryAdminAggregates(callback: ((Result<DTOv1.Aggregate, TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin", "aggregates")

        get(url) { [unowned self] (result: Result<DTOv1.Aggregate, TransferError>) in
            switch result {
            case let .success(insightQueryAdminAggregate):
                self.insightQueryAdminAggregate = insightQueryAdminAggregate
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getAppAdminEntrys(callback: ((Result<[DTOv1.AppAdminEntry], TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin", "appSignalCounts")

        get(url) { [unowned self] (result: Result<[DTOv1.AppAdminEntry], TransferError>) in
            switch result {
            case let .success(appSignalCounts):
                withAnimation {
                    self.appAdminSignalCounts = appSignalCounts
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getInsightQueryAdminListEntries(callback: ((Result<[DTOv1.InsightDTO], TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin")

        get(url) { [unowned self] (result: Result<[DTOv1.InsightDTO], TransferError>) in
            switch result {
            case let .success(insightQueryAdminListEntries):
                self.insightQueryAdminListEntries = insightQueryAdminListEntries
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getAppSignalCountHistory(forAppID appID: UUID, callback: ((Result<[DTOv1.InsightData], TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin", "appSignalCountHistory", appID.uuidString)

        get(url) { (result: Result<[DTOv1.InsightData], TransferError>) in
            callback?(result)
        }
    }

    func getOrganizationUsers(callback: ((Result<[DTOv1.UserDTO], TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "users")

        get(url) { [unowned self] (result: Result<[DTOv1.UserDTO], TransferError>) in
            switch result {
            case let .success(users):
                DispatchQueue.main.async {
                    self.organizationUsers = users
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getOrganizationJoinRequests(callback: ((Result<[DTOv1.OrganizationJoinRequest], TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests")

        get(url) { [unowned self] (result: Result<[DTOv1.OrganizationJoinRequest], TransferError>) in
            switch result {
            case let .success(joinRequests):
                DispatchQueue.main.async {
                    self.organizationJoinRequests = joinRequests
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func createOrganizationJoinRequest(for email: String, callback: ((Result<DTOv1.OrganizationJoinRequest, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", email)

        post("hi!", to: url) { [unowned self] (result: Result<DTOv1.OrganizationJoinRequest, TransferError>) in
            callback?(result)

            self.getOrganizationJoinRequests()
        }
    }

    func delete(organizationJoinRequest: DTOv1.OrganizationJoinRequest, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", organizationJoinRequest.id.uuidString)

        delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getOrganizationJoinRequests()
            callback?(result)
        }
    }

    /// sending a native druid query to the api
    func druidCustomQuery(query: DruidCustomQuery, callback: @escaping ([DruidTimeSeriesResult]) -> Void) {
        let url = urlForPath(apiVersion: .v2, "query", "timeSeries")

        post(query, to: url) { [unowned self] (result: Result<[DruidTimeSeriesResult], TransferError>) in
            switch result {
            case let .success(data):
                callback(data)
            case let .failure(error):
                handleError(error)
            }
        }
    }
}

// MARK: - Generic Methods

public extension APIClient {
    /// Generate an API URL for the given Path
    ///
    /// Path should be supplied as a series of strings, e.g.
    ///
    ///     urlForPath("api", "v1", "exhibitors")
    ///
    /// In DEBUG configuration, this method will print out the generated URL.
    func urlForPath(apiVersion: ApiVersion = .v1, _ path: String..., appendTrailingSlash _: Bool = false) -> URL {
        URL(string: APIClient.baseURLString + "\(apiVersion.rawValue)/" + path.joined(separator: "/") + "/")!
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

    func get<Output: Decodable>(_ url: URL, defaultValue _: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            print("🌍 GET", url)
        #endif

        let request = authenticatedURLRequest(for: url, httpMethod: "GET")
        runTask(with: request, completion: completion)
    }

    func post<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, defaultValue _: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            print("🌍 POST", url)
        #endif

        var request = authenticatedURLRequest(for: url, httpMethod: "POST")
        request.httpBody = try? JSONEncoder.druidEncoder.encode(data)
        runTask(with: request, completion: completion)
    }

    func patch<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, defaultValue _: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            print("🌍 PATCH", url)
        #endif

        var request = authenticatedURLRequest(for: url, httpMethod: "PATCH")
        request.httpBody = try? JSONEncoder.druidEncoder.encode(data)
        runTask(with: request, completion: completion)
    }

    func delete<Output: Decodable>(_ url: URL, defaultValue _: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            print("🌍 DELETE", url)
        #endif

        let request = authenticatedURLRequest(for: url, httpMethod: "DELETE")
        runTask(with: request, completion: completion)
    }

    private func runTask<Output: Decodable>(with request: URLRequest, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            if let httpBody = request.httpBody {
                print("➡️", httpBody.prettyPrintedJSONString ?? String(data: httpBody, encoding: .utf8) ?? "Undecodable")
            }
        #endif

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                #if DEBUG
                    print("⬅️", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
                #endif

                do {
                    let decoded = try JSONDecoder.druidDecoder.decode(Output.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                } catch {
                    if let decodedErrorMessage = try? JSONDecoder.druidDecoder.decode(ServerErrorDetailMessage.self, from: data) {
                        DispatchQueue.main.async {
                            completion(.failure(TransferError.serverError(message: decodedErrorMessage.detail)))
                            print("🛑 \(decodedErrorMessage.detail)")
                        }
                    } else if let decodedErrorMessage = try? JSONDecoder.druidDecoder.decode(ServerErrorReasonMessage.self, from: data) {
                        DispatchQueue.main.async {
                            completion(.failure(TransferError.serverError(message: decodedErrorMessage.reason)))
                            print("🛑 \(decodedErrorMessage.reason)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("🛑 Decode Failed: ", error)
                            completion(.failure(.decodeFailed))
                        }
                    }
                }
            } else if error != nil {
                DispatchQueue.main.async {
                    print("🛑 Transfer Failed")
                    completion(.failure(.transferFailed))
                }
            } else {
                print("🛑 Unknown result: no data and no error!")
            }

        }.resume()
    }

    func handleError(_: TransferError) {}
}
