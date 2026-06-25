import SwiftUI

struct PrayerTimesList: View {
  var prayerTimes: PrayerTimes?
  var tomorrowPrayerTimes: PrayerTimes?
  @Binding var selectedDate: Date

  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.timerManager) private var timerManager

  private var isToday: Bool {
    Calendar.current.isDateInToday(selectedDate)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 6) {
        DatePicker(
          "Select date",
          selection: $selectedDate,
          displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .frame(maxWidth: .infinity, alignment: .leading)

        if let times = prayerTimes {
          ForEach(times.orderedDates(), id: \.0) { prayer, date in
            PrayerTimeRow(
              prayer: prayer,
              date: date,
              isCurrent: isToday
                && prayer == timerManager.currentPrayer,
              isUpcoming: isToday
                && prayer == timerManager.upcomingPrayer,
            )
          }
        }
      }
      .animation(
        .smooth(duration: 0.42),
        value: timerManager.upcomingPrayer
      )
    }
    .safeAreaPadding(.horizontal)
    .onDisappear {
      timerManager.setTickingEnabled(false)
    }
    .onChange(of: prayerTimes, initial: true) { _, new in
      synchronizeTimer(today: new, tomorrow: tomorrowPrayerTimes)
    }
    .onChange(of: tomorrowPrayerTimes) { _, new in
      synchronizeTimer(today: prayerTimes, tomorrow: new)
    }
    .onChange(of: selectedDate) {
      synchronizeTimer(today: prayerTimes, tomorrow: tomorrowPrayerTimes)
    }
    .onChange(of: scenePhase, initial: true) { _, phase in
      timerManager.setTickingEnabled(isToday && phase == .active)
    }
  }

  private func synchronizeTimer(
    today: PrayerTimes?,
    tomorrow: PrayerTimes?
  ) {
    guard
      isToday,
      let today,
      Calendar.current.isDate(today.date, inSameDayAs: selectedDate)
    else {
      timerManager.update(today: nil, tomorrow: nil)
      timerManager.setTickingEnabled(false)
      return
    }

    timerManager.update(today: today, tomorrow: tomorrow)
    timerManager.setTickingEnabled(scenePhase == .active)
  }
}
