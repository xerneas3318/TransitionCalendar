import SwiftUI

struct CategoryView: View {
    let category: Category
    @EnvironmentObject var taskManager: TaskManager
    
    var tasksInCategory: [Task] {
        taskManager.tasks.filter { $0.category == category }
    }
    
    var body: some View {
        List {
            ForEach(tasksInCategory) { task in
                TaskRow(task: task)
            }
        }
        .navigationTitle(category.rawValue)
    }
}

struct TaskRow: View {
    let task: Task
    @EnvironmentObject var taskManager: TaskManager
    
    var statusColor: Color {
        task.status.color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                
                if task.isWorkInProgress {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            }
            
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Age Range: \(task.startAge)-\(task.endAge)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button(action: {
                    taskManager.updateTaskStatus(task, newStatus: task.status == .completed ? .notStarted : .completed)
                }) {
                    Text(task.status == .completed ? "Mark Incomplete" : "Mark Complete")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(task.status == .completed ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    taskManager.updateTaskStatus(task, newStatus: task.status == .inProgress ? .notStarted : .inProgress)
                }) {
                    Text(task.status == .inProgress ? "Remove In Progress" : "Mark In Progress")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        CategoryView(category: .transitionPlanning)
            .environmentObject(TaskManager())
    }
} 