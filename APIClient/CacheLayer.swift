//
//  CacheLayer.swift
//  CacheLayer
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import DataTransferObjects
import SwiftUICharts

struct InsightResultWrap {
    let chartDataSet: ChartDataSet
    let calculationResult: DTOv2.InsightCalculationResult
}

class CacheLayer: ObservableObject {
    let queue: DispatchQueue = .init(label: "CacheLayer")

    let organizationCache = Cache<String, DTOv2.Organization>(entryLifetime: 1200)
    let appCache = Cache<DTOv2.App.ID, DTOv2.App>(entryLifetime: 1200)
    let groupCache = Cache<DTOv2.Group.ID, DTOv2.Group>(entryLifetime: 600)
    let insightCache = Cache<DTOv2.Insight.ID, DTOv2.Insight>(entryLifetime: 300)
    let insightCalculationResultCache = Cache<String, InsightResultWrap>(entryLifetime: 1200)
}
