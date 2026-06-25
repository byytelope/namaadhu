import CoreLocation
import GRDB
import SwiftUI

struct IslandsView: View {
  @Binding var selectedIsland: Island?

  @Environment(\.databaseService) private var db
  @Environment(\.dismiss) private var dismiss

  @State private var errorMessage: String?
  @State private var expandedAtolls: Set<Atoll> = []
  @State private var isLocating = false
  @State private var islands: [Island] = []
  @State private var locationService = CurrentLocationService()
  @State private var preSearchExpandedAtolls: Set<Atoll>?
  @State private var searchText: String = ""

  private var isShowingError: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { isPresented in
        if !isPresented {
          errorMessage = nil
        }
      }
    )
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(groupedIslands, id: \.atoll) { group in
          DisclosureGroup(
            isExpanded: expansionBinding(for: group.atoll)
          ) {
            VStack(spacing: 0) {
              ForEach(group.islands) { island in
                islandButton(island)

                if island.id != group.islands.last?.id {
                  Divider()
                }
              }
            }
            .padding(.top, 8)
          } label: {
            Text(group.atoll.fullName)
              .font(.headline)
          }
          .padding()
          .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20)
          )
        }
      }
    }
    .safeAreaPadding()
    .navigationTitle("Islands")
    .toolbarTitleDisplayMode(.inline)
    .searchable(
      text: $searchText,
      placement: .automatic,
      prompt: "Search islands",
    )
    .overlay {
      if !searchQuery.isEmpty && filteredIslands.isEmpty {
        ContentUnavailableView.search(text: searchQuery)
      }
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Close", systemImage: "xmark") {
          dismiss()
        }
      }

      DefaultToolbarItem(kind: .search, placement: .bottomBar)
      ToolbarSpacer(.flexible, placement: .bottomBar)
      ToolbarItem(placement: .bottomBar) {
        Button {
          selectNearestIsland()
        } label: {
          if isLocating {
            ProgressView()
              .accessibilityLabel("Getting current location")
          } else {
            Label("Automatic", systemImage: "location.viewfinder")
          }
        }
        .disabled(isLocating || islands.isEmpty)
      }
    }
    .task {
      loadIslands()
    }
    .onChange(of: searchQuery) { oldQuery, newQuery in
      updateExpandedAtolls(
        from: oldQuery,
        to: newQuery
      )
    }
    .alert("Error", isPresented: isShowingError) {
      Button("OK") { errorMessage = nil }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  private func islandButton(_ island: Island) -> some View {
    Button {
      selectedIsland = island
      dismiss()
    } label: {
      HStack {
        Text(island.island)
          .foregroundStyle(.primary)

        Spacer()

        if island == selectedIsland {
          Image(systemName: "checkmark")
            .fontWeight(.semibold)
            .foregroundStyle(.accent)
        }
      }
      .padding(.vertical, 12)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private func loadIslands() {
    do {
      islands = try db.fetchAllIslands()
      if searchQuery.isEmpty, let selectedIsland {
        expandedAtolls.insert(selectedIsland.atoll)
      }
    } catch let decodingError as RowDecodingError {
      print("RowDecodingError:", decodingError)
      errorMessage = String(describing: decodingError)
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func selectNearestIsland() {
    isLocating = true

    locationService.requestLocation { result in
      isLocating = false

      switch result {
      case .success(let location):
        guard let island = nearestIsland(to: location) else {
          errorMessage = "No islands are available."
          return
        }

        selectedIsland = island
        dismiss()
      case .failure(let error):
        errorMessage = error.localizedDescription
      }
    }
  }

  private func nearestIsland(to location: CLLocation) -> Island? {
    islands.min { lhs, rhs in
      location.distance(
        from: CLLocation(latitude: lhs.latitude, longitude: lhs.longitude)
      ) < location.distance(
        from: CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)
      )
    }
  }

  private func expansionBinding(for atoll: Atoll) -> Binding<Bool> {
    Binding(
      get: {
        expandedAtolls.contains(atoll)
      },
      set: { isExpanded in
        if isExpanded {
          expandedAtolls.insert(atoll)
        } else {
          expandedAtolls.remove(atoll)
        }
      }
    )
  }

  private func updateExpandedAtolls(
    from oldQuery: String,
    to newQuery: String
  ) {
    if oldQuery.isEmpty, !newQuery.isEmpty {
      preSearchExpandedAtolls = expandedAtolls
    }

    if newQuery.isEmpty {
      expandedAtolls = preSearchExpandedAtolls
        ?? selectedIsland.map { Set([$0.atoll]) }
        ?? []
      preSearchExpandedAtolls = nil
    } else {
      expandedAtolls = Set(groupedIslands.map(\.atoll))
    }
  }

  private var filteredIslands: [Island] {
    guard !searchQuery.isEmpty else { return islands }

    return islands.filter { island in
      island.island.localizedCaseInsensitiveContains(searchQuery)
        || island.atoll.fullName.localizedCaseInsensitiveContains(searchQuery)
        || island.atoll.rawValue.localizedCaseInsensitiveContains(searchQuery)
        || island.name.localizedCaseInsensitiveContains(searchQuery)
    }
  }

  private var searchQuery: String {
    searchText.trimmingCharacters(in: .whitespacesAndNewlines)
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
