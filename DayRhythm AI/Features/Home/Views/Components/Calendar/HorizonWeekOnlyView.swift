//
//  HorizonWeekOnlyView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//

import SwiftUI
import HorizonCalendar
import UIKit


struct HorizonWeekOnlyView: UIViewRepresentable {
    @ObservedObject var viewModel: TopHeaderViewModel
    @State private var currentWeekOffset = 0

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        
        let calendarView = makeCalendarView(context: context)
        containerView.addSubview(calendarView)

        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: containerView.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        context.coordinator.calendarView = calendarView

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let calendarView = context.coordinator.calendarView {
            calendarView.setContent(makeCalendarContent())

            
            if context.coordinator.lastSelectedDate != viewModel.selectedDate {
                calendarView.scroll(
                    toDayContaining: viewModel.selectedDate,
                    scrollPosition: .centered,
                    animated: true
                )
                context.coordinator.lastSelectedDate = viewModel.selectedDate
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    private func makeCalendarView(context: Context) -> CalendarView {
        let calendarView = CalendarView(initialContent: makeCalendarContent())

        calendarView.backgroundColor = .clear

        
        calendarView.daySelectionHandler = { [weak viewModel] day in
            guard let viewModel = viewModel,
                  let date = Calendar.current.date(from: day.components) else { return }

            
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
                toDayContaining: viewModel.selectedDate,
                scrollPosition: .centered,
                animated: false
            )
        }

        return calendarView
    }

    private func makeCalendarContent() -> CalendarViewContent {
        let calendar = Calendar.current

        
        let today = viewModel.selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        
        let startDate = calendar.date(byAdding: .weekOfYear, value: -26, to: startOfWeek) ?? today
        let endDate = calendar.date(byAdding: .weekOfYear, value: 26, to: startOfWeek) ?? today

        let content = CalendarViewContent(
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

        
        let modifiedContent = content
            .interMonthSpacing(0)
            .verticalDayMargin(4)
            .horizontalDayMargin(4)

        
        let finalContent = modifiedContent.dayItemProvider { [weak viewModel] day in
            guard let viewModel = viewModel else {
                return CalendarItemModel<WeekDayView>(
                    invariantViewProperties: .init(
                        dayNumber: 1,
                        dayName: "Mon",
                        isSelected: false,
                        isToday: false,
                        eventColors: []
                    ),
                    content: .init()
                )
            }

            let date = calendar.date(from: day.components)!
            let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
            let isToday = calendar.isDateInToday(date)

            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = String(dayFormatter.string(from: date).prefix(3))

            
            let dateKey = viewModel.homeViewModel.dateKeyFor(date)
            let dayEvents = viewModel.homeViewModel.eventsByDate[dateKey] ?? []
            let eventColors = Array(dayEvents.map { $0.color }.prefix(3))

            return CalendarItemModel<WeekDayView>(
                invariantViewProperties: .init(
                    dayNumber: day.day,
                    dayName: dayName,
                    isSelected: isSelected,
                    isToday: isToday,
                    eventColors: eventColors
                ),
                content: .init()
            )
        }

        
        return finalContent
    }

    class Coordinator: NSObject {
        let viewModel: TopHeaderViewModel
        var lastSelectedDate: Date
        weak var calendarView: CalendarView?

        init(viewModel: TopHeaderViewModel) {
            self.viewModel = viewModel
            self.lastSelectedDate = viewModel.selectedDate
        }
    }
}


struct WeekDayView: CalendarItemViewRepresentable {

    struct InvariantViewProperties: Hashable {
        let dayNumber: Int
        let dayName: String
        let isSelected: Bool
        let isToday: Bool
        let eventColors: [Color]
    }

    struct Content: Equatable {}

    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> WeekDayUIView {
        WeekDayUIView(invariantViewProperties: invariantViewProperties)
    }

    static func setContent(_ content: Content, on view: WeekDayUIView) {
        
    }
}


final class WeekDayUIView: UIView {
    private let containerStack = UIStackView()
    private let dayNameLabel = UILabel()
    private let dayNumberLabel = UILabel()
    private let selectionCircle = UIView()
    private let eventStackView = UIStackView()

    init(invariantViewProperties: WeekDayView.InvariantViewProperties) {
        super.init(frame: .zero)
        setupViews()
        updateAppearance(with: invariantViewProperties)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        
        selectionCircle.backgroundColor = .white
        selectionCircle.layer.cornerRadius = 22
        selectionCircle.isHidden = true
        addSubview(selectionCircle)

        
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.distribution = .fill
        containerStack.spacing = 4
        addSubview(containerStack)

        
        dayNameLabel.textAlignment = .center
        dayNameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dayNameLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        containerStack.addArrangedSubview(dayNameLabel)

        
        dayNumberLabel.textAlignment = .center
        dayNumberLabel.font = .systemFont(ofSize: 16, weight: .medium)
        containerStack.addArrangedSubview(dayNumberLabel)

        
        eventStackView.axis = .horizontal
        eventStackView.distribution = .fillEqually
        eventStackView.spacing = 2
        containerStack.addArrangedSubview(eventStackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        
        let circleSize: CGFloat = 44
        selectionCircle.frame = CGRect(
            x: (bounds.width - circleSize) / 2,
            y: (bounds.height - circleSize) / 2,
            width: circleSize,
            height: circleSize
        )

        
        containerStack.frame = bounds
    }

    func updateAppearance(with properties: WeekDayView.InvariantViewProperties) {
        
        dayNameLabel.text = properties.dayName
        dayNumberLabel.text = "\(properties.dayNumber)"

        
        if properties.isSelected {
            selectionCircle.isHidden = false
            dayNumberLabel.textColor = UIColor(Color.black)
            dayNumberLabel.font = .systemFont(ofSize: 16, weight: .bold)
            dayNameLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        } else if properties.isToday {
            selectionCircle.isHidden = true
            dayNumberLabel.textColor = UIColor(Color.appPrimary)
            dayNumberLabel.font = .systemFont(ofSize: 16, weight: .bold)
            dayNameLabel.textColor = UIColor(Color.appPrimary).withAlphaComponent(0.7)
        } else {
            selectionCircle.isHidden = true
            dayNumberLabel.textColor = .white
            dayNumberLabel.font = .systemFont(ofSize: 16, weight: .medium)
            dayNameLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        }

        
        eventStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if !properties.eventColors.isEmpty {
            for color in properties.eventColors.prefix(3) {
                let dot = UIView()
                dot.backgroundColor = UIColor(color)
                dot.layer.cornerRadius = 2
                dot.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    dot.widthAnchor.constraint(equalToConstant: 4),
                    dot.heightAnchor.constraint(equalToConstant: 4)
                ])
                eventStackView.addArrangedSubview(dot)
            }
        } else {
            
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spacer.heightAnchor.constraint(equalToConstant: 4)
            ])
            eventStackView.addArrangedSubview(spacer)
        }
    }
}

#Preview {
    ZStack {
        Color.appPrimary
            .ignoresSafeArea()

        HorizonWeekOnlyView(viewModel: TopHeaderViewModel(homeViewModel: HomeViewModel()))
            .frame(height: 80)
    }
}