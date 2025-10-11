import SwiftUI
import Toasts

struct PrayerTimesList: View {
  var prayerTimes: PrayerTimes?
  var selectedDate: Date

  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.timerManager) private var timerManager
  @Environment(\.presentToast) private var presentToast

  @State private var alertEnabled = false

  private var isToday: Bool {
    Calendar.current.isDateInToday(selectedDate)
  }

  var body: some View {
    List {
      if let times = prayerTimes {
        ForEach(times.orderedDates(), id: \.0) { prayer, date in
          prayerRow(
            prayer: prayer,
            date: date,
            isCurrent: isToday && prayer == timerManager.currentPrayer,
            isUpcoming: isToday && prayer == timerManager.upcomingPrayer,
          )
        }
      }
    }
    .listStyle(.plain)
    .listRowSpacing(6)
    .contentMargins(16)
    .scrollContentBackground(.hidden)
    .onDisappear {
      timerManager.setTickingEnabled(false)
    }
    .onChange(of: prayerTimes, initial: true) { _, new in
      if isToday {
        timerManager.update(prayerTimes: new)
      }
    }
    .onChange(of: scenePhase, initial: true) { _, phase in
      if isToday {
        timerManager.setTickingEnabled(phase == .active)
      }
    }
  }

  @ViewBuilder
  private func prayerRow(
    prayer: Prayer,
    date: Date,
    isCurrent: Bool = false,
    isUpcoming: Bool = false
  )
    -> some View
  {
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
              .fontWeight(.medium)
              .monospacedDigit()
          }
          .padding()
          .background(Capsule().fill(.regularMaterial))
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
                Capsule().fill(Material.regular)
              }
            }
          )
          .fontWeight(isCurrent ? .medium : .regular)
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
      .tint(alertEnabled ? Color(UIColor.tertiarySystemFill) : .orange)
    }
  }
}
