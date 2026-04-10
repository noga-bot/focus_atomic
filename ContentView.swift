import SwiftUI
import UserNotifications

// --- 1. מודל הנתונים ---
struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let isRecovery: Bool
}

// --- 2. ניהול המצב ---
class AppState: ObservableObject {
    @Published var currentTask: TaskItem?
    @Published var energyLevel: Double = 5.0
    @Published var isStressed: Bool = false
    @Published var showingDiagnostic = true
    
    // רשימת המשימות שלך
    let taskPool = [
        TaskItem(title: "לכתוב את המייל הראשון", isRecovery: false),
        TaskItem(title: "לשתות כוס מים ולנשום", isRecovery: true),
        TaskItem(title: "לסיים את הפרויקט - שלב א׳", isRecovery: false)
    ]
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func selectNextTask() {
        if energyLevel < 3 || isStressed {
            currentTask = taskPool.first(where: { $0.isRecovery })
        } else {
            currentTask = taskPool.first(where: { !$0.isRecovery })
        }
        showingDiagnostic = false
        scheduleReminder()
    }
    
    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "עדיין שם?"
        content.body = "עברו 20 דקות, בואי נחזור לפוקוס על המשימה."
        content.sound = .default
        
        // התראה ל-20 דקות (1200 שניות)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1200, repeats: false)
        let request = UNNotificationRequest(identifier: "focusReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// --- 3. מסך ראשי ---
struct ContentView: View {
    @StateObject var state = AppState()
    
    var body: some View {
        ZStack {
            Color(white: 0.97).ignoresSafeArea()
            
            if state.showingDiagnostic {
                DiagnosticView(state: state)
            } else if let task = state.currentTask {
                FocusView(task: task, state: state)
            }
        }
        .onAppear {
            state.requestNotificationPermission()
        }
    }
}

// --- 4. מסך אבחון (Minimalist) ---
struct DiagnosticView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack(spacing: 40) {
            Text("איך את מרגישה כרגע?")
                .font(.system(size: 26, weight: .light, design: .rounded))
            
            VStack {
                Text("רמת אנרגיה: \(Int(state.energyLevel))")
                    .font(.caption).bold()
                Slider(value: $state.energyLevel, in: 1...10, step: 1)
                    .accentColor(.indigo)
            }
            .padding()
            
            Toggle("אני מרגישה בסטרס", isOn: $state.isStressed)
                .padding()
                .background(Color.white.cornerRadius(12))
            
            Button(action: state.selectNextTask) {
                Text("הצעד הבא")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(15)
            }
        }
        .padding(30)
    }
}

// --- 5. מסך פוקוס (Atomic Focus) ---
struct FocusView: View {
    let task: TaskItem
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack {
            Spacer()
            
            if task.isRecovery {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.largeTitle)
                    .foregroundColor(.brown)
            }
            
            Text(task.title)
                .font(.system(size: 45, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focusReminder"])
                withAnimation { state.showingDiagnostic = true }
            }) {
                Circle()
                    .fill(Color.indigo)
                    .frame(width: 90, height: 90)
                    .overlay(Image(systemName: "checkmark").foregroundColor(.white).font(.title.bold()))
                    .shadow(color: .indigo.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.bottom, 50)
        }
    }
}
