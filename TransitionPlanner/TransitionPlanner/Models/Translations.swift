import Foundation
import SwiftUI

struct Translations {
    static let shared = Translations()
    static var isSpanish: Bool = false {
        didSet {
            print("Language changed to: \(isSpanish ? "Spanish" : "English")")
        }
    }
    
    static var isVietnamese: Bool = false {
        didSet {
            print("Language changed to: \(isVietnamese ? "Vietnamese" : "English")")
        }
    }
    
    private var isSpanish = false
    private var isVietnamese = false
    
    mutating func setLanguage(spanish: Bool = false, vietnamese: Bool = false) {
        isSpanish = spanish
        isVietnamese = vietnamese
        Translations.isSpanish = spanish
        Translations.isVietnamese = vietnamese
    }
    
    var title: String {
        isVietnamese ? "PHP Kế Hoạch" : (isSpanish ? "PHP Planificador" : "PHP Planner")
    }
    
    var settings: String {
        isVietnamese ? "Cài Đặt" : (isSpanish ? "Ajustes" : "Settings")
    }
    
    var done: String {
        isVietnamese ? "Xong" : (isSpanish ? "Hecho" : "Done")
    }
    
    var resetTasks: String {
        isVietnamese ? "Đặt Lại Công Việc" : (isSpanish ? "Restablecer Tareas" : "Reset Tasks")
    }
    
    var resetConfirmation: String {
        isVietnamese ? "Bạn có chắc chắn muốn đặt lại tất cả các công việc về trạng thái mặc định? Hành động này không thể hoàn tác." : (isSpanish ? "¿Está seguro de que desea restablecer todas las tareas a su estado predeterminado? Esta acción no se puede deshacer." : "Are you sure you want to reset all tasks to their default state? This action cannot be undone.")
    }
    
    var cancel: String {
        isVietnamese ? "Hủy" : (isSpanish ? "Cancelar" : "Cancel")
    }
    
    var reset: String {
        isVietnamese ? "Đặt Lại" : (isSpanish ? "Restablecer" : "Reset")
    }
    
    var childBirthDate: String {
        isVietnamese ? "Ngày Sinh của Trẻ" : (isSpanish ? "Fecha de Nacimiento del Niño" : "Child's Birth Date")
    }
    
    var resetToDefault: String {
        isVietnamese ? "Đặt Lại về Công Việc Mặc Định" : (isSpanish ? "Restablecer a Tareas Predeterminadas" : "Reset to Default Tasks")
    }
    
    var changeToSpanish: String {
        isVietnamese ? "Chuyển sang Tiếng Việt" : (isSpanish ? "Cambiar a Inglés" : "Change to Spanish")
    }
    
    var under12: String {
        isVietnamese ? "< 12" : (isSpanish ? "< 12" : "Under 12")
    }
    
    var ageRange12to16: String {
        isVietnamese ? "12 - 16" : (isSpanish ? "12 - 16" : "12 - 16")
    }
    
    var ageRange16to18: String {
        isVietnamese ? "16 - 18" : (isSpanish ? "16 - 18" : "16 - 18")
    }
    
    var ageRange18to22: String {
        isVietnamese ? "18 - 22" : (isSpanish ? "18 - 22" : "18 - 22")
    }
    
    var ageRange22plus: String {
        isVietnamese ? "22+" : (isSpanish ? "22+" : "22+")
    }
    
    // Category translations
    var transitionPlanning: String {
        isVietnamese ? "Kế Hoạch Chuyển Tiếp" : (isSpanish ? "Planificación de Transición" : "Transition Planning")
    }
    
    var educationTraining: String {
        isVietnamese ? "Giáo Dục và Đào Tạo" : (isSpanish ? "Educación y Capacitación" : "Education and Training")
    }
    
    var adultLife: String {
        isVietnamese ? "Cuộc Sống Người Lớn" : (isSpanish ? "Vida Adulta" : "Adult Life")
    }
    
    var selfAdvocacy: String {
        isVietnamese ? "Tự Vận Động" : (isSpanish ? "Auto-Defensa" : "Self-Advocacy")
    }
    
    var workPreparation: String {
        isVietnamese ? "Chuẩn Bị Công Việc" : (isSpanish ? "Preparación para el Trabajo" : "Work Preparation")
    }
    
    // Task status translations
    var notStarted: String {
        isVietnamese ? "Chưa Bắt Đầu" : (isSpanish ? "No Iniciado" : "Not Started")
    }
    
    var inProgress: String {
        isVietnamese ? "Đang Thực Hiện" : (isSpanish ? "En Progreso" : "In Progress")
    }
    
    var completed: String {
        isVietnamese ? "Hoàn Thành" : (isSpanish ? "Completado" : "Completed")
    }
}

private struct TranslationsKey: EnvironmentKey {
    static let defaultValue = Translations.shared
}

extension EnvironmentValues {
    var translations: Translations {
        get { self[TranslationsKey.self] }
        set { self[TranslationsKey.self] = newValue }
    }
} 
