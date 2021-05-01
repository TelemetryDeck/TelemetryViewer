//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Combine
import Foundation
import TelemetryModels
import SwiftUI

final class APIRepresentative: ObservableObject {
    private static let baseURLString =
        ProcessInfo.processInfo.environment["API_URL"] == "local"
            ? "http://localhost:8080/api/v1/"
            : "https://apptelemetry.io/api/v1/"
    private static let userTokenStandardsKey = "org.breakthesystem.telemetry.viewer.userToken"

    init() {
        if let encodedUserToken = UserDefaults.standard.data(forKey: APIRepresentative.userTokenStandardsKey),
           let userToken = try? JSONDecoder.telemetryDecoder.decode(UserToken.self, from: encodedUserToken)
        {
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

    /// The beginning of the time window. If nil, defaults to current Date minus 30 days
    @Published var timeWindowBeginning: Date? = nil

    /// The end of the currently displayed time window. If nil, defaults to date()
    @Published var timeWindowEnd: Date? = nil

    @Published var user: UserDTO?
    @Published var userNotLoggedIn: Bool = true
    @Published var userLoginFailed: Bool = false

    @Published var totalNumberOfSignals: Int = 0
    @Published var numberOfSignalsThisMonth: Int = 0

    @Published var apps: [TelemetryApp] = []

    @Published var signals: [TelemetryApp: [Signal]] = [:]
    @Published var insightGroups: [TelemetryApp: [InsightGroup]] = [:]
    @Published var insightData: [UUID: InsightDTO] = [:]

    @Published var lexiconSignalTypes: [TelemetryApp: [LexiconSignalType]] = [:]
    @Published var lexiconPayloadKeys: [TelemetryApp: [LexiconPayloadKey]] = [:]

    @Published var betaRequests: [BetaRequestEmail] = []
    @Published var organizationAdminListEntries: [OrganizationAdminListEntry] = []
    @Published var insightQueryAdminListEntries: [Insight] = []
    @Published var insightQueryAdminAggregate: AggregateDTO?
    @Published var appAdminSignalCounts: [AppSignalCountDTO] = []

    @Published var organizationUsers: [UserDTO] = []
    @Published var organizationJoinRequests: [OrganizationJoinRequest] = []
    
    // MARK: Loading stuff
    @Published var isLoadingApps: Bool = false
    @Published var loadingIDs: [UUID] = []
}

extension APIRepresentative {
    func app(with id: UUID) -> TelemetryApp? {
        apps.first(where: { $0.id == id })
    }
}

extension APIRepresentative {
    func reloadVisibleInsights() {
        // Expensive function, poor server
        for app in insightGroups.keys {
            let insightGroupsList = insightGroups[app] ?? []
            for insightGroup in insightGroupsList {
                for insight in insightGroup.insights {
                    getInsightData(for: insight, in: insightGroup, in: app)
                }
            }
        }
    }
}

extension APIRepresentative {
    func login(loginRequestBody: LoginRequestBody, callback: @escaping (Bool) -> Void) {
        let url = urlForPath("users", "login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(loginRequestBody.basicHTMLAuthString, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
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

    func register(registrationRequestBody: RegistrationRequestBody, callback: @escaping (Result<UserDTO, TransferError>) -> Void) {
        let url = urlForPath("users", "register")

        post(registrationRequestBody, to: url) { [unowned self] (result: Result<UserDTO, TransferError>) in
            switch result {
            case .success:
                break
            case let .failure(error):
                self.handleError(error)
            }

            callback(result)
        }
    }

    func joinOrganization(with organizationJoinRequest: OrganizationJoinRequestURLObject, callback: ((Result<UserDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", "join")

        post(organizationJoinRequest, to: url) { (result: Result<UserDTO, TransferError>) in
            callback?(result)
        }
    }

    func getOrganizationJoinRequest(with registrationCode: String, callback: @escaping (Result<OrganizationJoinRequest, TransferError>) -> Void) {
        let url = urlForPath("organization", "joinRequests", registrationCode)

        get(url) { (result: Result<OrganizationJoinRequest, TransferError>) in
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

    func getUserInformation(callback: ((Result<UserDTO, TransferError>) -> Void)? = nil) {
        userLoginFailed = false
        
        let url = urlForPath("users", "me")

        get(url) { [unowned self] (result: Result<UserDTO, TransferError>) in
            switch result {
            case let .success(userDTO):
                DispatchQueue.main.async {
                    self.user = userDTO
                    self.getApps()
                    if self.user?.organization?.isSuperOrg == true {
                        self.getBetaRequests()
                    }
                }
            case let .failure(error):
                userLoginFailed = true
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func updatePassword(with passwordChangeRequest: PasswordChangeRequestBody, callback: ((Result<UserDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("users", "updatePassword")

        post(passwordChangeRequest, to: url) { [unowned self] (result: Result<UserDTO, TransferError>) in
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

    func getNumberOfSignalsThisMonth(callback: ((Result<Int, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "signalcount")

        get(url) { [unowned self] (result: Result<Int, TransferError>) in
            switch result {
            case let .success(signalCount):
                DispatchQueue.main.async {
                    self.numberOfSignalsThisMonth = signalCount
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getTotalNumberOfSignals(callback: ((Result<Int, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "totalSignalcount")

        get(url) { [unowned self] (result: Result<Int, TransferError>) in
            switch result {
            case let .success(signalCount):
                DispatchQueue.main.async {
                    self.totalNumberOfSignals = signalCount
                }
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getApps(callback: ((Result<[TelemetryApp], TransferError>) -> Void)? = nil) {
        isLoadingApps = true
        let url = urlForPath("apps")

        get(url) { [unowned self] (result: Result<[TelemetryApp], TransferError>) in
            switch result {
            case let .success(apps):
                DispatchQueue.main.async {
                    self.apps = apps
                }

                for app in apps {
                    self.getInsightGroups(for: app)
                }
            case let .failure(error):
                self.handleError(error)
            }

            self.isLoadingApps = false
            callback?(result)
        }
    }

    func create(appNamed name: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps")

        post(["name": name], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }

    func update(app: TelemetryApp, newName: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString)

        patch(["name": newName], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }

    func delete(app: TelemetryApp, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString)

        delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }

    func getSignals(for app: TelemetryApp, callback: ((Result<[Signal], TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "signals")

        get(url) { [unowned self] (result: Result<[Signal], TransferError>) in
            switch result {
            case let .success(signals):
                self.signals[app] = signals
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getInsightGroups(for app: TelemetryApp, callback: ((Result<[InsightGroup], TransferError>) -> Void)? = nil) {
        loadingIDs.append(app.id)
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")

        get(url) { [unowned self] (result: Result<[InsightGroup], TransferError>) in
            switch result {
            case let .success(foundInsightGroups):
                DispatchQueue.main.async {
                    self.insightGroups[app] = foundInsightGroups.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                }

            case let .failure(error):
                self.handleError(error)
            }

            self.loadingIDs.removeAll { $0 == app.id}
            callback?(result)
        }
    }

    func create(insightGroupNamed: String, for app: TelemetryApp, callback: ((Result<InsightGroupDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups")

        post(["title": insightGroupNamed], to: url) { [unowned self] (result: Result<InsightGroupDTO, TransferError>) in
            self.getInsightGroups(for: app) { _ in
                callback?(result)
            }
        }
    }

    func update(insightGroup: InsightGroupDTO, in app: TelemetryApp, callback: ((Result<InsightGroupDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString)

        patch(insightGroup, to: url) { [unowned self] (result: Result<InsightGroupDTO, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }

    func delete(insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<InsightGroup, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString)

        delete(url) { [unowned self] (result: Result<InsightGroup, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }

    func getInsightData(for insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<InsightDTO, TransferError>) -> Void)? = nil) {
        let timeWindowEndDate = timeWindowEnd ?? Date()
        let timeWindowBeginDate = timeWindowBeginning ?? timeWindowEndDate.addingTimeInterval(-60 * 60 * 24 * 30)

        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights",
                             insight.id.uuidString,
                             Formatter.iso8601noFS.string(from: timeWindowBeginDate),
                             Formatter.iso8601noFS.string(from: timeWindowEndDate))

        get(url) { [unowned self] (result: Result<InsightDTO, TransferError>) in
            if let insightDTO = try? result.get() {
                withAnimation {
                    self.insightData[insightDTO.id] = insightDTO
                }
            }

            callback?(result)
        }
    }

    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroup: InsightGroup, for app: TelemetryApp, callback: ((Result<InsightDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights")

        post(requestBody, to: url) { [unowned self] (result: Result<InsightDTO, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }

    func update(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, with insightUpdateRequestBody: InsightDefinitionRequestBody, callback: ((Result<InsightDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)

        patch(insightUpdateRequestBody, to: url) { [unowned self] (result: Result<InsightDTO, TransferError>) in
            self.getInsightGroups(for: app)
            self.getInsightData(for: insight, in: insightGroup, in: app)
            callback?(result)
        }
    }

    func delete(insight: Insight, in insightGroup: InsightGroup, in app: TelemetryApp, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "insightgroups", insightGroup.id.uuidString, "insights", insight.id.uuidString)

        delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getInsightGroups(for: app)
            callback?(result)
        }
    }

    func getBetaRequests(callback: ((Result<[BetaRequestEmail], TransferError>) -> Void)? = nil) {
        let url = urlForPath("betarequests")

        get(url) { [unowned self] (result: Result<[BetaRequestEmail], TransferError>) in
            switch result {
            case let .success(betaRequests):
                self.betaRequests = betaRequests
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

    func getInsightQueryAdminAggregates(callback: ((Result<AggregateDTO, TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin", "aggregates")

        get(url) { [unowned self] (result: Result<AggregateDTO, TransferError>) in
            switch result {
            case let .success(insightQueryAdminAggregate):
                self.insightQueryAdminAggregate = insightQueryAdminAggregate
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getAppSignalCounts(callback: ((Result<[AppSignalCountDTO], TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin", "appSignalCounts")

        get(url) { [unowned self] (result: Result<[AppSignalCountDTO], TransferError>) in
            switch result {
            case let .success(appSignalCounts):
                self.appAdminSignalCounts = appSignalCounts
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getInsightQueryAdminListEntries(callback: ((Result<[Insight], TransferError>) -> Void)? = nil) {
        let url = urlForPath("insightqueryadmin")

        get(url) { [unowned self] (result: Result<[Insight], TransferError>) in
            switch result {
            case let .success(insightQueryAdminListEntries):
                self.insightQueryAdminListEntries = insightQueryAdminListEntries
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func sendEmail(for betaRequest: BetaRequestEmail, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("betarequests", betaRequest.id.uuidString, "send_email")

        post("", to: url) { [unowned self] (result: Result<String, TransferError>) in
            self.getBetaRequests()
            callback?(result)
        }
    }

    func update(betaRequest: BetaRequestEmail, with betaRequestUpdateBody: BetaRequestUpdateBody, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("betarequests", betaRequest.id.uuidString)

        patch(betaRequestUpdateBody, to: url) { [unowned self] (result: Result<String, TransferError>) in
            self.getBetaRequests()
            callback?(result)
        }
    }

    func delete(betaRequest: BetaRequestEmail, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("betarequests", betaRequest.id.uuidString)

        delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getBetaRequests()
            callback?(result)
        }
    }

    func getSignalTypes(for app: TelemetryApp, callback: ((Result<[LexiconSignalType], TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "lexicon", "signaltypes")

        get(url) { [unowned self] (result: Result<[LexiconSignalType], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconSignalTypes[app] = lexiconItems
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getPayloadKeys(for app: TelemetryApp, callback: ((Result<[LexiconPayloadKey], TransferError>) -> Void)? = nil) {
        let url = urlForPath("apps", app.id.uuidString, "lexicon", "payloadkeys")

        get(url) { [unowned self] (result: Result<[LexiconPayloadKey], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconPayloadKeys[app] = lexiconItems
            case let .failure(error):
                self.handleError(error)
            }

            callback?(result)
        }
    }

    func getOrganizationUsers(callback: ((Result<[UserDTO], TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "users")

        get(url) { [unowned self] (result: Result<[UserDTO], TransferError>) in
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

    func getOrganizationJoinRequests(callback: ((Result<[OrganizationJoinRequest], TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests")

        get(url) { [unowned self] (result: Result<[OrganizationJoinRequest], TransferError>) in
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

    func createOrganizationJoinRequest(for email: String, callback: ((Result<OrganizationJoinRequest, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", email)

        post("hi!", to: url) { [unowned self] (result: Result<OrganizationJoinRequest, TransferError>) in
            callback?(result)

            self.getOrganizationJoinRequests()
        }
    }

    func delete(organizationJoinRequest: OrganizationJoinRequest, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = urlForPath("organization", "joinRequests", organizationJoinRequest.id.uuidString)

        delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getOrganizationJoinRequests()
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
    func urlForPath(_ path: String..., appendTrailingSlash _: Bool = false) -> URL {
        URL(string: APIRepresentative.baseURLString + path.joined(separator: "/") + "/")!
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
        request.httpBody = try? JSONEncoder.telemetryEncoder.encode(data)
        runTask(with: request, completion: completion)
    }

    func patch<Input: Encodable, Output: Decodable>(_ data: Input, to url: URL, defaultValue _: Output? = nil, completion: @escaping (Result<Output, TransferError>) -> Void) {
        #if DEBUG
            print("🌍 PATCH", url)
        #endif

        var request = authenticatedURLRequest(for: url, httpMethod: "PATCH")
        request.httpBody = try? JSONEncoder.telemetryEncoder.encode(data)
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
            DispatchQueue.main.async {
                if let data = data {
                    #if DEBUG
                        print("⬅️", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
                    #endif

                    do {
                        let decoded = try JSONDecoder.telemetryDecoder.decode(Output.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        if let decodedErrorMessage = try? JSONDecoder.telemetryDecoder.decode(ServerErrorDetailMessage.self, from: data) {
                            completion(.failure(TransferError.serverError(message: decodedErrorMessage.detail)))
                            print("🛑 \(decodedErrorMessage.detail)")
                        } else if let decodedErrorMessage = try? JSONDecoder.telemetryDecoder.decode(ServerErrorReasonMessage.self, from: data) {
                            completion(.failure(TransferError.serverError(message: decodedErrorMessage.reason)))
                            print("🛑 \(decodedErrorMessage.reason)")
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

    private func handleError(_: TransferError) {}
}
