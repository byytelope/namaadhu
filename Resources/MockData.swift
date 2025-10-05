import Foundation

let mockIslands: [Island] = [
  Island(
    id: 1,
    categoryId: 1,
    atoll: "A.",
    island: "Alpha",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 1,
  ),
  Island(
    id: 2,
    categoryId: 1,
    atoll: "B.",
    island: "Beta",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 1,
  ),
  Island(
    id: 3,
    categoryId: 2,
    atoll: "C.",
    island: "Charlie",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 4,
    categoryId: 2,
    atoll: "C.",
    island: "Da",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 5,
    categoryId: 3,
    atoll: "D.",
    island: "Darwin",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 6,
    categoryId: 3,
    atoll: "D.",
    island: "Da",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
]

let mockPrayerTimes: [PrayerTimes] = [
  PrayerTimes(
    categoryId: 1,
    dayOfYear: 0,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 735),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1085),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 1,
    dayOfYear: 1,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 1,
    dayOfYear: 2,
    fajr: DateComponents(minute: 302),
    sunrise: DateComponents(minute: 378),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 935),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1164)
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 0,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 735),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1085),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 1,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 2,
    fajr: DateComponents(minute: 302),
    sunrise: DateComponents(minute: 378),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 935),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1164)
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 0,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 735),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1085),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 1,
    fajr: DateComponents(minute: 301),
    sunrise: DateComponents(minute: 377),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 934),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1163)
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 2,
    fajr: DateComponents(minute: 302),
    sunrise: DateComponents(minute: 378),
    dhuhr: DateComponents(minute: 736),
    asr: DateComponents(minute: 935),
    maghrib: DateComponents(minute: 1086),
    isha: DateComponents(minute: 1164)
  ),
]
