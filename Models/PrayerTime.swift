import Foundation
import GRDB

/// A value type representing the daily prayer times for a specific calendar day and category.
///
/// Data encoding:
/// - `date` is the day-of-year index in the Gregorian calendar (1...366).
/// - Prayer time fields (`fajr`, `sunrise`, `dhuhr`, `asr`, `maghrib`, `isha`) are stored as minutes after local midnight (0...1439).
/// - Times are expressed in the local time zone for the associated category/location.
struct PrayerTime: FetchableRecord, Decodable {
  let categoryId: Int
  let date: Int
  let fajr: Int
  let sunrise: Int
  let dhuhr: Int
  let asr: Int
  let maghrib: Int
  let isha: Int
}
