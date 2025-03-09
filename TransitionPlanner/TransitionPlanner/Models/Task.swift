import Foundation
import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var category: Category
    var startAge: Int
    var endAge: Int
    var status: TaskStatus = .notStarted
    var isWorkInProgress: Bool = false
    
    enum TaskStatus: String, Codable, CaseIterable {
        case notStarted = "Not Started"
        case inProgress = "In Progress"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .notStarted: return "circle"
            case .inProgress: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .notStarted: return .gray
            case .inProgress: return .blue
            case .completed: return .green
            }
        }
    }
}

enum Category: String, Codable, CaseIterable {
    case transitionPlanning = "Transition Planning"
    case educationTraining = "Education and Training"
    case adultLife = "Adult Life"
    case selfAdvocacy = "Self-Advocacy"
    case workPreparation = "Work Preparation"
    
    var icon: String {
        switch self {
        case .transitionPlanning:
            return "gear"
        case .educationTraining:
            return "book.fill"
        case .adultLife:
            return "person.2.fill"
        case .selfAdvocacy:
            return "person.fill.viewfinder"
        case .workPreparation:
            return "briefcase.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .transitionPlanning:
            return .green
        case .educationTraining:
            return .blue
        case .adultLife:
            return .pink
        case .selfAdvocacy:
            return .orange
        case .workPreparation:
            return .indigo
        }
    }
} 