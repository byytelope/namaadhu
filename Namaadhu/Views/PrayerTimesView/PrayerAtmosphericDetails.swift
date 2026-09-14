import SwiftUI

struct PrayerAtmosphericDetails: View {
  let prayer: Prayer
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var shootingStarRenderSeed = UInt64.random(in: 1...UInt64.max)

  var body: some View {
    ZStack {
      if prayer == .maghrib {
        DaytimeClouds(style: .maghrib)
      }

      if !stars.isEmpty {
        StarLayer(
          stars: stars,
          horizonFade: horizonStarFade
        )
      }

      if !shootingStars.isEmpty {
        ShootingStarLayer(stars: shootingStars)
      }

      if prayer == .dhuhr {
        DhuhrSky()
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private var stars: [Star] {
    switch prayer {
    case .fajr:
      [
        .init(x: 0.12, y: 0.18, size: 1.2, opacity: 0.24),
        .init(x: 0.29, y: 0.10, size: 0.9, opacity: 0.18),
        .init(x: 0.48, y: 0.27, size: 1.4, opacity: 0.22),
        .init(x: 0.71, y: 0.16, size: 1.0, opacity: 0.20),
        .init(x: 0.89, y: 0.34, size: 0.8, opacity: 0.15),
      ]
    case .maghrib:
      [
        .init(x: 0.12, y: 0.20, size: 1.0, opacity: 0.16),
        .init(x: 0.36, y: 0.13, size: 1.3, opacity: 0.18),
        .init(x: 0.64, y: 0.25, size: 0.9, opacity: 0.14),
        .init(x: 0.88, y: 0.16, size: 1.2, opacity: 0.18),
      ]
    case .isha:
      [
        .init(x: 0.08, y: 0.22, size: 1.2, opacity: 0.42),
        .init(x: 0.22, y: 0.11, size: 1.7, opacity: 0.58),
        .init(x: 0.35, y: 0.31, size: 0.8, opacity: 0.32),
        .init(x: 0.48, y: 0.18, size: 1.1, opacity: 0.44),
        .init(x: 0.63, y: 0.28, size: 1.6, opacity: 0.54),
        .init(x: 0.78, y: 0.13, size: 0.9, opacity: 0.38),
        .init(x: 0.88, y: 0.36, size: 1.2, opacity: 0.44),
        .init(x: 0.95, y: 0.20, size: 0.8, opacity: 0.34),
      ]
    case .sunrise, .dhuhr, .asr:
      []
    }
  }

  private var shootingStars: [ShootingStar] {
    ShootingStarScene.generate(
      for: prayer,
      horizontalSizeClass: horizontalSizeClass,
      renderSeed: shootingStarRenderSeed
    )
  }

  private var horizonStarFade: Double {
    switch prayer {
    case .fajr:
      0.56
    case .maghrib:
      0.48
    case .isha:
      0.12
    case .sunrise, .dhuhr, .asr:
      0
    }
  }
}

private enum ShootingStarScene {
  static func generate(
    for prayer: Prayer,
    horizontalSizeClass: UserInterfaceSizeClass?,
    renderSeed: UInt64
  ) -> [ShootingStar] {
    guard prayer == .fajr else { return [] }

    var generator = SeededValueGenerator(
      seed: renderSeed ^ 0xF4_7A_15_51_00_71
    )
    let isRegular = horizontalSizeClass == .regular
    let count = generator.nextInt(in: isRegular ? 1...2 : 1...1)
    let xRange: ClosedRange<CGFloat> = isRegular ? 0.52...1.02 : 0.58...1.04

    return (0..<count).map { index in
      ShootingStar(
        x: generator.next(in: xRange),
        y: generator.next(in: 0.08...0.34),
        length: generator.next(in: isRegular ? 42...70 : 34...54),
        thickness: generator.next(in: 1.0...1.6),
        angle: generator.next(in: (-24)...(-15)),
        travel: generator.next(in: isRegular ? 0.20...0.34 : 0.24...0.40),
        opacity: Double(generator.next(in: 0.28...0.46)),
        cycleDuration: Double(
          generator.next(in: isRegular ? 18.0...32.0 : 22.0...38.0)
        ),
        activeDuration: Double(generator.next(in: 0.62...0.96)),
        phaseOffset: Double(index) * 10.0
          + Double(generator.next(in: 0.0...8.0))
      )
    }
  }
}

private struct StarLayer: View {
  let stars: [Star]
  let horizonFade: Double

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var twinkles = false

  var body: some View {
    GeometryReader { proxy in
      ForEach(stars.indices, id: \.self) { index in
        let star = stars[index]

        Circle()
          .fill(.white)
          .frame(width: star.size, height: star.size)
          .opacity(opacity(for: star, at: index))
          .scaleEffect(scale(for: index))
          .shadow(
            color: .white.opacity(shadowOpacity(for: star, at: index)),
            radius: star.size * 0.45
          )
          .position(
            x: proxy.size.width * star.x,
            y: proxy.size.height * star.y
          )
          .animation(starAnimation(for: index), value: twinkles)
      }
    }
    .onAppear(perform: updateMotion)
    .onChange(of: reduceMotion) {
      updateMotion()
    }
  }

  private func updateMotion() {
    if reduceMotion {
      var transaction = Transaction()
      transaction.disablesAnimations = true

      withTransaction(transaction) {
        twinkles = false
      }
    } else {
      twinkles = true
    }
  }

  private func opacity(for star: Star, at index: Int) -> Double {
    let baseOpacity = star.opacity * horizonVisibility(for: star)

    guard !reduceMotion else { return baseOpacity }

    let isBrightPhase = (index % 2 == 0) == twinkles
    let factor = isBrightPhase ? 1.06 : 0.82

    return min(baseOpacity * factor, 0.78)
  }

  private func scale(for index: Int) -> CGFloat {
    guard !reduceMotion else { return 1 }

    return (index % 2 == 0) == twinkles ? 1.04 : 0.94
  }

  private func shadowOpacity(for star: Star, at index: Int) -> Double {
    let baseOpacity = star.opacity * horizonVisibility(for: star)

    guard !reduceMotion else { return baseOpacity * 0.10 }

    return (index % 2 == 0) == twinkles
      ? baseOpacity * 0.28
      : baseOpacity * 0.08
  }

  private func starAnimation(for index: Int) -> Animation? {
    guard !reduceMotion else { return nil }

    return .easeInOut(duration: 3.1 + Double(index % 3) * 0.8)
      .repeatForever(autoreverses: true)
  }

  private func horizonVisibility(for star: Star) -> Double {
    let horizonProgress = min(
      max((Double(star.y) - 0.30) / 0.55, 0),
      1
    )

    return 1 - (horizonProgress * horizonFade)
  }
}

private struct ShootingStarLayer: View {
  let stars: [ShootingStar]

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    if reduceMotion || stars.isEmpty {
      EmptyView()
    } else {
      TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
        GeometryReader { proxy in
          ForEach(stars.indices, id: \.self) { index in
            let star = stars[index]
            let currentPhase = phase(for: star, at: timeline.date)
            let offset = offset(
              for: star,
              progress: currentPhase.progress,
              in: proxy.size
            )

            ShootingStarTrail(
              star: star,
              progress: currentPhase.progress,
              opacity: currentPhase.opacity
            )
              .frame(width: star.length, height: star.thickness * 12)
              .rotationEffect(.degrees(Double(star.angle)))
              .position(
                x: (proxy.size.width * star.x) + offset.width,
                y: (proxy.size.height * star.y) + offset.height
              )
          }
        }
      }
      .drawingGroup(opaque: false, colorMode: .extendedLinear)
      .allowedDynamicRange(.constrainedHigh)
    }
  }

  private func phase(
    for star: ShootingStar,
    at date: Date
  ) -> ShootingStarPhase {
    let elapsed = (
      date.timeIntervalSinceReferenceDate + star.phaseOffset
    )
      .truncatingRemainder(dividingBy: star.cycleDuration)

    guard elapsed <= star.activeDuration else {
      return ShootingStarPhase(progress: 0, opacity: 0)
    }

    let progress = elapsed / star.activeDuration
    let fadeIn = smoothStep(progress / 0.18)
    let fadeOut = smoothStep((1 - progress) / 0.48)

    return ShootingStarPhase(
      progress: progress,
      opacity: star.opacity * fadeIn * fadeOut
    )
  }

  private func smoothStep(_ value: Double) -> Double {
    let clampedValue = min(max(value, 0), 1)

    return clampedValue * clampedValue * (3 - (2 * clampedValue))
  }

  private func offset(
    for star: ShootingStar,
    progress: Double,
    in size: CGSize
  ) -> CGSize {
    let radians = Double(star.angle) * .pi / 180
    let travel = min(size.width * star.travel, 180)
    let progress = CGFloat(progress)

    return CGSize(
      width: -CGFloat(cos(radians)) * travel * progress,
      height: -CGFloat(sin(radians)) * travel * progress
    )
  }
}

private struct ShootingStarTrail: View {
  let star: ShootingStar
  let progress: Double
  let opacity: Double

  var body: some View {
    let energy = phaseEnergy
    let tailLength = star.length * (0.36 + energy * 0.64)
    let glowHeight = max(star.thickness * 8.5, 8)
    let coreHeight = max(star.thickness * 2.6, 2.6)
    let headDiameter = max(star.thickness * 7.8, 8)
    let coreDiameter = max(star.thickness * 1.8, 2.2)

    ZStack(alignment: .leading) {
      // The head sits at the leading edge; the trail extends opposite travel.
      ShootingStarTailShape()
        .fill(tailGradient(opacityScale: 0.32))
        .frame(width: tailLength, height: glowHeight)
        .blur(radius: max(star.thickness * 0.9, 0.8))

      ShootingStarTailShape()
        .fill(tailGradient(opacityScale: 0.78))
        .frame(width: tailLength * 0.86, height: coreHeight)
        .blur(radius: max(star.thickness * 0.22, 0.2))

      Circle()
        .fill(
          RadialGradient(
            colors: [
              hdrWhite(intensity: 3.60, opacity: opacity * 0.92),
              hdrWhite(intensity: 1.80, opacity: opacity * 0.34),
              .white.opacity(0),
            ],
            center: .center,
            startRadius: 0,
            endRadius: headDiameter * 0.55
          )
        )
        .frame(width: headDiameter, height: headDiameter)
        .offset(x: -headDiameter * 0.5)
        .blur(radius: max(star.thickness * 0.18, 0.18))

      Circle()
        .fill(hdrWhite(intensity: 4.20, opacity: opacity))
        .frame(width: coreDiameter, height: coreDiameter)
        .offset(x: -coreDiameter * 0.5)
        .blur(radius: max(star.thickness * 0.08, 0.08))
    }
    .blendMode(.screen)
    .shadow(
      color: hdrWhite(intensity: 2.20, opacity: opacity * 0.36),
      radius: max(star.thickness * 3.5, 3.5)
    )
  }

  private var phaseEnergy: CGFloat {
    let clampedProgress = min(max(progress, 0), 1)

    return CGFloat(sin(clampedProgress * .pi))
  }

  private func tailGradient(opacityScale: Double) -> LinearGradient {
    LinearGradient(
      stops: [
        .init(
          color: hdrWhite(intensity: 2.20, opacity: opacity * opacityScale),
          location: 0
        ),
        .init(
          color: hdrWhite(
            intensity: 1.55,
            opacity: opacity * opacityScale * 0.56
          ),
          location: 0.20
        ),
        .init(
          color: hdrWhite(
            intensity: 1.15,
            opacity: opacity * opacityScale * 0.16
          ),
          location: 0.58
        ),
        .init(color: .white.opacity(0), location: 1),
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
  }

  private func hdrWhite(intensity: Double, opacity: Double) -> Color {
    Color(
      .sRGBLinear,
      white: intensity,
      opacity: opacity
    )
  }
}

private struct ShootingStarTailShape: Shape {
  func path(in rect: CGRect) -> Path {
    let centerY = rect.midY
    let headRadius = rect.height * 0.44

    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: centerY - headRadius))
    path.addCurve(
      to: CGPoint(x: rect.maxX, y: centerY),
      control1: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY),
      control2: CGPoint(
        x: rect.minX + rect.width * 0.72,
        y: centerY - rect.height * 0.14
      )
    )
    path.addCurve(
      to: CGPoint(x: rect.minX, y: centerY + headRadius),
      control1: CGPoint(
        x: rect.minX + rect.width * 0.72,
        y: centerY + rect.height * 0.14
      ),
      control2: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.maxY)
    )
    path.closeSubpath()

    return path
  }
}

private struct ShootingStarPhase {
  let progress: Double
  let opacity: Double
}

private struct SeededValueGenerator {
  private var state: UInt64

  init(seed: UInt64) {
    state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
  }

  mutating func next(in range: ClosedRange<CGFloat>) -> CGFloat {
    range.lowerBound + ((range.upperBound - range.lowerBound) * nextUnit())
  }

  mutating func nextInt(in range: ClosedRange<Int>) -> Int {
    let count = range.upperBound - range.lowerBound + 1
    let offset = Int((nextUnit() * CGFloat(count)).rounded(.down))

    return range.lowerBound + min(offset, count - 1)
  }

  private mutating func nextUnit() -> CGFloat {
    state = state &* 6_364_136_223_846_793_005
      &+ 1_442_695_040_888_963_407

    return CGFloat(Double(state >> 11) / 9_007_199_254_740_992)
  }
}

private struct Star {
  let x: CGFloat
  let y: CGFloat
  let size: CGFloat
  let opacity: Double
}

private struct ShootingStar {
  let x: CGFloat
  let y: CGFloat
  let length: CGFloat
  let thickness: CGFloat
  let angle: CGFloat
  let travel: CGFloat
  let opacity: Double
  let cycleDuration: Double
  let activeDuration: Double
  let phaseOffset: Double
}
