import GRDB
import SwiftUI

struct PrayerTimesView: View {
  @Namespace private var namespace

  @Environment(\.databaseService) private var db
  @Environment(\.preferencesService) private var prefs

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?
  @State private var showIslands = false
  @State private var showDatePicker = false

  var body: some View {
    NavigationStack {
      Group {
        if prefs.selectedIsland != nil {
          List {
            datePicker
            times
          }
          .listSectionSpacing(.compact)
        } else {
          ContentUnavailableView(
            "Select an island to continue",
            systemImage: "location.slash",
            description: Text("Please select an island from the list.")
          )
        }
      }
      .navigationTitle(prefs.selectedIsland?.name ?? "")
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button("Islands", systemImage: "location") {
            showIslands = true
          }
        }
        .matchedTransitionSource(id: "islandsbutton", in: namespace)
      }
      .sheet(isPresented: $showIslands) {
        IslandsView()
          .navigationTransition(.zoom(sourceID: "islandsbutton", in: namespace))
      }
    }
    .onChange(of: selectedDate) { oldDate, newDate in
      if oldDate != newDate {
        loadPrayerTimes()
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

  private var datePicker: some View {
    Section {
      Button {
        withAnimation {
          showDatePicker.toggle()
        }
      } label: {
        HStack {
          Label("Date", systemImage: "calendar")
            .tint(.primary)

          Spacer()

          Group {
            Text(
              selectedDate.formatted(date: .abbreviated, time: .omitted)
            )
            Image(systemName: "chevron.right")
              .rotationEffect(.degrees(showDatePicker ? 90 : 0))
          }
          .tint(.accent)
        }
      }

      if showDatePicker {
        DatePicker(
          "Select a date",
          selection: $selectedDate,
          displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
      }
    }
  }

  private var times: some View {
    Section {
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
}
