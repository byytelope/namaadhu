import SwiftUI

/// One clock and one set of cloud rectangles drive lighting and occlusion.
struct DhuhrSky: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @State private var seed = UInt64.random(in: 0...UInt64.max)
  @State private var isOnScreen = false
  @State private var accumulatedTime: TimeInterval = 0
  @State private var startedAt: Date?

  private var shouldAnimate: Bool {
    isOnScreen && scenePhase == .active && !reduceMotion
  }

  var body: some View {
    TimelineView(.animation(minimumInterval: 1.0 / 15, paused: !shouldAnimate)) { timeline in
      GeometryReader { proxy in
        let elapsed =
          accumulatedTime
          + (startedAt.map { max(0, timeline.date.timeIntervalSince($0)) } ?? 0)
        let sun = CGPoint(x: proxy.size.width * 0.72, y: proxy.size.height * 0.18)
        let clouds = cloudSprites(width: proxy.size.width, elapsed: elapsed)

        ZStack {
          DhuhrSun(clouds: clouds)
          ForEach(clouds.indices, id: \.self) { index in
            let cloud = clouds[index]
            Image(cloud.asset)
              .resizable()
              .interpolation(.high)
              .frame(width: cloud.rect.width, height: cloud.rect.height)
              .colorEffect(
                ShaderLibrary.dhuhrCloudLighting(
                  .float2(Float(sun.x - cloud.rect.minX), Float(sun.y - cloud.rect.minY)),
                  .float(Float(cloud.density))
                )
              )
              .position(x: cloud.rect.midX, y: cloud.rect.midY)
          }
        }
        .drawingGroup(opaque: false, colorMode: .extendedLinear)
        .allowedDynamicRange(.constrainedHigh)
      }
    }
    .onAppear {
      isOnScreen = true
      updateClock()
    }
    .onScrollVisibilityChange(threshold: 0.01) { visible in
      isOnScreen = visible
      updateClock()
    }
    .onChange(of: shouldAnimate) { updateClock() }
    .onDisappear {
      isOnScreen = false
      updateClock()
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func updateClock() {
    if shouldAnimate {
      if startedAt == nil { startedAt = .now }
    } else if let startedAt {
      accumulatedTime += max(0, Date.now.timeIntervalSince(startedAt))
      self.startedAt = nil
    }
  }

  private func cloudSprites(width: CGFloat, elapsed: TimeInterval) -> [DhuhrCloudSprite] {
    let phase = Double((seed >> 8) % 1024) / 1024 * 2 * .pi
    let crossingWidth = min(width * 0.82, 320)
    let distantWidth = min(width * 0.70, 350)
    return [
      DhuhrCloudSprite(
        asset: assetName(.layer, seed: seed),
        center: CGPoint(x: width * 0.72 + 35 + 80 * sin(elapsed * 2 * .pi / 210 + phase), y: 32),
        width: crossingWidth, density: 0.85
      ),
      DhuhrCloudSprite(
        asset: assetName(.bank, seed: seed >> 4),
        center: CGPoint(x: width * 0.23 + 28 * sin(elapsed * 2 * .pi / 290 + phase * 0.7), y: 48),
        width: distantWidth, density: 0.44
      ),
    ]
  }

  private func assetName(_ type: DaytimeCloudType, seed: UInt64) -> String {
    type.assetName(variant: Int(seed % UInt64(type.variantCount)))
  }
}

struct DhuhrCloudSprite {
  let asset: String
  let rect: CGRect
  let density: Double

  init(asset: String, center: CGPoint, width: CGFloat, density: Double) {
    self.asset = asset
    self.density = density
    let height = width * (768.0 / 2048.0)
    rect = CGRect(
      x: center.x - width / 2, y: center.y - height / 2,
      width: width, height: height)
  }

  func occlusion(sun: CGPoint, isFlare: Bool) -> Shader {
    ShaderLibrary.dhuhrCloudOcclusion(
      .image(Image(asset)),
      .float4(Float(rect.minX), Float(rect.minY), Float(rect.width), Float(rect.height)),
      .float2(Float(sun.x), Float(sun.y)),
      .float(Float(density)),
      .float(isFlare ? 1 : 0)
    )
  }
}

struct DhuhrCloudOcclusion: ViewModifier {
  let clouds: [DhuhrCloudSprite]
  let sun: CGPoint
  var isFlare = false

  @ViewBuilder
  func body(content: Content) -> some View {
    if clouds.count == 2 {
      // SwiftUI supports one image argument per shader, so each cloud gets a pass.
      content
        .colorEffect(clouds[0].occlusion(sun: sun, isFlare: isFlare))
        .colorEffect(clouds[1].occlusion(sun: sun, isFlare: isFlare))
    } else {
      content
    }
  }
}
