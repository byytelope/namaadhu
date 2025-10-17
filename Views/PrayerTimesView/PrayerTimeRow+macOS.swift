#if os(macOS)
  import SwiftUI

  struct PrayerTimeRow: View {
    var prayer: Prayer
    var date: Date
    var isCurrent: Bool = false
    var isUpcoming: Bool = false

    @Environment(\.timerManager) private var timerManager

    @State private var alertEnabled = false

    var body: some View {
      HStack {
        if isUpcoming {
          Group {
            HStack {
              Label(prayer.displayName, systemImage: prayer.sfSymbol)
              Spacer()
              Text(
                DateFormatter.localizedString(
                  from: date,
                  dateStyle: .none,
                  timeStyle: .short
                )
              )
              .monospacedDigit()
            }

            Text(timerManager.timeRemaining.formattedTime())
              .monospacedDigit()
          }
          .padding()
          .background(Capsule().fill(.regularMaterial.opacity(0.75)))
        } else {
          HStack {
            Label(prayer.displayName, systemImage: prayer.sfSymbol)
            Spacer()
            Text(
              DateFormatter.localizedString(
                from: date,
                dateStyle: .none,
                timeStyle: .short
              )
            )
            .monospacedDigit()
          }
          .padding()
          .background(Capsule().fill(.ultraThinMaterial.opacity(0.75)))
          .fontWeight(isCurrent ? .semibold : .regular)
        }
      }
      .symbolVariant(.fill)
      .symbolRenderingMode(.hierarchical)
      .symbolColorRenderingMode(.gradient)
      .padding(.vertical, 3)
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .swipeActions {
        Group {
          alertEnabled
            ? Button("Disable alert", systemImage: "bell.slash") {
              alertEnabled = false
            }
            : Button("Enable alert", systemImage: "bell") {
              alertEnabled = true
            }
        }
        .labelStyle(.iconOnly)
        .tint(
          alertEnabled
            ? Color(NSColor.tertiarySystemFill)
            : .orange
        )
      }
    }
  }
#endif
