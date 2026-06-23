import GRDB
import SwiftUI

struct IslandsView: View {
  @Binding var selectedIsland: Island?

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.databaseService) private var db

  @State private var errorMessage: String?
  @State private var islands: [Island] = []
  @State private var searchText: String = ""

  var body: some View {
    List(selection: $selectedIsland) {
      ForEach(groupedIslands, id: \.atoll) { group in
        Section(group.atoll.fullName) {
          ForEach(group.islands) { island in
            Text(island.island)
              .tag(island)
          }
        }
      }
    }
    .navigationTitle("Islands")
    .headerProminence(.increased)
    .listStyle(.sidebar)
    .scrollEdgeEffectStyle(.soft, for: .all)
    .searchable(
      text: $searchText,
      placement: .sidebar,
      prompt: "Search islands",
    )
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          errorMessage =
            "This feature hasn't been implemented yet."
        } label: {
          Label("Automatic", systemImage: "location.viewfinder")
        }
      }
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
        || island.atoll.fullName.localizedCaseInsensitiveContains(query)
        || island.atoll.rawValue.localizedCaseInsensitiveContains(query)
        || island.name.localizedCaseInsensitiveContains(query)
    }
  }

  private var groupedIslands: [(atoll: Atoll, islands: [Island])] {
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
        lhs.atoll.displayOrder < rhs.atoll.displayOrder
      }
  }
}

struct IslandsViewPreview: View {
  @State private var selectedIsland: Island? = mockIslands[0]

  var body: some View {
    IslandsView(selectedIsland: $selectedIsland)
  }
}

#Preview {
  IslandsViewPreview()
}
