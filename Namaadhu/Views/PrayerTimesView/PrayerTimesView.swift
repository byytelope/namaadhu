import GRDB
import SwiftUI

struct PrayerTimesView: View {
  var selectedIsland: Island
  var islandTransition: Namespace.ID
  var onSelectLocation: () -> Void = {}

  @Environment(\.databaseService) private var db

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var tomorrowPrayerTimes: PrayerTimes?
  @State private var errorMessage: String?

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
      selectedDate: $selectedDate
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
    }
    .alert("Error", isPresented: isShowingError) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Location", systemImage: "location") {
        onSelectLocation()
      }
      .matchedTransitionSource(
        id: "islands",
        in: islandTransition
      )
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
