import CoreLocation
import GRDB
import SwiftUI

struct IslandsView: View {
  @Binding var selectedIsland: Island?

  @Environment(\.databaseService) private var db
  @Environment(\.dismiss) private var dismiss

  @State private var errorMessage: String?
  @State private var isLocating = false
  @State private var islands: [Island] = []
  @State private var expandedAtoll: Atoll?
  @State private var locationService = CurrentLocationService()
  @State private var searchText: String = ""

  init(selectedIsland: Binding<Island?>) {
    self._selectedIsland = selectedIsland
    self._expandedAtoll = State(initialValue: selectedIsland.wrappedValue?.atoll)
  }

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
    ScrollViewReader { scrollProxy in
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(groupedIslands, id: \.atoll) { group in
            AtollDisclosureCard(
              atoll: group.atoll,
              islands: group.islands,
              isExpanded: isExpanded(group.atoll),
              isSearching: isSearching,
              selectedIsland: selectedIsland,
              onToggle: {
                toggleExpansion(for: group.atoll)
              },
              onSelect: selectIsland
            )
          }
        }
        .safeAreaPadding()
      }
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
        await scrollToSelectedIsland(using: scrollProxy)
      }
      .alert("Error", isPresented: isShowingError) {
        Button("OK") { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "")
      }
    }
  }

  private func selectIsland(_ island: Island) {
    selectedIsland = island
    dismiss()
  }

  private func isExpanded(_ atoll: Atoll) -> Bool {
    isSearching || expandedAtoll == atoll
  }

  private func toggleExpansion(for atoll: Atoll) {
    if expandedAtoll == atoll {
      expandedAtoll = nil
    } else {
      expandedAtoll = atoll
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

  private func scrollToSelectedIsland(using scrollProxy: ScrollViewProxy) async {
    guard let selectedIsland else { return }

    expandedAtoll = selectedIsland.atoll
    await Task.yield()

    withAnimation(.snappy) {
      scrollProxy.scrollTo(selectedIsland.id, anchor: .center)
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
      )
        < location.distance(
          from: CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)
        )
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

  private var isSearching: Bool {
    !searchQuery.isEmpty
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

private struct AtollDisclosureCard: View {
  let atoll: Atoll
  let islands: [Island]
  let isExpanded: Bool
  let isSearching: Bool
  let selectedIsland: Island?
  let onToggle: () -> Void
  let onSelect: (Island) -> Void

  var body: some View {
    VStack(spacing: 0) {
      Button {
        if !isSearching {
          withAnimation(.spring) {
            onToggle()
          }
        }
      } label: {
        HStack {
          Text(atoll.fullName)
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)

          Spacer()

          Image(systemName: "chevron.forward")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .rotationEffect(
              isExpanded ? .degrees(90) : .zero
            )
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if isExpanded {
        VStack(spacing: 0) {
          ForEach(islands) { island in
            IslandSelectionRow(
              island: island,
              isSelected: island == selectedIsland,
              showsDivider: island.id != islands.last?.id,
              onSelect: {
                onSelect(island)
              }
            )
            .id(island.id)
          }
        }
        .padding(.top)
        .padding(.leading)
      }
    }
    .padding()
    .background(
      .regularMaterial,
      in: RoundedRectangle(cornerRadius: 20, style: .continuous)
    )
  }
}

private struct IslandSelectionRow: View {
  let island: Island
  let isSelected: Bool
  let showsDivider: Bool
  let onSelect: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Button {
        onSelect()
      } label: {
        HStack {
          Text(island.island)
            .foregroundStyle(.primary)

          Spacer()

          ZStack {
            if isSelected {
              Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Color.accentColor.gradient)
                .transition(.symbolEffect(.drawOn))
            }
          }
          .frame(width: 20, height: 20)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if showsDivider {
        Divider()
      }
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
