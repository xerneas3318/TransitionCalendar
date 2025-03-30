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
    
    @Published var isVietnamese: Bool = false {
        didSet {
            print("TaskManager language changed to: \(isVietnamese ? "Vietnamese" : "English")")
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
        
        // Reset tasks to English titles first
        self.tasks = TaskManager.createInitialTasks()
        
        // Then update based on current language setting
        if isSpanish || isVietnamese {
            updateTaskTitles()
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
            
            // Transition Planning
            if task.title == "IEP Participation" {
                updatedTask.title = isVietnamese ? "Tham Gia IEP" : (isSpanish ? "Participación en el IEP" : "IEP Participation")
                updatedTask.description = isVietnamese ? "Cho con bạn tham gia các cuộc họp IEP và tìm hiểu về IEP do học sinh lãnh đạo để xây dựng kỹ năng tự vận động" : (isSpanish ? "Haga que su hijo participe en las reuniones del IEP y aprenda sobre IEP dirigidos por estudiantes para desarrollar habilidades de auto-defensa" : "Have your child participate at IEP meetings and learn about student-led IEPs to build self-advocacy skills")
            } else if task.title == "Tham Gia IEP" || task.title == "Participación en el IEP" {
                updatedTask.title = isVietnamese ? "Tham Gia IEP" : (isSpanish ? "Participación en el IEP" : "IEP Participation")
                updatedTask.description = isVietnamese ? "Cho con bạn tham gia các cuộc họp IEP và tìm hiểu về IEP do học sinh lãnh đạo để xây dựng kỹ năng tự vận động" : (isSpanish ? "Haga que su hijo participe en las reuniones del IEP y aprenda sobre IEP dirigidos por estudiantes para desarrollar habilidades de auto-defensa" : "Have your child participate at IEP meetings and learn about student-led IEPs to build self-advocacy skills")
            } else if task.title == "Disability Understanding" {
                updatedTask.title = isVietnamese ? "Hiểu về Khuyết Tật" : (isSpanish ? "Comprensión de la Discapacidad" : "Disability Understanding")
                updatedTask.description = isVietnamese ? "Dạy con về khuyết tật của chúng và cùng nhau xác định điểm mạnh và nhu cầu cá nhân" : (isSpanish ? "Enseñe al niño sobre su discapacidad y trabajen juntos para identificar sus fortalezas y necesidades personales" : "Teach child about their disability and work together to identify their personal strengths and needs")
            } else if task.title == "Hiểu về Khuyết Tật" || task.title == "Comprensión de la Discapacidad" {
                updatedTask.title = isVietnamese ? "Hiểu về Khuyết Tật" : (isSpanish ? "Comprensión de la Discapacidad" : "Disability Understanding")
                updatedTask.description = isVietnamese ? "Dạy con về khuyết tật của chúng và cùng nhau xác định điểm mạnh và nhu cầu cá nhân" : (isSpanish ? "Enseñe al niño sobre su discapacidad y trabajen juntos para identificar sus fortalezas y necesidades personales" : "Teach child about their disability and work together to identify their personal strengths and needs")
            } else if task.title == "Transition Plan" {
                updatedTask.title = isVietnamese ? "Kế Hoạch Chuyển Tiếp" : (isSpanish ? "Plan de Transición" : "Transition Plan")
                updatedTask.description = isVietnamese ? "Tìm hiểu về Kế Hoạch Chuyển Tiếp Cá Nhân (ITP) và tham gia với nhóm 504 về các chiến lược lập kế hoạch chuyển tiếp" : (isSpanish ? "Aprenda sobre el Plan de Transición Individual (ITP) y participe con el equipo 504 sobre estrategias de planificación de transición" : "Learn about Individual Transition Plan (ITP) and engage with 504 team about transition planning strategies")
            } else if task.title == "Kế Hoạch Chuyển Tiếp" || task.title == "Plan de Transición" {
                updatedTask.title = isVietnamese ? "Kế Hoạch Chuyển Tiếp" : (isSpanish ? "Plan de Transición" : "Transition Plan")
                updatedTask.description = isVietnamese ? "Tìm hiểu về Kế Hoạch Chuyển Tiếp Cá Nhân (ITP) và tham gia với nhóm 504 về các chiến lược lập kế hoạch chuyển tiếp" : (isSpanish ? "Aprenda sobre el Plan de Transición Individual (ITP) y participe con el equipo 504 sobre estrategias de planificación de transición" : "Learn about Individual Transition Plan (ITP) and engage with 504 team about transition planning strategies")
            } else if task.title == "Self-Care Skills" {
                updatedTask.title = isVietnamese ? "Kỹ Năng Tự Chăm Sóc" : (isSpanish ? "Habilidades de Autocuidado" : "Self-Care Skills")
                updatedTask.description = isVietnamese ? "Phát triển thói quen tự chăm sóc và xây dựng trách nhiệm thông qua các công việc nhà được giao" : (isSpanish ? "Desarrolle rutinas de autocuidado y construya responsabilidad a través de tareas domésticas asignadas" : "Develop self-care routines and build responsibility through assigned household chores")
            } else if task.title == "Kỹ Năng Tự Chăm Sóc" || task.title == "Habilidades de Autocuidado" {
                updatedTask.title = isVietnamese ? "Kỹ Năng Tự Chăm Sóc" : (isSpanish ? "Habilidades de Autocuidado" : "Self-Care Skills")
                updatedTask.description = isVietnamese ? "Phát triển thói quen tự chăm sóc và xây dựng trách nhiệm thông qua các công việc nhà được giao" : (isSpanish ? "Desarrolle rutinas de autocuidado y construya responsabilidad a través de tareas domésticas asignadas" : "Develop self-care routines and build responsibility through assigned household chores")
            } else if task.title == "Graduation Options" {
                updatedTask.title = isVietnamese ? "Lựa Chọn Tốt Nghiệp" : (isSpanish ? "Opciones de Graduación" : "Graduation Options")
                updatedTask.description = isVietnamese ? "Khám phá các lựa chọn để hoàn thành trung học: bằng tốt nghiệp tiêu chuẩn, con đường thay thế hoặc chứng chỉ hoàn thành" : (isSpanish ? "Explore opciones para completar la preparatoria: diploma estándar, ruta alternativa o certificado de finalización" : "Explore options for high school completion: standard diploma, alternative pathway, or certificate of completion")
            } else if task.title == "Lựa Chọn Tốt Nghiệp" || task.title == "Opciones de Graduación" {
                updatedTask.title = isVietnamese ? "Lựa Chọn Tốt Nghiệp" : (isSpanish ? "Opciones de Graduación" : "Graduation Options")
                updatedTask.description = isVietnamese ? "Khám phá các lựa chọn để hoàn thành trung học: bằng tốt nghiệp tiêu chuẩn, con đường thay thế hoặc chứng chỉ hoàn thành" : (isSpanish ? "Explore opciones para completar la preparatoria: diploma estándar, ruta alternativa o certificado de finalización" : "Explore options for high school completion: standard diploma, alternative pathway, or certificate of completion")
            } else if task.title == "ITP Review" {
                updatedTask.title = isVietnamese ? "Xem Xét ITP" : (isSpanish ? "Revisión del ITP" : "ITP Review")
                updatedTask.description = isVietnamese ? "Tạo và thường xuyên xem xét Kế Hoạch Chuyển Tiếp Cá Nhân toàn diện, bao gồm đóng góp từ nhóm 504 cho việc lập kế hoạch chuyển tiếp" : (isSpanish ? "Cree y revise frecuentemente un Plan de Transición Individual robusto, incluyendo aportes del equipo 504 para la planificación de transición" : "Create and frequently review a robust Individual Transition Plan, including input from 504 team for transition planning")
            } else if task.title == "Xem Xét ITP" || task.title == "Revisión del ITP" {
                updatedTask.title = isVietnamese ? "Xem Xét ITP" : (isSpanish ? "Revisión del ITP" : "ITP Review")
                updatedTask.description = isVietnamese ? "Tạo và thường xuyên xem xét Kế Hoạch Chuyển Tiếp Cá Nhân toàn diện, bao gồm đóng góp từ nhóm 504 cho việc lập kế hoạch chuyển tiếp" : (isSpanish ? "Cree y revise frecuentemente un Plan de Transición Individual robusto, incluyendo aportes del equipo 504 para la planificación de transición" : "Create and frequently review a robust Individual Transition Plan, including input from 504 team for transition planning")
            } else if task.title == "Post-High School" {
                updatedTask.title = isVietnamese ? "Sau Trung Học" : (isSpanish ? "Después de la Secundaria" : "Post-High School")
                updatedTask.description = isVietnamese ? "Nghiên cứu và nộp đơn vào đại học và khám phá các chương trình và cơ hội khác sau trung học" : (isSpanish ? "Investigue y solicite ingreso a la universidad y explore otros programas y oportunidades después de la preparatoria" : "Research and apply for college and explore other post-high school programs and opportunities")
            } else if task.title == "Sau Trung Học" || task.title == "Después de la Secundaria" {
                updatedTask.title = isVietnamese ? "Sau Trung Học" : (isSpanish ? "Después de la Secundaria" : "Post-High School")
                updatedTask.description = isVietnamese ? "Nghiên cứu và nộp đơn vào đại học và khám phá các chương trình và cơ hội khác sau trung học" : (isSpanish ? "Investigue y solicite ingreso a la universidad y explore otros programas y oportunidades después de la preparatoria" : "Research and apply for college and explore other post-high school programs and opportunities")
            } else if task.title == "Legal Documents" {
                updatedTask.title = isVietnamese ? "Giấy Tờ Pháp Lý" : (isSpanish ? "Documentos Legales" : "Legal Documents")
                updatedTask.description = isVietnamese ? "Lấy giấy tờ tùy thân cần thiết và hoàn thành trách nhiệm công dân: Bằng Lái/ID, Hộ Chiếu, Đăng Ký Bầu Cử, Nghĩa Vụ Quân Sự" : (isSpanish ? "Obtenga la identificación necesaria y complete responsabilidades cívicas: Licencia de Conducir/ID, Pasaporte, Registro para Votar, Servicio Selectivo" : "Obtain necessary identification and complete civic responsibilities: Driver's License/ID, Passport, Register to Vote, Selective Service")
            } else if task.title == "Giấy Tờ Pháp Lý" || task.title == "Documentos Legales" {
                updatedTask.title = isVietnamese ? "Giấy Tờ Pháp Lý" : (isSpanish ? "Documentos Legales" : "Legal Documents")
                updatedTask.description = isVietnamese ? "Lấy giấy tờ tùy thân cần thiết và hoàn thành trách nhiệm công dân: Bằng Lái/ID, Hộ Chiếu, Đăng Ký Bầu Cử, Nghĩa Vụ Quân Sự" : (isSpanish ? "Obtenga la identificación necesaria y complete responsabilidades cívicas: Licencia de Conducir/ID, Pasaporte, Registro para Votar, Servicio Selectivo" : "Obtain necessary identification and complete civic responsibilities: Driver's License/ID, Passport, Register to Vote, Selective Service")
            }
            
            // Education and Training
            else if task.title == "Annual Assessments" {
                updatedTask.title = isVietnamese ? "Đánh Giá Hàng Năm" : (isSpanish ? "Evaluaciones Anuales" : "Annual Assessments")
                updatedTask.description = isVietnamese ? "Hoàn thành đánh giá chuyển tiếp bao gồm kiểm kê sở thích/nghề nghiệp, kỹ năng sống độc lập, nhu cầu giáo dục/đào tạo và sẵn sàng việc làm" : (isSpanish ? "Complete evaluaciones de transición incluyendo inventarios de intereses/carreras, habilidades de vida independiente, necesidades de educación/entrenamiento y preparación para el empleo" : "Complete transition assessments including interest/career inventories, independent living skills, education/training needs, and employment readiness")
            } else if task.title == "Đánh Giá Hàng Năm" || task.title == "Evaluaciones Anuales" {
                updatedTask.title = isVietnamese ? "Đánh Giá Hàng Năm" : (isSpanish ? "Evaluaciones Anuales" : "Annual Assessments")
                updatedTask.description = isVietnamese ? "Hoàn thành đánh giá chuyển tiếp bao gồm kiểm kê sở thích/nghề nghiệp, kỹ năng sống độc lập, nhu cầu giáo dục/đào tạo và sẵn sàng việc làm" : (isSpanish ? "Complete evaluaciones de transición incluyendo inventarios de intereses/carreras, habilidades de vida independiente, necesidades de educación/entrenamiento y preparación para el empleo" : "Complete transition assessments including interest/career inventories, independent living skills, education/training needs, and employment readiness")
            } else if task.title == "Decision Making" {
                updatedTask.title = isVietnamese ? "Ra Quyết Định" : (isSpanish ? "Toma de Decisiones" : "Decision Making")
                updatedTask.description = isVietnamese ? "Đánh giá khả năng ra quyết định của thanh niên ở tuổi 18 và khám phá các lựa chọn hỗ trợ phù hợp nếu cần" : (isSpanish ? "Evalúe la capacidad del joven para tomar decisiones a los 18 años y explore opciones de apoyo apropiadas si es necesario" : "Evaluate youth's ability to make decisions at age 18 and explore appropriate support options if needed")
            } else if task.title == "Ra Quyết Định" || task.title == "Toma de Decisiones" {
                updatedTask.title = isVietnamese ? "Ra Quyết Định" : (isSpanish ? "Toma de Decisiones" : "Decision Making")
                updatedTask.description = isVietnamese ? "Đánh giá khả năng ra quyết định của thanh niên ở tuổi 18 và khám phá các lựa chọn hỗ trợ phù hợp nếu cần" : (isSpanish ? "Evalúe la capacidad del joven para tomar decisiones a los 18 años y explore opciones de apoyo apropiadas si es necesario" : "Evaluate youth's ability to make decisions at age 18 and explore appropriate support options if needed")
            } else if task.title == "Letter of Intent" {
                updatedTask.title = isVietnamese ? "Thư Nguyện Vọng" : (isSpanish ? "Carta de Intención" : "Letter of Intent")
                updatedTask.description = isVietnamese ? "Tạo Thư Nguyện Vọng ghi lại mong muốn và sở thích, và thiết lập quy trình xem xét hàng năm" : (isSpanish ? "Cree una Carta de Intención documentando deseos y preferencias, y establezca un proceso para revisión anual" : "Create a Letter of Intent documenting wishes and preferences, and establish a process for annual review")
            } else if task.title == "Thư Nguyện Vọng" || task.title == "Carta de Intención" {
                updatedTask.title = isVietnamese ? "Thư Nguyện Vọng" : (isSpanish ? "Carta de Intención" : "Letter of Intent")
                updatedTask.description = isVietnamese ? "Tạo Thư Nguyện Vọng ghi lại mong muốn và sở thích, và thiết lập quy trình xem xét hàng năm" : (isSpanish ? "Cree una Carta de Intención documentando deseos y preferencias, y establezca un proceso para revisión anual" : "Create a Letter of Intent documenting wishes and preferences, and establish a process for annual review")
            } else if task.title == "Healthcare Plan" {
                updatedTask.title = isVietnamese ? "Kế Hoạch Chăm Sóc Sức Khỏe" : (isSpanish ? "Plan de Salud" : "Healthcare Plan")
                updatedTask.description = isVietnamese ? "Lập kế hoạch chuyển tiếp từ chăm sóc sức khỏe nhi khoa sang người lớn, bao gồm xem xét bảo hiểm và điều khoản đủ điều kiện tiếp tục" : (isSpanish ? "Planee la transición de atención médica pediátrica a adulta, incluyendo revisión de cobertura de seguro y cláusula de elegibilidad continua" : "Plan transition from pediatric to adult healthcare, including insurance coverage review and rider of continued eligibility")
            } else if task.title == "Kế Hoạch Chăm Sóc Sức Khỏe" || task.title == "Plan de Salud" {
                updatedTask.title = isVietnamese ? "Kế Hoạch Chăm Sóc Sức Khỏe" : (isSpanish ? "Plan de Salud" : "Healthcare Plan")
                updatedTask.description = isVietnamese ? "Lập kế hoạch chuyển tiếp từ chăm sóc sức khỏe nhi khoa sang người lớn, bao gồm xem xét bảo hiểm và điều khoản đủ điều kiện tiếp tục" : (isSpanish ? "Planee la transición de atención médica pediátrica a adulta, incluyendo revisión de cobertura de seguro y cláusula de elegibilidad continua" : "Plan transition from pediatric to adult healthcare, including insurance coverage review and rider of continued eligibility")
            }
            
            // Adult Life
            else if task.title == "Support Services" {
                updatedTask.title = isVietnamese ? "Dịch Vụ Hỗ Trợ" : (isSpanish ? "Servicios de Apoyo" : "Support Services")
                updatedTask.description = isVietnamese ? "Nghiên cứu các lựa chọn hỗ trợ cho người lớn bao gồm Sở Phục Hồi Chức Năng, Trung Tâm Khu Vực, giáo dục/đào tạo, nhà ở và công nghệ hỗ trợ" : (isSpanish ? "Investigue opciones de apoyo para adultos incluyendo Departamento de Rehabilitación, Centro Regional, educación/entrenamiento, vivienda y tecnología asistiva" : "Research adult support options including Department of Rehabilitation, Regional Center, education/training, housing, and assistive technology")
            } else if task.title == "Dịch Vụ Hỗ Trợ" || task.title == "Servicios de Apoyo" {
                updatedTask.title = isVietnamese ? "Dịch Vụ Hỗ Trợ" : (isSpanish ? "Servicios de Apoyo" : "Support Services")
                updatedTask.description = isVietnamese ? "Nghiên cứu các lựa chọn hỗ trợ cho người lớn bao gồm Sở Phục Hồi Chức Năng, Trung Tâm Khu Vực, giáo dục/đào tạo, nhà ở và công nghệ hỗ trợ" : (isSpanish ? "Investigue opciones de apoyo para adultos incluyendo Departamento de Rehabilitación, Centro Regional, educación/entrenamiento, vivienda y tecnología asistiva" : "Research adult support options including Department of Rehabilitation, Regional Center, education/training, housing, and assistive technology")
            } else if task.title == "Public Benefits" {
                updatedTask.title = isVietnamese ? "Phúc Lợi Công Cộng" : (isSpanish ? "Beneficios Públicos" : "Public Benefits")
                updatedTask.description = isVietnamese ? "Nghiên cứu điều kiện và quy trình nộp đơn cho CalFresh, IHSS, SSI, MediCal, Medicare và các phúc lợi công cộng khác" : (isSpanish ? "Investigue elegibilidad y proceso de solicitud para CalFresh, IHSS, SSI, MediCal, Medicare y otros beneficios públicos" : "Research eligibility and application process for CalFresh, IHSS, SSI, MediCal, Medicare, and other public benefits")
            } else if task.title == "Phúc Lợi Công Cộng" || task.title == "Beneficios Públicos" {
                updatedTask.title = isVietnamese ? "Phúc Lợi Công Cộng" : (isSpanish ? "Beneficios Públicos" : "Public Benefits")
                updatedTask.description = isVietnamese ? "Nghiên cứu điều kiện và quy trình nộp đơn cho CalFresh, IHSS, SSI, MediCal, Medicare và các phúc lợi công cộng khác" : (isSpanish ? "Investigue elegibilidad y proceso de solicitud para CalFresh, IHSS, SSI, MediCal, Medicare y otros beneficios públicos" : "Research eligibility and application process for CalFresh, IHSS, SSI, MediCal, Medicare, and other public benefits")
            } else if task.title == "Financial Planning" {
                updatedTask.title = isVietnamese ? "Hoạch Định Tài Chính" : (isSpanish ? "Planificación Financiera" : "Financial Planning")
                updatedTask.description = isVietnamese ? "Khám phá các lựa chọn hoạch định tài chính và di sản: tài khoản ABLE, quỹ tín thác nhu cầu đặc biệt, bảo hộ, giấy ủy quyền và ra quyết định có hỗ trợ" : (isSpanish ? "Explore opciones de planificación financiera y patrimonial: cuentas ABLE, fideicomisos para necesidades especiales, tutela, poder notarial y toma de decisiones con apoyo" : "Explore financial and estate planning options: ABLE accounts, special needs trusts, conservatorship, power of attorney, and supported decision making")
            } else if task.title == "Hoạch Định Tài Chính" || task.title == "Planificación Financiera" {
                updatedTask.title = isVietnamese ? "Hoạch Định Tài Chính" : (isSpanish ? "Planificación Financiera" : "Financial Planning")
                updatedTask.description = isVietnamese ? "Khám phá các lựa chọn hoạch định tài chính và di sản: tài khoản ABLE, quỹ tín thác nhu cầu đặc biệt, bảo hộ, giấy ủy quyền và ra quyết định có hỗ trợ" : (isSpanish ? "Explore opciones de planificación financiera y patrimonial: cuentas ABLE, fideicomisos para necesidades especiales, tutela, poder notarial y toma de decisiones con apoyo" : "Explore financial and estate planning options: ABLE accounts, special needs trusts, conservatorship, power of attorney, and supported decision making")
            } else if task.title == "Transportation" {
                updatedTask.title = isVietnamese ? "Giao Thông" : (isSpanish ? "Transporte" : "Transportation")
                updatedTask.description = isVietnamese ? "Phát triển chiến lược toàn diện cho giao thông độc lập và di chuyển trong cộng đồng" : (isSpanish ? "Desarrolle estrategias integrales para transporte independiente y movilidad en la comunidad" : "Develop comprehensive strategies for independent transportation and mobility in the community")
            } else if task.title == "Giao Thông" || task.title == "Transporte" {
                updatedTask.title = isVietnamese ? "Giao Thông" : (isSpanish ? "Transporte" : "Transportation")
                updatedTask.description = isVietnamese ? "Phát triển chiến lược toàn diện cho giao thông độc lập và di chuyển trong cộng đồng" : (isSpanish ? "Desarrolle estrategias integrales para transporte independiente y movilidad en la comunidad" : "Develop comprehensive strategies for independent transportation and mobility in the community")
            } else if task.title == "Regional Center" {
                updatedTask.title = isVietnamese ? "Trung Tâm Khu Vực" : (isSpanish ? "Centro Regional" : "Regional Center")
                updatedTask.description = isVietnamese ? "Cho khách hàng Trung Tâm Khu Vực: Hiểu về các dịch vụ sau trung học có sẵn và khám phá các lựa chọn của chương trình Tự Quyết" : (isSpanish ? "Para clientes del Centro Regional: Entienda los servicios post-secundarios disponibles y explore opciones del programa de Auto-Determinación" : "For Regional Center clients: Understand available post-secondary services and explore Self-Determination program options")
            } else if task.title == "Trung Tâm Khu Vực" || task.title == "Centro Regional" {
                updatedTask.title = isVietnamese ? "Trung Tâm Khu Vực" : (isSpanish ? "Centro Regional" : "Regional Center")
                updatedTask.description = isVietnamese ? "Cho khách hàng Trung Tâm Khu Vực: Hiểu về các dịch vụ sau trung học có sẵn và khám phá các lựa chọn của chương trình Tự Quyết" : (isSpanish ? "Para clientes del Centro Regional: Entienda los servicios post-secundarios disponibles y explore opciones del programa de Auto-Determinación" : "For Regional Center clients: Understand available post-secondary services and explore Self-Determination program options")
            } else if task.title == "Support Team" {
                updatedTask.title = isVietnamese ? "Nhóm Hỗ Trợ" : (isSpanish ? "Equipo de Apoyo" : "Support Team")
                updatedTask.description = isVietnamese ? "Xây dựng mạng lưới toàn diện những người ủng hộ và người chăm sóc để cung cấp hỗ trợ liên tục trong tương lai" : (isSpanish ? "Construya una red integral de partidarios y cuidadores para proporcionar apoyo continuo en el futuro" : "Build a comprehensive network of supporters and caregivers to provide continued support in the future")
            } else if task.title == "Nhóm Hỗ Trợ" || task.title == "Equipo de Apoyo" {
                updatedTask.title = isVietnamese ? "Nhóm Hỗ Trợ" : (isSpanish ? "Equipo de Apoyo" : "Support Team")
                updatedTask.description = isVietnamese ? "Xây dựng mạng lưới toàn diện những người ủng hộ và người chăm sóc để cung cấp hỗ trợ liên tục trong tương lai" : (isSpanish ? "Construya una red integral de partidarios y cuidadores para proporcionar apoyo continuo en el futuro" : "Build a comprehensive network of supporters and caregivers to provide continued support in the future")
            } else if task.title == "Independence Skills" {
                updatedTask.title = isVietnamese ? "Kỹ Năng Độc Lập" : (isSpanish ? "Habilidades de Independencia" : "Independence Skills")
                updatedTask.description = isVietnamese ? "Phát triển và duy trì tính độc lập trong cuộc sống hàng ngày, bao gồm ra quyết định, giao tiếp, kỹ năng sống và các lĩnh vực quan trọng khác" : (isSpanish ? "Desarrolle y mantenga independencia en la vida diaria, incluyendo toma de decisiones, comunicación, habilidades de vida y otras áreas clave" : "Build and maintain independence in daily living, including choice-making, communication, living skills, and other key areas")
            } else if task.title == "Kỹ Năng Độc Lập" || task.title == "Habilidades de Independencia" {
                updatedTask.title = isVietnamese ? "Kỹ Năng Độc Lập" : (isSpanish ? "Habilidades de Independencia" : "Independence Skills")
                updatedTask.description = isVietnamese ? "Phát triển và duy trì tính độc lập trong cuộc sống hàng ngày, bao gồm ra quyết định, giao tiếp, kỹ năng sống và các lĩnh vực quan trọng khác" : (isSpanish ? "Desarrolle y mantenga independencia en la vida diaria, incluyendo toma de decisiones, comunicación, habilidades de vida y otras áreas clave" : "Build and maintain independence in daily living, including choice-making, communication, living skills, and other key areas")
            }
            
            // Self-Advocacy
            else if task.title == "Self-Advocacy" {
                updatedTask.title = isVietnamese ? "Tự Vận Động" : (isSpanish ? "Auto-Defensa" : "Self-Advocacy")
                updatedTask.description = isVietnamese ? "Phát triển kỹ năng tự vận động sớm thông qua lập kế hoạch lấy người dùng làm trung tâm dựa trên điểm mạnh và tạo kế hoạch lấy người dùng làm trung tâm" : (isSpanish ? "Desarrolle habilidades tempranas de auto-defensa a través de planificación centrada en la persona basada en fortalezas y cree un plan centrado en la persona" : "Develop early self-advocacy skills through strength-based person centered planning and create a person centered plan")
            } else if task.title == "Tự Vận Động" || task.title == "Auto-Defensa" {
                updatedTask.title = isVietnamese ? "Tự Vận Động" : (isSpanish ? "Auto-Defensa" : "Self-Advocacy")
                updatedTask.description = isVietnamese ? "Phát triển kỹ năng tự vận động sớm thông qua lập kế hoạch lấy người dùng làm trung tâm dựa trên điểm mạnh và tạo kế hoạch lấy người dùng làm trung tâm" : (isSpanish ? "Desarrolle habilidades tempranas de auto-defensa a través de planificación centrada en la persona basada en fortalezas y cree un plan centrado en la persona" : "Develop early self-advocacy skills through strength-based person centered planning and create a person centered plan")
            } else if task.title == "Assistive Tech" {
                updatedTask.title = isVietnamese ? "Công Nghệ Hỗ Trợ" : (isSpanish ? "Tecnología Asistiva" : "Assistive Tech")
                updatedTask.description = isVietnamese ? "Nghiên cứu và triển khai các công cụ công nghệ hỗ trợ có thể tăng cường sự tham gia và tạo cơ hội mới" : (isSpanish ? "Investigue e implemente herramientas de tecnología asistiva que pueden aumentar la participación y crear nuevas oportunidades" : "Research and implement assistive technology tools that can increase participation and create new opportunities")
            } else if task.title == "Công Nghệ Hỗ Trợ" || task.title == "Tecnología Asistiva" {
                updatedTask.title = isVietnamese ? "Công Nghệ Hỗ Trợ" : (isSpanish ? "Tecnología Asistiva" : "Assistive Tech")
                updatedTask.description = isVietnamese ? "Nghiên cứu và triển khai các công cụ công nghệ hỗ trợ có thể tăng cường sự tham gia và tạo cơ hội mới" : (isSpanish ? "Investigue e implemente herramientas de tecnología asistiva que pueden aumentar la participación y crear nuevas oportunidades" : "Research and implement assistive technology tools that can increase participation and create new opportunities")
            } else if task.title == "Health Education" {
                updatedTask.title = isVietnamese ? "Giáo Dục Sức Khỏe" : (isSpanish ? "Educación para la Salud" : "Health Education")
                updatedTask.description = isVietnamese ? "Giải quyết các chủ đề phát triển quan trọng bao gồm dậy thì, tình dục và an toàn cá nhân" : (isSpanish ? "Aborde temas importantes del desarrollo incluyendo pubertad, sexualidad y seguridad personal" : "Address important developmental topics including puberty, sexuality, and personal safety")
            } else if task.title == "Giáo Dục Sức Khỏe" || task.title == "Educación para la Salud" {
                updatedTask.title = isVietnamese ? "Giáo Dục Sức Khỏe" : (isSpanish ? "Educación para la Salud" : "Health Education")
                updatedTask.description = isVietnamese ? "Giải quyết các chủ đề phát triển quan trọng bao gồm dậy thì, tình dục và an toàn cá nhân" : (isSpanish ? "Aborde temas importantes del desarrollo incluyendo pubertad, sexualidad y seguridad personal" : "Address important developmental topics including puberty, sexuality, and personal safety")
            } else if task.title == "Disability Rights" {
                updatedTask.title = isVietnamese ? "Quyền Người Khuyết Tật" : (isSpanish ? "Derechos de Discapacidad" : "Disability Rights")
                updatedTask.description = isVietnamese ? "Tìm hiểu về lịch sử và tầm quan trọng của các phong trào và vận động quyền người khuyết tật" : (isSpanish ? "Aprenda sobre la historia e importancia de los movimientos y la defensa de los derechos de las personas con discapacidad" : "Learn about the history and importance of disability rights movements and advocacy")
            } else if task.title == "Quyền Người Khuyết Tật" || task.title == "Derechos de Discapacidad" {
                updatedTask.title = isVietnamese ? "Quyền Người Khuyết Tật" : (isSpanish ? "Derechos de Discapacidad" : "Disability Rights")
                updatedTask.description = isVietnamese ? "Tìm hiểu về lịch sử và tầm quan trọng của các phong trào và vận động quyền người khuyết tật" : (isSpanish ? "Aprenda sobre la historia e importancia de los movimientos y la defensa de los derechos de las personas con discapacidad" : "Learn about the history and importance of disability rights movements and advocacy")
            }
            
            // Work Preparation
            else if task.title == "Work Programs" {
                updatedTask.title = isVietnamese ? "Chương Trình Làm Việc" : (isSpanish ? "Programas de Trabajo" : "Work Programs")
                updatedTask.description = isVietnamese ? "Khám phá WorkAbility, quan hệ đối tác chuyển tiếp và dịch vụ của Sở Phục Hồi Chức Năng bao gồm các lựa chọn việc làm cho sinh viên và hỗ trợ" : (isSpanish ? "Explore WorkAbility, asociaciones de transición y servicios del Departamento de Rehabilitación incluyendo opciones de empleo estudiantil y de apoyo" : "Explore WorkAbility, transition partnerships, and Department of Rehabilitation services including student and supportive employment options")
            } else if task.title == "Chương Trình Làm Việc" || task.title == "Programas de Trabajo" {
                updatedTask.title = isVietnamese ? "Chương Trình Làm Việc" : (isSpanish ? "Programas de Trabajo" : "Work Programs")
                updatedTask.description = isVietnamese ? "Khám phá WorkAbility, quan hệ đối tác chuyển tiếp và dịch vụ của Sở Phục Hồi Chức Năng bao gồm các lựa chọn việc làm cho sinh viên và hỗ trợ" : (isSpanish ? "Explore WorkAbility, asociaciones de transición y servicios del Departamento de Rehabilitación incluyendo opciones de empleo estudiantil y de apoyo" : "Explore WorkAbility, transition partnerships, and Department of Rehabilitation services including student and supportive employment options")
            } else if task.title == "Career Goals" {
                updatedTask.title = isVietnamese ? "Mục Tiêu Nghề Nghiệp" : (isSpanish ? "Objetivos de Carrera" : "Career Goals")
                updatedTask.description = isVietnamese ? "Phát triển mục tiêu việc làm sau trung học như một phần của ITP và tạo kế hoạch nghề nghiệp toàn diện để xem xét thường xuyên" : (isSpanish ? "Desarrolle objetivos de empleo post-secundario como parte de su ITP y cree un plan de carrera integral para revisar regularmente" : "Develop post-secondary employment goals as part of your ITP and create a comprehensive career plan to review regularly")
            } else if task.title == "Mục Tiêu Nghề Nghiệp" || task.title == "Objetivos de Carrera" {
                updatedTask.title = isVietnamese ? "Mục Tiêu Nghề Nghiệp" : (isSpanish ? "Objetivos de Carrera" : "Career Goals")
                updatedTask.description = isVietnamese ? "Phát triển mục tiêu việc làm sau trung học như một phần của ITP và tạo kế hoạch nghề nghiệp toàn diện để xem xét thường xuyên" : (isSpanish ? "Desarrolle objetivos de empleo post-secundario como parte de su ITP y cree un plan de carrera integral para revisar regularmente" : "Develop post-secondary employment goals as part of your ITP and create a comprehensive career plan to review regularly")
            } else if task.title == "Work Experience" {
                updatedTask.title = isVietnamese ? "Kinh Nghiệm Làm Việc" : (isSpanish ? "Experiencia Laboral" : "Work Experience")
                updatedTask.description = isVietnamese ? "Xây dựng kinh nghiệm làm việc thực tế thông qua thực tập, tình nguyện hoặc việc làm. Thực hành nộp đơn xin việc và viết sơ yếu lý lịch" : (isSpanish ? "Construya experiencia laboral práctica a través de pasantías, trabajo voluntario o empleos. Practique solicitudes de trabajo y escritura de currículum" : "Build practical work experience through internships, volunteer work, or jobs. Practice job applications and resume writing")
            } else if task.title == "Kinh Nghiệm Làm Việc" || task.title == "Experiencia Laboral" {
                updatedTask.title = isVietnamese ? "Kinh Nghiệm Làm Việc" : (isSpanish ? "Experiencia Laboral" : "Work Experience")
                updatedTask.description = isVietnamese ? "Xây dựng kinh nghiệm làm việc thực tế thông qua thực tập, tình nguyện hoặc việc làm. Thực hành nộp đơn xin việc và viết sơ yếu lý lịch" : (isSpanish ? "Construya experiencia laboral práctica a través de pasantías, trabajo voluntario o empleos. Practique solicitudes de trabajo y escritura de currículum" : "Build practical work experience through internships, volunteer work, or jobs. Practice job applications and resume writing")
            } else if task.title == "Employment Support" {
                updatedTask.title = isVietnamese ? "Hỗ Trợ Việc Làm" : (isSpanish ? "Apoyo al Empleo" : "Employment Support")
                updatedTask.description = isVietnamese ? "Cho khách hàng Trung Tâm Khu Vực: Khám phá dịch vụ việc làm hỗ trợ và cơ hội trong chương trình Thực Tập Có Lương" : (isSpanish ? "Para clientes del Centro Regional: Explore servicios de empleo de apoyo y oportunidades en el programa de Pasantía Pagada" : "For Regional Center clients: Explore supportive employment services and opportunities in the Paid Internship program")
            } else if task.title == "Hỗ Trợ Việc Làm" || task.title == "Apoyo al Empleo" {
                updatedTask.title = isVietnamese ? "Hỗ Trợ Việc Làm" : (isSpanish ? "Apoyo al Empleo" : "Employment Support")
                updatedTask.description = isVietnamese ? "Cho khách hàng Trung Tâm Khu Vực: Khám phá dịch vụ việc làm hỗ trợ và cơ hội trong chương trình Thực Tập Có Lương" : (isSpanish ? "Para clientes del Centro Regional: Explore servicios de empleo de apoyo y oportunidades en el programa de Pasantía Pagada" : "For Regional Center clients: Explore supportive employment services and opportunities in the Paid Internship program")
            }
            
            return updatedTask
        }
    }
} 
