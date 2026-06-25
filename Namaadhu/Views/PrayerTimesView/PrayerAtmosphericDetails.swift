import SwiftUI

struct PrayerAtmosphericDetails: View {
  let prayer: Prayer

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Canvas { context, size in
          drawClouds(in: &context, size: size)
          drawStars(in: &context, size: size)
        }

        if prayer == .dhuhr {
          DhuhrSun()
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
        .init(x: 0.15, y: 0.22, size: 1.6, opacity: 0.32),
        .init(x: 0.33, y: 0.12, size: 1.2, opacity: 0.25),
        .init(x: 0.57, y: 0.28, size: 1.7, opacity: 0.28),
        .init(x: 0.82, y: 0.18, size: 1.2, opacity: 0.30),
      ]
    case .maghrib:
      [
        .init(x: 0.18, y: 0.18, size: 1.2, opacity: 0.22),
        .init(x: 0.72, y: 0.14, size: 1.5, opacity: 0.24),
        .init(x: 0.88, y: 0.30, size: 1.1, opacity: 0.22),
      ]
    case .isha:
      [
        .init(x: 0.10, y: 0.24, size: 1.5, opacity: 0.52),
        .init(x: 0.24, y: 0.12, size: 2.1, opacity: 0.65),
        .init(x: 0.38, y: 0.34, size: 1.2, opacity: 0.44),
        .init(x: 0.54, y: 0.16, size: 1.6, opacity: 0.55),
        .init(x: 0.69, y: 0.28, size: 2.0, opacity: 0.62),
        .init(x: 0.84, y: 0.13, size: 1.2, opacity: 0.48),
        .init(x: 0.92, y: 0.40, size: 1.7, opacity: 0.52),
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

  private func drawClouds(
    in context: inout GraphicsContext,
    size: CGSize
  ) {
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

        layer.fill(path, with: .color(.white.opacity(cloud.opacity)))
      }
    }
  }

  private func drawStars(
    in context: inout GraphicsContext,
    size: CGSize
  ) {
    for star in stars {
      let rect = CGRect(
        x: (size.width * star.x) - (star.size / 2),
        y: (size.height * star.y) - (star.size / 2),
        width: star.size,
        height: star.size
      )

      context.fill(
        Path(ellipseIn: rect),
        with: .color(.white.opacity(star.opacity))
      )
    }
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
