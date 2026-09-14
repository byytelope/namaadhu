import SwiftUI

struct AsrSky: View {
  var body: some View {
    LinearGradient(
      stops: [
        .init(color: Color(red: 0.13, green: 0.28, blue: 0.46), location: 0),
        .init(color: Color(red: 0.28, green: 0.42, blue: 0.54), location: 0.45),
        .init(color: Color(red: 0.47, green: 0.52, blue: 0.55), location: 0.76),
        .init(color: Color(red: 0.64, green: 0.60, blue: 0.52), location: 1),
      ],
      startPoint: .top,
      endPoint: .bottom
    )
    .overlay {
      DaytimeClouds(style: .asr)
    }
    .overlay {
      // Afternoon light enters from above/right; the sun itself is out of frame.
      EllipticalGradient(
        stops: [
          .init(color: Color(red: 1.0, green: 0.94, blue: 0.79).opacity(0.16), location: 0),
          .init(color: Color(red: 0.97, green: 0.93, blue: 0.85).opacity(0.07), location: 0.45),
          .init(color: .clear, location: 1),
        ],
        center: UnitPoint(x: 0.92, y: -0.18),
        startRadiusFraction: 0,
        endRadiusFraction: 0.95
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
