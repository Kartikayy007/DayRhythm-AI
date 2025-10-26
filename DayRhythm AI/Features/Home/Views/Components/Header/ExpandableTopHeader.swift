//
//  ExpandableTopHeader.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//

import SwiftUI

struct ExpandableTopHeader: View {
    @StateObject private var viewModel: TopHeaderViewModel
    @State private var headerState: HeaderState = .collapsed
    @State private var headerHeight: CGFloat = 140
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let collapsedHeight: CGFloat = 150
    private let expandedHeightRatio: CGFloat = 0.515

    init(homeViewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: TopHeaderViewModel(homeViewModel: homeViewModel))
    }

    private var expandedHeight: CGFloat {
        UIScreen.main.bounds.height * expandedHeightRatio
    }

    private var currentHeight: CGFloat {
        switch headerState {
        case .collapsed:
            return collapsedHeight + max(0, dragOffset)
        case .expanded:
            return expandedHeight + min(0, dragOffset)
        case .dragging:
            return headerHeight + dragOffset
        }
    }

    private var expansionProgress: CGFloat {
        let progress = (currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)
        return min(1, max(0, progress))
    }

    var body: some View {
        ZStack(alignment: .top) {
            ExpandableHeaderBackground(
                height: currentHeight,
                cornerRadius: 40,
                expansionProgress: expansionProgress
            )

            VStack(spacing: 0) {
                
                headerBar
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                
                calendarContent
                    .frame(maxHeight: .infinity)
            }
            .frame(height: currentHeight)

            
            VStack {
                Spacer()
                dragIndicator
                    .padding(.bottom, 8)
            }
            .frame(height: currentHeight)
        }
        .frame(height: currentHeight)
        .gesture(dragGesture)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: headerState)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentHeight)
        .sheet(isPresented: $viewModel.showMonthPicker) {
            monthPickerSheet
        }
    }

    

    private var headerBar: some View {
        HStack {
            
            AnimatedDateDisplay(date: viewModel.selectedDate)

            
            Button(action: viewModel.handleMonthPickerTap) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var calendarContent: some View {
        ZStack(alignment: .top) {
            
            if headerState != .expanded {
                SimpleWeekView(viewModel: viewModel)
                    .opacity(1 - expansionProgress)
                    .frame(height: 80)
            }

            
            if headerState != .collapsed {
                VStack(spacing: 0) {
                    
                    Color.clear
                        .frame(height: 20)

                    HorizonMonthView(viewModel: viewModel)
                        .opacity(expansionProgress)
                        
                }
            }
        }
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.white.opacity(isDragging ? 0.8 : 0.5))
            .frame(width: isDragging ? 42 : 36, height: 5)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
            .scaleEffect(isDragging ? 1.1 : 1.0)
    }

    private var monthPickerSheet: some View {
        MonthPickerView(
            selectedMonth: $viewModel.localSelectedMonth,
            onDone: viewModel.confirmMonthSelection
        )
    }

    

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragOffset) { value, state, _ in
                
                if abs(value.translation.height) > abs(value.translation.width) * 1.5 {
                    state = value.translation.height
                }
            }
            .onChanged { value in
                
                let isVerticalGesture = abs(value.translation.height) > abs(value.translation.width) * 1.5

                if isVerticalGesture && !isDragging {
                    isDragging = true
                    headerState = .dragging

                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
            .onEnded { value in
                
                let isVerticalGesture = abs(value.translation.height) > abs(value.translation.width) * 1.5

                guard isVerticalGesture && isDragging else {
                    isDragging = false
                    return
                }

                isDragging = false

                let velocity = value.predictedEndTranslation.height - value.translation.height
                let shouldExpand: Bool

                if abs(velocity) > 100 {
                    
                    shouldExpand = velocity > 0
                } else {
                    
                    let dragThreshold: CGFloat = 40
                    if headerState == .collapsed {
                        shouldExpand = value.translation.height > dragThreshold
                    } else {
                        shouldExpand = value.translation.height > -dragThreshold
                    }
                }

                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    headerState = shouldExpand ? .expanded : .collapsed
                    headerHeight = shouldExpand ? expandedHeight : collapsedHeight

                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
    }
}



private enum HeaderState {
    case collapsed
    case expanded
    case dragging
}



private struct ExpandableHeaderBackground: View {
    let height: CGFloat
    let cornerRadius: CGFloat
    let expansionProgress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Color.appPrimary
                .cornerRadius(cornerRadius, corners: [.bottomLeft, .bottomRight])
                .frame(
                    width: geometry.size.width,
                    height: height + 60 
                )
                .offset(y: -60)
                .shadow(
                    color: .black.opacity(0.1 * expansionProgress),
                    radius: 10 * expansionProgress,
                    x: 0,
                    y: 5 * expansionProgress
                )
        }
    }
}



private extension TopHeaderViewModel {
    var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack {
            ExpandableTopHeader(homeViewModel: HomeViewModel())
            Spacer()
        }
    }
}
