import SwiftUI
import WidgetKit

@main
struct PrayerTimesWidgetBundle: WidgetBundle {
  var body: some Widget {
    PrayerTimesWidget()
    PrayerTimesWidgetLiveActivity()
  }
}
