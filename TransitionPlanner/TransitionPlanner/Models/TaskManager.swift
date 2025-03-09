import Foundation

class TaskManager: ObservableObject {
    @Published var tasks: [Task]
    @Published var childBirthday: Date {
        didSet {
            updateTaskStatuses()
        }
    }
    
    var childAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: childBirthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    init(childBirthday: Date = Calendar.current.date(byAdding: .year, value: -12, to: Date()) ?? Date()) {
        self.childBirthday = childBirthday
        self.tasks = TaskManager.createInitialTasks()
        updateTaskStatuses()
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
    
    func toggleWorkInProgress(_ task: Task, value: Bool? = nil) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if let value = value {
                tasks[index].isWorkInProgress = value
            } else {
                tasks[index].isWorkInProgress.toggle()
            }
        }
    }
    
    static func createInitialTasks() -> [Task] {
        return [
            // Transition Planning
            Task(title: "IEP Participation",
                 description: "Have your child participate at their IEP meetings; learn about student-led IEPs",
                 category: .transitionPlanning,
                 startAge: 8,
                 endAge: 22),
            Task(title: "Disability Understanding",
                 description: "Teach child about their disability; identify strengths and needs",
                 category: .transitionPlanning,
                 startAge: 8,
                 endAge: 16),
            Task(title: "Individual Transition Plan",
                 description: "Learn about an Individual Transition Plan (ITP); ask 504 team about transition planning",
                 category: .transitionPlanning,
                 startAge: 8,
                 endAge: 16),
            Task(title: "Self-care Routines",
                 description: "Develop self-care routines; assign chores",
                 category: .transitionPlanning,
                 startAge: 8,
                 endAge: 14),
            Task(title: "High School Planning",
                 description: "High school diploma? New pathway to diploma? Certificate of completion?",
                 category: .transitionPlanning,
                 startAge: 12,
                 endAge: 16),
            Task(title: "Post-High School Planning",
                 description: "Apply for college and/or other post-high school programs and opportunities",
                 category: .transitionPlanning,
                 startAge: 16,
                 endAge: 18),
            Task(title: "Legal Documents",
                 description: "Obtain Driver's License/ID, Passport, Register to Vote, Selective Service",
                 category: .transitionPlanning,
                 startAge: 18,
                 endAge: 22),
                 
            // Education and Training
            Task(title: "Decision Making Assessment",
                 description: "Determine youth's ability to make decisions at 18",
                 category: .educationTraining,
                 startAge: 12,
                 endAge: 16),
            Task(title: "Healthcare Transition",
                 description: "Navigate transition from pediatric to adult healthcare; review insurance coverage; investigate rider of continued eligibility",
                 category: .educationTraining,
                 startAge: 16,
                 endAge: 18),
                 
            // Adult Life
            Task(title: "Letter of Intent",
                 description: "Start a Letter of Intent; review on an annual basis",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Adult Options",
                 description: "Explore adulting options: Department of Rehabilitation, Regional Center, education/training, housing, assistive technology",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Public Benefits",
                 description: "Investigate public benefits: CalFresh, In-Home Supportive Services (IHSS), Supplemental Security Income (SSI), MediCal, Medicare",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Financial Planning",
                 description: "Explore financial/estate planning: ABLE accounts, special needs trusts, conservatorship, durable power of attorney, supported decision making",
                 category: .adultLife,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Regional Center Services",
                 description: "Regional Center clients: understand post secondary services; explore Self-Determination",
                 category: .adultLife,
                 startAge: 16,
                 endAge: 18),
                 
            // Self-Advocacy
            Task(title: "Transportation Strategies",
                 description: "Develop transportation/mobility strategies",
                 category: .selfAdvocacy,
                 startAge: 12,
                 endAge: 18),
            Task(title: "Independence Skills",
                 description: "Increase independence at home; promote independence in choice-making, communication, life skills, and more",
                 category: .selfAdvocacy,
                 startAge: 8,
                 endAge: 22),
            Task(title: "Self-Advocacy Skills",
                 description: "Develop self-advocacy/determination skills early. Research strength-based person centered planning; develop a person centered plan",
                 category: .selfAdvocacy,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Assistive Technology",
                 description: "Investigate assistive technology tools that increase involvement and opportunities",
                 category: .selfAdvocacy,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Health Education",
                 description: "Talk about puberty, sexuality, and safety",
                 category: .selfAdvocacy,
                 startAge: 12,
                 endAge: 16),
            Task(title: "Disability Rights",
                 description: "Explore history of disability rights",
                 category: .selfAdvocacy,
                 startAge: 16,
                 endAge: 22),
                 
            // Work Preparation
            Task(title: "Work Programs",
                 description: "Explore WorkAbility and/or transition partnership programs; understand Department of Rehabilitation services, including student services and supportive employment services",
                 category: .workPreparation,
                 startAge: 12,
                 endAge: 22),
            Task(title: "Career Planning",
                 description: "Develop a postsecondary employment goal as part of your ITP; develop and review a career plan",
                 category: .workPreparation,
                 startAge: 16,
                 endAge: 18),
            Task(title: "Work Experience",
                 description: "Build work experience: intern/volunteer/job; practicing filling out job applications, writing resumes",
                 category: .workPreparation,
                 startAge: 16,
                 endAge: 18),
            Task(title: "Employment Services",
                 description: "Regional Center clients: explore supportive employment/work services and Paid Internship program",
                 category: .workPreparation,
                 startAge: 16,
                 endAge: 22)
        ]
    }
} 