import SwiftUI
import WidgetKit

struct PrayerTimesWidget: Widget {
  let kind: String = "PrayerTimesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Prayer Times")
    .description("Countdown to upcoming prayer & list of prayers for the day.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

#Preview(as: .systemMedium) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.placeholder
}
