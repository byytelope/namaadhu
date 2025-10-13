import GRDB
import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

struct PrayerTimesView: View {
  var selectedIsland: Island

  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.databaseService) private var db

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      ZStack {
        bgGradient()

        PrayerTimesList(
          prayerTimes: prayerTimes,
          selectedDate: selectedDate
        )
      }
      .navigationTitle(selectedIsland.name)
      .navigationSubtitle(
        selectedDate.formatted(date: .abbreviated, time: .omitted)
      )
      .toolbar(content: toolbarContent)
    }
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

  @ViewBuilder
  func bgGradient() -> some View {
    LinearGradient(
      gradient: Gradient(
        colors: [
          .secondaryAccent,
          colorScheme == .light ? .white : .black,
          colorScheme == .light ? .white : .black,
        ]
      ),
      startPoint: .top,
      endPoint: .bottom
    )
    .edgesIgnoringSafeArea(.all)
  }

  @ToolbarContentBuilder
  func toolbarContent() -> some ToolbarContent {
    ToolbarItem(
      placement: {
        #if os(macOS)
          .automatic
        #else
          .bottomBar
        #endif
      }()
    ) {
      Label("Select date", systemImage: "calendar")
        .overlay {
          DatePicker(
            "Select date",
            selection: $selectedDate,
            displayedComponents: .date
          )
          .labelsHidden()
          .colorMultiply(.clear)
        }
    }

    ToolbarItem(
      placement: {
        #if os(macOS)
          .automatic
        #else
          .bottomBar
        #endif
      }()
    ) {
      Button("Location", systemImage: "location") {
        dismiss()
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
    #if canImport(Toasts)
      .installToast(position: .top)
    #endif
}
