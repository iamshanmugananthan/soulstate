import SwiftUI
import WidgetKit

@main
struct SoulStateWidgets: WidgetBundle {
  var body: some Widget {
    HabitGridWidget()
    TodayWidget()
    StatsWidget()
    TodosWidget()
    HeatmapWidget()
  }
}

struct SoulStateEntry: TimelineEntry {
  let date: Date
  let payload: Payload?
}

enum Timelines {
  static func dates() -> [Date] {
    let now = Date()
    let cutoff = Payload.load(at: now)?.dayCutoff ?? 0
    return [now, DayKeys.nextDayStart(after: now, cutoff: cutoff)]
  }
}

struct SoulStateProvider: TimelineProvider {
  func placeholder(in context: Context) -> SoulStateEntry {
    SoulStateEntry(date: Date(), payload: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (SoulStateEntry) -> Void) {
    completion(SoulStateEntry(date: Date(), payload: Payload.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SoulStateEntry>) -> Void) {
    let dates = Timelines.dates()
    let entries = dates.map { SoulStateEntry(date: $0, payload: Payload.load(at: $0)) }
    completion(Timeline(entries: entries, policy: .after(dates[1])))
  }
}

typealias StreakWidgets = SoulStateWidgets
typealias StreakEntry = SoulStateEntry
typealias StreakProvider = SoulStateProvider
