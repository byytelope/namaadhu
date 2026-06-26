import SwiftUI

struct PrayerAtmosphericDetails: View {
  let prayer: Prayer

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var atmosphericRenderSeed = UInt64.random(in: 1...UInt64.max)

  var body: some View {
    ZStack {
      if !clouds.isEmpty {
        CloudLayer(clouds: clouds)
      }

      if !stars.isEmpty {
        StarLayer(stars: stars)
      }

      if !shootingStars.isEmpty {
        ShootingStarLayer(stars: shootingStars)
      }

      if prayer == .dhuhr {
        DhuhrSun()
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
    CloudScene.generate(
      for: prayer,
      horizontalSizeClass: horizontalSizeClass,
      renderSeed: atmosphericRenderSeed
    )
  }

  private var shootingStars: [ShootingStar] {
    ShootingStarScene.generate(
      for: prayer,
      horizontalSizeClass: horizontalSizeClass,
      renderSeed: atmosphericRenderSeed
    )
  }
}

private enum CloudScene {
  static func generate(
    for prayer: Prayer,
    horizontalSizeClass: UserInterfaceSizeClass?,
    renderSeed: UInt64
  ) -> [Cloud] {
    switch prayer {
    case .sunrise:
      return generateClouds(
        prayerSalt: 0x51_71_52_15_45,
        renderSeed: renderSeed,
        horizontalSizeClass: horizontalSizeClass,
        opacityRange: opacityRange(
          compact: 0.075...0.125,
          regular: 0.045...0.085,
          horizontalSizeClass: horizontalSizeClass
        ),
        silhouettes: [.cumulus, .flatShelf, .band, .veil]
      )
    case .asr:
      return generateClouds(
        prayerSalt: 0xA5_12_34_89,
        renderSeed: renderSeed,
        horizontalSizeClass: horizontalSizeClass,
        opacityRange: opacityRange(
          compact: 0.075...0.125,
          regular: 0.045...0.085,
          horizontalSizeClass: horizontalSizeClass
        ),
        silhouettes: [.cumulus, .flatShelf, .band]
      )
    case .fajr, .dhuhr, .maghrib, .isha:
      return []
    }
  }

  private static func generateClouds(
    prayerSalt: UInt64,
    renderSeed: UInt64,
    horizontalSizeClass: UserInterfaceSizeClass?,
    opacityRange: ClosedRange<Double>,
    silhouettes: [CloudSilhouette]
  ) -> [Cloud] {
    var generator = SeededValueGenerator(seed: renderSeed ^ prayerSalt)
    let count = generator.nextInt(in: 2...3)
    let selectedSilhouettes = selectedSilhouettes(
      count: count,
      from: silhouettes,
      using: &generator
    )
    let isRegular = horizontalSizeClass == .regular
    let slotWidth = CGFloat(0.76) / CGFloat(count)
    let leadingInset: CGFloat = 0.12

    return selectedSilhouettes.enumerated().map { index, silhouette in
      let slotCenter = leadingInset + (slotWidth * (CGFloat(index) + 0.5))
      let x = slotCenter + generator.next(
        in: (-slotWidth * 0.36)...(slotWidth * 0.36)
      )
      let width = generator.next(
        in: widthRange(
          for: silhouette,
          isRegular: isRegular
        )
      )
      let y = generator.next(
        in: yRange(
          for: silhouette,
          isRegular: isRegular
        )
      )
      let opacity = Double(generator.next(
        in: CGFloat(opacityRange.lowerBound)...CGFloat(opacityRange.upperBound)
      ))

      return Cloud(
        x: min(max(x, 0.10), 0.90),
        y: y,
        width: width,
        opacity: opacity,
        silhouette: silhouette
      )
    }
  }

  private static func selectedSilhouettes(
    count: Int,
    from silhouettes: [CloudSilhouette],
    using generator: inout SeededValueGenerator
  ) -> [CloudSilhouette] {
    var selected = (0..<count).map { _ in
      silhouettes[generator.nextInt(in: 0...(silhouettes.count - 1))]
    }

    selected[generator.nextInt(in: 0...(count - 1))] = .cumulus

    return selected
  }

  private static func widthRange(
    for silhouette: CloudSilhouette,
    isRegular: Bool
  ) -> ClosedRange<CGFloat> {
    if isRegular {
      switch silhouette {
      case .cumulus:
        return 0.25...0.34
      case .flatShelf:
        return 0.22...0.31
      case .band:
        return 0.24...0.34
      case .veil:
        return 0.18...0.28
      }
    }

    switch silhouette {
    case .cumulus:
      return 0.24...0.34
    case .flatShelf:
      return 0.22...0.31
    case .band:
      return 0.23...0.33
    case .veil:
      return 0.18...0.27
    }
  }

  private static func yRange(
    for silhouette: CloudSilhouette,
    isRegular: Bool
  ) -> ClosedRange<CGFloat> {
    if isRegular {
      switch silhouette {
      case .cumulus:
        return 0.25...0.35
      case .flatShelf:
        return 0.40...0.54
      case .band:
        return 0.38...0.52
      case .veil:
        return 0.46...0.62
      }
    }

    switch silhouette {
    case .cumulus:
      return 0.28...0.38
    case .flatShelf:
      return 0.40...0.54
    case .band:
      return 0.38...0.52
    case .veil:
      return 0.46...0.62
    }
  }

  private static func opacityRange(
    compact: ClosedRange<Double>,
    regular: ClosedRange<Double>,
    horizontalSizeClass: UserInterfaceSizeClass?
  ) -> ClosedRange<Double> {
    horizontalSizeClass == .regular ? regular : compact
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

private struct CloudLayer: View {
  let clouds: [Cloud]

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var drifts = false

  var body: some View {
    GeometryReader { proxy in
      ForEach(clouds.indices, id: \.self) { index in
        let cloud = clouds[index]
        let form = GeneratedCloudForm.generate(
          seed: cloudSeed(for: cloud, at: index),
          preferredSilhouette: cloud.silhouette
        )
        let metrics = form.silhouette.metrics(
          for: horizontalSizeClass
        )
        let aspectRatio = cloudAspectRatio(for: form, metrics: metrics)
        let width = cloudWidth(
          for: cloud,
          at: index,
          in: proxy.size,
          aspectRatio: aspectRatio,
          metrics: metrics
        )
        let height = width * aspectRatio

        GeneratedCloudShape(form: form)
          .fill(
            .white.opacity(
              cloudOpacity(for: cloud, at: index, metrics: metrics)
            )
          )
          .frame(width: width, height: height)
          .blur(radius: cloudBlur(for: width, metrics: metrics))
          .position(
            x: proxy.size.width * cloud.x,
            y: cloudPositionY(
              for: cloud,
              silhouette: form.silhouette,
              in: proxy.size
            )
          )
          .offset(
            x: horizontalOffset(
              for: form.silhouette,
              at: index,
              in: proxy.size
            ),
            y: verticalOffset(for: form.silhouette, at: index)
          )
          .animation(
            cloudAnimation(for: form.silhouette, at: index),
            value: drifts
          )
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
        drifts = false
      }
    } else {
      drifts = true
    }
  }

  private func horizontalOffset(
    for silhouette: CloudSilhouette,
    at index: Int,
    in size: CGSize
  ) -> CGFloat {
    guard !reduceMotion else { return 0 }

    let direction: CGFloat = index % 2 == 0 ? 1 : -1
    let travel = min(14, max(7, size.width * 0.028))

    return drifts
      ? travel * silhouette.motionTravelScale * direction
      : -travel * 0.45 * silhouette.motionTravelScale * direction
  }

  private func verticalOffset(
    for silhouette: CloudSilhouette,
    at index: Int
  ) -> CGFloat {
    guard !reduceMotion else { return 0 }

    let travel: CGFloat = index % 2 == 0 ? 1.4 : -1
    let silhouetteScale: CGFloat = silhouette == .cumulus ? 0.72 : 1

    return drifts ? travel * silhouetteScale : -travel * silhouetteScale
  }

  private func cloudAnimation(
    for silhouette: CloudSilhouette,
    at index: Int
  ) -> Animation? {
    guard !reduceMotion else { return nil }

    return .easeInOut(
      duration: silhouette.motionDuration(
        for: horizontalSizeClass,
        offsetIndex: index
      )
    )
      .repeatForever(autoreverses: true)
  }

  private func cloudWidth(
    for cloud: Cloud,
    at index: Int,
    in size: CGSize,
    aspectRatio: CGFloat,
    metrics: CloudSilhouette.Metrics
  ) -> CGFloat {
    let isRegular = horizontalSizeClass == .regular
    let lengthScale = cloudLengthScale(for: aspectRatio)
    let absoluteMaxWidth: CGFloat =
      isRegular
      ? (index % 2 == 0 ? 270 : 230)
      : (index % 2 == 0 ? 126 : 96)
    let heightScale: CGFloat =
      isRegular
      ? (index % 2 == 0 ? 3.6 : 3.1)
      : (index % 2 == 0 ? 1.36 : 1.08)
    let heightBasedMaxWidth = size.height * heightScale

    return min(
      size.width * cloud.width * metrics.widthScale * lengthScale,
      absoluteMaxWidth * lengthScale,
      heightBasedMaxWidth
    )
  }

  private func cloudAspectRatio(
    for form: GeneratedCloudForm,
    metrics: CloudSilhouette.Metrics
  ) -> CGFloat {
    max(
      form.aspectRatio * metrics.aspectRatioScale,
      metrics.minimumAspectRatio
    )
  }

  private func cloudLengthScale(for aspectRatio: CGFloat) -> CGFloat {
    let minAspectRatio: CGFloat = 0.16
    let maxAspectRatio: CGFloat = 0.24
    let normalizedFlatness = (maxAspectRatio - aspectRatio)
      / (maxAspectRatio - minAspectRatio)
    let flatness = min(max(normalizedFlatness, 0), 1)
    let maxExtraLength: CGFloat = horizontalSizeClass == .regular
      ? 0.36
      : 0.22

    return 1 + flatness * maxExtraLength
  }

  private func cloudOpacity(
    for cloud: Cloud,
    at index: Int,
    metrics: CloudSilhouette.Metrics
  ) -> Double {
    let factor = index % 2 == 0 ? 1.14 : 1.04

    return min(cloud.opacity * factor * metrics.opacityScale, 0.15)
  }

  private func cloudBlur(
    for width: CGFloat,
    metrics: CloudSilhouette.Metrics
  ) -> CGFloat {
    min(5.2, max(3.4, width * 0.036 * metrics.blurScale))
  }

  private func cloudPositionY(
    for cloud: Cloud,
    silhouette: CloudSilhouette,
    in size: CGSize
  ) -> CGFloat {
    let adjustedY = cloud.y + silhouette.verticalBias(
      for: horizontalSizeClass
    )

    return size.height * min(max(adjustedY, 0.10), 0.82)
  }

  private func cloudSeed(for cloud: Cloud, at index: Int) -> UInt64 {
    let x = UInt64((cloud.x * 1_000).rounded())
    let y = UInt64((cloud.y * 1_000).rounded())
    let width = UInt64((cloud.width * 1_000).rounded())

    return x &+ (y &* 31) &+ (width &* 131) &+ UInt64(index &* 997)
  }
}

private struct StarLayer: View {
  let stars: [Star]

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
    guard !reduceMotion else { return star.opacity }

    let isBrightPhase = (index % 2 == 0) == twinkles
    let factor = isBrightPhase ? 1.10 : 0.68

    return min(star.opacity * factor, 0.78)
  }

  private func scale(for index: Int) -> CGFloat {
    guard !reduceMotion else { return 1 }

    return (index % 2 == 0) == twinkles ? 1.10 : 0.88
  }

  private func shadowOpacity(for star: Star, at index: Int) -> Double {
    guard !reduceMotion else { return star.opacity * 0.12 }

    return (index % 2 == 0) == twinkles
      ? star.opacity * 0.36
      : star.opacity * 0.10
  }

  private func starAnimation(for index: Int) -> Animation? {
    guard !reduceMotion else { return nil }

    return .easeInOut(duration: 2.4 + Double(index % 3) * 0.55)
      .repeatForever(autoreverses: true)
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
    let fadeIn = min(progress / 0.18, 1)
    let fadeOut = min((1 - progress) / 0.48, 1)

    return ShootingStarPhase(
      progress: progress,
      opacity: star.opacity * fadeIn * fadeOut
    )
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

private struct GeneratedCloudShape: Shape {
  let form: GeneratedCloudForm

  func path(in rect: CGRect) -> Path {
    var path = Path()

    for ellipse in form.ellipses {
      path.addEllipse(in: ellipse.rect(in: rect))
    }

    return path
  }
}

private struct GeneratedCloudForm {
  let silhouette: CloudSilhouette
  let aspectRatio: CGFloat
  let ellipses: [CloudEllipse]

  static func generate(
    seed: UInt64,
    preferredSilhouette: CloudSilhouette?
  ) -> GeneratedCloudForm {
    var generator = SeededValueGenerator(seed: seed)
    let silhouette = preferredSilhouette
      ?? CloudSilhouette.generated(from: seed)

    switch silhouette {
    case .cumulus:
      return cumulus(using: &generator)
    case .flatShelf:
      return flatShelf(using: &generator)
    case .band:
      return band(using: &generator)
    case .veil:
      return veil(using: &generator)
    }
  }

  private static func cumulus(
    using generator: inout SeededValueGenerator
  ) -> GeneratedCloudForm {
    let aspectRatio = generator.next(in: 0.19...0.24)
    let baseHeight = generator.next(in: 0.34...0.44)
    let baseY = generator.next(in: 0.50...0.60)
    let leadingWidth = generator.next(in: 0.40...0.52)
    let leadingHeight = generator.next(in: 0.58...0.76)
    let trailingWidth = generator.next(in: 0.34...0.46)
    let trailingHeight = generator.next(in: 0.46...0.64)

    return GeneratedCloudForm(
      silhouette: .cumulus,
      aspectRatio: aspectRatio,
      ellipses: [
        CloudEllipse(
          x: generator.next(in: 0.01...0.06),
          y: baseY,
          width: generator.next(in: 0.88...0.96),
          height: baseHeight
        ),
        CloudEllipse(
          x: generator.next(in: 0.20...0.31),
          y: generator.next(in: 0.12...0.22),
          width: leadingWidth,
          height: leadingHeight
        ),
        CloudEllipse(
          x: generator.next(in: 0.50...0.60),
          y: generator.next(in: 0.24...0.34),
          width: trailingWidth,
          height: trailingHeight
        ),
      ]
    )
  }

  private static func flatShelf(
    using generator: inout SeededValueGenerator
  ) -> GeneratedCloudForm {
    GeneratedCloudForm(
      silhouette: .flatShelf,
      aspectRatio: generator.next(in: 0.19...0.23),
      ellipses: [
        CloudEllipse(
          x: generator.next(in: 0.02...0.08),
          y: generator.next(in: 0.42...0.52),
          width: generator.next(in: 0.84...0.94),
          height: generator.next(in: 0.38...0.52)
        ),
        CloudEllipse(
          x: generator.next(in: 0.19...0.31),
          y: generator.next(in: 0.31...0.42),
          width: generator.next(in: 0.44...0.58),
          height: generator.next(in: 0.36...0.50)
        ),
        CloudEllipse(
          x: generator.next(in: 0.50...0.62),
          y: generator.next(in: 0.35...0.46),
          width: generator.next(in: 0.32...0.46),
          height: generator.next(in: 0.32...0.44)
        ),
      ]
    )
  }

  private static func band(
    using generator: inout SeededValueGenerator
  ) -> GeneratedCloudForm {
    GeneratedCloudForm(
      silhouette: .band,
      aspectRatio: generator.next(in: 0.18...0.22),
      ellipses: [
        CloudEllipse(
          x: generator.next(in: 0.02...0.07),
          y: generator.next(in: 0.41...0.52),
          width: generator.next(in: 0.74...0.88),
          height: generator.next(in: 0.36...0.48)
        ),
        CloudEllipse(
          x: generator.next(in: 0.23...0.35),
          y: generator.next(in: 0.34...0.46),
          width: generator.next(in: 0.48...0.62),
          height: generator.next(in: 0.34...0.46)
        ),
        CloudEllipse(
          x: generator.next(in: 0.56...0.66),
          y: generator.next(in: 0.39...0.50),
          width: generator.next(in: 0.28...0.40),
          height: generator.next(in: 0.30...0.40)
        ),
      ]
    )
  }

  private static func veil(
    using generator: inout SeededValueGenerator
  ) -> GeneratedCloudForm {
    GeneratedCloudForm(
      silhouette: .veil,
      aspectRatio: generator.next(in: 0.19...0.23),
      ellipses: [
        CloudEllipse(
          x: generator.next(in: 0.03...0.09),
          y: generator.next(in: 0.40...0.52),
          width: generator.next(in: 0.52...0.66),
          height: generator.next(in: 0.36...0.48)
        ),
        CloudEllipse(
          x: generator.next(in: 0.31...0.42),
          y: generator.next(in: 0.32...0.44),
          width: generator.next(in: 0.44...0.56),
          height: generator.next(in: 0.34...0.46)
        ),
        CloudEllipse(
          x: generator.next(in: 0.58...0.68),
          y: generator.next(in: 0.43...0.54),
          width: generator.next(in: 0.26...0.38),
          height: generator.next(in: 0.28...0.38)
        ),
      ]
    )
  }
}

private enum CloudSilhouette: Equatable {
  case cumulus
  case flatShelf
  case band
  case veil

  struct Metrics {
    let widthScale: CGFloat
    let aspectRatioScale: CGFloat
    let minimumAspectRatio: CGFloat
    let opacityScale: Double
    let blurScale: CGFloat
  }

  func verticalBias(for horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    let isRegular = horizontalSizeClass == .regular

    switch self {
    case .cumulus:
      return isRegular ? -0.13 : -0.10
    case .flatShelf:
      return isRegular ? 0.01 : 0.01
    case .band:
      return isRegular ? 0.03 : 0.02
    case .veil:
      return isRegular ? 0.04 : 0.03
    }
  }

  var motionTravelScale: CGFloat {
    switch self {
    case .cumulus:
      return 0.82
    case .flatShelf:
      return 1.00
    case .band:
      return 1.14
    case .veil:
      return 1.26
    }
  }

  func motionDuration(
    for horizontalSizeClass: UserInterfaceSizeClass?,
    offsetIndex: Int
  ) -> Double {
    let isRegular = horizontalSizeClass == .regular
    let baseDuration: Double

    switch self {
    case .cumulus:
      baseDuration = isRegular ? 31 : 28
    case .flatShelf:
      baseDuration = isRegular ? 25 : 23
    case .band:
      baseDuration = isRegular ? 21 : 19
    case .veil:
      baseDuration = isRegular ? 18 : 16
    }

    return baseDuration + Double(offsetIndex % 3) * 1.8
  }

  func metrics(for horizontalSizeClass: UserInterfaceSizeClass?) -> Metrics {
    if horizontalSizeClass == .regular {
      return regularMetrics
    }

    return compactMetrics
  }

  private var compactMetrics: Metrics {
    switch self {
    case .cumulus:
      Metrics(
        widthScale: 1.00,
        aspectRatioScale: 0.92,
        minimumAspectRatio: 0.19,
        opacityScale: 0.92,
        blurScale: 1.08
      )
    case .flatShelf:
      Metrics(
        widthScale: 1.15,
        aspectRatioScale: 1.00,
        minimumAspectRatio: 0.20,
        opacityScale: 1.15,
        blurScale: 0.96
      )
    case .band:
      Metrics(
        widthScale: 1.25,
        aspectRatioScale: 1.00,
        minimumAspectRatio: 0.19,
        opacityScale: 1.20,
        blurScale: 0.94
      )
    case .veil:
      Metrics(
        widthScale: 1.10,
        aspectRatioScale: 1.00,
        minimumAspectRatio: 0.20,
        opacityScale: 1.12,
        blurScale: 0.98
      )
    }
  }

  private var regularMetrics: Metrics {
    switch self {
    case .cumulus:
      Metrics(
        widthScale: 1.68,
        aspectRatioScale: 0.68,
        minimumAspectRatio: 0.16,
        opacityScale: 0.82,
        blurScale: 1.14
      )
    case .flatShelf:
      Metrics(
        widthScale: 1.70,
        aspectRatioScale: 0.86,
        minimumAspectRatio: 0.17,
        opacityScale: 1.00,
        blurScale: 1.02
      )
    case .band:
      Metrics(
        widthScale: 1.85,
        aspectRatioScale: 0.82,
        minimumAspectRatio: 0.16,
        opacityScale: 1.04,
        blurScale: 0.98
      )
    case .veil:
      Metrics(
        widthScale: 1.58,
        aspectRatioScale: 0.86,
        minimumAspectRatio: 0.17,
        opacityScale: 0.98,
        blurScale: 1.04
      )
    }
  }

  static func generated(from seed: UInt64) -> CloudSilhouette {
    switch seed % 5 {
    case 0:
      return .cumulus
    case 1:
      return .flatShelf
    case 2:
      return .band
    case 3:
      return .veil
    default:
      return .flatShelf
    }
  }
}

private struct CloudEllipse {
  let x: CGFloat
  let y: CGFloat
  let width: CGFloat
  let height: CGFloat

  func rect(in rect: CGRect) -> CGRect {
    CGRect(
      x: rect.minX + (rect.width * x),
      y: rect.minY + (rect.height * y),
      width: rect.width * width,
      height: rect.height * height
    )
  }
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

private struct Cloud {
  let x: CGFloat
  let y: CGFloat
  let width: CGFloat
  let opacity: Double
  let silhouette: CloudSilhouette?

  init(
    x: CGFloat,
    y: CGFloat,
    width: CGFloat,
    opacity: Double,
    silhouette: CloudSilhouette? = nil
  ) {
    self.x = x
    self.y = y
    self.width = width
    self.opacity = opacity
    self.silhouette = silhouette
  }
}
