import CoreMotion
import SwiftUI

struct DhuhrSun: View {
  var clouds: [DhuhrCloudSprite] = []

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @State private var breathes = false
  @State private var gyroFlareOffset = CGSize.zero
  @State private var gyroscopeBaselineRoll: Double?
  @State private var gyroscopeBaselinePitch: Double?
  @State private var motionManager = CMMotionManager()

  private let rayAngles = [12.0, 58.0, 104.0, 166.0]

  var body: some View {
    GeometryReader { proxy in
      let sunPosition = CGPoint(
        x: proxy.size.width * 0.72,
        y: proxy.size.height * 0.18
      )
      let motionEnabled = breathes && !reduceMotion
      let rayRotation = reduceMotion ? 0 : (breathes ? 1.8 : -1.1)

      ZStack {
        ZStack {
          Circle()
            .fill(
              RadialGradient(
                colors: [
                  Color(
                    .sRGBLinear,
                    red: 1.02,
                    green: 1.08,
                    blue: 1.12,
                    opacity: 0.24
                  ),
                  Color(
                    .sRGBLinear,
                    red: 0.82,
                    green: 0.94,
                    blue: 1.00,
                    opacity: 0.11
                  ),
                  Color(
                    .sRGBLinear,
                    white: 0.92,
                    opacity: 0.025
                  ),
                  .clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 96
              )
            )
            .frame(width: 192, height: 192)
            .blur(radius: 11)
            .scaleEffect(motionEnabled ? 1.03 : 0.98)
            .opacity(motionEnabled ? 0.94 : 0.78)
            .position(sunPosition)

          Circle()
            .fill(
              RadialGradient(
                colors: [
                  Color(
                    .sRGBLinear,
                    red: 1.30,
                    green: 1.22,
                    blue: 0.98,
                    opacity: 0.30
                  ),
                  Color(
                    .sRGBLinear,
                    red: 1.00,
                    green: 1.02,
                    blue: 0.92,
                    opacity: 0.09
                  ),
                  .clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 60
              )
            )
            .frame(width: 120, height: 120)
            .blur(radius: 3)
            .scaleEffect(motionEnabled ? 1.04 : 0.98)
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
              .frame(width: 98, height: 0.9)
              .blur(radius: 1.6)
              .opacity(motionEnabled ? 0.44 : 0.24)
              .rotationEffect(.degrees(angle + rayRotation))
              .position(sunPosition)
          }

          Circle()
            .fill(
              RadialGradient(
                colors: [
                  Color(.sRGBLinear, red: 4.0, green: 3.35, blue: 1.95),
                  Color(.sRGBLinear, red: 2.25, green: 1.82, blue: 0.78),
                  Color(
                    .sRGBLinear,
                    white: 1.20,
                    opacity: 0.18
                  ),
                  .clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 26
              )
            )
            .frame(width: 52, height: 52)
            .shadow(color: .white.opacity(0.9), radius: 11)
            .scaleEffect(motionEnabled ? 1.02 : 0.99)
            .opacity(motionEnabled ? 1 : 0.96)
            .position(sunPosition)
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .modifier(DhuhrCloudOcclusion(clouds: clouds, sun: sunPosition))

        ZStack {
          flareArtifact(
            diameter: 20,
            widthScale: 1.65,
            blurRadius: 1.8,
            opacity: 0.11,
            color: Color(red: 0.68, green: 0.90, blue: 1.00),
            x: 0.50,
            y: 0.52,
            in: proxy.size
          )
          .opacity(motionEnabled ? 1 : 0.72)
          .offset(
            x: (motionEnabled ? -1.2 : 0.5) + gyroFlareOffset.width,
            y: (motionEnabled ? 0.8 : -0.4) + gyroFlareOffset.height
          )

          flareArtifact(
            diameter: 12,
            widthScale: 1.20,
            blurRadius: 1.05,
            opacity: 0.14,
            color: Color(red: 0.84, green: 0.74, blue: 1.00),
            x: 0.37,
            y: 0.68,
            in: proxy.size
          )
          .opacity(motionEnabled ? 1 : 0.68)
          .offset(
            x: (motionEnabled ? -0.8 : 0.4) + (gyroFlareOffset.width * 0.65),
            y: (motionEnabled ? 0.5 : -0.3) + (gyroFlareOffset.height * 0.65)
          )

          flareArtifact(
            diameter: 7,
            widthScale: 0.88,
            blurRadius: 0.55,
            opacity: 0.18,
            color: .white,
            x: 0.29,
            y: 0.78,
            in: proxy.size
          )
          .opacity(motionEnabled ? 1 : 0.74)
          .offset(
            x: (motionEnabled ? -0.5 : 0.3) + (gyroFlareOffset.width * 0.35),
            y: (motionEnabled ? 0.3 : -0.2) + (gyroFlareOffset.height * 0.35)
          )
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .modifier(DhuhrCloudOcclusion(clouds: clouds, sun: sunPosition, isFlare: true))
      }
      .blendMode(.plusLighter)
    }
    .onAppear {
      updateMotion()
      updateGyroscope()
    }
    .onChange(of: reduceMotion) {
      updateMotion()
      updateGyroscope()
    }
    .onChange(of: scenePhase) {
      updateGyroscope()
    }
    .onDisappear(perform: stopGyroscope)
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

  private func updateGyroscope() {
    stopGyroscope()

    guard
      !reduceMotion,
      scenePhase == .active,
      motionManager.isGyroAvailable,
      motionManager.isDeviceMotionAvailable
    else {
      return
    }

    motionManager.deviceMotionUpdateInterval = 1.0 / 20.0
    motionManager.startDeviceMotionUpdates(
      using: .xArbitraryCorrectedZVertical,
      to: .main
    ) { motion, _ in
      guard scenePhase == .active else { return }
      guard let motion else { return }
      guard
        let gyroscopeBaselineRoll,
        let gyroscopeBaselinePitch
      else {
        gyroscopeBaselineRoll = motion.attitude.roll
        gyroscopeBaselinePitch = motion.attitude.pitch
        return
      }

      let relativeRoll = motion.attitude.roll - gyroscopeBaselineRoll
      let relativePitch = motion.attitude.pitch - gyroscopeBaselinePitch
      let targetOffset = CGSize(
        width: CGFloat(min(max(relativeRoll * 28, -14), 14)),
        height: CGFloat(min(max(relativePitch * 20, -10), 10))
      )
      let smoothedOffset = CGSize(
        width: gyroFlareOffset.width + ((targetOffset.width - gyroFlareOffset.width) * 0.2),
        height: gyroFlareOffset.height
          + ((targetOffset.height - gyroFlareOffset.height) * 0.2)
      )

      guard
        abs(smoothedOffset.width - gyroFlareOffset.width) > 0.01
          || abs(smoothedOffset.height - gyroFlareOffset.height) > 0.01
      else {
        return
      }

      gyroFlareOffset = smoothedOffset
    }
  }

  private func stopGyroscope() {
    motionManager.stopDeviceMotionUpdates()

    var transaction = Transaction()
    transaction.disablesAnimations = true

    withTransaction(transaction) {
      gyroFlareOffset = .zero
      gyroscopeBaselineRoll = nil
      gyroscopeBaselinePitch = nil
    }
  }

  private func flareArtifact(
    diameter: CGFloat,
    widthScale: CGFloat,
    blurRadius: CGFloat,
    opacity: Double,
    color: Color,
    x: CGFloat,
    y: CGFloat,
    in size: CGSize
  ) -> some View {
    Ellipse()
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
      .frame(width: diameter * widthScale, height: diameter)
      .blur(radius: blurRadius)
      .position(x: size.width * x, y: size.height * y)
  }
}
