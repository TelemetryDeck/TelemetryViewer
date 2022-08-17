import Foundation

/// A single data point in a `ChartDataSet`
public struct ChartDataPoint: Hashable, Identifiable {
    public var id: String { xAxisValue }

    public let xAxisValue: String // for donut charts (topN)
    public let xAxisDate: Date? // for timeseries

    public let yAxisValue: Int64?

    public init(xAxisValue: String, yAxisValue: Int64?) {
        self.xAxisValue = xAxisValue
        self.yAxisValue = yAxisValue

        if #available(macOS 10.14, iOS 14.0, *) {
            xAxisDate = Formatter.iso8601noFS.date(from: xAxisValue) ?? Formatter.iso8601.date(from: xAxisValue)
        } else {
            xAxisDate = nil
        }
    }

    public init(xAxisDate: Date, yAxisValue: Int64?) {
        self.yAxisValue = yAxisValue
        self.xAxisDate = xAxisDate

        if #available(macOS 10.14, iOS 14.0, *) {
            xAxisValue = Formatter.iso8601noFS.string(from: xAxisDate)
        } else {
            xAxisValue = ""
        }
    }
}
