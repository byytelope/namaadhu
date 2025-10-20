#if os(macOS)
  import SwiftUI

  struct PrayerTimeRow: View {
    var prayer: Prayer
    var date: Date
    var isUpcoming: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.timerManager) private var timerManager

    @State private var alertEnabled = false

    var body: some View {
      HStack {
        if isUpcoming {
          Group {
            HStack {
              Label {
                Text(prayer.displayName)
                  .foregroundStyle(
                    colorScheme == .light
                      ? Color.primary.mix(with: .accent, by: 0.7)
                      : .accent.mix(with: .primary, by: 0.9)
                  )
              } icon: {
                Image(systemName: prayer.sfSymbol)
                  .foregroundStyle(
                    colorScheme == .light
                      ? Color.primary.mix(with: .accent, by: 0.7)
                      : .accent.mix(with: .primary, by: 0.9)
                  )
              }
              .fontWeight(.semibold)

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
          .fontWeight(.semibold)
          .padding(10)
          .background(
            Capsule().fill(
              colorScheme == .light
                ? Material.thin.opacity(0.75) : Material.regular.opacity(0.75)
            )
          )
        } else {
          HStack {
            Label {
              Text(prayer.displayName)
                .foregroundStyle(
                  colorScheme == .light
                    ? Color.primary.mix(with: .accent, by: 0.7)
                    : .accent.mix(with: .primary, by: 0.9)
                )
            } icon: {
              Image(systemName: prayer.sfSymbol)
                .foregroundStyle(
                  colorScheme == .light
                    ? .accent
                    : .accent.mix(with: .primary, by: 0.5)
                )
            }
            .fontWeight(.medium)

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
          .padding(10)
          .background(
            Capsule().fill(
              colorScheme == .light
                ? Material.regular.opacity(0.75) : Material.thin.opacity(0.5)
            )
          )
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
