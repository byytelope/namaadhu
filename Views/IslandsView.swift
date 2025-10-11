import GRDB
import SwiftUI

struct IslandsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.databaseService) private var db
  @Environment(\.preferencesService) private var prefs

  @State private var errorMessage: String?
  @State private var islands: [Island] = []
  @State private var searchText: String = ""

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        List {
          Button("Automatic", systemImage: "location") {
            prefs.selectedIsland = nil
            dismiss()
          }
          .foregroundStyle(.accent)

          ForEach(groupedIslands, id: \.atoll) { group in
            Section(group.atoll) {
              ForEach(group.islands) { island in
                Button {
                  prefs.selectedIsland = island
                  dismiss()
                } label: {
                  HStack {
                    Text(island.island)
                    Spacer()

                    if let selectedIsland = prefs.selectedIsland,
                      selectedIsland.id == island.id
                    {
                      Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                    }
                  }
                }
              }
            }
          }
        }
        .onAppear {
          if let selectedIsland = prefs.selectedIsland {
            Task {
              try? await Task.sleep(for: .milliseconds(100))
              proxy.scrollTo(selectedIsland.id, anchor: .center)
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(role: .close) {
            dismiss()
          }
        }
      }
      .navigationTitle("Islands")
      .navigationBarTitleDisplayMode(.inline)
      .headerProminence(.increased)
      .listStyle(.sidebar)
      .searchable(text: $searchText, prompt: "Search islands")
    }
    .task {
      loadIslands()
    }
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  private func loadIslands() {
    do {
      islands = try db.fetchAllIslands()
    } catch let decodingError as RowDecodingError {
      print("RowDecodingError:", decodingError)
      errorMessage = String(describing: decodingError)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private var filteredIslands: [Island] {
    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return islands }
    return islands.filter { island in
      island.island.localizedCaseInsensitiveContains(query)
        || island.atoll.localizedCaseInsensitiveContains(query)
        || island.name.localizedCaseInsensitiveContains(query)
    }
  }

  private var groupedIslands: [(atoll: String, islands: [Island])] {
    let groups = Dictionary(grouping: filteredIslands, by: { $0.atoll })
    return
      groups
      .map { key, value in
        (
          atoll: key,
          islands: value.sorted {
            $0.island.localizedCaseInsensitiveCompare($1.island)
              == .orderedAscending
          }
        )
      }
      .sorted { lhs, rhs in
        lhs.atoll.localizedCaseInsensitiveCompare(rhs.atoll)
          == .orderedAscending
      }
  }
}

#Preview {
  IslandsView()
}
