import SwiftUI

private let prayerCardCornerRadius: CGFloat = 28

struct PrayerTimeRow: View {
  var prayer: Prayer
  var date: Date
  var isCurrent: Bool = false
  var isUpcoming: Bool = false

  @State private var hasAppeared = false
  @State private var timerPhase = TimerPhase.hidden
  @State private var timerTransitionTask: Task<Void, Never>?

  private var showsTimerLayout: Bool {
    timerPhase.showsLayout
  }

  private var showsTimerContent: Bool {
    timerPhase.showsContent
  }

  var body: some View {
    HStack(spacing: 24) {
      HStack(spacing: 14) {
        Image(systemName: prayer.sfSymbol)
          .frame(width: 24, height: 24)
          .font(.system(size: 22, weight: .semibold, design: .rounded))

        VStack(alignment: .leading, spacing: 2) {
          Text(prayer.displayName)
            .font(.system(size: 24, weight: .semibold, design: .rounded))

          if let sunnahSummary = prayer.sunnahSummary {
            Text(sunnahSummary)
              .font(.system(size: 13, weight: .medium, design: .rounded))
              .foregroundStyle(.white.opacity(0.72))
              .lineLimit(1)
          }
        }
      }

      Spacer(minLength: 16)

      VStack(alignment: .trailing, spacing: 2) {
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
        .glassEffect(isCurrent ? .clear : .identity)

        if timerPhase.rendersTimer {
          CountdownCapsule()
            .opacity(showsTimerContent ? 1 : 0)
            .blur(radius: showsTimerContent ? 0 : 8)
            .scaleEffect(showsTimerContent ? 1 : 0.96)
            .frame(height: showsTimerLayout ? 29 : 0, alignment: .top)
            .transition(.identity)
        }
      }
      .offset(y: showsTimerLayout ? -6 : 0)
    }
    .foregroundStyle(.white)
    .symbolVariant(.fill)
    .symbolRenderingMode(.hierarchical)
    .padding(20)
    .frame(maxWidth: .infinity)
    .frame(height: showsTimerLayout ? 116 : 85)
    .animation(.smooth(duration: 0.42), value: showsTimerLayout)
    .background {
      PrayerCardBackground(prayer: prayer)
    }
    .contentShape(
      RoundedRectangle(
        cornerRadius: prayerCardCornerRadius,
        style: .continuous
      )
    )
    .accessibilityElement(children: .combine)
    .onAppear(perform: appear)
    .onChange(of: isUpcoming) { _, newValue in
      animateTimer(isVisible: newValue)
    }
    .onDisappear {
      timerTransitionTask?.cancel()
    }
  }

  private func appear() {
    if !hasAppeared {
      var transaction = Transaction()
      transaction.disablesAnimations = true
      withTransaction(transaction) {
        timerPhase = isUpcoming ? .contentVisible : .hidden
        hasAppeared = true
      }
    }
  }

  private func animateTimer(isVisible: Bool) {
    guard hasAppeared else { return }

    timerTransitionTask?.cancel()
    timerTransitionTask = Task { @MainActor in
      if isVisible {
        withAnimation(.smooth(duration: 0.42)) {
          timerPhase = .layoutVisible
        }

        try? await Task.sleep(for: .milliseconds(320))
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.28)) {
          timerPhase = .contentVisible
        }
      } else {
        withAnimation(.smooth(duration: 0.42)) {
          timerPhase = .collapsing
        }

        try? await Task.sleep(for: .milliseconds(420))
        guard !Task.isCancelled else { return }

        timerPhase = .hidden
      }
    }
  }
}

private extension Prayer {
  var sunnahSummary: String? {
    switch self {
    case .fajr:
      "2 before"
    case .sunrise:
      nil
    case .dhuhr:
      "4 before · 2 after"
    case .asr:
      "4 before"
    case .maghrib:
      "2 after"
    case .isha:
      "2 after · Witr 3"
    }
  }
}

private struct CountdownCapsule: View {
  @Environment(\.timerManager) private var timerManager

  @State private var countdownTextWidth: CGFloat?

  var body: some View {
    let formattedTime = timerManager.timeRemaining.formattedTime()

    HStack(spacing: 6) {
      Image(systemName: "arrow.right.circle")
      countdownText(formattedTime)
        .contentTransition(.numericText(countsDown: true))
        .animation(.default, value: formattedTime)
        .frame(width: countdownTextWidth, alignment: .trailing)
        .background {
          countdownText(formattedTime)
            .fixedSize()
            .hidden()
            .onGeometryChange(for: CGFloat.self) { proxy in
              proxy.size.width
            } action: { newWidth in
              guard countdownTextWidth != newWidth else { return }

              if countdownTextWidth == nil {
                countdownTextWidth = newWidth
              } else {
                withAnimation(.smooth(duration: 0.3)) {
                  countdownTextWidth = newWidth
                }
              }
            }
        }
    }
    .padding(.leading, 6)
    .padding(.trailing, 10)
    .padding(.vertical, 5)
    .background(.white.opacity(0.18), in: Capsule())
  }

  private func countdownText(_ value: String) -> some View {
    Text(value)
      .font(.system(size: 16, weight: .semibold, design: .rounded))
      .monospacedDigit()
  }
}

private struct PrayerCardBackground: View {
  let prayer: Prayer

  var body: some View {
    RoundedRectangle(
      cornerRadius: prayerCardCornerRadius,
      style: .continuous
    )
    .fill(backgroundGradient)
    .overlay {
      PrayerAtmosphericDetails(prayer: prayer)
        .clipShape(
          RoundedRectangle(
            cornerRadius: prayerCardCornerRadius,
            style: .continuous
          )
        )
    }
    .overlay {
      RoundedRectangle(
        cornerRadius: prayerCardCornerRadius,
        style: .continuous
      )
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
        .init(color: Color(red: 0.20, green: 0.24, blue: 0.48), location: 0.50),
        .init(color: Color(red: 0.47, green: 0.36, blue: 0.52), location: 1),
      ]
    case .sunrise:
      [
        .init(color: Color(red: 0.20, green: 0.39, blue: 0.67), location: 0),
        .init(color: Color(red: 0.42, green: 0.53, blue: 0.72), location: 0.50),
        .init(color: Color(red: 0.78, green: 0.55, blue: 0.52), location: 0.87),
        .init(color: Color(red: 0.88, green: 0.68, blue: 0.48), location: 1),
      ]
    case .dhuhr:
      [
        .init(color: Color(red: 0.10, green: 0.34, blue: 0.61), location: 0),
        .init(color: Color(red: 0.24, green: 0.46, blue: 0.68), location: 0.52),
        .init(color: Color(red: 0.49, green: 0.61, blue: 0.72), location: 0.88),
        .init(color: Color(red: 0.65, green: 0.69, blue: 0.72), location: 1),
      ]
    case .asr:
      [
        .init(color: Color(red: 0.13, green: 0.30, blue: 0.52), location: 0),
        .init(color: Color(red: 0.32, green: 0.46, blue: 0.60), location: 0.51),
        .init(color: Color(red: 0.59, green: 0.58, blue: 0.57), location: 0.87),
        .init(color: Color(red: 0.73, green: 0.63, blue: 0.54), location: 1),
      ]
    case .maghrib:
      [
        .init(color: Color(red: 0.08, green: 0.10, blue: 0.28), location: 0),
        .init(color: Color(red: 0.25, green: 0.20, blue: 0.43), location: 0.50),
        .init(color: Color(red: 0.51, green: 0.31, blue: 0.45), location: 1),
      ]
    case .isha:
      [
        .init(color: Color(red: 0.01, green: 0.02, blue: 0.06), location: 0),
        .init(color: Color(red: 0.03, green: 0.06, blue: 0.14), location: 0.51),
        .init(color: Color(red: 0.08, green: 0.13, blue: 0.23), location: 0.87),
        .init(color: Color(red: 0.13, green: 0.18, blue: 0.28), location: 1),
      ]
    }
  }

  private var gradientShadowColor: Color {
    gradientStops.first?.color ?? .black
  }
}

private enum TimerPhase {
  case hidden
  case layoutVisible
  case contentVisible
  case collapsing

  var showsLayout: Bool {
    switch self {
    case .layoutVisible, .contentVisible:
      return true
    case .hidden, .collapsing:
      return false
    }
  }

  var showsContent: Bool {
    self == .contentVisible
  }

  var rendersTimer: Bool {
    self != .hidden
  }
}
