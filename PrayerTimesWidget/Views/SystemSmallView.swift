import SwiftUI

struct SystemSmallView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let upcoming = entry.upcomingPrayer,
        let interval = entry.progressInterval,
        let island = entry.selectedIslandName
      {
        VStack(alignment: .leading) {
          Text("Upcoming")
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(upcoming.displayName)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.accent)
            .fontDesign(.rounded)
        }

        PrayerCountdownContainer(interval: interval)
          .font(.system(size: 32, weight: .bold))
          .padding(.horizontal, -6)

        Spacer(minLength: 0)

        HStack(spacing: 4) {
          Image(systemName: "location.fill")
          Text(island)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.accent)
        .fontDesign(.rounded)
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxHeight: .infinity)
    .fontDesign(.rounded)
  }
}
