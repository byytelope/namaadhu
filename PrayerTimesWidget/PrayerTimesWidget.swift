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
    .supportedFamilies([
      .systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular,
    ])
  }
}

#Preview(as: .systemMedium) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.progressPreview(fraction: 0.75)
}

#Preview(as: .accessoryCircular) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.progressPreview(fraction: 0.75)
}

#Preview(as: .accessoryRectangular) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.progressPreview(fraction: 0.75)
}

#Preview("No island", as: .systemMedium) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.empty
}

#Preview("No island · Circular", as: .accessoryCircular) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.empty
}

#Preview("No island · Rectangular", as: .accessoryRectangular) {
  PrayerTimesWidget()
} timeline: {
  PrayerTimesEntry.empty
}
