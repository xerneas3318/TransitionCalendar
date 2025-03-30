import SwiftUI

enum Language {
    case english
    case spanish
    case vietnamese
}

private struct IsSpanishKey: EnvironmentKey {
    static let defaultValue = false
}

private struct IsVietnameseKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isSpanish: Bool {
        get { self[IsSpanishKey.self] }
        set { self[IsSpanishKey.self] = newValue }
    }
    
    var isVietnamese: Bool {
        get { self[IsVietnameseKey.self] }
        set { self[IsVietnameseKey.self] = newValue }
    }
}

struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAgePrompt = true
    @State private var selectedTask: Task? = nil
    @State private var showingResetConfirmation = false
    @State private var isSpanish = false
    @State private var isVietnamese = false
    @State private var translations = Translations.shared
    @State private var selectedLanguage: Language = .english
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed age ranges header
                HStack(spacing: 0) {
                    ForEach([
                        translations.under12,
                        translations.ageRange12to16,
                        translations.ageRange16to18,
                        translations.ageRange18to22,
                        translations.ageRange22plus
                    ], id: \.self) { range in
                        Text(range)
                            .font(.system(size: 12))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 2)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 81/255, green: 70/255, blue: 127/255))
                            .foregroundColor(.white)
                            .overlay(
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(Color.white.opacity(0.5)),
                                alignment: .trailing
                            )
                    }
                }
                .padding(.horizontal, 8)
                
                // Grid lines and content
                ScrollView {
                    ZStack(alignment: .top) {
                        // Vertical grid lines
                        HStack(spacing: 0) {
                            ForEach(0..<5) { index in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: index == 4 ? 0 : 1), // Don't show last line
                                        alignment: .trailing
                                    )
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // Categories and tasks
                        VStack(spacing: 2) {
                            ForEach(Category.allCases, id: \.self) { category in
                                CategoryTimelineView(category: category, selectedTask: $selectedTask)
                                    .environment(\.translations, translations)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .background(Color(red: 155/255, green: 155/255, blue: 155/255))
            }
            .background(Color(red: 155/255, green: 155/255, blue: 155/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(translations.title)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAgePrompt = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .environment(\.translations, translations)
        .sheet(isPresented: $showingAgePrompt) {
            NavigationView {
                VStack(spacing: 20) {
                    Section {
                        HStack {
                            Text(isVietnamese ? "Ngày Sinh:" : (isSpanish ? "Fecha de Nacimiento:" : "Birthday:"))
                                .foregroundColor(.primary)
                            Spacer()
                            DatePicker(
                                isVietnamese ? "Ngày Sinh" : (isSpanish ? "Fecha de Nacimiento" : "Birthday"),
                                selection: $taskManager.childBirthday,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.locale, isVietnamese ? Locale(identifier: "vi") : (isSpanish ? Locale(identifier: "es") : Locale(identifier: "en")))
                        }
                    }
                    
                    Divider()
                    
                    // Language Selection
                    VStack(spacing: 10) {
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English").tag(Language.english)
                            Text("Español").tag(Language.spanish)
                            Text("Tiếng Việt").tag(Language.vietnamese)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedLanguage) { newValue in
                            isSpanish = (newValue == .spanish)
                            isVietnamese = (newValue == .vietnamese)
                            translations.setLanguage(spanish: isSpanish, vietnamese: isVietnamese)
                            taskManager.isSpanish = isSpanish
                            taskManager.isVietnamese = isVietnamese
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text(translations.resetToDefault)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(translations.settings)
                .navigationBarItems(trailing: Button(translations.done) {
                    showingAgePrompt = false
                })
                .alert(translations.resetTasks, isPresented: $showingResetConfirmation) {
                    Button(translations.cancel, role: .cancel) { }
                    Button(translations.reset, role: .destructive) {
                        taskManager.resetToDefaultTasks()
                    }
                } message: {
                    Text(translations.resetConfirmation)
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environment(\.isSpanish, isSpanish)
                .environment(\.isVietnamese, isVietnamese)
        }
    }
}

struct CategoryTimelineView: View {
    let category: Category
    @Binding var selectedTask: Task?
    @EnvironmentObject var taskManager: TaskManager
    @Environment(\.translations) var translations
    
    var tasksInCategory: [Task] {
        taskManager.tasks.filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Category header with icon
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .frame(width: 28, height: 28)
                
                Text(category.localizedName(translations))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            
            // Timeline tasks
            VStack(spacing: 2) {
                ForEach(tasksInCategory) { task in
                    TimelineTaskView(task: task, selectedTask: $selectedTask)
                        .padding(.horizontal, 8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TimelineTaskView: View {
    let task: Task
    @Binding var selectedTask: Task?
    
    private struct AgeRange {
        let range: ClosedRange<Int>
        let index: Int
        
        static let ranges: [AgeRange] = [
            AgeRange(range: 0...12, index: 0),
            AgeRange(range: 12...16, index: 1),
            AgeRange(range: 16...18, index: 2),
            AgeRange(range: 18...22, index: 3),
            AgeRange(range: 22...99, index: 4)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let segmentWidth = totalWidth / CGFloat(AgeRange.ranges.count)
            let startSegment = CGFloat(getStartSegmentIndex())
            let endSegment = CGFloat(getEndSegmentIndex())
            let startX = startSegment * segmentWidth
            let width = (endSegment - startSegment + 1) * segmentWidth
            
            ZStack {
                // Background grid segments
                HStack(spacing: 0) {
                    ForEach(AgeRange.ranges, id: \.index) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Single continuous bar
                Group {
                    if task.status == .inProgress {
                        TaperedRectangle(leftTaper: true, rightTaper: true)
                            .fill(task.category.color)
                            .frame(width: width - 2)
                    } else {
                        Rectangle()
                            .fill(task.status == .completed ? task.category.color.opacity(0.5) : task.category.color)
                            .frame(width: width - 2)
                    }
                }
                .position(x: startX + width / 2, y: geometry.size.height / 2)
                
                // Task title
                Text(task.title)
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .lineLimit(1)
                    .shadow(color: .black, radius: 1.5, x: 0, y: 1)
                    .frame(width: width - 8)
                    .position(
                        x: startX + width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .frame(height: 36)
            .cornerRadius(4)
        }
        .frame(height: 36)
        .onTapGesture {
            selectedTask = task
        }
    }
    
    private func getStartSegmentIndex() -> Int {
        AgeRange.ranges.firstIndex { range in
            task.startAge <= range.range.upperBound && task.endAge >= range.range.lowerBound
        } ?? 0
    }
    
    private func getEndSegmentIndex() -> Int {
        AgeRange.ranges.lastIndex { range in
            task.startAge <= range.range.upperBound && task.endAge >= range.range.lowerBound
        } ?? 0
    }
}

struct TimelineSegment: View {
    let task: Task
    let ageRange: ClosedRange<Int>
    
    private var isInRange: Bool {
        task.startAge <= ageRange.upperBound && task.endAge >= ageRange.lowerBound
    }
    
    private var isStartSegment: Bool {
        task.startAge >= ageRange.lowerBound && task.startAge <= ageRange.upperBound
    }
    
    private var isEndSegment: Bool {
        task.endAge >= ageRange.lowerBound && task.endAge <= ageRange.upperBound
    }
    
    private var segmentColor: Color {
        if !isInRange {
            return .clear
        }
        
        switch task.status {
        case .completed:
            return task.category.color.opacity(0.5)
        case .inProgress, .notStarted:
            return task.category.color
        }
    }
    
    var body: some View {
        if !isInRange {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 36)
        } else if task.status == .inProgress {
            if isStartSegment && isEndSegment {
                // Single segment with both tapers
                TaperedRectangle(leftTaper: true, rightTaper: true)
                    .fill(segmentColor)
                    .frame(height: 36)
            } else if isStartSegment {
                // Left tapered only
                TaperedRectangle(leftTaper: true, rightTaper: false)
                    .fill(segmentColor)
                    .frame(height: 36)
            } else if isEndSegment {
                // Right tapered only
                TaperedRectangle(leftTaper: false, rightTaper: true)
                    .fill(segmentColor)
                    .frame(height: 36)
            } else {
                // Middle segments are regular rectangles
                Rectangle()
                    .fill(segmentColor)
                    .frame(height: 36)
            }
        } else {
            Rectangle()
                .fill(segmentColor)
                .frame(height: 36)
        }
    }
}

struct TaperedRectangle: Shape {
    var leftTaper: Bool = true
    var rightTaper: Bool = true
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let taperWidth: CGFloat = 8
        
        // Starting point
        path.move(to: CGPoint(x: leftTaper ? rect.minX + taperWidth : rect.minX, y: rect.minY))
        
        // Top line
        path.addLine(to: CGPoint(x: rightTaper ? rect.maxX - taperWidth : rect.maxX, y: rect.minY))
        
        // Right side
        if rightTaper {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - taperWidth, y: rect.maxY))
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        // Bottom line
        path.addLine(to: CGPoint(x: leftTaper ? rect.minX + taperWidth : rect.minX, y: rect.maxY))
        
        // Left side
        if leftTaper {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        }
        
        path.closeSubpath()
        return path
    }
}

struct StripedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 6
        let spacing: CGFloat = 4
        let angle: CGFloat = .pi / 4 // 45 degrees
        
        // Calculate how many stripes we need
        let stripeSpacing = stripeWidth + spacing
        let rotatedHeight = rect.width * sin(angle) + rect.height * cos(angle)
        let numberOfStripes = Int(rotatedHeight / stripeSpacing) + 2
        
        // Calculate the start point to center the stripes
        let startX = -rect.height * sin(angle) - stripeSpacing
        
        // Draw each stripe
        for i in 0..<numberOfStripes {
            let xOffset = startX + CGFloat(i) * stripeSpacing
            
            var stripe = Path()
            stripe.move(to: CGPoint(x: xOffset, y: rect.maxY))
            stripe.addLine(to: CGPoint(x: xOffset + rect.height * sin(angle), y: rect.minY))
            stripe.addLine(to: CGPoint(x: xOffset + stripeWidth + rect.height * sin(angle), y: rect.minY))
            stripe.addLine(to: CGPoint(x: xOffset + stripeWidth, y: rect.maxY))
            stripe.closeSubpath()
            
            path.addPath(stripe)
        }
        
        // Clip to rectangle bounds
        let bounds = Path(rect)
        return path.intersection(bounds)
    }
}

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @State private var selectedStatus: Task.TaskStatus
    @State private var notes: String
    @Environment(\.isSpanish) var isSpanish
    @Environment(\.isVietnamese) var isVietnamese
    
    init(task: Task) {
        self.task = task
        _selectedStatus = State(initialValue: task.status)
        _notes = State(initialValue: task.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isVietnamese ? "Chi Tiết Công Việc" : (isSpanish ? "Detalles de la Tarea" : "Task Details")).font(.title3)) {
                    Text(task.title)
                        .font(.title3)
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text(isVietnamese ? "Độ Tuổi: \(task.startAge)-\(task.endAge)" : (isSpanish ? "Rango de Edad: \(task.startAge)-\(task.endAge)" : "Age Range: \(task.startAge)-\(task.endAge)"))
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Picker(isVietnamese ? "Trạng Thái" : (isSpanish ? "Estado" : "Status"), selection: $selectedStatus) {
                        ForEach(Task.TaskStatus.allCases, id: \.self) { status in
                            Label(
                                isVietnamese ? status.vietnameseValue : (isSpanish ? status.spanishValue : status.rawValue),
                                systemImage: status.icon
                            )
                            .foregroundColor(status.color)
                            .tag(status)
                        }
                    }
                    .onChange(of: selectedStatus) { newStatus in
                        taskManager.updateTaskStatus(task, newStatus: newStatus)
                    }
                }
                
                Section(header: Text(isVietnamese ? "Ghi Chú" : (isSpanish ? "Notas" : "Notes")).font(.title3)) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .font(.body)
                        .onChange(of: notes) { newValue in
                            taskManager.updateTaskNotes(task, notes: newValue)
                        }
                }
            }
            .navigationBarItems(trailing: Button(isVietnamese ? "Xong" : (isSpanish ? "Hecho" : "Done")) { dismiss() })
        }
    }
}

struct BirthdayPromptView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var isPresented: Bool
    
    var childAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: taskManager.childBirthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Child's Birthday").font(.title3)) {
                    DatePicker(
                        "Birthday",
                        selection: $taskManager.childBirthday,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .font(.body)
                }
                
                Section {
                    HStack {
                        Text("Current Age")
                            .font(.body)
                        Spacer()
                        Text("\(childAge) years old")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Set Birthday")
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskManager())
} 