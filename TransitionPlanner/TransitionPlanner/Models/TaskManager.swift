import Foundation

class TaskManager: ObservableObject {
    @Published var tasks: [Task] {
        didSet {
            saveTasks()
        }
    }
    @Published var childBirthday: Date {
        didSet {
            updateTaskStatuses()
            saveChildBirthday()
        }
    }
    @Published var isSpanish: Bool = false {
        didSet {
            print("TaskManager language changed to: \(isSpanish ? "Spanish" : "English")")
            updateTaskTitles()
        }
    }
    
    private let tasksKey = "SavedTasks"
    private let birthdayKey = "SavedBirthday"
    
    var childAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: childBirthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    init(childBirthday: Date = Calendar.current.date(byAdding: .year, value: -12, to: Date()) ?? Date()) {
        // Load saved tasks or create initial tasks if none exist
        if let savedTasksData = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasksData) {
            self.tasks = decodedTasks
        } else {
            self.tasks = TaskManager.createInitialTasks()
        }
        
        // Load saved birthday or use default
        if let savedBirthday = UserDefaults.standard.object(forKey: birthdayKey) as? Date {
            self.childBirthday = savedBirthday
        } else {
            self.childBirthday = childBirthday
        }
        
        updateTaskStatuses()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func saveChildBirthday() {
        UserDefaults.standard.set(childBirthday, forKey: birthdayKey)
    }
    
    func updateTaskStatuses() {
        tasks = tasks.map { task in
            var updatedTask = task
            if childAge < task.startAge {
                if task.status == .notStarted {
                    updatedTask.status = .notStarted
                }
            }
            return updatedTask
        }
    }
    
    func updateTaskStatus(_ task: Task, newStatus: Task.TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = newStatus
        }
    }
    
    func updateTaskNotes(_ task: Task, notes: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].notes = notes
        }
    }
    
    func toggleWorkInProgress(_ task: Task, value: Bool? = nil) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if let value = value {
                tasks[index].isWorkInProgress = value
            } else {
                tasks[index].isWorkInProgress.toggle()
            }
        }
    }
    
    func resetToDefaultTasks() {
        tasks = TaskManager.createInitialTasks()
        UserDefaults.standard.removeObject(forKey: tasksKey)
    }
    
    static func createInitialTasks() -> [Task] {
        return [
            // Transition Planning (exactly 8 tasks)
            // Under 12 (1 task)
            Task(title: "IEP Participation",
                 description: "Have your child participate at IEP meetings and learn about student-led IEPs to build self-advocacy skills",
                 category: .transitionPlanning,
                 startAge: 0,
                 endAge: 12),
            
            // 12-16 (3 tasks)
            Task(title: "Disability Understanding",
                 description: "Teach child about their disability and work together to identify their personal strengths and needs",
                 category: .transitionPlanning,
                 startAge: 12,
                 endAge: 16),
            
            Task(title: "Transition Plan",
                 description: "Learn about Individual Transition Plan (ITP) and engage with 504 team about transition planning strategies",
                 category: .transitionPlanning,
                 startAge: 12,
                 endAge: 16),
            
            Task(title: "Self-Care Skills",
                 description: "Develop self-care routines and build responsibility through assigned household chores",
                 category: .transitionPlanning,
                 startAge: 12,
                 endAge: 16),
            
            // 16-18 (2 tasks)
            Task(title: "Graduation Options",
                 description: "Explore options for high school completion: standard diploma, alternative pathway, or certificate of completion",
                 category: .transitionPlanning,
                 startAge: 16,
                 endAge: 18),
            
            Task(title: "ITP Review",
                 description: "Create and frequently review a robust Individual Transition Plan, including input from 504 team for transition planning",
                 category: .transitionPlanning,
                 startAge: 16,
                 endAge: 18),
            
            // 18-22 (2 tasks)
            Task(title: "Post-High School",
                 description: "Research and apply for college and explore other post-high school programs and opportunities",
                 category: .transitionPlanning,
                 startAge: 18,
                 endAge: 22),
            
            Task(title: "Legal Documents",
                 description: "Obtain necessary identification and complete civic responsibilities: Driver's License/ID, Passport, Register to Vote, Selective Service",
                 category: .transitionPlanning,
                 startAge: 18,
                 endAge: 22),
            
            // Education and Training
            // 12-16
            Task(title: "Annual Assessments",
                 description: "Complete transition assessments including interest/career inventories, independent living skills, education/training needs, and employment readiness",
                 category: .educationTraining,
                 startAge: 12,
                 endAge: 16),
            
            // 16-18
            Task(title: "Decision Making",
                 description: "Evaluate youth's ability to make decisions at age 18 and explore appropriate support options if needed",
                 category: .educationTraining,
                 startAge: 16,
                 endAge: 18),
            
            Task(title: "Letter of Intent",
                 description: "Create a Letter of Intent documenting wishes and preferences, and establish a process for annual review",
                 category: .educationTraining,
                 startAge: 16,
                 endAge: 18),
            
            // 18-22
            Task(title: "Healthcare Plan",
                 description: "Plan transition from pediatric to adult healthcare, including insurance coverage review and rider of continued eligibility",
                 category: .educationTraining,
                 startAge: 18,
                 endAge: 22),
            
            // Adult Life
            // 12-16
            Task(title: "Support Services",
                 description: "Research adult support options including Department of Rehabilitation, Regional Center, education/training, housing, and assistive technology",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 16),
            
            Task(title: "Public Benefits",
                 description: "Research eligibility and application process for CalFresh, IHSS, SSI, MediCal, Medicare, and other public benefits",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 16),
            
            Task(title: "Financial Planning",
                 description: "Explore financial and estate planning options: ABLE accounts, special needs trusts, conservatorship, power of attorney, and supported decision making",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 16),
            
            // 16-18
            Task(title: "Transportation",
                 description: "Develop comprehensive strategies for independent transportation and mobility in the community",
                 category: .adultLife,
                 startAge: 16,
                 endAge: 18),
            
            // 18-22
            Task(title: "Regional Center",
                 description: "For Regional Center clients: Understand available post-secondary services and explore Self-Determination program options",
                 category: .adultLife,
                 startAge: 18,
                 endAge: 22),
            
            Task(title: "Support Team",
                 description: "Build a comprehensive network of supporters and caregivers to provide continued support in the future",
                 category: .adultLife,
                 startAge: 18,
                 endAge: 22),
            
            // Ongoing/22+
            Task(title: "Independence Skills",
                 description: "Build and maintain independence in daily living, including choice-making, communication, living skills, and other key areas",
                 category: .adultLife,
                 startAge: 22,
                 endAge: 99),
            
            // Self-Advocacy
            // Under 12
            Task(title: "Self-Advocacy",
                 description: "Develop early self-advocacy skills through strength-based person centered planning and create a person centered plan",
                 category: .selfAdvocacy,
                 startAge: 0,
                 endAge: 12),
            
            // 12-16
            Task(title: "Assistive Tech",
                 description: "Research and implement assistive technology tools that can increase participation and create new opportunities",
                 category: .selfAdvocacy,
                 startAge: 12,
                 endAge: 16),
            
            // 16-18
            Task(title: "Health Education",
                 description: "Address important developmental topics including puberty, sexuality, and personal safety",
                 category: .selfAdvocacy,
                 startAge: 16,
                 endAge: 18),
            
            // 18-22
            Task(title: "Disability Rights",
                 description: "Learn about the history and importance of disability rights movements and advocacy",
                 category: .selfAdvocacy,
                 startAge: 18,
                 endAge: 22),
            
            // Work Preparation
            // 12-16
            Task(title: "Work Programs",
                 description: "Explore WorkAbility, transition partnerships, and Department of Rehabilitation services including student and supportive employment options",
                 category: .workPreparation,
                 startAge: 12,
                 endAge: 16),
            
            // 16-18
            Task(title: "Career Goals",
                 description: "Develop post-secondary employment goals as part of your ITP and create a comprehensive career plan to review regularly",
                 category: .workPreparation,
                 startAge: 16,
                 endAge: 18),
            
            // 18-22
            Task(title: "Work Experience",
                 description: "Build practical work experience through internships, volunteer work, or jobs. Practice job applications and resume writing",
                 category: .workPreparation,
                 startAge: 18,
                 endAge: 22),
            
            Task(title: "Employment Support",
                 description: "For Regional Center clients: Explore supportive employment services and opportunities in the Paid Internship program",
                 category: .workPreparation,
                 startAge: 18,
                 endAge: 22)
        ]
    }
    
    private func updateTaskTitles() {
        tasks = tasks.map { task in
            var updatedTask = task
            switch task.title {
            case "IEP Participation":
                updatedTask.title = isSpanish ? "Participación en el IEP" : "IEP Participation"
                updatedTask.description = isSpanish ? 
                    "Haga que su hijo participe en las reuniones del IEP y aprenda sobre IEP dirigidos por estudiantes para desarrollar habilidades de autodefensa" :
                    "Have your child participate at IEP meetings and learn about student-led IEPs to build self-advocacy skills"
            case "Disability Understanding":
                updatedTask.title = isSpanish ? "Comprensión de la Discapacidad" : "Disability Understanding"
                updatedTask.description = isSpanish ?
                    "Enseñe al niño sobre su discapacidad y trabajen juntos para identificar sus fortalezas y necesidades personales" :
                    "Teach child about their disability and work together to identify their personal strengths and needs"
            case "Transition Plan":
                updatedTask.title = isSpanish ? "Plan de Transición" : "Transition Plan"
                updatedTask.description = isSpanish ?
                    "Aprenda sobre el Plan de Transición Individual (ITP) y participe con el equipo 504 sobre estrategias de planificación de transición" :
                    "Learn about Individual Transition Plan (ITP) and engage with 504 team about transition planning strategies"
            case "Self-Care Skills":
                updatedTask.title = isSpanish ? "Habilidades de Autocuidado" : "Self-Care Skills"
                updatedTask.description = isSpanish ?
                    "Desarrollar rutinas de autocuidado y construir responsabilidad a través de tareas domésticas asignadas" :
                    "Develop self-care routines and build responsibility through assigned household chores"
            case "Graduation Options":
                updatedTask.title = isSpanish ? "Opciones de Graduación" : "Graduation Options"
                updatedTask.description = isSpanish ?
                    "Explorar opciones para la finalización de la escuela secundaria: diploma estándar, ruta alternativa o certificado de finalización" :
                    "Explore options for high school completion: standard diploma, alternative pathway, or certificate of completion"
            case "ITP Review":
                updatedTask.title = isSpanish ? "Revisión del ITP" : "ITP Review"
                updatedTask.description = isSpanish ?
                    "Crear y revisar frecuentemente un Plan de Transición Individual robusto, incluyendo aportes del equipo 504 para la planificación de transición" :
                    "Create and frequently review a robust Individual Transition Plan, including input from 504 team for transition planning"
            case "Post-High School":
                updatedTask.title = isSpanish ? "Después de la Secundaria" : "Post-High School"
                updatedTask.description = isSpanish ?
                    "Investigar y solicitar ingreso a la universidad y explorar otros programas y oportunidades después de la secundaria" :
                    "Research and apply for college and explore other post-high school programs and opportunities"
            case "Legal Documents":
                updatedTask.title = isSpanish ? "Documentos Legales" : "Legal Documents"
                updatedTask.description = isSpanish ?
                    "Obtener identificación necesaria y completar responsabilidades cívicas: Licencia de Conducir/ID, Pasaporte, Registro para Votar, Servicio Selectivo" :
                    "Obtain necessary identification and complete civic responsibilities: Driver's License/ID, Passport, Register to Vote, Selective Service"
            case "Annual Assessments":
                updatedTask.title = isSpanish ? "Evaluaciones Anuales" : "Annual Assessments"
                updatedTask.description = isSpanish ?
                    "Completar evaluaciones de transición incluyendo inventarios de intereses/carreras, habilidades de vida independiente, necesidades de educación/capacitación y preparación para el empleo" :
                    "Complete transition assessments including interest/career inventories, independent living skills, education/training needs, and employment readiness"
            case "Decision Making":
                updatedTask.title = isSpanish ? "Toma de Decisiones" : "Decision Making"
                updatedTask.description = isSpanish ?
                    "Evaluar la capacidad del joven para tomar decisiones a los 18 años y explorar opciones de apoyo apropiadas si es necesario" :
                    "Evaluate youth's ability to make decisions at age 18 and explore appropriate support options if needed"
            case "Letter of Intent":
                updatedTask.title = isSpanish ? "Carta de Intención" : "Letter of Intent"
                updatedTask.description = isSpanish ?
                    "Crear una Carta de Intención documentando deseos y preferencias, y establecer un proceso para revisión anual" :
                    "Create a Letter of Intent documenting wishes and preferences, and establish a process for annual review"
            case "Healthcare Plan":
                updatedTask.title = isSpanish ? "Plan de Salud" : "Healthcare Plan"
                updatedTask.description = isSpanish ?
                    "Planificar la transición de atención médica pediátrica a adulta, incluyendo revisión de cobertura de seguro y continuación de elegibilidad" :
                    "Plan transition from pediatric to adult healthcare, including insurance coverage review and rider of continued eligibility"
            case "Support Services":
                updatedTask.title = isSpanish ? "Servicios de Apoyo" : "Support Services"
                updatedTask.description = isSpanish ?
                    "Investigar opciones de apoyo para adultos incluyendo Departamento de Rehabilitación, Centro Regional, educación/capacitación, vivienda y tecnología asistiva" :
                    "Research adult support options including Department of Rehabilitation, Regional Center, education/training, housing, and assistive technology"
            case "Public Benefits":
                updatedTask.title = isSpanish ? "Beneficios Públicos" : "Public Benefits"
                updatedTask.description = isSpanish ?
                    "Investigar elegibilidad y proceso de solicitud para CalFresh, IHSS, SSI, MediCal, Medicare y otros beneficios públicos" :
                    "Research eligibility and application process for CalFresh, IHSS, SSI, MediCal, Medicare, and other public benefits"
            case "Financial Planning":
                updatedTask.title = isSpanish ? "Planificación Financiera" : "Financial Planning"
                updatedTask.description = isSpanish ?
                    "Explorar opciones de planificación financiera y patrimonial: cuentas ABLE, fideicomisos de necesidades especiales, tutela, poder notarial y toma de decisiones con apoyo" :
                    "Explore financial and estate planning options: ABLE accounts, special needs trusts, conservatorship, power of attorney, and supported decision making"
            case "Transportation":
                updatedTask.title = isSpanish ? "Transporte" : "Transportation"
                updatedTask.description = isSpanish ?
                    "Desarrollar estrategias integrales para transporte independiente y movilidad en la comunidad" :
                    "Develop comprehensive strategies for independent transportation and mobility in the community"
            case "Regional Center":
                updatedTask.title = isSpanish ? "Centro Regional" : "Regional Center"
                updatedTask.description = isSpanish ?
                    "Para clientes del Centro Regional: Entender servicios post-secundarios disponibles y explorar opciones del programa de Autodeterminación" :
                    "For Regional Center clients: Understand available post-secondary services and explore Self-Determination program options"
            case "Support Team":
                updatedTask.title = isSpanish ? "Equipo de Apoyo" : "Support Team"
                updatedTask.description = isSpanish ?
                    "Construir una red integral de partidarios y cuidadores para proporcionar apoyo continuo en el futuro" :
                    "Build a comprehensive network of supporters and caregivers to provide continued support in the future"
            case "Independence Skills":
                updatedTask.title = isSpanish ? "Habilidades de Independencia" : "Independence Skills"
                updatedTask.description = isSpanish ?
                    "Construir y mantener independencia en la vida diaria, incluyendo toma de decisiones, comunicación, habilidades de vida y otras áreas clave" :
                    "Build and maintain independence in daily living, including choice-making, communication, living skills, and other key areas"
            case "Self-Advocacy":
                updatedTask.title = isSpanish ? "Autodefensa" : "Self-Advocacy"
                updatedTask.description = isSpanish ?
                    "Desarrollar habilidades tempranas de autodefensa a través de planificación centrada en la persona basada en fortalezas y crear un plan centrado en la persona" :
                    "Develop early self-advocacy skills through strength-based person centered planning and create a person centered plan"
            case "Assistive Tech":
                updatedTask.title = isSpanish ? "Tecnología Asistiva" : "Assistive Tech"
                updatedTask.description = isSpanish ?
                    "Investigar e implementar herramientas de tecnología asistiva que pueden aumentar la participación y crear nuevas oportunidades" :
                    "Research and implement assistive technology tools that can increase participation and create new opportunities"
            case "Health Education":
                updatedTask.title = isSpanish ? "Educación para la Salud" : "Health Education"
                updatedTask.description = isSpanish ?
                    "Abordar temas importantes del desarrollo incluyendo pubertad, sexualidad y seguridad personal" :
                    "Address important developmental topics including puberty, sexuality, and personal safety"
            case "Disability Rights":
                updatedTask.title = isSpanish ? "Derechos de Discapacidad" : "Disability Rights"
                updatedTask.description = isSpanish ?
                    "Aprender sobre la historia e importancia de los movimientos y la defensa de los derechos de discapacidad" :
                    "Learn about the history and importance of disability rights movements and advocacy"
            case "Work Programs":
                updatedTask.title = isSpanish ? "Programas de Trabajo" : "Work Programs"
                updatedTask.description = isSpanish ?
                    "Explorar WorkAbility, asociaciones de transición y servicios del Departamento de Rehabilitación incluyendo opciones de empleo estudiantil y de apoyo" :
                    "Explore WorkAbility, transition partnerships, and Department of Rehabilitation services including student and supportive employment options"
            case "Career Goals":
                updatedTask.title = isSpanish ? "Objetivos de Carrera" : "Career Goals"
                updatedTask.description = isSpanish ?
                    "Desarrollar objetivos de empleo post-secundario como parte de su ITP y crear un plan de carrera integral para revisar regularmente" :
                    "Develop post-secondary employment goals as part of your ITP and create a comprehensive career plan to review regularly"
            case "Work Experience":
                updatedTask.title = isSpanish ? "Experiencia Laboral" : "Work Experience"
                updatedTask.description = isSpanish ?
                    "Construir experiencia laboral práctica a través de pasantías, trabajo voluntario o empleos. Practicar solicitudes de trabajo y escritura de currículum" :
                    "Build practical work experience through internships, volunteer work, or jobs. Practice job applications and resume writing"
            case "Employment Support":
                updatedTask.title = isSpanish ? "Apoyo al Empleo" : "Employment Support"
                updatedTask.description = isSpanish ?
                    "Para clientes del Centro Regional: Explorar servicios de empleo de apoyo y oportunidades en el programa de Pasante Pagado" :
                    "For Regional Center clients: Explore supportive employment services and opportunities in the Paid Internship program"
            default:
                break
            }
            return updatedTask
        }
    }
} 
