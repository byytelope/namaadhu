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
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 1,
    dayOfYear: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 1,
    dayOfYear: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 0,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 2,
    dayOfYear: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 0,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  PrayerTimes(
    categoryId: 3,
    dayOfYear: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
]
