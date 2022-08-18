import DataTransferObjects
import Foundation

/// Error associated with failure to initialize ChartDataSet
public enum ChartDataSetError: Error {
    case conversionError(message: String)

    public var localizedDescription: String {
        switch self {
        case let .conversionError(message: message):
            return "The conversion to a ChartDataSet failed with this error message: \(message)"
        }
    }
}

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

    public init(fromQueryResultWrapper queryResultWrapper: QueryResultWrapper?, groupBy: InsightGroupByInterval? = nil) throws {
        guard let queryResult = queryResultWrapper?.result else { throw ChartDataSetError.conversionError(message: "QueryResult is nil.") }

        switch queryResult {
        case let .timeSeries(timeSeriesQueryResult):
            var timeSeriesRows: [TimeSeriesQueryResultRow]!

            timeSeriesRows = timeSeriesQueryResult.rows

            var data: [ChartDataPoint] = []

            for row in timeSeriesRows {
                let yValue = row.result.values.first ?? 0
                let yInt = Int64(yValue)
                data.append(ChartDataPoint(xAxisDate: row.timestamp, yAxisValue: yInt))
            }

            self.init(data: data, groupBy: groupBy)

        case let .topN(topNQueryResult):

            let topNQueryResultRows: [TopNQueryResultRow] = topNQueryResult.rows

            // some guard statement that catches topNQueryResults that are not yet supported?
            guard topNQueryResultRows.count == 1 else {
                throw ChartDataSetError.conversionError(message: "TopNQueryResults with more than one row are not supported yet.")
            }

            var data: [ChartDataPoint] = []

            guard topNQueryResultRows.first != nil, topNQueryResultRows.first?.result != nil else {
                throw ChartDataSetError.conversionError(message: "TopNQueryResults are nil.")
            }

            for adaptableItem in topNQueryResultRows.first!.result {
                guard adaptableItem.dimensions.values.first != nil else { continue }
                let yValue = adaptableItem.metrics.values.first ?? 0
                let yInt = Int64(yValue)
                let xString = adaptableItem.dimensions.values.first!
                data.append(ChartDataPoint(xAxisValue: xString, yAxisValue: yInt))
            }

            self.init(data: data, groupBy: groupBy)

        default:
            throw ChartDataSetError.conversionError(message: "QueryResult is not of a supported Type.")
        }
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
