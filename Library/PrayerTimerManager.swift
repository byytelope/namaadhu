import Combine
import SwiftUI

@Observable
class PrayerTimerManager {
  fileprivate(set) var currentPrayer: Prayer?
  fileprivate(set) var upcomingPrayer: Prayer?
  fileprivate(set) var timeRemaining: TimeInterval = 0

  private var prayerTimes: PrayerTimes?
  private var singleShot: DispatchSourceTimer?
  private var tickTimer: Timer?
  private var tickEnabled = false
  private var cancellables = Set<AnyCancellable>()
  private let calendar: Calendar

  init() {
    self.calendar = .current
  }

  deinit {
    cancelSingleShot()
    stopTickTimer()
  }

  func update(prayerTimes: PrayerTimes?) {
    self.prayerTimes = prayerTimes
    computeAndSchedule()
  }

  func setTickingEnabled(_ enabled: Bool) {
    guard enabled != tickEnabled else { return }
    tickEnabled = enabled

    if enabled {
      startTickTimer()
    } else {
      stopTickTimer()
    }
  }

  private func computeAndSchedule() {
    cancelSingleShot()

    guard let pt = prayerTimes else {
      currentPrayer = nil
      upcomingPrayer = nil
      timeRemaining = 0

      return
    }

    let now = Date()
    let occurrences = pt.orderedDates()

    let tomorrowDay = calendar.date(byAdding: .day, value: 1, to: pt.date)!
    let fajrComps = pt[.fajr]
    let fajrTomorrow = calendar.date(
      byAdding: fajrComps,
      to: calendar.startOfDay(for: tomorrowDay)
    )!
    var allOccurrences = occurrences
    allOccurrences.append((.fajr, fajrTomorrow))

    guard let nextTuple = allOccurrences.first(where: { $0.1 > now }) else {
      currentPrayer = nil
      upcomingPrayer = nil
      timeRemaining = 0

      return
    }

    let upcoming = nextTuple.0
    upcomingPrayer = upcoming
    timeRemaining = nextTuple.1.timeIntervalSince(now)

    if let upcomingIndex = allOccurrences.firstIndex(where: {
      $0.0 == upcoming && $0.1 == nextTuple.1
    }) {
      let prevIndex =
        (upcomingIndex - 1 + allOccurrences.count) % allOccurrences.count
      currentPrayer = allOccurrences[prevIndex].0
    } else {
      currentPrayer = nil
    }

    scheduleSingleShot(at: nextTuple.1)
  }

  private func scheduleSingleShot(at date: Date) {
    cancelSingleShot()

    let interval = max(0.0, date.timeIntervalSinceNow)
    let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
    timer.schedule(deadline: .now() + interval, leeway: .seconds(1))
    timer.setEventHandler { [weak self] in
      guard let self = self else { return }
      DispatchQueue.main.async {
        self.computeAndSchedule()
      }
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

    tickTimer =
      Timer
      .scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        guard let self = self else { return }

        if let pt = self.prayerTimes, let upcoming = self.upcomingPrayer {
          let now = Date()
          let occurrences = pt.orderedDates()
          let tomorrowDay = self.calendar.date(
            byAdding: .day,
            value: 1,
            to: pt.date
          )!
          let fajrTomorrow = self.calendar.date(
            byAdding: pt[.fajr],
            to: self.calendar.startOfDay(for: tomorrowDay)
          )!
          var all = occurrences
          all.append((.fajr, fajrTomorrow))

          if let tuple = all.first(where: { $0.0 == upcoming && $0.1 > now }) {
            self.timeRemaining = tuple.1.timeIntervalSince(now)
          } else {
            self.computeAndSchedule()
          }
        } else {
          self.timeRemaining = 0
        }
      }

    RunLoop.main.add(tickTimer!, forMode: .common)
  }

  private func stopTickTimer() {
    tickTimer?.invalidate()
    tickTimer = nil
  }
}

@Observable
class MockPrayerTimerManager: PrayerTimerManager {
  override init() {
    super.init()
    self.currentPrayer = .dhuhr
    self.upcomingPrayer = .asr
    self.timeRemaining = 3600
  }

  override func update(prayerTimes: PrayerTimes?) {
  }

  override func setTickingEnabled(_ enabled: Bool) {
    if enabled {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
        [weak self] _ in
        guard let self = self else { return }
        self.timeRemaining = max(0, self.timeRemaining - 1)
      }
    }
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
  static let defaultValue = {
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
