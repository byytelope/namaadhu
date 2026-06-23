import SwiftUI
import Toasts

struct PrayerTimeRow: View {
  var prayer: Prayer
  var date: Date
  var isUpcoming: Bool = false

  @Environment(\.timerManager) private var timerManager
  @Environment(\.presentToast) private var presentToast

  @State private var alertEnabled = false

  var body: some View {
    HStack(spacing: 24) {
      HStack(spacing: 14) {
        Image(systemName: prayer.sfSymbol)
          .frame(width: 24, height: 24)
          .font(.system(size: 22, weight: .semibold, design: .rounded))

        Text(prayer.displayName)
          .font(.system(size: 24, weight: .semibold, design: .rounded))
      }

      Spacer(minLength: 16)

      VStack(alignment: .trailing, spacing: 8) {
        Text(
          DateFormatter.localizedString(
            from: date,
            dateStyle: .none,
            timeStyle: .short
          )
        )
        .font(.system(size: 24, weight: .semibold, design: .rounded))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glassEffect(isUpcoming ? .clear.interactive() : .identity)

        if isUpcoming {
          HStack(spacing: 4) {
            Image(systemName: "arrow.right.circle")
            Text(timerManager.timeRemaining.formattedTime())
              .font(.system(size: 16, weight: .semibold, design: .rounded))
              .monospacedDigit()
              .contentTransition(.numericText())
              .animation(.default, value: timerManager.timeRemaining)
          }
          .padding(.leading, 6)
          .padding(.trailing, 10)
          .padding(.vertical, 5)
          .background(.white.opacity(0.18), in: Capsule())
        }
      }
    }
    .foregroundStyle(.white)
    .symbolVariant(.fill)
    .symbolRenderingMode(.hierarchical)
    .padding(20)
    .frame(maxWidth: .infinity, minHeight: 80)
    .background {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(backgroundGradient)
        .overlay {
          AtmosphericDetails(prayer: prayer)
            .clipShape(
              RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
        }
        .overlay {
          RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
              LinearGradient(
                colors: [
                  .black.opacity(0.08),
                  .clear,
                  .white.opacity(0.10),
                ],
                startPoint: .top,
                endPoint: .bottom
              )
            )
        }
        .shadow(
          color: gradientShadowColor.opacity(0.18),
          radius: 12,
          y: 6
        )
    }
    .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    .accessibilityElement(children: .combine)
    .listRowInsets(EdgeInsets())
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
  }

  private var backgroundGradient: LinearGradient {
    LinearGradient(
      gradient: Gradient(stops: gradientStops),
      startPoint: .top,
      endPoint: .bottom
    )
  }

  private var gradientStops: [Gradient.Stop] {
    switch prayer {
    case .fajr:
      [
        .init(color: Color(red: 0.07, green: 0.12, blue: 0.32), location: 0),
        .init(color: Color(red: 0.20, green: 0.24, blue: 0.48), location: 0.42),
        .init(color: Color(red: 0.47, green: 0.36, blue: 0.52), location: 0.72),
        .init(color: Color(red: 0.67, green: 0.50, blue: 0.53), location: 1),
      ]
    case .sunrise:
      [
        .init(color: Color(red: 0.20, green: 0.39, blue: 0.67), location: 0),
        .init(color: Color(red: 0.42, green: 0.53, blue: 0.72), location: 0.42),
        .init(color: Color(red: 0.78, green: 0.55, blue: 0.52), location: 0.72),
        .init(color: Color(red: 0.88, green: 0.68, blue: 0.48), location: 1),
      ]
    case .dhuhr:
      [
        .init(color: Color(red: 0.10, green: 0.34, blue: 0.61), location: 0),
        .init(color: Color(red: 0.24, green: 0.46, blue: 0.68), location: 0.48),
        .init(color: Color(red: 0.49, green: 0.61, blue: 0.72), location: 0.76),
        .init(color: Color(red: 0.65, green: 0.69, blue: 0.72), location: 1),
      ]
    case .asr:
      [
        .init(color: Color(red: 0.13, green: 0.30, blue: 0.52), location: 0),
        .init(color: Color(red: 0.32, green: 0.46, blue: 0.60), location: 0.46),
        .init(color: Color(red: 0.59, green: 0.58, blue: 0.57), location: 0.75),
        .init(color: Color(red: 0.73, green: 0.63, blue: 0.54), location: 1),
      ]
    case .maghrib:
      [
        .init(color: Color(red: 0.08, green: 0.10, blue: 0.28), location: 0),
        .init(color: Color(red: 0.25, green: 0.20, blue: 0.43), location: 0.42),
        .init(color: Color(red: 0.51, green: 0.31, blue: 0.45), location: 0.72),
        .init(color: Color(red: 0.70, green: 0.47, blue: 0.47), location: 1),
      ]
    case .isha:
      [
        .init(color: Color(red: 0.01, green: 0.02, blue: 0.06), location: 0),
        .init(color: Color(red: 0.03, green: 0.06, blue: 0.14), location: 0.46),
        .init(color: Color(red: 0.08, green: 0.13, blue: 0.23), location: 0.76),
        .init(color: Color(red: 0.13, green: 0.18, blue: 0.28), location: 1),
      ]
    }
  }

  private var gradientShadowColor: Color {
    gradientStops.first?.color ?? .black
  }
}

private struct AtmosphericDetails: View {
  let prayer: Prayer

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Canvas { context, size in
          for cloud in clouds {
            let width = size.width * cloud.width
            let height = width * 0.24
            let centerX = size.width * cloud.x
            let centerY = size.height * cloud.y

            context.drawLayer { layer in
              layer.addFilter(.blur(radius: 5))

              var path = Path()
              path.addEllipse(
                in: CGRect(
                  x: centerX - (width * 0.50),
                  y: centerY - (height * 0.05),
                  width: width,
                  height: height * 0.55
                )
              )
              path.addEllipse(
                in: CGRect(
                  x: centerX - (width * 0.28),
                  y: centerY - (height * 0.48),
                  width: width * 0.40,
                  height: height
                )
              )
              path.addEllipse(
                in: CGRect(
                  x: centerX,
                  y: centerY - (height * 0.34),
                  width: width * 0.32,
                  height: height * 0.78
                )
              )

              layer.fill(
                path,
                with: .color(.white.opacity(cloud.opacity))
              )
            }
          }

          for star in stars {
            let diameter = star.size
            let rect = CGRect(
              x: (size.width * star.x) - (diameter / 2),
              y: (size.height * star.y) - (diameter / 2),
              width: diameter,
              height: diameter
            )

            context.fill(
              Path(ellipseIn: rect),
              with: .color(.white.opacity(star.opacity))
            )
          }
        }

      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private var stars: [Star] {
    switch prayer {
    case .fajr:
      [
        .init(x: 0.15, y: 0.22, size: 1.3, opacity: 0.22),
        .init(x: 0.33, y: 0.12, size: 1.0, opacity: 0.16),
        .init(x: 0.57, y: 0.28, size: 1.4, opacity: 0.18),
        .init(x: 0.82, y: 0.18, size: 1.0, opacity: 0.20),
      ]
    case .maghrib:
      [
        .init(x: 0.18, y: 0.18, size: 1.0, opacity: 0.12),
        .init(x: 0.72, y: 0.14, size: 1.2, opacity: 0.14),
        .init(x: 0.88, y: 0.30, size: 0.9, opacity: 0.12),
      ]
    case .isha:
      [
        .init(x: 0.10, y: 0.24, size: 1.2, opacity: 0.42),
        .init(x: 0.24, y: 0.12, size: 1.8, opacity: 0.55),
        .init(x: 0.38, y: 0.34, size: 1.0, opacity: 0.34),
        .init(x: 0.54, y: 0.16, size: 1.3, opacity: 0.45),
        .init(x: 0.69, y: 0.28, size: 1.7, opacity: 0.52),
        .init(x: 0.84, y: 0.13, size: 1.0, opacity: 0.38),
        .init(x: 0.92, y: 0.40, size: 1.4, opacity: 0.42),
      ]
    case .sunrise, .dhuhr, .asr:
      []
    }
  }

  private var clouds: [Cloud] {
    switch prayer {
    case .sunrise:
      [
        .init(x: 0.64, y: 0.24, width: 0.30, opacity: 0.12),
        .init(x: 0.88, y: 0.58, width: 0.18, opacity: 0.08),
      ]
    case .asr:
      [
        .init(x: 0.25, y: 0.24, width: 0.24, opacity: 0.09),
        .init(x: 0.72, y: 0.48, width: 0.32, opacity: 0.12),
      ]
    case .fajr, .dhuhr, .maghrib, .isha:
      []
    }
  }

  private struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
  }

  private struct Cloud {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let opacity: Double
  }

}
