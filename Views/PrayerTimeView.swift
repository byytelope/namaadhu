import GRDB
import SwiftUI

struct PrayerTimeView: View {
  var island: Island

  @Environment(\.prayerTimeService) private var prayerTimeService

  @State private var prayerTime: PrayerTime?
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      List {
        if let prayerTime = prayerTime {
          HStack {
            Text("Fajr")
            Spacer()
            Text(prayerTime.fajr.formatted())
          }

          HStack {
            Text("Sunrise")
            Spacer()
            Text(prayerTime.sunrise.formatted())
          }

          HStack {
            Text("Dhuhr")
            Spacer()
            Text(prayerTime.dhuhr.formatted())
          }

          HStack {
            Text("Asr")
            Spacer()
            Text(prayerTime.asr.formatted())
          }

          HStack {
            Text("Maghrib")
            Spacer()
            Text(prayerTime.maghrib.formatted())
          }

          HStack {
            Text("Isha")
            Spacer()
            Text(prayerTime.isha.formatted())
          }
        }
      }
      .navigationTitle(island.name)
      .navigationSubtitle(
        Date.now.formatted(date: .complete, time: .omitted)
      )
    }
    .task {
      do {
        prayerTime =
          try prayerTimeService
          .fetchPrayerTime(for: island, in: Date.now)
      } catch let decodingError as RowDecodingError {
        print("RowDecodingError:", decodingError)
        errorMessage = String(describing: decodingError)
      } catch {
        errorMessage = error.localizedDescription
      }
    }
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }
}

#Preview {
  PrayerTimeView(island: mockIslands[0])
}
