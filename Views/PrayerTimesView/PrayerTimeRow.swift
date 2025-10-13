import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

struct PrayerTimeRow: View {
  var prayer: Prayer
  var date: Date
  var isCurrent: Bool = false
  var isUpcoming: Bool = false

  @Environment(\.timerManager) private var timerManager
  #if canImport(Toasts)
    @Environment(\.presentToast) private var presentToast
  #endif

  @State private var alertEnabled = false

  var body: some View {
    GlassEffectContainer {
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
          .background(
            Group {
              if isCurrent {
                Color.clear
              } else {
                Capsule().fill(.regularMaterial.opacity(0.75))
              }
            }
          )
          .fontWeight(isCurrent ? .semibold : .regular)
          .glassEffect(isCurrent ? .regular.interactive() : .identity)
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
            #if canImport(Toasts)
              presentToast(
                .init(
                  icon: Image(systemName: "bell.slash")
                    .symbolVariant(.fill)
                    .symbolColorRenderingMode(.gradient)
                    .foregroundStyle(.red),
                  message: "Alerts disabled for \(prayer.displayName)"
                )
              )
            #endif
            alertEnabled = false
          }
          : Button("Enable alert", systemImage: "bell") {
            #if canImport(Toasts)
              presentToast(
                .init(
                  icon: Image(systemName: "bell")
                    .symbolVariant(.fill)
                    .symbolColorRenderingMode(.gradient),
                  message: "Alerts enabled for \(prayer.displayName)"
                )
              )
            #endif
            alertEnabled = true
          }
      }
      .labelStyle(.iconOnly)
      .tint(
        alertEnabled
          ? {
            #if os(macOS)
              Color(NSColor.tertiarySystemFill)
            #else
              Color(UIColor.tertiarySystemFill)
            #endif
          }()
          : .orange
      )
    }
  }
}
