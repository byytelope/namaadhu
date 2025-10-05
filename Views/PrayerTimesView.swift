import GRDB
import SwiftUI

struct PrayerTimesView: View {
  @Environment(\.databaseService) private var db
  @Environment(\.preferencesService) private var prefs

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?
  @State private var showIslands = false

  var body: some View {
    NavigationStack {
      Group {
        if prefs.selectedIsland != nil {
          List {
            if let times = prayerTimes {
              HStack {
                Text("Fajr")
                Spacer()
                Text(
                  times
                    .fajrDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }

              HStack {
                Text("Sunrise")
                Spacer()
                Text(
                  times
                    .sunriseDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }

              HStack {
                Text("Dhuhr")
                Spacer()
                Text(
                  times
                    .dhuhrDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }

              HStack {
                Text("Asr")
                Spacer()
                Text(
                  times
                    .asrDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }

              HStack {
                Text("Maghrib")
                Spacer()
                Text(
                  times
                    .maghribDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }

              HStack {
                Text("Isha")
                Spacer()
                Text(
                  times
                    .ishaDate(on: selectedDate)?
                    .formatted(date: .omitted, time: .shortened) ?? ""
                )
              }
            }
          }
        } else {
          ContentUnavailableView(
            "Select an island to continue",
            systemImage: "location.slash",
            description: Text("Please select an island from the list.")
          )
        }
      }
      .navigationTitle(prefs.selectedIsland?.name ?? "")
      .navigationSubtitle(
        Date.now.formatted(date: .complete, time: .omitted)
      )
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button("Islands", systemImage: "location") {
            showIslands = true
          }
        }
      }
      .sheet(isPresented: $showIslands) {
        IslandsView()
      }
    }
    .task {
      loadPrayerTimes()
    }
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  private func loadPrayerTimes() {
    if let island = prefs.selectedIsland {
      do {
        prayerTimes =
          try db
          .fetchPrayerTime(for: island, in: Date.now)
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
}
