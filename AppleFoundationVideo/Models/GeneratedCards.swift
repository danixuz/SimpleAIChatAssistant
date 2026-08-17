import Foundation
import FoundationModels

// MARK: - Quiz Card
@Generable
struct QuizCard: Equatable {
    @Guide(description: "The question to ask the user")
    var question: String
    
    @Guide(description: "List of 3 to 4 answer choices")
    var options: [String]
    
    @Guide(description: "0-based index of the correct answer choice")
    var correctIndex: Int
    
    @Guide(description: "Brief explanation of the correct answer")
    var explanation: String
}

// MARK: - Workout Card
@Generable
struct WorkoutCard: Equatable {
    @Guide(description: "Title of the workout session")
    var title: String
    
    @Guide(description: "Target muscle group or focus area (e.g. Core, Legs, Upper Body, Cardio)")
    var category: String
    
    @Guide(description: "Estimated workout duration in minutes")
    var durationMinutes: Int
    
    @Guide(description: "List of exercises with sets and reps (e.g. 'Push-ups: 3 sets of 15 reps')")
    var exercises: [String]
}

// MARK: - Recipe Card
@Generable
struct RecipeCard: Equatable {
    @Guide(description: "Name of the dish or meal")
    var title: String
    
    @Guide(description: "Preparation and cook time in minutes")
    var prepMinutes: Int
    
    @Guide(description: "Estimated calorie count in kcal")
    var calories: Int
    
    @Guide(description: "List of ingredients with quantities")
    var ingredients: [String]
    
    @Guide(description: "Numbered cooking instructions")
    var steps: [String]
}

// MARK: - Card Container Enum
enum GeneratedCard: Equatable {
    case quiz(QuizCard)
    case workout(WorkoutCard)
    case recipe(RecipeCard)
}
