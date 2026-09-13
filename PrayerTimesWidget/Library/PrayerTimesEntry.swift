import Foundation
import WidgetKit

struct PrayerTimesEntry: TimelineEntry {
  let date: Date
  let selectedIslandName: String?
  let currentPrayer: Prayer?
  let upcomingPrayer: Prayer?
  let upcomingPrayerDate: Date?
  let prayerTimes: PrayerTimes?
  
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
    currentPrayer: .dhuhr,
    upcomingPrayer: .asr,
    upcomingPrayerDate: _date.addingTimeInterval(3600),
    prayerTimes: mockPrayerTimes[0]
  )
}
