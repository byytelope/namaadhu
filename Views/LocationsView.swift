import GRDB
import SwiftUI

struct LocationsView: View {
  @Environment(\.prayerTimeService) private var prayerTimeService

  @State private var islands: [Island] = []
  @State private var errorMessage: String?
  @State private var selectedIsland: Island?
  @State private var searchText: String = ""
  @State private var expandedAtolls: Set<String> = []

  var body: some View {
    NavigationStack {
      List {
        ForEach(groupedIslands, id: \.atoll) { group in
          Section(group.atoll, isExpanded: isExpandedBinding(for: group.atoll))
          {
            ForEach(group.islands) { island in
              NavigationLink {
                PrayerTimeView(island: island)
              } label: {
                HStack {
                  Text(island.island)
                }
              }
            }
          }
        }
      }
      .navigationTitle("Islands")
      .headerProminence(.increased)
      .listStyle(.sidebar)
      .task {
        do {
          islands = try prayerTimeService.fetchAllIslands()
          expandedAtolls = Set(islands.map { $0.atoll })
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
      .searchable(text: $searchText, prompt: "Search islands")
    }
  }

  private func isExpandedBinding(for atoll: String) -> Binding<Bool> {
    Binding(
      get: {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
          return true
        }
        return expandedAtolls.contains(atoll)
      },
      set: { newValue in
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.isEmpty else {
          return
        }
        if newValue {
          expandedAtolls.insert(atoll)
        } else {
          expandedAtolls.remove(atoll)
        }
      }
    )
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
  LocationsView()
}
