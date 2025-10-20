import GRDB
import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

struct PrayerTimesView: View {
  var selectedIsland: Island

  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.databaseService) private var db

  @State private var selectedDate = Date.now
  @State private var prayerTimes: PrayerTimes?
  @State private var errorMessage: String?

  private var isiPhone: Bool {
    horizontalSizeClass == .compact
  }

  var body: some View {
    NavigationStack {
      ZStack {
        BGGradient()

        PrayerTimesList(
          prayerTimes: prayerTimes,
          selectedDate: $selectedDate
        )
      }
      .navigationTitle("Namaadhu")
      .navigationSubtitle(selectedIsland.name)
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
  func BGGradient() -> some View {
    #if os(iOS)
      colorScheme == .light
        ? RadialGradient(
          colors: [
            .accent,
            .cream,
          ],
          center: isiPhone ? .bottom : .bottomTrailing,
          startRadius: isiPhone ? 1000 : 1500,
          endRadius: isiPhone ? 100 : 0
        )
        .edgesIgnoringSafeArea(.all)
        : RadialGradient(
          colors: [
            .darkPurple,
            .accent,
            .cream,
          ],
          center: isiPhone ? .bottom : .bottomTrailing,
          startRadius: isiPhone ? 900 : 1500,
          endRadius: isiPhone ? 50 : 0
        )
        .edgesIgnoringSafeArea(.all)
    #else
      colorScheme == .light
        ? RadialGradient(
          colors: [
            .accent,
            .cream,
          ],
          center: .topTrailing,
          startRadius: 700,
          endRadius: 50
        )
        .edgesIgnoringSafeArea(.all)
        : RadialGradient(
          colors: [
            .darkPurple,
            .accent,
            .cream,
          ],
          center: .topTrailing,
          startRadius: 900,
          endRadius: 50
        )
        .edgesIgnoringSafeArea(.all)
    #endif
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    #if os(iOS)
      if isiPhone {
        ToolbarItem(placement: .bottomBar) {
          Button("Location", systemImage: "location") {
            dismiss()
          }
        }
      }
    #else
      ToolbarSpacer()
    #endif
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
