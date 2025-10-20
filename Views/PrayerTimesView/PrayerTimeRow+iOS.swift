#if os(iOS)
  import SwiftUI
  import Toasts

  struct PrayerTimeRow: View {
    var prayer: Prayer
    var date: Date
    var isUpcoming: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.timerManager) private var timerManager
    @Environment(\.presentToast) private var presentToast

    @State private var alertEnabled = false

    var body: some View {
      GlassEffectContainer {
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
            .padding()
            .glassEffect(.regular.interactive())
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
            .padding()
            .background(
              Capsule().fill(
                colorScheme == .light
                  ? Material.regular.opacity(0.75) : Material.thin.opacity(0.5)
              )
            )
          }
        }
      }
      .symbolVariant(.fill)
      .symbolRenderingMode(.hierarchical)
      .symbolColorRenderingMode(.gradient)
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      .swipeActions {
        Group {
          alertEnabled
            ? Button("Disable alert", systemImage: "bell.slash") {
              presentToast(
                .init(
                  icon: Image(systemName: "bell.slash")
                    .symbolVariant(.fill)
                    .symbolColorRenderingMode(.gradient)
                    .foregroundStyle(.red),
                  message: "Alerts disabled for \(prayer.displayName)"
                )
              )
              alertEnabled = false
            }
            : Button("Enable alert", systemImage: "bell") {
              presentToast(
                .init(
                  icon: Image(systemName: "bell")
                    .symbolVariant(.fill)
                    .symbolColorRenderingMode(.gradient),
                  message: "Alerts enabled for \(prayer.displayName)"
                )
              )
              alertEnabled = true
            }
        }
        .labelStyle(.iconOnly)
        .tint(
          alertEnabled
            ? Color(UIColor.tertiarySystemFill)
            : .orange
        )
      }
    }
  }
#endif
