import SwiftUI

struct WorkoutCardView: View {
    let workout: WorkoutCard
    @State private var completedExercises: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(workout.category, systemImage: "flame.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
                
                Spacer()
                
                Label("\(workout.durationMinutes) min", systemImage: "clock.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            Text(workout.title)
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(0..<workout.exercises.count, id: \.self) { index in
                    Button {
                        withAnimation {
                            if completedExercises.contains(index) {
                                completedExercises.remove(index)
                            } else {
                                completedExercises.insert(index)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: completedExercises.contains(index) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completedExercises.contains(index) ? .green : .secondary)
                            
                            Text(workout.exercises[index])
                                .font(.subheadline)
                                .strikethrough(completedExercises.contains(index))
                                .foregroundStyle(completedExercises.contains(index) ? .secondary : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
