import GRDB
import SwiftUI

struct PrayerTimesView: View {
  var selectedIsland: Island
  var islandTransition: Namespace.ID
  var onSelectLocation: () -> Void = {}

  @Environment(\.databaseService) private var db
  @Environment(\.preferencesService) private var preferences
  @Environment(\.scenePhase) private var scenePhase

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var tomorrowPrayerTimes: PrayerTimes?
  @State private var errorMessage: String?
  @State private var isDatePickerPresented = false
  @State private var isNotificationsPresented = false

  private var isShowingError: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { isPresented in
        if !isPresented {
          errorMessage = nil
        }
      }
    )
  }

  var body: some View {
    PrayerTimesList(
      prayerTimes: prayerTimes,
      tomorrowPrayerTimes: tomorrowPrayerTimes,
      selectedDate: selectedDate
    )
    .navigationTitle("Namaadhu")
    .navigationSubtitle(selectedIsland.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar(content: toolbarContent)
    .onChange(of: selectedDate) { oldDate, newDate in
      if oldDate != newDate {
        loadPrayerTimes()
      }
    }
    .onChange(of: selectedIsland, initial: true) { _, _ in
      loadPrayerTimes()
      updatePrayerNotificationSchedule()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        updatePrayerNotificationSchedule()
      }
    }
    .sheet(isPresented: $isDatePickerPresented) {
      datePickerSheet
    }
    .sheet(isPresented: $isNotificationsPresented) {
      NavigationStack {
        PrayerNotificationsView(selectedIsland: selectedIsland)
      }
      .navigationTransition(
        .zoom(sourceID: "notifications", in: islandTransition)
      )
    }
    .alert("Error", isPresented: isShowingError) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button("Prayer Notifications", systemImage: "bell") {
        isNotificationsPresented = true
      }
      .matchedTransitionSource(
        id: "notifications",
        in: islandTransition
      )

    }

    ToolbarItem(placement: .bottomBar) {
      HStack(spacing: 8) {
        Button("Previous day", systemImage: "chevron.left") {
          changeSelectedDate(byAddingDays: -1)
        }
        .labelStyle(.iconOnly)

        datePickerButton

        Button("Next day", systemImage: "chevron.right") {
          changeSelectedDate(byAddingDays: 1)
        }
        .labelStyle(.iconOnly)
      }
    }

    ToolbarSpacer(.flexible, placement: .bottomBar)

    ToolbarItem(placement: .bottomBar) {
      HStack {
        Button("Location", systemImage: "location") {
          onSelectLocation()
        }
        .matchedTransitionSource(
          id: "islands",
          in: islandTransition
        )
      }
    }
  }

  private var datePickerButton: some View {
    Text(
      isSelectedDateToday
        ? "Today"
        : selectedDate.formatted(date: .abbreviated, time: .omitted)
    )
    .font(.body)
    .lineLimit(1)
    .fixedSize(horizontal: true, vertical: false)
    .padding(.horizontal, 8)
    .padding(.vertical, 8)
    .contentShape(.rect)
    .contentTransition(.numericText(value: selectedDateNumericValue))
    .animation(.snappy, value: selectedDateNumericValue)
    .gesture(datePickerGesture)
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel("Select date")
    .accessibilityAction {
      isDatePickerPresented = true
    }
    .accessibilityAction(named: "Reset to today") {
      resetSelectedDateToToday()
    }
  }

  private var datePickerGesture: some Gesture {
    LongPressGesture()
      .exclusively(before: TapGesture())
      .onEnded { value in
        switch value {
        case .first:
          resetSelectedDateToToday()
        case .second:
          isDatePickerPresented = true
        }
      }
  }

  private var datePickerSheet: some View {
    DatePicker(
      "Select date",
      selection: $selectedDate,
      displayedComponents: .date
    )
    .datePickerStyle(.graphical)
    .labelsHidden()
    .padding()
    .onChange(of: selectedDate) {
      isDatePickerPresented = false
    }
    .presentationDetents([.height(400)])
    .presentationDragIndicator(.visible)
  }

  private var selectedDateNumericValue: Double {
    Calendar.current.startOfDay(for: selectedDate)
      .timeIntervalSinceReferenceDate
  }

  private var isSelectedDateToday: Bool {
    Calendar.current.isDateInToday(selectedDate)
  }

  private func changeSelectedDate(byAddingDays days: Int) {
    if let date = Calendar.current.date(
      byAdding: .day,
      value: days,
      to: selectedDate
    ) {
      withAnimation(.snappy) {
        selectedDate = date
      }
    }
  }

  private func resetSelectedDateToToday() {
    guard !isSelectedDateToday else { return }

    withAnimation(.snappy) {
      selectedDate = .now
    }
  }

  private func loadPrayerTimes() {
    do {
      let prayerTimes = try db.fetchPrayerTime(
        for: selectedIsland,
        in: selectedDate
      )

      let tomorrowPrayerTimes: PrayerTimes?
      if Calendar.current.isDateInToday(selectedDate),
        let tomorrow = Calendar.current.date(
          byAdding: .day,
          value: 1,
          to: selectedDate
        )
      {
        tomorrowPrayerTimes = try db.fetchPrayerTime(
          for: selectedIsland,
          in: tomorrow
        )
      } else {
        tomorrowPrayerTimes = nil
      }

      self.prayerTimes = prayerTimes
      self.tomorrowPrayerTimes = tomorrowPrayerTimes
    } catch let decodingError as RowDecodingError {
      print("RowDecodingError:", decodingError)
      errorMessage = String(describing: decodingError)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func updatePrayerNotificationSchedule() {
    Task {
      do {
        _ = try await PrayerNotificationScheduler.updateSchedule(
          for: selectedIsland,
          enabledPrayers: preferences.notificationEnabledPrayers,
          database: db,
          requestsAuthorization: false
        )
      } catch {
        print("PrayerTimesView: failed to schedule notifications:", error)
      }
    }
  }
}

private struct PrayerTimesViewPreview: View {
  @Namespace private var islandTransition

  var body: some View {
    PrayerTimesView(
      selectedIsland: mockIslands[0],
      islandTransition: islandTransition
    )
  }
}

#Preview {
  PrayerTimesViewPreview()
}
