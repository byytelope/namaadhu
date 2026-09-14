import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall: SystemSmallView(entry: entry)
    case .systemMedium: SystemMediumView(entry: entry)
    case .accessoryCircular:
      LockScreenPrayerView(entry: entry, circular: true)
    case .accessoryRectangular:
      LockScreenPrayerView(entry: entry, circular: false)
    default: SystemSmallView(entry: entry)
    }
  }
}

struct PrayerCountdownContainer: View {
  let interval: ClosedRange<Date>

  var body: some View {
    Text(timerInterval: interval, countsDown: true, showsHours: true)
      .monospacedDigit()
      .lineLimit(1)
      .foregroundStyle(Color.primary.mix(with: .accent, by: 0.5))
      .minimumScaleFactor(0.65)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background {
        PrayerProgressFill(interval: interval)
      }
      .clipShape(Capsule())
  }
}

struct PrayerProgressFill: View {
  let interval: ClosedRange<Date>

  var body: some View {
    GeometryReader { geometry in
      ProgressView(timerInterval: interval, countsDown: true) {
        EmptyView()
      } currentValueLabel: {
        EmptyView()
      }
      .progressViewStyle(.linear)
      .tint(.accent.opacity(0.3))
      .frame(width: geometry.size.width, height: 4)
      .scaleEffect(x: 1, y: geometry.size.height / 4)
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .accessibilityHidden(true)
  }
}

struct LockScreenPrayerView: View {
  let entry: Provider.Entry
  let circular: Bool

  var body: some View {
    if let prayer = entry.upcomingPrayer, let interval = entry.progressInterval
    {
      if circular {
        ZStack {
          ProgressView(timerInterval: interval, countsDown: true) {
            EmptyView()
          } currentValueLabel: {
            EmptyView()
          }
          .progressViewStyle(.circular)
          .tint(.primary)
          .accessibilityHidden(true)

          Image(systemName: prayer.sfSymbol)
            .font(.system(size: 20))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(prayer.displayName))
      } else {
        HStack(spacing: 10) {
          Image(systemName: prayer.sfSymbol)
            .font(.system(size: 28))
          VStack(alignment: .leading, spacing: 0) {
            Text(prayer.displayName)
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(.secondary)
            countdown(interval)
              .font(.title2.bold())
            ProgressView(timerInterval: interval, countsDown: true) {
              EmptyView()
            } currentValueLabel: {
              EmptyView()
            }
            .progressViewStyle(.linear)
            .tint(.primary)
            .accessibilityHidden(true)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    } else {
      VStack(spacing: 2) {
        Image(systemName: "location")
        Text(circular ? "Open app" : "Select an island in Namaadhu")
          .font(.caption2)
          .multilineTextAlignment(.center)
      }
    }
  }

  private func countdown(_ interval: ClosedRange<Date>) -> some View {
    Text(timerInterval: interval, countsDown: true, showsHours: true)
      .monospacedDigit()
      .lineLimit(1)
      .minimumScaleFactor(0.6)
      .fontDesign(.rounded)
  }
}
