import GRDB
import SwiftUI
import Toasts

struct PrayerTimesView: View {
  @Namespace private var namespace

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.databaseService) private var db
  @Environment(\.preferencesService) private var prefs

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?
  @State private var showIslands = false

  var body: some View {
    NavigationStack {
      ZStack {
        bgGradient()

        Group {
          if prefs.selectedIsland != nil {
            PrayerTimesList(
              prayerTimes: prayerTimes,
              selectedDate: selectedDate
            )
          } else {
            contentUnavailableView()
          }
        }
      }
      .navigationTitle(
        prefs.selectedIsland == nil
          ? "" : selectedDate.formatted(date: .abbreviated, time: .omitted)
      )
      .navigationSubtitle(prefs.selectedIsland?.name ?? "")
      .toolbar(content: toolbarContent)
      .sheet(isPresented: $showIslands) {
        IslandsView()
          .navigationTransition(
            .zoom(sourceID: "islandsbutton", in: namespace)
          )
      }
    }
    .onChange(of: selectedDate) { oldDate, newDate in
      if oldDate != newDate {
        loadPrayerTimes()
      }
    }
    .onChange(of: prefs.selectedIsland, initial: true) { _, _ in
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
          colorScheme == .light ? .white : .black,
          .secondaryAccent.mix(with: .accent, by: 0.5),
        ]
      ),
      startPoint: .top,
      endPoint: .bottom
    )
    .edgesIgnoringSafeArea(.all)
  }

  @ViewBuilder
  func contentUnavailableView() -> some View {
    ContentUnavailableView(
      "Select an island to continue",
      systemImage: "location.slash.circle.fill",
      description: Text("Please select an island from the list.")
    )
  }

  @ToolbarContentBuilder
  func toolbarContent() -> some ToolbarContent {
    prefs.selectedIsland == nil
      ? nil
      : ToolbarItem(placement: .bottomBar) {
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

    ToolbarItem(placement: .bottomBar) {
      Button("Location", systemImage: "location") {
        showIslands = true
      }
    }
    .matchedTransitionSource(id: "islandsbutton", in: namespace)
  }

  private func loadPrayerTimes() {
    if let island = prefs.selectedIsland {
      do {
        prayerTimes =
          try db
          .fetchPrayerTime(for: island, in: selectedDate)
      } catch let decodingError as RowDecodingError {
        print("RowDecodingError:", decodingError)
        errorMessage = String(describing: decodingError)
      } catch {
        errorMessage = error.localizedDescription
      }
    }
  }
}

#Preview {
  PrayerTimesView()
    .installToast(position: .top)
}
