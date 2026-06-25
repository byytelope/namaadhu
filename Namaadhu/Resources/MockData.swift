import Foundation

let mockIslands: [Island] = [
  Island(
    id: 1,
    categoryId: 1,
    atoll: .haaAlifu,
    island: "Alpha",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 1,
  ),
  Island(
    id: 2,
    categoryId: 1,
    atoll: .haaAlifu,
    island: "Beta",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 1,
  ),
  Island(
    id: 3,
    categoryId: 2,
    atoll: .kaafu,
    island: "Charlie",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 4,
    categoryId: 2,
    atoll: .vaavu,
    island: "Da",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 5,
    categoryId: 3,
    atoll: .seenu,
    island: "Darwin",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
  Island(
    id: 6,
    categoryId: 3,
    atoll: .seenu,
    island: "Da",
    minutes: 0,
    latitude: 0,
    longitude: 0,
    status: 0,
  ),
]

let mockPrayerTimes: [PrayerTimes] = [
  makeMockPrayerTimes(
    categoryId: 1,
    dayOffset: 0,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 1,
    dayOffset: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 1,
    dayOffset: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
  makeMockPrayerTimes(
    categoryId: 2,
    dayOffset: 0,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 2,
    dayOffset: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 2,
    dayOffset: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
  makeMockPrayerTimes(
    categoryId: 3,
    dayOffset: 0,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 735,
    asrMinutes: 934,
    maghribMinutes: 1085,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 3,
    dayOffset: 1,
    fajrMinutes: 301,
    sunriseMinutes: 377,
    dhuhrMinutes: 736,
    asrMinutes: 934,
    maghribMinutes: 1086,
    ishaMinutes: 1163
  ),
  makeMockPrayerTimes(
    categoryId: 3,
    dayOffset: 2,
    fajrMinutes: 302,
    sunriseMinutes: 378,
    dhuhrMinutes: 736,
    asrMinutes: 935,
    maghribMinutes: 1086,
    ishaMinutes: 1164
  ),
]

private func makeMockPrayerTimes(
  categoryId: Int,
  dayOffset: Int,
  fajrMinutes: Int,
  sunriseMinutes: Int,
  dhuhrMinutes: Int,
  asrMinutes: Int,
  maghribMinutes: Int,
  ishaMinutes: Int
) -> PrayerTimes {
  let calendar = Calendar.current
  let date = calendar.date(
    byAdding: .day,
    value: dayOffset,
    to: calendar.startOfDay(for: .now)
  )!

  return PrayerTimes(
    categoryId: categoryId,
    date: date,
    values: PrayerTimes.Values(
      fajr: fajrMinutes,
      sunrise: sunriseMinutes,
      dhuhr: dhuhrMinutes,
      asr: asrMinutes,
      maghrib: maghribMinutes,
      isha: ishaMinutes
    )
  )
}
