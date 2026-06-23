import GRDB
import SwiftUI
import Toasts

struct PrayerTimesView: View {
  var selectedIsland: Island

  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.databaseService) private var db

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?

  private var isCompact: Bool {
    horizontalSizeClass == .compact
  }

  var body: some View {
    PrayerTimesList(
      prayerTimes: prayerTimes,
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
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    if isCompact {
      ToolbarItem(placement: .bottomBar) {
        Button("Location", systemImage: "location") {
          dismiss()
        }
      }
    }
  }

  private func loadPrayerTimes() {
    do {
      prayerTimes =
        try db
        .fetchPrayerTime(for: selectedIsland, in: selectedDate)
    } catch let decodingError as RowDecodingError {
      print("RowDecodingError:", decodingError)
      errorMessage = String(describing: decodingError)
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

#Preview {
  PrayerTimesView(selectedIsland: mockIslands[0])
}
