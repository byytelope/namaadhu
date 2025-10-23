import SwiftUI

struct PrayerTimesList: View {
  var prayerTimes: PrayerTimes?
  @Binding var selectedDate: Date

  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.timerManager) private var timerManager

  private var isToday: Bool {
    Calendar.current.isDateInToday(selectedDate)
  }

  var body: some View {
    List {
      DatePicker(
        "Select date",
        selection: $selectedDate,
        displayedComponents: .date
      )
      .datePickerStyle(.compact)
      .labelsHidden()
      .listRowBackground(Color.clear)
      .listSectionSeparator(.hidden)
      .listRowInsets(EdgeInsets())

      if let times = prayerTimes {
        ForEach(times.orderedDates(), id: \.0) { prayer, date in
          PrayerTimeRow(
            prayer: prayer,
            date: date,
            isUpcoming: isToday && prayer == timerManager.upcomingPrayer,
          )
        }
      }
    }
    .listStyle(.plain)
    .safeAreaPadding()
    .listRowSpacing(6)
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
}
