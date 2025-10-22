import SwiftUI

struct SystemMediumView: View {
  var entry: Provider.Entry

  private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
  }()

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      if let current = entry.currentPrayer,
        let upcoming = entry.upcomingPrayer,
        let upcomingDate = entry.upcomingPrayerDate,
        let selectedIslandName = entry.selectedIslandName,
        let prayerTimes = entry.prayerTimes
      {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 2) {
            Text(upcoming.displayName)
              .font(.subheadline)
              .bold()
              .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))

            Text(upcomingDate, style: .timer)
              .font(.title)
              .fontWeight(.bold)
          }
          Spacer()

          HStack(alignment: .top, spacing: 4) {
            VStack(alignment: .trailing, spacing: 2) {
              Text(selectedIslandName)
                .font(.footnote)
                .bold()
                .foregroundStyle(.accent)

              Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))
            }

            Image(systemName: "location.fill")
              .font(.footnote)
              .bold()
              .foregroundStyle(.accent)
          }
        }

        Spacer()

        HStack(spacing: 4) {
          ForEach(prayerTimes.orderedDates(), id: \.0) {
            prayer,
            date in
            VStack(spacing: 4) {
              Text(prayer.displayName)
                .font(.caption)
                .bold()
                .foregroundStyle(
                  current == prayer
                    ? .accent.mix(with: .cream, by: 0.9)
                    : .accent.mix(with: .secondary, by: 0.5)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)

              Image(systemName: prayer.sfSymbol)
                .font(.subheadline)
                .foregroundStyle(
                  current == prayer
                    ? .cream
                    : .accent.mix(with: .secondary, by: 0.3)
                )
                .padding(.vertical, 3)

              Text(
                date
                  .formatted(
                    .dateTime
                      .hour(.twoDigits(amPM: .omitted))
                      .minute(.twoDigits)
                  )
              )
              .font(.caption)
              .bold()
              .foregroundStyle(
                current == prayer
                  ? .accent.mix(with: .cream, by: 0.9)
                  : .accent.mix(with: .secondary, by: 0.5)
              )
            }
            .symbolVariant(.fill)
            .symbolRenderingMode(.hierarchical)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background(
              ConcentricRectangle()
                .fill(
                  current == prayer
                    ? .accent.mix(with: .secondary, by: 0.5).opacity(0.5)
                    : .accent.mix(with: .secondary, by: 0.5).opacity(0.1)
                )
            )
          }
        }
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}
