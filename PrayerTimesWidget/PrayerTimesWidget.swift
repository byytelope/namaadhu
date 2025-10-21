import SwiftUI
import WidgetKit

struct PrayerTimerEntry: TimelineEntry {
  let date: Date
  let selectedIslandName: String?
  let currentPrayer: Prayer?
  let upcomingPrayer: Prayer?
  let upcomingPrayerDate: Date?

  static let empty = PrayerTimerEntry(
    date: Date(),
    selectedIslandName: nil,
    currentPrayer: nil,
    upcomingPrayer: nil,
    upcomingPrayerDate: nil
  )

  static let placeholder = PrayerTimerEntry(
    date: Date(),
    selectedIslandName: "K. Malé",
    currentPrayer: .dhuhr,
    upcomingPrayer: .asr,
    upcomingPrayerDate: Date().addingTimeInterval(3600)
  )
}

struct PrayerTimesWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let upcoming = entry.upcomingPrayer {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("UPCOMING")
              .font(.caption2)
              .bold()
              .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))

            Text(upcoming.displayName)
              .font(.title3)
              .bold()
              .foregroundStyle(.accent)

            if let upcomingDate = entry.upcomingPrayerDate {
              Text(upcomingDate, style: .time)
                .font(.caption2)
                .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))
            }
          }
          Spacer()
        }

        if let upcomingDate = entry.upcomingPrayerDate {
          Text(upcomingDate, style: .timer)
            .font(.system(size: 32, weight: .semibold))
        }

        if let selectedIslandName = entry.selectedIslandName {
          Label(selectedIslandName, systemImage: "location")
            .font(.caption2)
            .foregroundStyle(.accent)
        }
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

struct PrayerTimesWidget: Widget {
  let kind: String = "PrayerTimesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      PrayerTimesWidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Prayer Times")
    .description("Upcoming prayer timer and prayer times list.")
    .supportedFamilies([.systemSmall])
  }
}

#Preview(as: .systemSmall) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimerEntry.placeholder
  PrayerTimerEntry.placeholder
}
