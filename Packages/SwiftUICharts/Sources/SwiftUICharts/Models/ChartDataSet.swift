import Foundation

/// Collection of data that can be displayed as a Chart
public struct ChartDataSet {
    public let data: [ChartDataPoint]
    public let highestValue: Int64
    public let lowestValue: Int64
    public let groupBy: InsightGroupByInterval?

    public var isEmpty: Bool { data.isEmpty }


    public init(data: [ChartDataPoint], groupBy: InsightGroupByInterval? = nil) {
        self.data = data
        self.groupBy = groupBy

        highestValue = self.data.reduce(0) { max($0, $1.yAxisValue ?? 0) }
        lowestValue = 0
    }

    /// `true` if the point represents the current day/week/month/etc, and therefore contains
    /// incomplete data.
    public func isCurrentPeriod(_ chartDataPoint: ChartDataPoint) -> Bool {
        let groupByPeriod = groupBy ?? .day

        guard let date = chartDataPoint.xAxisDate else { return false }

        switch groupByPeriod {
        case .hour:
            return date.isInCurrent(.hour)
        case .day:
            return date.isInToday
        case .week:
            return date.isInCurrentWeek
        case .month:
            return date.isInCurrentMonth
        }
    }
}
