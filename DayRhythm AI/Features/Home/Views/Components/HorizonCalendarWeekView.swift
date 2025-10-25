//
//  HorizonCalendarWeekView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//

import SwiftUI
import HorizonCalendar
import UIKit


struct HorizonCalendarWeekView: UIViewRepresentable {
    @ObservedObject var viewModel: TopHeaderViewModel

    func makeUIView(context: Context) -> CalendarView {
        let calendarView = CalendarView(initialContent: makeContent())

        
        calendarView.backgroundColor = .clear

        
        calendarView.daySelectionHandler = { day in
            guard let date = Calendar.current.date(from: day.components) else { return }

            
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()

            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.handleDaySelection(date)
                }
            }
        }

        
        calendarView.scroll(
            toDayContaining: viewModel.selectedDate,
            scrollPosition: .centered,
            animated: false
        )

        return calendarView
    }

    func updateUIView(_ uiView: CalendarView, context: Context) {
        uiView.setContent(makeContent())

        
        if context.coordinator.lastSelectedDate != viewModel.selectedDate {
            uiView.scroll(
                toDayContaining: viewModel.selectedDate,
                scrollPosition: .centered,
                animated: true
            )
            context.coordinator.lastSelectedDate = viewModel.selectedDate
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current

        
        let startDate = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .month, value: 6, to: Date()) ?? Date()

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .horizontal(
                options: HorizontalMonthsLayoutOptions(
                    maximumFullyVisibleMonths: 1,
                    scrollingBehavior: .paginatedScrolling(
                        .init(
                            restingPosition: .atLeadingEdgeOfEachMonth,
                            restingAffinity: .atPositionsClosestToTargetOffset
                        )
                    )
                )
            )
        )
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .interMonthSpacing(24)
        .dayItemProvider { [weak viewModel] day in
            guard let viewModel = viewModel else { return CalendarItemModel<DayView>(
                invariantViewProperties: .init(dayNumber: 1, isSelected: false, isToday: false, eventColors: []),
                content: .init()
            )}

            let date = calendar.date(from: day.components)!
            let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
            let isToday = calendar.isDateInToday(date)

            
            let dateKey = viewModel.homeViewModel.dateKeyFor(date)
            let dayEvents = viewModel.homeViewModel.eventsByDate[dateKey] ?? []
            let eventColors = Array(dayEvents.map { $0.color }.prefix(3))

            return CalendarItemModel<DayView>(
                invariantViewProperties: .init(
                    dayNumber: day.day,
                    isSelected: isSelected,
                    isToday: isToday,
                    eventColors: eventColors
                ),
                content: .init()
            )
        }
    }

    class Coordinator: NSObject {
        let viewModel: TopHeaderViewModel
        var lastSelectedDate: Date

        init(viewModel: TopHeaderViewModel) {
            self.viewModel = viewModel
            self.lastSelectedDate = viewModel.selectedDate
        }
    }
}


struct DayView: CalendarItemViewRepresentable {

    struct InvariantViewProperties: Hashable {
        let dayNumber: Int
        let isSelected: Bool
        let isToday: Bool
        let eventColors: [Color]
    }

    struct Content: Equatable {}

    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> DayUIView {
        DayUIView(invariantViewProperties: invariantViewProperties)
    }

    static func setContent(_ content: Content, on view: DayUIView) {
        
    }
}


final class DayUIView: UIView {
    private let dayLabel = UILabel()
    private let selectionCircle = UIView()
    private let todayIndicator = UIView()
    private let eventStackView = UIStackView()

    init(invariantViewProperties: DayView.InvariantViewProperties) {
        super.init(frame: .zero)

        setupViews()
        updateAppearance(with: invariantViewProperties)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        
        selectionCircle.backgroundColor = .white
        selectionCircle.layer.cornerRadius = 20
        selectionCircle.isHidden = true
        addSubview(selectionCircle)

        
        todayIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        todayIndicator.layer.cornerRadius = 20
        todayIndicator.isHidden = true
        addSubview(todayIndicator)

        
        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(dayLabel)

        
        eventStackView.axis = .horizontal
        eventStackView.distribution = .fillEqually
        eventStackView.spacing = 2
        addSubview(eventStackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size: CGFloat = 40
        let circleFrame = CGRect(
            x: (bounds.width - size) / 2,
            y: (bounds.height - size) / 2,
            width: size,
            height: size
        )

        selectionCircle.frame = circleFrame
        todayIndicator.frame = circleFrame

        dayLabel.frame = CGRect(
            x: 0,
            y: (bounds.height - size) / 2,
            width: bounds.width,
            height: 24
        )

        
        let dotsWidth: CGFloat = 20
        let dotsHeight: CGFloat = 4
        eventStackView.frame = CGRect(
            x: (bounds.width - dotsWidth) / 2,
            y: dayLabel.frame.maxY + 2,
            width: dotsWidth,
            height: dotsHeight
        )
    }

    func updateAppearance(with properties: DayView.InvariantViewProperties) {
        
        dayLabel.text = "\(properties.dayNumber)"

        
        if properties.isSelected {
            selectionCircle.isHidden = false
            dayLabel.textColor = UIColor(Color.black)
            dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
        } else {
            selectionCircle.isHidden = true
            dayLabel.textColor = .white
            dayLabel.font = .systemFont(ofSize: 16, weight: properties.isToday ? .bold : .medium)
        }

        
        todayIndicator.isHidden = !properties.isToday || properties.isSelected

        
        eventStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for color in properties.eventColors.prefix(3) {
            let dot = UIView()
            dot.backgroundColor = UIColor(color)
            dot.layer.cornerRadius = 2
            dot.widthAnchor.constraint(equalToConstant: 4).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 4).isActive = true
            eventStackView.addArrangedSubview(dot)
        }
    }
}


#Preview {
    ZStack {
        Color.appPrimary
            .ignoresSafeArea()

        HorizonCalendarWeekView(viewModel: TopHeaderViewModel(homeViewModel: HomeViewModel()))
            .frame(height: 80)
    }
}