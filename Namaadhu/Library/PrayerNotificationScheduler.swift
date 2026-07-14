import Foundation
import UserNotifications

@MainActor
enum PrayerNotificationScheduler {
  private static let identifierPrefix = "prayer-notification-"
  private static let schedulingHorizonInDays = 10

  static func authorizationStatus() async -> UNAuthorizationStatus {
    await UNUserNotificationCenter.current()
      .notificationSettings()
      .authorizationStatus
  }

  static func updateSchedule(
    for island: Island,
    enabledPrayers: Set<Prayer>,
    database: any DatabaseServiceProtocol,
    requestsAuthorization: Bool
  ) async throws -> UNAuthorizationStatus {
    let notificationCenter = UNUserNotificationCenter.current()
    await removePendingPrayerNotifications(from: notificationCenter)

    guard !enabledPrayers.isEmpty else {
      return await notificationCenter.notificationSettings().authorizationStatus
    }

    var authorizationStatus =
      await notificationCenter
      .notificationSettings()
      .authorizationStatus

    if authorizationStatus == .notDetermined && requestsAuthorization {
      _ = try await notificationCenter.requestAuthorization(
        options: [.alert, .sound]
      )
      authorizationStatus =
        await notificationCenter
        .notificationSettings()
        .authorizationStatus
    }

    guard authorizationStatus == .authorized || authorizationStatus == .provisional
    else {
      return authorizationStatus
    }

    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: .now)

    for dayOffset in 0..<schedulingHorizonInDays {
      guard
        let date = calendar.date(
          byAdding: .day,
          value: dayOffset,
          to: startOfToday
        ), let prayerTimes = try database.fetchPrayerTime(for: island, in: date)
      else {
        continue
      }

      for occurrence in prayerTimes.orderedDates(calendar: calendar)
      where enabledPrayers.contains(occurrence.prayer) && occurrence.date > .now {
        try await notificationCenter.add(
          notificationRequest(for: occurrence, calendar: calendar)
        )
      }
    }

    return authorizationStatus
  }

  private static func removePendingPrayerNotifications(
    from notificationCenter: UNUserNotificationCenter
  ) async {
    let identifiers =
      await notificationCenter
      .pendingNotificationRequests()
      .map(\.identifier)
      .filter { $0.hasPrefix(identifierPrefix) }

    notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
  }

  private static func notificationRequest(
    for occurrence: PrayerTimeOccurrence,
    calendar: Calendar
  ) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    let prayerName = String(localized: occurrence.prayer.displayName)
    content.title = prayerName
    content.body = "It is time for \(prayerName)."
    content.sound = .default

    let dateComponents = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: occurrence.date
    )
    let trigger = UNCalendarNotificationTrigger(
      dateMatching: dateComponents,
      repeats: false
    )

    return UNNotificationRequest(
      identifier: identifier(for: occurrence, calendar: calendar),
      content: content,
      trigger: trigger
    )
  }

  private static func identifier(
    for occurrence: PrayerTimeOccurrence,
    calendar: Calendar
  ) -> String {
    let day = calendar.startOfDay(for: occurrence.date)
      .timeIntervalSinceReferenceDate

    return "\(identifierPrefix)\(occurrence.prayer.rawValue)-\(Int(day))"
  }
}
