import SwiftUI

struct RecipeCardView: View {
    let recipe: RecipeCard
    @State private var checkedIngredients: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.title)
                    .font(.headline)
                
                Spacer()
                
                Label("\(recipe.prepMinutes) min", systemImage: "clock")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            Text("🔥 \(recipe.calories) kcal")
                .font(.caption.bold())
                .foregroundStyle(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
            
            Divider()
            
            Text("Ingredients")
                .font(.subheadline.bold())
            
            VStack(spacing: 6) {
                ForEach(0..<recipe.ingredients.count, id: \.self) { index in
                    Button {
                        withAnimation {
                            if checkedIngredients.contains(index) {
                                checkedIngredients.remove(index)
                            } else {
                                checkedIngredients.insert(index)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: checkedIngredients.contains(index) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(checkedIngredients.contains(index) ? .green : .secondary)
                            
                            Text(recipe.ingredients[index])
                                .font(.subheadline)
                                .strikethrough(checkedIngredients.contains(index))
                                .foregroundStyle(checkedIngredients.contains(index) ? .secondary : .primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if !recipe.steps.isEmpty {
                Divider()
                
                Text("Instructions")
                    .font(.subheadline.bold())
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<recipe.steps.count, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.caption.bold())
                                .foregroundStyle(.tint)
                            
                            Text(recipe.steps[index])
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
