//
//  PricingSettingsView.swift
//  PricingSettingsView
//
//  Created by Daniel Jilg on 15.09.21.
//

import SwiftUI

struct OrganizationSignalNumbersView: View {
    @EnvironmentObject var api: APIClient
    @State private var organizationSignalNumbers: ChartDataSet?

    var body: some View {
        VStack {
            if organizationSignalNumbers == nil {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            organizationSignalNumbers.map {
                BarChartView(chartDataSet: $0, isSelected: false)
                    .padding(.top, 10)
                    .frame(height: 160)
                    .padding(.bottom, -20)
            }
        }
        .onAppear(perform: loadOrganizationSignalNumbers)
    }

    func loadOrganizationSignalNumbers() {
        let url = api.urlForPath("organization", "signalcount")

        api.get(url) { (result: Result<[DTOsWithIdentifiers.InsightCalculationResultRow], TransferError>) in
            switch result {
            case .success(let signalCount):
                DispatchQueue.global(qos: .default).async {
                    let chartDataSet = ChartDataSet(data: signalCount, groupBy: .month)

                    DispatchQueue.main.async {
                        withAnimation {
                            self.organizationSignalNumbers = chartDataSet
                        }
                    }
                }

            case .failure(let error):
                api.handleError(error)
            }
        }
    }
}

struct SignalsPerMonthDisplay: View {
    let signals: Int64
    
    var body: some View {
        HStack {
            Text("\(signals)").font(.largeTitle)
            Text("/mo").foregroundColor(.grayColor)
        }
    }
}

struct PriceSettingsNotSubscribedView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService

    @State var prices: [DTOsWithIdentifiers.PriceStructure] = []

    var body: some View {
        VStack {
            Text("You are on the free Plan").font(.title)
            Text("The free plan includes 100 000 signals per month.").foregroundColor(.grayColor)
            
            orgService.organization?.maxSignalsMultiplier.map {
                Text("Your are getting a multipler of ") + Text("\($0)").bold() + Text("applied to your signals.")
            }
            
            SignalsPerMonthDisplay(signals: Int64(100000.0 * (orgService.organization?.maxSignalsMultiplier ?? 1.0)))
            
            Divider()

            ForEach(prices) { priceStructure in
                HStack {
                    Text(priceStructure.title).font(.title)
                    Text(priceStructure.description).font(.footnote)
                    Text(priceStructure.price).font(.largeTitle)
                    Button("Get") {
                        openCheckoutSession(priceID: priceStructure.id)
                    }
                }
                .border(.blue)
            }
        }
        .onAppear(perform: load)
    }

    func load() {
        let url = api.urlForPath(apiVersion: .v2, "stripe", "prices")

        api.get(url, defaultValue: []) { (result: Result<[DTOsWithIdentifiers.PriceStructure], TransferError>) in
            switch result {
            case .failure(let error):
                break
//                 errorMessage = error.localizedDescription
            case .success(let prices):
                DispatchQueue.main.async {
                    self.prices = prices
                }
            }
        }
    }

    func openCheckoutSession(priceID: String) {
        let checkoutSessionURL = api.urlForPath(apiVersion: .v2, "stripe", "create-checkout-session")

        api.post(["priceID": priceID], to: checkoutSessionURL, defaultValue: [:]) { (result: Result<[String: String], TransferError>) in
            switch result {
            case .success(let dict):
                if let sessionURLString = dict["sessionURL"],
                   let sessionURL = URL(string: sessionURLString)
                {
                    sessionURL.open()
                }
            case .failure(let transferError):
                api.handleError(transferError)
            }
        }
    }
}

struct PriceSettingsSubscribedView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService

    var body: some View {
        VStack {
            Text("Thanks for subscribing to TelemetryDeck!").font(.title)
            
            orgService.organization?.maxSignalsMultiplier.map {
                Text("You're paying for ") + Text("\(orgService.organization?.stripeMaxSignals ?? 100000)") + Text(" signals but we're applying a multiplier of ") + Text("\($0)").bold() + Text(" to your signals.")
            }
            
            SignalsPerMonthDisplay(signals: Int64(Double(orgService.organization?.stripeMaxSignals ?? 100000) * (orgService.organization?.maxSignalsMultiplier ?? 1.0)))
            
            Button("Open Billing Portal") {
                openBillingPortal()
            }
            .buttonStyle(SmallSecondaryButtonStyle())
            .padding()
        }
    }

    func openBillingPortal() {
        let portalSessionURL = api.urlForPath(apiVersion: .v2, "stripe", "create-portal-session")

        api.post("", to: portalSessionURL, defaultValue: [:]) { (result: Result<[String: String], TransferError>) in
            switch result {
            case .success(let dict):
                if let sessionURLString = dict["sessionURL"],
                   let sessionURL = URL(string: sessionURLString)
                {
                    sessionURL.open()
                }
            case .failure(let transferError):
                api.handleError(transferError)
            }
        }
    }
}

struct PricingSettingsView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService

    var body: some View {
        VStack {
            OrganizationSignalNumbersView()

            Divider()

            if orgService.organization == nil {
                ProgressView()
            } else if orgService.organization?.stripeMaxSignals == nil {
                PriceSettingsNotSubscribedView()
            } else {
                PriceSettingsSubscribedView()
            }
        }
    }
}
