//
//  AIScheduleViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//

import SwiftUI
import Combine
import UIKit

class AIScheduleViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var parsedTasks: [ParsedTaskUI] = []
    @Published var errorMessage: String?
    @Published var selectedImage: UIImage?

    private let backendService = BackendService.shared

    func parseTask() {
        guard !userInput.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        let currentPrompt = userInput

        Task {
            do {
                
                let results = try await backendService.parseSchedule(prompt: currentPrompt)

                await MainActor.run {
                    isLoading = false

                    if !results.isEmpty {
                        for parsedTask in results {
                            let duration = parsedTask.endTime - parsedTask.startTime
                            let uiTask = ParsedTaskUI(
                                id: UUID(),
                                title: parsedTask.title,
                                description: parsedTask.description,
                                startTime: parsedTask.startTime,
                                endTime: parsedTask.endTime,
                                duration: duration,
                                date: parsedTask.date,
                                emoji: parsedTask.emoji,
                                colorHex: parsedTask.colorHex
                            )
                            parsedTasks.append(uiTask)
                        }

                        
                        userInput = ""
                    } else {
                        
                        errorMessage = "Failed to parse task. Please try again."
                    }
                }
            } catch let error as BackendError {
                await MainActor.run {
                    isLoading = false
                    

                    
                    switch error {
                    case .unauthorized:
                        errorMessage = "Please sign in to use AI features"
                    case .networkError:
                        errorMessage = "Network error. Check your connection."
                    default:
                        errorMessage = error.localizedDescription
                    }

                    
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    errorMessage = "Something went wrong. Please try again."
                }
            }
        }
    }

    func addTaskToSchedule(_ task: ParsedTaskUI, to viewModel: HomeViewModel) {
        let color = Color(hex: task.colorHex) ?? Color.white

        let newEvent = DayEvent(
            title: task.title,
            startHour: task.startTime,
            endHour: task.startTime + task.duration,
            color: color,
            category: "AI Generated",
            emoji: task.emoji,
            description: task.description,
            participants: [],
            isCompleted: false
        )

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let targetDate = dateFormatter.date(from: task.date) {
            
            let previousDate = viewModel.selectedDate

            
            viewModel.selectedDate = targetDate

            
            viewModel.addEvent(newEvent)

            
            viewModel.selectedDate = previousDate
        } else {
            
            viewModel.addEvent(newEvent)
        }

        parsedTasks.removeAll { $0.id == task.id }
    }

    func removeTask(_ task: ParsedTaskUI) {
        parsedTasks.removeAll { $0.id == task.id }
    }

    // MARK: - Image Handling

    func parseTaskFromImage() {
        guard let image = selectedImage else { return }

        isLoading = true
        errorMessage = nil

        let currentPrompt = userInput.isEmpty ? nil : userInput

        Task {
            do {
                // Convert UIImage to Data (JPEG format)
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Failed to process image"
                    }
                    return
                }

                // Parse schedule from image
                let results = try await backendService.parseScheduleFromImage(
                    imageData: imageData,
                    prompt: currentPrompt
                )

                await MainActor.run {
                    isLoading = false

                    if !results.isEmpty {
                        for parsedTask in results {
                            let duration = parsedTask.endTime - parsedTask.startTime
                            let uiTask = ParsedTaskUI(
                                id: UUID(),
                                title: parsedTask.title,
                                description: parsedTask.description,
                                startTime: parsedTask.startTime,
                                endTime: parsedTask.endTime,
                                duration: duration,
                                date: parsedTask.date,
                                emoji: parsedTask.emoji,
                                colorHex: parsedTask.colorHex
                            )
                            parsedTasks.append(uiTask)
                        }

                        
                        userInput = ""
                        selectedImage = nil // Clear the image after processing
                    } else {
                        
                        errorMessage = "No schedule found in image. Please try a clearer photo."
                    }
                }
            } catch let error as BackendError {
                await MainActor.run {
                    isLoading = false
                    

                    switch error {
                    case .unauthorized:
                        errorMessage = "Please sign in to use AI features"
                    case .networkError:
                        errorMessage = "Network error. Check your connection."
                    default:
                        errorMessage = error.localizedDescription
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    errorMessage = "Failed to process image. Please try again."
                }
            }
        }
    }

    func clearImage() {
        selectedImage = nil
        errorMessage = nil
    }
}

struct ParsedTaskUI: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let startTime: Double   
    let endTime: Double     
    let duration: Double    
    let date: String        
    let emoji: String
    let colorHex: String

    var timeString: String {
        let startHourInt = Int(startTime)
        let startMinute = Int((startTime - Double(startHourInt)) * 60)
        let endHourInt = Int(endTime)
        let endMinute = Int((endTime - Double(endHourInt)) * 60)

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let startDate = Calendar.current.date(bySettingHour: startHourInt, minute: startMinute, second: 0, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: endHourInt, minute: endMinute, second: 0, of: Date())!

        let timeRange = "\(formatter.string(from: startDate))–\(formatter.string(from: endDate))"

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let taskDate = dateFormatter.date(from: date) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d"
            let dateString = displayFormatter.string(from: taskDate)

            
            let calendar = Calendar.current
            if calendar.isDateInToday(taskDate) {
                return "Today at \(timeRange)"
            } else if calendar.isDateInTomorrow(taskDate) {
                return "Tomorrow at \(timeRange)"
            } else {
                return "\(dateString) at \(timeRange)"
            }
        }

        return timeRange
    }

    var durationString: String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

