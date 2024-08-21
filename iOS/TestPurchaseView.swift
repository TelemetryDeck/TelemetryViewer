//
//  TestPurchaseView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 21.08.24.
//

import RevenueCat
import SwiftUI

struct TestPurchaseView: View {
    @State private var isPerformingTask = false
    @State var offering: Offering?

    var body: some View {
        VStack {
            Text("\(isPerformingTask ? "Loading" : "Hi, buy one of these great packages:")")

            if let offering {
                ForEach(offering.availablePackages, id: \.self) { package in
                    Button(package.storeProduct.productIdentifier) {
                        Purchases.shared.purchase(package: package) { _, customerInfo, _, _ in
                            if customerInfo?.entitlements["your_entitlement_id"]?.isActive == true {
                                // Unlock that great "pro" content
                                print("unlocked")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task { await getOfferings() }
        }
    }

    func getOfferings() async {
        isPerformingTask = true

        do {
            offering = try await Purchases.shared.offerings().current

        } catch {
            print(error)
        }

        isPerformingTask = false
    }
}

#Preview {
    TestPurchaseView()
}
