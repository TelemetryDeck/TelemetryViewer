//
//  PricingSettingsView.swift
//  PricingSettingsView
//
//  Created by Daniel Jilg on 15.09.21.
//

import DataTransferObjects
import SwiftUI

import TelemetryClient

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
                    .padding(.bottom, -20)
            }
        }
        .frame(height: 140)
        .onAppear(perform: loadOrganizationSignalNumbers)
    }

    func loadOrganizationSignalNumbers() {
        let url = api.urlForPath("organization", "signalcount")

        api.get(url) { (result: Result<[DTOv2.InsightCalculationResultRow], TransferError>) in
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

struct PriceButton: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService
    @Binding var showCheckoutPrices: Bool
    let priceStructure: DTOv2.PriceStructure

    @State var isLoading = false

    var body: some View {
        CardView {
            VStack {
                Text(priceStructure.title)
                    .font(.title)
                    .padding(.top)

                Text(priceStructure.description)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .padding(.horizontal)

                Spacer()

                VStack(spacing: -4) {
                    ValueView(value: Double(priceStructure.includedSignals), shouldFormatBigNumbers: true)
                    Text("signals per month")
                        .smallValueStyle()
                }
                .foregroundColor(.grayColor)

                Button {
                    guard !isLoading else { return }
                    isLoading = true
                    openCheckoutSession(priceID: priceStructure.id)

                    TelemetryManager.send("CheckoutButtonPressed")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                        showCheckoutPrices = false
                    }

                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .padding(7)
                    } else {
                        VStack {
                            Text(priceStructure.price)
                                .valueStyle()
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(6)
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

struct CheckoutPricesView: View {
    @EnvironmentObject var api: APIClient
    @Binding var showCheckoutPrices: Bool
    @State var prices: [DTOv2.PriceStructure] = []
    @State var selectedCurrency = "EUR"
    @State var selectedBillingPeriod = "month"

    var availableCurrencies: [String] {
        var currencies = Set<String>()
        prices.forEach { price in currencies.insert(price.currency) }
        return currencies.sorted()
    }

    var availableBillingPeriods: [String] {
        var billingPeriods = Set<String>()
        prices.forEach { price in billingPeriods.insert(price.billingPeriod) }
        return billingPeriods.sorted()
    }

    var filteredPrices: [DTOv2.PriceStructure] {
        prices.filter { price in
            price.currency == selectedCurrency && price.billingPeriod == selectedBillingPeriod
        }
    }

    var body: some View {
        VStack {
            if availableCurrencies.count > 1 || availableBillingPeriods.count > 1 {
                HStack {
                    if availableBillingPeriods.count > 1 {
                        Picker("Billing Period", selection: $selectedBillingPeriod) {
                            ForEach(availableBillingPeriods, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    if availableCurrencies.count > 1 {
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(availableCurrencies, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }

                Divider()
            }

            HStack(spacing: -25) {
                ForEach(filteredPrices) { priceStructure in
                    PriceButton(showCheckoutPrices: $showCheckoutPrices, priceStructure: priceStructure)
                        .scaleEffect((priceStructure == filteredPrices.last || priceStructure == filteredPrices.first) ? 0.85 : 1.0)
                        .zIndex((priceStructure == filteredPrices.last || priceStructure == filteredPrices.first) ? -1 : 1)
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
        .onAppear(perform: load)
    }

    func load() {
        let url = api.urlForPath(apiVersion: .v2, "stripe", "prices")

        api.get(url, defaultValue: []) { (result: Result<[DTOv2.PriceStructure], TransferError>) in
            switch result {
            case .failure:
                break
            case .success(let prices):
                DispatchQueue.main.async {
                    withAnimation {
                        self.prices = prices
                    }
                }
            }
        }
    }
}

struct CheckoutPricesContainerView: View {
    @Binding var showCheckoutPrices: Bool

    var body: some View {
        CheckoutPricesView(showCheckoutPrices: $showCheckoutPrices)
            .transition(.slide)

        VStack {
            Text("Clicking the price buttons opens a browser window, where you can use Stripe to checkout. You can manage or cancel your subscription at any time by coming back to this screen.")
                .font(.footnote)
                .foregroundColor(.grayColor)
                .padding(.horizontal)
            Button("Cancel") {
                withAnimation {
                    showCheckoutPrices = false
                }
            }
            .buttonStyle(.borderless)
        }
        .transition(.opacity)
        .onAppear {
            TelemetryManager.send("PricingSettingsShown")
        }
    }
}

struct OpenBillingPortalButton: View {
    @EnvironmentObject var api: APIClient
    @State var isLoading = false

    var body: some View {
        Button {
            guard !isLoading else { return }

            isLoading = true
            openBillingPortal()

            TelemetryManager.send("OpenBillingPortalButtonPressed")

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        } label: {
            if isLoading {
                ProgressView()
            } else {
                VStack {
                    Text("Manage your subscription").font(.headline)
                    Text("Upgrade Plans, Change payment method, Cancel, etc").foregroundColor(.grayColor)
                }
            }
        }
        .buttonStyle(SecondaryButtonStyle())
        .padding()
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

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    @State var showCheckoutPrices = false

    func multiplierDescription(multiplier: Double) -> String {
        if let maxSignals = orgService.organization?.stripeMaxSignals {
            return "\(maxSignals) ✕ \(String(format: "%.2f", multiplier))"
        }

        return "Included Signals ✕ \(String(format: "%.2f", multiplier))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                OrganizationSignalNumbersView().padding(.top)

                Divider()

                if showCheckoutPrices {
                    CheckoutPricesContainerView(showCheckoutPrices: $showCheckoutPrices)
                } else {
                    VStack(spacing: 24) {
                        VStack {
                            Text("Subscription Status")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                            Text(orgService.organization?.stripeMaxSignals == nil ? "Free" : "Subscription Active").valueStyle()
                        }

                        VStack {
                            if orgService.organization?.stripeMaxSignals == -1 {
                                HStack {
                                    Text("∞").valueStyle()
                                    Text("signals/mo").unitStyle()
                                }
                            } else {
                                ValueAndUnitView(value: Double(orgService.organization?.resolvedMaxSignals ?? 0), unit: "signals/mo", shouldFormatBigNumbers: false)

                                if let multiplier = orgService.organization?.maxSignalsMultiplier {
                                    Text(multiplierDescription(multiplier: multiplier))
                                        .font(.footnote)
                                        .foregroundColor(.grayColor)
                                }
                            }
                        }

                        if orgService.organization?.isInRestrictedMode == true {
                            VStack(spacing: 10) {
                                Text("Restricted Mode").font(.title)
                                Text("Your apps have sent more signals to TelemetryDeck in the current month than are currently included in your plan. We will continue to accept all signals your applications send to us, and store them safely, but we ask you to please upgrade your plan to a higher tier.")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }

                        Button("Show Plans") {
                            withAnimation {
                                showCheckoutPrices = true
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)

                        if orgService.organization?.stripeMaxSignals != nil {
                            OpenBillingPortalButton()
                        }
                    }
                    .transition(.slide)
                }

                HStack {
                    Button("Terms of Service") {
                        URL(string: "https://telemetrydeck.com/pages/termsofservice.html")?.open()
                    }
                    .buttonStyle(.borderless)

                    Button("Privacy Policy") {
                        URL(string: "https://telemetrydeck.com/pages/privacy-policy.html")?.open()
                    }
                    .buttonStyle(.borderless)
                }

                Spacer()
            }
            .onAppear {
                TelemetryManager.send("PricingSettingsShown")
            }
            .onReceive(timer) { _ in
                orgService.getOrganisation()
            }
        }
    }
}
