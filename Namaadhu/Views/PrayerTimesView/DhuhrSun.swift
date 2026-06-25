import SwiftUI

struct DhuhrSun: View {
  var body: some View {
    GeometryReader { proxy in
      let sunPosition = CGPoint(
        x: proxy.size.width * 0.72,
        y: proxy.size.height * 0.18
      )

      ZStack {
        Circle()
          .fill(
            RadialGradient(
              colors: [
                Color(
                  .sRGBLinear,
                  red: 1.35,
                  green: 1.55,
                  blue: 1.75,
                  opacity: 0.38
                ),
                Color(
                  .sRGBLinear,
                  red: 0.78,
                  green: 0.92,
                  blue: 1.00,
                  opacity: 0.20
                ),
                .clear,
              ],
              center: .center,
              startRadius: 0,
              endRadius: 72
            )
          )
          .frame(width: 144, height: 144)
          .blur(radius: 5)
          .position(sunPosition)

        ForEach([0.0, 45.0, 90.0, 135.0], id: \.self) { angle in
          Capsule()
            .fill(
              LinearGradient(
                colors: [
                  .clear,
                  Color(
                    .sRGBLinear,
                    white: 1.35,
                    opacity: 0.18
                  ),
                  .clear,
                ],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(
              width: 112,
              height: angle == 0 || angle == 90 ? 1.4 : 0.8
            )
            .blur(radius: 0.7)
            .rotationEffect(.degrees(angle))
            .position(sunPosition)
        }

        Circle()
          .fill(
            RadialGradient(
              colors: [
                Color(
                  .sRGBLinear,
                  red: 3.20,
                  green: 2.70,
                  blue: 1.55
                ),
                Color(
                  .sRGBLinear,
                  red: 2.10,
                  green: 1.70,
                  blue: 0.72
                ),
                Color(
                  .sRGBLinear,
                  white: 1.30,
                  opacity: 0.22
                ),
                .clear,
              ],
              center: .center,
              startRadius: 0,
              endRadius: 19
            )
          )
          .frame(width: 38, height: 38)
          .shadow(color: .white.opacity(0.9), radius: 8)
          .position(sunPosition)

        flareArtifact(
          diameter: 17,
          opacity: 0.13,
          color: Color(red: 0.68, green: 0.90, blue: 1.00),
          x: 0.50,
          y: 0.52,
          in: proxy.size
        )

        flareArtifact(
          diameter: 9,
          opacity: 0.16,
          color: Color(red: 0.84, green: 0.74, blue: 1.00),
          x: 0.37,
          y: 0.68,
          in: proxy.size
        )

        flareArtifact(
          diameter: 5,
          opacity: 0.22,
          color: .white,
          x: 0.29,
          y: 0.78,
          in: proxy.size
        )
      }
      .blendMode(.plusLighter)
    }
    .drawingGroup(opaque: false, colorMode: .extendedLinear)
    .allowedDynamicRange(.constrainedHigh)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func flareArtifact(
    diameter: CGFloat,
    opacity: Double,
    color: Color,
    x: CGFloat,
    y: CGFloat,
    in size: CGSize
  ) -> some View {
    Circle()
      .fill(
        RadialGradient(
          colors: [
            color.opacity(opacity),
            color.opacity(opacity * 0.25),
            .clear,
          ],
          center: .center,
          startRadius: 0,
          endRadius: diameter / 2
        )
      )
      .overlay {
        Circle()
          .stroke(color.opacity(opacity * 0.55), lineWidth: 0.7)
      }
      .frame(width: diameter, height: diameter)
      .position(x: size.width * x, y: size.height * y)
  }
}
