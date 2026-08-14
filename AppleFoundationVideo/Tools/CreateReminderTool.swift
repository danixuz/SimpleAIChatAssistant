import Foundation
import EventKit
import FoundationModels

struct CreateReminderTool: Tool {
    let name = "createReminder"
    let description = "Creates a reminder in the Apple Reminders app. ONLY use this tool when the user explicitly asks to set, add, or create a reminder."
    
    @Generable
    struct Arguments {
        @Guide(description: "The title or task description for the reminder (e.g. 'Buy groceries', 'Call John', 'Finish Swift project')")
        var title: String
        
        @Guide(description: "Optional additional notes or details for the reminder")
        var notes: String?
    }
    
    private let eventStore = EKEventStore()
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        let hasAccess = try await requestAccess()
        guard hasAccess else {
            return "Could not create reminder: permission to access Apple Reminders was not granted."
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = arguments.title
        reminder.notes = arguments.notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            return "Successfully created reminder: '\(arguments.title)' in your Apple Reminders app."
        } catch {
            return "Failed to save reminder: \(error.localizedDescription)"
        }
    }
    
    private func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToReminders()
        } else {
            return try await eventStore.requestAccess(to: .reminder)
        }
    }
}
