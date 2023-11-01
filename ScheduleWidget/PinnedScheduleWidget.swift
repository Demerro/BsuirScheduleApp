import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import ScheduleCore
import Combine
import StoreKit
import Dependencies

struct PinnedScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetService.Timeline.pinnedSchedule.rawValue,
            provider: PinnedScheduleProvider()
        ) { entry in
            PinnedScheduleWidgetEntryView(entry: entry)
                .environmentObject({
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService
                }())
        }
        .configurationDisplayName("widget.pinned.displayName")
        .supportedFamilies(supportedFamilies)
        .description("widget.pinned.description")
    }

    private let supportedFamilies: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .accessoryCircular,
        .accessoryRectangular,
        .accessoryInline,
    ]
}

struct PinnedScheduleWidgetEntryView: View {
    let entry: ScheduleEntry
    @Environment(\.widgetFamily) var size

    var body: some View {
        Group {
            switch size {
            case .systemSmall:
                ScheduleWidgetEntrySmallView(config: entry.config, date: entry.date)
            case .systemMedium:
                ScheduleWidgetEntryMediumView(config: entry.config, date: entry.date)
            case .systemLarge:
                ScheduleWidgetEntryLargeView(config: entry.config, date: entry.date)
            case .systemExtraLarge:
                EmptyView()
            case .accessoryCircular:
                ScheduleWidgetEntryAccessoryCircularView(config: entry.config)
            case .accessoryRectangular:
                ScheduleWidgetEntryAccessoryRectangularView(config: entry.config)
            case .accessoryInline:
                ScheduleWidgetEntryAccessoryInlineView(config: entry.config)
            @unknown default:
                EmptyView()
            }
        }
        .widgetURL(entry.config.deeplink)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview("Pinned Schedule", as: .systemSmall) {
    PinnedScheduleWidget()
} timeline: {
    let entry = ScheduleEntry.previewEntry
    return [
        entry,
        mutating(entry) { $0.config.content = .pairs() },
        mutating(entry) { $0.config.content = .needsConfiguration },
        mutating(entry) { $0.config.content = .noPinned }
    ]
}

private extension ScheduleEntry {
    static let previewEntry = ScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        config: ScheduleWidgetConfiguration(
            title: "Иванов АН",
            subgroup: 1,
            content: .pairs(
                passed: [
                    .init(
                        from: "10:00",
                        to: "11:45",
                        interval: "10:00-11:45",
                        form: .practice,
                        subject: "Миапр1",
                        subjectFullName: "Миапр1",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:05",
                        to: "11:45",
                        interval: "10:05-11:45",
                        form: .practice,
                        subject: "Философ1",
                        subjectFullName: "Философ1",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:10",
                        to: "11:45",
                        interval: "10:10-11:45",
                        form: .practice,
                        subject: "Миапр1",
                        subjectFullName: "Миапр1",
                        auditory: "101-2"
                    ),

                ],
                upcoming: [
                    .init(
                        from: "10:15",
                        to: "11:45",
                        interval: "10:15-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2", progress: .init(constant: 0.35)
                    ),
                    .init(
                        from: "10:20",
                        to: "11:45",
                        interval: "10:20-11:45",
                        form: .lecture,
                        subject: "Миапр",
                        subjectFullName: "Миапр",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:25",
                        to: "11:45",
                        interval: "10:25-11:45",
                        form: .lecture,
                        subject: "Физра",
                        subjectFullName: "Физра",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:30",
                        to: "11:45",
                        interval: "10:30-11:45",
                        form: .lecture,
                        subject: "ПОИТ",
                        subjectFullName: "ПОИТ",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:35",
                        to: "11:45",
                        interval: "10:35-11:45",
                        form: .lecture,
                        subject: "ОкПрог",
                        subjectFullName: "ОкПрог",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:40",
                        to: "11:45",
                        interval: "10:40-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:45",
                        to: "11:45",
                        interval: "10:45-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2"
                    ),
                ]
            )
        )
    )
}