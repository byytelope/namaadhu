import SwiftUI

struct SystemSmallView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      if let upcoming = entry.upcomingPrayer,
        let upcomingDate = entry.upcomingPrayerDate,
        let selectedIslandName = entry.selectedIslandName
      {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text("UPCOMING")
              .font(.caption2)
              .bold()
              .foregroundStyle(.accent)

            Text(upcoming.displayName)
              .font(.headline)
              .bold()

            Text(
              .currentDate,
              format: .timer(
                countingDownIn: entry.date..<upcomingDate,
                showsHours: true,
                maxPrecision: .seconds(1)
              )
            )
            .font(.caption2)
            .bold()
            .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))
          }
          Spacer()
        }

        Spacer()

        Text(
          .currentDate,
          format: .timer(
            countingDownIn: entry.date..<upcomingDate,
            showsHours: true,
            maxPrecision: .seconds(1)
          )
        )
          .font(.system(size: 32, weight: .semibold))

        HStack(spacing: 4) {
          Text(selectedIslandName)
          Image(systemName: "location.fill")
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}
