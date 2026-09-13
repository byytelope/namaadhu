import SwiftUI

struct SystemMediumView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      if let current = entry.currentPrayer,
        let upcoming = entry.upcomingPrayer,
        let interval = entry.progressInterval,
        let selectedIslandName = entry.selectedIslandName,
        let prayerTimes = entry.prayerTimes
      {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 6) {
            Text(upcoming.displayName)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))

            Text(timerInterval: interval, countsDown: true, showsHours: true)
              .monospacedDigit()
              .lineLimit(1)
              .foregroundStyle(Color.primary.mix(with: .accent, by: 0.5))
              .minimumScaleFactor(0.65)
              .font(.system(size: 40, weight: .bold))
          }
          Spacer()

          VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
              Image(systemName: "location.fill")
              Text(selectedIslandName)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            .font(.footnote)
            .bold()
            .foregroundStyle(.accent)

            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(.accent.mix(with: .secondary, by: 0.5))
          }
        }

        HStack(spacing: 4) {
          ForEach(prayerTimes.orderedDates()) { occurrence in
            VStack(spacing: 4) {
              Text(occurrence.prayer.displayName)
                .font(.caption)
                .bold()
                .foregroundStyle(
                  current == occurrence.prayer
                    ? .accent.mix(with: .cream, by: 0.9)
                    : .accent.mix(with: .secondary, by: 0.5)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)

              Image(systemName: occurrence.prayer.sfSymbol)
                .font(.subheadline)
                .foregroundStyle(
                  current == occurrence.prayer
                    ? .cream
                    : .accent.mix(with: .secondary, by: 0.3)
                )
                .padding(.vertical, 3)

              Text(
                occurrence.date
                  .formatted(
                    .dateTime
                      .hour(.twoDigits(amPM: .omitted))
                      .minute(.twoDigits)
                  )
              )
              .font(.caption)
              .bold()
              .foregroundStyle(
                current == occurrence.prayer
                  ? .accent.mix(with: .cream, by: 0.9)
                  : .accent.mix(with: .secondary, by: 0.5)
              )
            }
            .symbolVariant(.fill)
            .symbolRenderingMode(.hierarchical)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background {
              ConcentricRectangle()
                .fill(
                  current == occurrence.prayer
                    ? .accent.mix(with: .secondary, by: 0.5).opacity(0.5)
                    : .accent.mix(with: .secondary, by: 0.5).opacity(0.1)
                )
            }
          }
        }
      } else {
        Text("No upcoming prayer")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxHeight: .infinity, alignment: .center)
    .fontDesign(.rounded)
  }
}
