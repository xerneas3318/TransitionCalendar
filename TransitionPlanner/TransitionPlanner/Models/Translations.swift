import Foundation
import SwiftUI

struct Translations {
    static let shared = Translations()
    static var isSpanish: Bool = false {
        didSet {
            print("Language changed to: \(isSpanish ? "Spanish" : "English")")
        }
    }
    
    private var isSpanish = false
    
    mutating func setLanguage(_ spanish: Bool) {
        isSpanish = spanish
        Translations.isSpanish = spanish
    }
    
    var title: String {
        isSpanish ? "PHP Planificador" : "PHP Planner"
    }
    
    var settings: String {
        isSpanish ? "Ajustes" : "Settings"
    }
    
    var done: String {
        isSpanish ? "Hecho" : "Done"
    }
    
    var resetTasks: String {
        isSpanish ? "Restablecer Tareas" : "Reset Tasks"
    }
    
    var resetConfirmation: String {
        isSpanish ? "¿Está seguro de que desea restablecer todas las tareas a su estado predeterminado? Esta acción no se puede deshacer." : "Are you sure you want to reset all tasks to their default state? This action cannot be undone."
    }
    
    var cancel: String {
        isSpanish ? "Cancelar" : "Cancel"
    }
    
    var reset: String {
        isSpanish ? "Restablecer" : "Reset"
    }
    
    var childBirthDate: String {
        isSpanish ? "Fecha de Nacimiento del Niño" : "Child's Birth Date"
    }
    
    var resetToDefault: String {
        isSpanish ? "Restablecer a Tareas Predeterminadas" : "Reset to Default Tasks"
    }
    
    var changeToSpanish: String {
        isSpanish ? "Cambiar a Inglés" : "Change to Spanish"
    }
    
    var under12: String {
        isSpanish ? "< 12" : "Under 12"
    }
    
    var ageRange12to16: String {
        isSpanish ? "12 - 16" : "12 - 16"
    }
    
    var ageRange16to18: String {
        isSpanish ? "16 - 18" : "16 - 18"
    }
    
    var ageRange18to22: String {
        isSpanish ? "18 - 22" : "18 - 22"
    }
    
    var ageRange22plus: String {
        isSpanish ? "22+" : "22+"
    }
    
    // Category translations
    var transitionPlanning: String {
        isSpanish ? "Planificación de Transición" : "Transition Planning"
    }
    
    var educationTraining: String {
        isSpanish ? "Educación y Capacitación" : "Education and Training"
    }
    
    var adultLife: String {
        isSpanish ? "Vida Adulta" : "Adult Life"
    }
    
    var selfAdvocacy: String {
        isSpanish ? "Auto-Defensa" : "Self-Advocacy"
    }
    
    var workPreparation: String {
        isSpanish ? "Preparación para el Trabajo" : "Work Preparation"
    }
    
    // Task status translations
    var notStarted: String {
        isSpanish ? "No Iniciado" : "Not Started"
    }
    
    var inProgress: String {
        isSpanish ? "En Progreso" : "In Progress"
    }
    
    var completed: String {
        isSpanish ? "Completado" : "Completed"
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