import SwiftUI

/// Directional sky lighting with gently drifting, textured clouds.
struct SunriseSky: View {
  var body: some View {
    LinearGradient(
      stops: [
        .init(color: Color(red: 0.19, green: 0.33, blue: 0.54), location: 0),
        .init(color: Color(red: 0.34, green: 0.45, blue: 0.61), location: 0.42),
        .init(color: Color(red: 0.51, green: 0.51, blue: 0.59), location: 0.74),
        .init(color: Color(red: 0.68, green: 0.55, blue: 0.49), location: 1),
      ],
      startPoint: .top,
      endPoint: .bottom
    )
    .overlay {
      DaytimeClouds(style: .sunrise)
    }
    .overlay {
      // The light source sits below the card: only its broad scattered glow shows.
      EllipticalGradient(
        stops: [
          .init(color: Color(red: 1.0, green: 0.79, blue: 0.52).opacity(0.48), location: 0),
          .init(color: Color(red: 0.98, green: 0.73, blue: 0.51).opacity(0.32), location: 0.24),
          .init(color: Color(red: 0.92, green: 0.66, blue: 0.55).opacity(0.12), location: 0.60),
          .init(color: .clear, location: 1),
        ],
        center: UnitPoint(x: 0.72, y: 1.16),
        startRadiusFraction: 0,
        endRadiusFraction: 0.86
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}

struct DaytimeClouds: View {
  enum Style {
    case sunrise, asr, maghrib
  }

  let style: Style

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @State private var renderSeed = UInt64.random(in: 1...UInt64.max)
  @State private var isOnScreen = false
  @State private var accumulatedTime: TimeInterval = 0
  @State private var startedAt: Date?

  private var isAfternoon: Bool { style == .asr }

  private var seed: UInt64 {
    let salt: UInt64 = switch style {
    case .sunrise: 0
    case .asr: 0xA5_12_34_89
    case .maghrib: 0xAA_67_21_43
    }
    return renderSeed ^ salt
  }

  private var bankTint: Color {
    isAfternoon
      ? Color(red: 1.0, green: 0.98, blue: 0.94)
      : Color(red: 1.0, green: 0.96, blue: 0.92)
  }

  private var shouldAnimate: Bool {
    isOnScreen && scenePhase == .active && !reduceMotion
  }

  var body: some View {
    TimelineView(.animation(minimumInterval: 1.0 / 15.0, paused: !shouldAnimate)) { timeline in
      GeometryReader { proxy in
        cloudField(in: proxy.size, elapsed: elapsedTime(at: timeline.date))
      }
    }
    .onAppear {
      isOnScreen = true
      updateMotionClock()
    }
    .onScrollVisibilityChange(threshold: 0.01) { visible in
      isOnScreen = visible
      updateMotionClock()
    }
    .onChange(of: shouldAnimate) {
      updateMotionClock()
    }
    .onDisappear {
      isOnScreen = false
      updateMotionClock()
    }
  }

  private func elapsedTime(at date: Date) -> TimeInterval {
    accumulatedTime + (startedAt.map { max(0, date.timeIntervalSince($0)) } ?? 0)
  }

  private func updateMotionClock() {
    if shouldAnimate {
      if startedAt == nil { startedAt = .now }
    } else if let startedAt {
      accumulatedTime += max(0, Date.now.timeIntervalSince(startedAt))
      self.startedAt = nil
    }
  }

  @ViewBuilder
  private func cloudField(in size: CGSize, elapsed: TimeInterval) -> some View {
    if style == .maghrib {
      twilightWisps(width: size.width, elapsed: elapsed)
    } else {
      daytimeCloudField(in: size, elapsed: elapsed)
    }
  }

  private func twilightWisps(width: CGFloat, elapsed: TimeInterval) -> some View {
    ZStack {
      // A faint, flat layer catches the remaining sunset light. Fixed point
      // heights keep this sky stable when the countdown expands the card.
      cloud(
        .layer, slot: 6, elapsed: elapsed, width: min(width * 0.82, 390),
        x: width * 0.66, y: 32, opacity: 0.14,
        tint: Color(red: 1.0, green: 0.88, blue: 0.85)
      )

      if horizontalSizeClass == .regular {
        let wideBlend = min(max((width - 500) / 400, 0), 1)
        cloud(
          .layer, slot: 7, elapsed: elapsed, width: 320,
          x: width * 0.24, y: 45, opacity: 0.085 * Double(wideBlend),
          tint: Color(red: 0.93, green: 0.90, blue: 1.0)
        )
      }
    }
  }

  private func daytimeCloudField(in size: CGSize, elapsed: TimeInterval) -> some View {
    ZStack {
      let width = size.width
      // Narrow iPad windows blend back into the accepted phone composition.
      let wideBlend: CGFloat = horizontalSizeClass == .regular
        ? min(max((width - 500) / 260, 0), 1) : 0
      let landscapeBlend = min(max((width - 780) / 300, 0), 1) * wideBlend
      let composition = SunriseCloudVariation(seed: seed, slot: 100, variantCount: 1)
      // Unequal groups share an anchor, rather than filling evenly spaced slots.
      let mainAnchor = width * (isAfternoon ? 0.31 : 0.66)
        + composition.x * 3
      let secondaryAnchor = width * (isAfternoon ? 0.79 : 0.17)
        - composition.x * 2
      let shoulder: CGFloat = isAfternoon ? -1 : 1
      // Expansion reveals more sky below the same cloud field on every device.
      let fieldHeight: CGFloat = 85
      let layerX: CGFloat = isAfternoon ? 0.80 : 0.23
      let bankX: CGFloat = isAfternoon ? 0.43 : 0.66

      if horizontalSizeClass == .regular {
        // The quieter group overlaps at different heights and clips into an edge.
        cloud(
          .bank, slot: 0, elapsed: elapsed, width: 350,
          x: secondaryAnchor, y: fieldHeight * 0.28,
          opacity: 0.22 * Double(wideBlend),
          tint: Color(red: 0.96, green: 0.97, blue: 1.0)
        )
        cloud(
          .layer, slot: 1, elapsed: elapsed, width: 410,
          x: secondaryAnchor - shoulder * 105, y: fieldHeight * 0.69,
          opacity: 0.19 * Double(wideBlend),
          tint: bankTint
        )

        // Extra coverage fades in with available width; texture detail never stretches.
        cloud(
          .layer, slot: 4, elapsed: elapsed, width: 430,
          x: mainAnchor - shoulder * 175, y: fieldHeight * 0.56,
          opacity: 0.16 * Double(landscapeBlend),
          tint: Color(red: 0.96, green: 0.97, blue: 1.0)
        )
        cloud(
          .layer, slot: 5, elapsed: elapsed, width: 340,
          x: width * (isAfternoon ? 0.03 : 0.97), y: fieldHeight * 0.46,
          opacity: 0.14 * Double(landscapeBlend),
          tint: bankTint
        )
      }

      cloud(
        .layer, slot: 2, elapsed: elapsed, width: min(width * 0.72, 360),
        x: width * layerX + (mainAnchor + shoulder * 100 - width * layerX) * wideBlend,
        y: fieldHeight * 0.65, opacity: isAfternoon ? 0.22 : 0.24,
        tint: Color(red: 0.96, green: 0.97, blue: 1.0)
      )
      cloud(
        .bank, slot: 3, elapsed: elapsed, width: min(width * 0.90, 460),
        x: width * bankX + (mainAnchor - width * bankX) * wideBlend,
        y: fieldHeight * (isAfternoon ? 0.30 : 0.36), opacity: isAfternoon ? 0.34 : 0.40,
        tint: bankTint
      )
    }
  }

  private func cloud(
    _ type: DaytimeCloudType, slot: UInt64, elapsed: TimeInterval,
    width: CGFloat, x: CGFloat, y: CGFloat,
    opacity: Double, tint: Color
  ) -> some View {
    let variation = SunriseCloudVariation(seed: seed, slot: slot, variantCount: type.variantCount)
    let renderedWidth = width * variation.scale
    // Drift changes by cloud family, while the selected PNG stays fixed for this seed.
    let drift = type.driftDistance
      * CGFloat(sin(elapsed * variation.speed * 2 * .pi / type.driftPeriod))

    return Image(type.assetName(variant: variation.variantIndex))
      .renderingMode(.original)
      .resizable()
      .interpolation(.high)
      .aspectRatio(2048.0 / 768.0, contentMode: .fit)
      // Fix both dimensions so aspect-fit never uses the changing card height.
      .frame(width: renderedWidth, height: renderedWidth * (768.0 / 2048.0))
      .colorMultiply(tint)
      .opacity(opacity * variation.opacity)
      .position(x: x + variation.x, y: y + variation.y)
      .offset(x: drift)
  }

}

enum DaytimeCloudType {
  case layer
  case bank

  private var assets: [String] {
    switch self {
    case .layer:
      ["AtmosphereCloudLayer", "AtmosphereCloudLayer3", "AtmosphereCloudLayer4"]
    case .bank:
      ["AtmosphereCloudBank", "AtmosphereCloudBank2", "AtmosphereCloudBank3", "AtmosphereCloudBank4"]
    }
  }

  var variantCount: Int { assets.count }

  func assetName(variant: Int) -> String {
    assets[variant]
  }

  var driftDistance: CGFloat {
    switch self {
    case .layer:
      22
    case .bank:
      14
    }
  }

  var driftPeriod: TimeInterval {
    switch self {
    case .layer:
      190
    case .bank:
      270
    }
  }

}

private struct SunriseCloudVariation {
  let scale: CGFloat
  let x: CGFloat
  let y: CGFloat
  let opacity: Double
  let speed: Double
  let variantIndex: Int

  init(seed: UInt64, slot: UInt64, variantCount: Int) {
    // Each slot has its own stream, so adding peripheral clouds or changing
    // size class never changes the variations of the two primary clouds.
    var state = seed &+ (slot &* 0x9E37_79B9_7F4A_7C15)
    func sample(_ lower: Double, _ upper: Double) -> Double {
      state &+= 0x9E37_79B9_7F4A_7C15
      var value = state
      value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
      value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
      value ^= value >> 31
      let unit = Double(value >> 11) / 9_007_199_254_740_992
      return lower + (upper - lower) * unit
    }

    scale = CGFloat(sample(0.90, 1.0))
    x = CGFloat(sample(-14, 14))
    y = CGFloat(sample(-3, 3))
    opacity = sample(0.90, 1.05)
    // Preserve the existing sample sequence for texture selection and drift.
    _ = sample(0, 1)
    speed = sample(0.88, 1.12)
    variantIndex = min(Int(sample(0, Double(variantCount))), variantCount - 1)
  }
}
