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
} 
