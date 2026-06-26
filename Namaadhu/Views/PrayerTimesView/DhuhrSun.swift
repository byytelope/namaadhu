import SwiftUI

struct DhuhrSun: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var breathes = false

  private let rayAngles = [0.0, 45.0, 90.0, 135.0]

  var body: some View {
    GeometryReader { proxy in
      let sunPosition = CGPoint(
        x: proxy.size.width * 0.72,
        y: proxy.size.height * 0.18
      )
      let motionEnabled = breathes && !reduceMotion
      let rayRotation = reduceMotion ? 0 : (breathes ? 1.8 : -1.1)

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
          .scaleEffect(motionEnabled ? 1.03 : 0.98)
          .opacity(motionEnabled ? 1 : 0.86)
          .position(sunPosition)

        ForEach(rayAngles, id: \.self) { angle in
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
            .opacity(motionEnabled ? 1 : 0.68)
            .rotationEffect(.degrees(angle + rayRotation))
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
          .scaleEffect(motionEnabled ? 1.015 : 0.99)
          .opacity(motionEnabled ? 1 : 0.94)
          .position(sunPosition)

        flareArtifact(
          diameter: 17,
          opacity: 0.13,
          color: Color(red: 0.68, green: 0.90, blue: 1.00),
          x: 0.50,
          y: 0.52,
          in: proxy.size
        )
        .opacity(motionEnabled ? 1 : 0.72)
        .offset(
          x: motionEnabled ? -1.2 : 0.5,
          y: motionEnabled ? 0.8 : -0.4
        )

        flareArtifact(
          diameter: 9,
          opacity: 0.16,
          color: Color(red: 0.84, green: 0.74, blue: 1.00),
          x: 0.37,
          y: 0.68,
          in: proxy.size
        )
        .opacity(motionEnabled ? 1 : 0.68)
        .offset(
          x: motionEnabled ? -0.8 : 0.4,
          y: motionEnabled ? 0.5 : -0.3
        )

        flareArtifact(
          diameter: 5,
          opacity: 0.22,
          color: .white,
          x: 0.29,
          y: 0.78,
          in: proxy.size
        )
        .opacity(motionEnabled ? 1 : 0.74)
        .offset(
          x: motionEnabled ? -0.5 : 0.3,
          y: motionEnabled ? 0.3 : -0.2
        )
      }
      .blendMode(.plusLighter)
    }
    .onAppear(perform: updateMotion)
    .onChange(of: reduceMotion) {
      updateMotion()
    }
    .drawingGroup(opaque: false, colorMode: .extendedLinear)
    .allowedDynamicRange(.constrainedHigh)
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func updateMotion() {
    if reduceMotion {
      var transaction = Transaction()
      transaction.disablesAnimations = true

      withTransaction(transaction) {
        breathes = false
      }
    } else {
      withAnimation(.easeInOut(duration: 7.5).repeatForever(autoreverses: true)) {
        breathes = true
      }
    }
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
