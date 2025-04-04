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
    var notes: String = ""
    
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
        
        var spanishValue: String {
            switch self {
            case .notStarted: return "No Iniciado"
            case .inProgress: return "En Progreso"
            case .completed: return "Completado"
            }
        }
        
        var vietnameseValue: String {
            switch self {
            case .notStarted: return "Chưa Bắt Đầu"
            case .inProgress: return "Đang Thực Hiện"
            case .completed: return "Hoàn Thành"
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
            return Color(red: 255/255, green: 223/255, blue: 119/255) // #ffdf77 yellow
        case .educationTraining:
            return Color(red: 227/255, green: 158/255, blue: 45/255) // #e39e2d gold
        case .adultLife:
            return Color(red: 181/255, green: 0/255, blue: 148/255) // #b50094 magenta
        case .selfAdvocacy:
            return Color(red: 108/255, green: 104/255, blue: 150/255) // #6c6896 slate purple
        case .workPreparation:
            return Color(red: 101/255, green: 0/255, blue: 102/255) // #650066 deep purple
        }
    }
    
    func localizedName(_ translations: Translations) -> String {
        switch self {
        case .transitionPlanning:
            return translations.transitionPlanning
        case .educationTraining:
            return translations.educationTraining
        case .adultLife:
            return translations.adultLife
        case .selfAdvocacy:
            return translations.selfAdvocacy
        case .workPreparation:
            return translations.workPreparation
        }
    }
}
