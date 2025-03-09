import SwiftUI

struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAgePrompt = true
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed age ranges header
                HStack(spacing: 0) {
                    ForEach(["Under 12", "12 - 16", "16 - 18", "18 - 22", "22+"], id: \.self) { range in
                        Text(range)
                            .font(.system(size: 14))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .overlay(
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(Color.white.opacity(0.3)),
                                alignment: .trailing
                            )
                    }
                }
                
                // Grid lines and content
                ScrollView {
                    ZStack(alignment: .top) {
                        // Vertical grid lines
                        HStack(spacing: 0) {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 1),
                                        alignment: .trailing
                                    )
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // Categories and tasks
                        VStack(spacing: 2) {
                            ForEach(Category.allCases, id: \.self) { category in
                                CategoryTimelineView(category: category, selectedTask: $selectedTask)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Transition Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Transition Planner")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAgePrompt = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAgePrompt) {
            BirthdayPromptView(isPresented: $showingAgePrompt)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
}

struct CategoryTimelineView: View {
    let category: Category
    @Binding var selectedTask: Task?
    @EnvironmentObject var taskManager: TaskManager
    
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
                
                Text(category.rawValue)
                    .font(.title3)
                    .foregroundColor(category.color)
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
    
    init(task: Task) {
        self.task = task
        _selectedStatus = State(initialValue: task.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").font(.title3)) {
                    Text(task.title)
                        .font(.title3)
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("Age Range: \(task.startAge)-\(task.endAge)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Status").font(.title3)) {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(Task.TaskStatus.allCases, id: \.self) { status in
                            Label(status.rawValue, systemImage: status.icon)
                                .foregroundColor(status.color)
                                .tag(status)
                        }
                    }
                    .onChange(of: selectedStatus) { newStatus in
                        taskManager.updateTaskStatus(task, newStatus: newStatus)
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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