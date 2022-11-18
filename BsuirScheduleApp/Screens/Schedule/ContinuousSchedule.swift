import BsuirApi
import Combine
import Foundation
import os.log
import BsuirUI
import BsuirCore

final class ContinuousSchedule: ObservableObject {
    @Published private(set) var days: [DayViewModel] = []
    @Published private(set) var doneLoading: Bool = false

    func loadMore() {
        self.loadMoreSubject.send()
    }

    init(schedule: DaySchedule, startDate: Date?, endDate: Date?, calendar: Calendar, now: Date) {
        self.calendar = calendar
        self.now = now
        
        if let startDate, let endDate {
            self.weekSchedule = WeekSchedule(schedule: schedule, startDate: startDate, endDate: endDate)
        } else {
            self.weekSchedule = nil
        }
        
        self.loadDays(12)

        self.loadMoreSubject
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] in
                os_log(.debug, "[ContinuousSchedule] Loading more days...")
                self?.loadDays(10)
            }
            .store(in: &cancellables)
    }

    private func loadDays(_ count: Int) {
        guard
            let weekSchedule,
            let offset = offset,
            let start = calendar.date(byAdding: .day, value: 1, to: offset)
        else { return }
        
        let days = Array(weekSchedule.schedule(starting: start, now: now, calendar: calendar).prefix(count))
        
        self.doneLoading = days.count < count

        if mostRelevant == nil {
            mostRelevant = days.first { $0.hasUnfinishedPairs(calendar: calendar, now: now) }?.date
        }

        self.offset = days.last?.date
        self.days.append(contentsOf: days.map(self.day))
    }

    private func day(for element: WeekSchedule.ScheduleElement) -> DayViewModel {
        return DayViewModel(
            title: String(localized: "screen.schedule.day.title.\(element.date.formatted(.scheduleDay)).\(element.weekNumber)"),
            subtitle: Self.relativeFormatter.relativeName(for: element.date, now: now),
            pairs: element.pairs.map(PairViewModel.init(pair:)),
            isToday: calendar.isDateInToday(element.date),
            isMostRelevant: mostRelevant == element.date
        )
    }

    private let now: Date
    private lazy var offset = calendar.date(byAdding: .day, value: -4, to: now)
    private var mostRelevant: Date?
    private let weekSchedule: WeekSchedule?
    private let calendar: Calendar
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private static let relativeFormatter = RelativeDateTimeFormatter.relativeNameOnly()
}
