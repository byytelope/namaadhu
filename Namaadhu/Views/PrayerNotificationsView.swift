import SwiftUI
import UserNotifications

struct PrayerNotificationsView: View {
  var selectedIsland: Island

  @Environment(\.databaseService) private var database
  @Environment(\.preferencesService) private var preferences
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase

  @State private var authorizationStatus: UNAuthorizationStatus?
  @State private var schedulingErrorMessage: String?

  var body: some View {
    List {
      Section {
        ForEach(Prayer.allCases) { prayer in
          Toggle(isOn: notificationBinding(for: prayer)) {
            Label(prayer.displayName, systemImage: prayer.sfSymbol)
          }
          .tint(.accentColor)
          .disabled(isNotificationPermissionUnavailable)
        }
      } header: {
        Text("Prayer times")
      } footer: {
        Text(
          "Choose the prayer times for which you would like to receive notifications."
        )
      }

      if isNotificationPermissionDenied {
        Section {
          Label {
            Text(
              "Notifications are disabled for Namaadhu in Settings. Enable them to manage prayer alerts."
            )
          } icon: {
            Image(systemName: "bell.slash")
          }
          .foregroundStyle(.secondary)
        }
      }

      if let schedulingErrorMessage {
        Section {
          Label(schedulingErrorMessage, systemImage: "exclamationmark.triangle")
            .foregroundStyle(.red)
        }
      }
    }
    .navigationTitle("Prayer Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Close", systemImage: "xmark") {
          dismiss()
        }
      }
    }
    .onChange(of: preferences.notificationEnabledPrayers) {
      oldValue,
      newValue in
      Task {
        await updateSchedule(
          requestingAuthorization: newValue.count > oldValue.count
        )
      }
    }
    .task {
      await refreshAuthorizationStatus()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        Task {
          await refreshAuthorizationStatus()
        }
      }
    }
  }

  private var isNotificationPermissionDenied: Bool {
    authorizationStatus == .some(.denied)
  }

  private var isNotificationPermissionUnavailable: Bool {
    authorizationStatus == nil || isNotificationPermissionDenied
  }

  private func notificationBinding(for prayer: Prayer) -> Binding<Bool> {
    if isNotificationPermissionUnavailable {
      return .constant(false)
    }

    return preferences.notificationBinding(for: prayer)
  }

  private func updateSchedule(requestingAuthorization: Bool) async {
    do {
      schedulingErrorMessage = nil
      let authorizationStatus =
        try await PrayerNotificationScheduler.updateSchedule(
          for: selectedIsland,
          enabledPrayers: preferences.notificationEnabledPrayers,
          database: database,
          requestsAuthorization: requestingAuthorization
        )

      self.authorizationStatus = authorizationStatus
    } catch {
      schedulingErrorMessage = error.localizedDescription
    }
  }

  private func refreshAuthorizationStatus() async {
    authorizationStatus = await PrayerNotificationScheduler.authorizationStatus()

    guard
      authorizationStatus == .some(.authorized)
        || authorizationStatus == .some(.provisional),
      !preferences.notificationEnabledPrayers.isEmpty
    else {
      return
    }

    await updateSchedule(requestingAuthorization: false)
  }
}

#Preview {
  NavigationStack {
    PrayerNotificationsView(selectedIsland: mockIslands[0])
  }
  .environment(\.preferencesService, PreferencesService())
}
