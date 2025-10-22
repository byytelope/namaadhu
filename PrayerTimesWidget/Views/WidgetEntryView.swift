import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall: SystemSmallView(entry: entry)
    case .systemMedium: SystemMediumView(entry: entry)
    default: SystemSmallView(entry: entry)
    }
  }
}
