//
//  HorizonMonthView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//

import SwiftUI
import HorizonCalendar
import UIKit

struct HorizonMonthView: UIViewRepresentable {
    @ObservedObject var viewModel: TopHeaderViewModel

    func makeUIView(context: Context) -> CalendarView {
        let calendarView = CalendarView(initialContent: makeContent())


        calendarView.backgroundColor = .clear

        DispatchQueue.main.async {
            self.configureScrollViews(in: calendarView)
        }


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


        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            calendarView.scroll(
                toMonthContaining: viewModel.selectedDate,
                scrollPosition: .centered,
                animated: false
            )
        }

        return calendarView
    }

    func updateUIView(_ uiView: CalendarView, context: Context) {
        uiView.setContent(makeContent())

        // Reconfigure scrollviews to catch lazily-created ones
        DispatchQueue.main.async {
            self.configureScrollViews(in: uiView)
        }


        if context.coordinator.lastDisplayedMonth != viewModel.selectedDate {
            uiView.scroll(
                toMonthContaining: viewModel.selectedDate,
                scrollPosition: .centered,
                animated: true
            )
            context.coordinator.lastDisplayedMonth = viewModel.selectedDate
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    // Helper method to disable touch delays on internal UIScrollViews
    private func configureScrollViews(in view: UIView) {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                // Disable touch delays for instant tap response
                scrollView.delaysContentTouches = false

                // CRITICAL: Also disable pan gesture delays
                scrollView.panGestureRecognizer.delaysTouchesBegan = false
                scrollView.panGestureRecognizer.delaysTouchesEnded = false

                // Additional optimization
                scrollView.canCancelContentTouches = true
            }
            // Recursively check all subviews
            configureScrollViews(in: subview)
        }
    }

    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current

        
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .year, value: 1, to: Date()) ?? Date()

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
        .verticalDayMargin(1)
        .horizontalDayMargin(2)
        .interMonthSpacing(8)
        .dayItemProvider { [weak viewModel] day in
            guard let viewModel = viewModel else {
                return CalendarItemModel<MonthDayView>(
                    invariantViewProperties: .init(
                        dayNumber: 1,
                        isSelected: false,
                        isToday: false,
                        isInCurrentMonth: true,
                        eventColors: []
                    ),
                    content: .init()
                )
            }

            let date = calendar.date(from: day.components)!
            let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
            let isToday = calendar.isDateInToday(date)
            let isInCurrentMonth = calendar.isDate(date, equalTo: viewModel.selectedDate, toGranularity: .month)

            
            let dateKey = viewModel.homeViewModel.dateKeyFor(date)
            let dayEvents = viewModel.homeViewModel.eventsByDate[dateKey] ?? []
            let eventColors = Array(dayEvents.map { $0.color }.prefix(3))

            return CalendarItemModel<MonthDayView>(
                invariantViewProperties: .init(
                    dayNumber: day.day,
                    isSelected: isSelected,
                    isToday: isToday,
                    isInCurrentMonth: isInCurrentMonth,
                    eventColors: eventColors
                ),
                content: .init()
            )
        }
        .dayOfWeekItemProvider { _, weekdayIndex in
            CalendarItemModel<WeekdayLabel>(
                invariantViewProperties: .init(weekdayIndex: weekdayIndex),
                content: .init()
            )
        }
    }

    class Coordinator: NSObject {
        let viewModel: TopHeaderViewModel
        var lastDisplayedMonth: Date

        init(viewModel: TopHeaderViewModel) {
            self.viewModel = viewModel
            self.lastDisplayedMonth = viewModel.selectedDate
        }
    }
}


struct MonthDayView: CalendarItemViewRepresentable {

    struct InvariantViewProperties: Hashable {
        let dayNumber: Int
        let isSelected: Bool
        let isToday: Bool
        let isInCurrentMonth: Bool
        let eventColors: [Color]
    }

    struct Content: Equatable {}

    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> MonthDayUIView {
        MonthDayUIView(invariantViewProperties: invariantViewProperties)
    }

    static func setContent(_ content: Content, on view: MonthDayUIView) {
        
    }
}


final class MonthDayUIView: UIView {
    private let dayLabel = UILabel()
    private let selectionCircle = UIView()
    private let todayIndicator = UIView()
    private let eventStackView = UIStackView()

    init(invariantViewProperties: MonthDayView.InvariantViewProperties) {
        super.init(frame: .zero)
        setupViews()
        updateAppearance(with: invariantViewProperties)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        
        selectionCircle.backgroundColor = .white
        selectionCircle.layer.cornerRadius = 18
        selectionCircle.isHidden = true
        addSubview(selectionCircle)

        
        todayIndicator.backgroundColor = UIColor.clear
        todayIndicator.layer.borderColor = UIColor.white.cgColor
        todayIndicator.layer.borderWidth = 2
        todayIndicator.layer.cornerRadius = 18
        todayIndicator.isHidden = true
        addSubview(todayIndicator)

        
        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(dayLabel)

        
        eventStackView.axis = .horizontal
        eventStackView.distribution = .fillEqually
        eventStackView.spacing = 2
        eventStackView.alignment = .center
        addSubview(eventStackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size: CGFloat = 36
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
            y: (bounds.height - 20) / 2,
            width: bounds.width,
            height: 20
        )

        
        let dotsWidth: CGFloat = min(18, CGFloat(eventStackView.arrangedSubviews.count * 5))
        let dotsHeight: CGFloat = 3
        eventStackView.frame = CGRect(
            x: (bounds.width - dotsWidth) / 2,
            y: dayLabel.frame.maxY + 1,
            width: dotsWidth,
            height: dotsHeight
        )
    }

    func updateAppearance(with properties: MonthDayView.InvariantViewProperties) {
        
        dayLabel.text = "\(properties.dayNumber)"

        
        if properties.isSelected {
            selectionCircle.isHidden = false
            todayIndicator.isHidden = true
            dayLabel.textColor = UIColor(Color.black)
            dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
        } else if properties.isToday {
            selectionCircle.isHidden = true
            todayIndicator.isHidden = false
            dayLabel.textColor = .white
            dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
        } else {
            selectionCircle.isHidden = true
            todayIndicator.isHidden = true
            dayLabel.textColor = .white  
            dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }

        
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


struct WeekdayLabel: CalendarItemViewRepresentable {

    struct InvariantViewProperties: Hashable {
        let weekdayIndex: Int
    }

    struct Content: Equatable {}

    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> WeekdayLabelView {
        WeekdayLabelView(weekdayIndex: invariantViewProperties.weekdayIndex)
    }

    static func setContent(_ content: Content, on view: WeekdayLabelView) {
        
    }
}

final class WeekdayLabelView: UIView {
    private let label = UILabel()

    init(weekdayIndex: Int) {
        super.init(frame: .zero)

        let weekdaySymbols = Calendar.current.shortWeekdaySymbols
        label.text = String(weekdaySymbols[weekdayIndex].prefix(3)).uppercased()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.6)

        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}

#Preview {
    ZStack {
        Color.appPrimary
            .ignoresSafeArea()

        HorizonMonthView(viewModel: TopHeaderViewModel(homeViewModel: HomeViewModel()))
            .frame(height: 300)
    }
}