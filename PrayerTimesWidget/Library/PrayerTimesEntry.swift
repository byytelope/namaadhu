import Foundation
import WidgetKit

struct PrayerTimesEntry: TimelineEntry {
  let date: Date
  let selectedIslandName: String?
  let currentPrayer: Prayer?
  let upcomingPrayer: Prayer?
  let upcomingPrayerDate: Date?
  let prayerTimes: PrayerTimes?
  var currentPrayerDate: Date? = nil

  var progressInterval: ClosedRange<Date>? {
    guard let end = upcomingPrayerDate else { return nil }
    let start =
      currentPrayerDate
      ?? prayerTimes?.orderedDates().last(where: { $0.date <= date })?.date
      ?? date
    guard start < end else { return nil }
    return start...end
  }

  static let _date = Date()
  static let empty = PrayerTimesEntry(
    date: _date,
    selectedIslandName: nil,
    currentPrayer: nil,
    upcomingPrayer: nil,
    upcomingPrayerDate: nil,
    prayerTimes: nil
  )

  static let placeholder = PrayerTimesEntry(
    date: _date,
    selectedIslandName: "K. Malé",
    currentPrayer: .asr,
    upcomingPrayer: .maghrib,
    upcomingPrayerDate: _date.addingTimeInterval(3600),
    prayerTimes: mockPrayerTimes[0]
  )

  static func progressPreview(fraction: Double) -> PrayerTimesEntry {
    let times = mockPrayerTimes[0]
    let occurrences = times.orderedDates()
    guard let start = occurrences.first(where: { $0.prayer == .asr })?.date,
      let end = occurrences.first(where: { $0.prayer == .maghrib })?.date,
      end > start
    else { return .placeholder }

    let now = Date()
    let duration = end.timeIntervalSince(start)
    let intervalStart = now.addingTimeInterval(
      -duration * min(max(fraction, 0), 1)
    )
    return PrayerTimesEntry(
      date: now,
      selectedIslandName: placeholder.selectedIslandName,
      currentPrayer: .asr,
      upcomingPrayer: .maghrib,
      upcomingPrayerDate: intervalStart.addingTimeInterval(duration),
      prayerTimes: times,
      currentPrayerDate: intervalStart
    )
  }
}
