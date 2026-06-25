import SwiftUI

@Observable
class PrayerTimerManager {
  fileprivate(set) var currentPrayer: Prayer?
  fileprivate(set) var upcomingPrayer: Prayer?
  fileprivate(set) var timeRemaining: TimeInterval = 0

  private var todayPrayerTimes: PrayerTimes?
  private var tomorrowPrayerTimes: PrayerTimes?
  private var upcomingPrayerDate: Date?
  private var singleShot: DispatchSourceTimer?
  private var tickTimer: Timer?
  private var tickEnabled = false

  deinit {
    cancelSingleShot()
    stopTickTimer()
  }

  func update(
    today: PrayerTimes?,
    tomorrow: PrayerTimes?
  ) {
    todayPrayerTimes = today
    tomorrowPrayerTimes = tomorrow
    refresh()
  }

  func setTickingEnabled(_ enabled: Bool) {
    guard enabled != tickEnabled else { return }
    tickEnabled = enabled

    if enabled {
      refresh()
      startTickTimer()
    } else {
      stopTickTimer()
    }
  }

  private func refresh() {
    cancelSingleShot()

    guard
      let todayPrayerTimes,
      let state = PrayerSchedule.state(
        at: .now,
        today: todayPrayerTimes,
        tomorrow: tomorrowPrayerTimes
      )
    else {
      clearState()
      return
    }

    currentPrayer = state.currentPrayer
    upcomingPrayer = state.upcomingPrayer
    upcomingPrayerDate = state.upcomingPrayerDate
    timeRemaining = max(0, state.upcomingPrayerDate.timeIntervalSinceNow)

    scheduleSingleShot(at: state.upcomingPrayerDate)
  }

  private func tick() {
    guard let upcomingPrayerDate else {
      timeRemaining = 0
      return
    }

    let remaining = upcomingPrayerDate.timeIntervalSinceNow
    if remaining > 0 {
      timeRemaining = remaining
    } else {
      refresh()
    }
  }

  private func clearState() {
    currentPrayer = nil
    upcomingPrayer = nil
    upcomingPrayerDate = nil
    timeRemaining = 0
  }

  private func scheduleSingleShot(at date: Date) {
    let interval = max(0, date.timeIntervalSinceNow)
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline: .now() + interval, leeway: .seconds(1))
    timer.setEventHandler { [weak self] in
      self?.refresh()
    }
    singleShot = timer
    timer.resume()
  }

  private func cancelSingleShot() {
    singleShot?.cancel()
    singleShot = nil
  }

  private func startTickTimer() {
    stopTickTimer()

    let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
    }
    tickTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  private func stopTickTimer() {
    tickTimer?.invalidate()
    tickTimer = nil
  }
}

@Observable
class MockPrayerTimerManager: PrayerTimerManager {
  private var mockTimer: Timer?

  override init() {
    super.init()
    currentPrayer = .dhuhr
    upcomingPrayer = .asr
    timeRemaining = 3600
  }

  deinit {
    mockTimer?.invalidate()
  }

  override func update(
    today: PrayerTimes?,
    tomorrow: PrayerTimes?
  ) {
  }

  override func setTickingEnabled(_ enabled: Bool) {
    mockTimer?.invalidate()
    mockTimer = nil

    guard enabled else { return }

    let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
      guard let self else { return }
      self.timeRemaining = max(0, self.timeRemaining - 1)
    }
    mockTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  func advancePrayer() {
    guard let upcomingPrayer else { return }

    let prayers = Prayer.allCases
    let upcomingIndex = prayers.firstIndex(of: upcomingPrayer) ?? 0

    currentPrayer = upcomingPrayer
    self.upcomingPrayer =
      prayers[(upcomingIndex + 1) % prayers.count]
    timeRemaining = 3602
  }
}

extension TimeInterval {
  func formattedTime() -> String {
    guard self > 0 else { return "00:00:00" }

    let totalSeconds = Int(max(0, rounded()))
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    return if hours > 0 {
      String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      String(format: "%02d:%02d", minutes, seconds)
    }
  }
}

private struct PrayerTimerManagerKey: EnvironmentKey {
  static let defaultValue: PrayerTimerManager = {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    {
      MockPrayerTimerManager()
    } else {
      PrayerTimerManager()
    }
  }()
}

extension EnvironmentValues {
  var timerManager: PrayerTimerManager {
    get { self[PrayerTimerManagerKey.self] }
    set { self[PrayerTimerManagerKey.self] = newValue }
  }
}
