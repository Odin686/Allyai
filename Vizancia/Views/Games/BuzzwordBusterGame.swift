import SwiftUI

struct BuzzwordBusterGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showResult = false
    @State private var lastCorrect = false
    
    private let totalRounds = 10
    
    private let terms: [(term: String, isReal: Bool, explanation: String)] = [
        ("Transformer", true, "The Transformer is the architecture behind GPT, BERT, and most modern language models."),
        ("Neural Network", true, "Neural networks are computing systems inspired by biological neural networks in the brain."),
        ("Gradient Descent", true, "An optimization algorithm used to minimize the error in machine learning models."),
        ("Quantum Cognition Engine", false, "This is made up! There's no AI technology called a Quantum Cognition Engine."),
        ("Hallucination", true, "When AI generates confident but incorrect or fabricated information."),
        ("Backpropagation", true, "The algorithm used to train neural networks by propagating errors backward through the network."),
        ("Synapse Fusion Protocol", false, "This sounds technical but it's completely made up!"),
        ("Tokenization", true, "Breaking text into smaller units (tokens) that AI models can process."),
        ("Recursive Empathy Module", false, "AI doesn't have empathy modules — this is a fake buzzword!"),
        ("Overfitting", true, "When a model learns training data too well and fails to generalize to new data."),
        ("Attention Mechanism", true, "A key component that helps models focus on relevant parts of the input."),
        ("Neural Entanglement Layer", false, "This combines real terms but isn't an actual AI concept."),
        ("Hyperparameter", true, "Configuration settings that control the learning process, set before training begins."),
        ("Cognitive Mesh Architecture", false, "Sounds impressive but it's not a real AI architecture!"),
        ("Few-Shot Learning", true, "Training a model to learn from just a few examples."),
        ("Awareness Gradient", false, "AI doesn't have awareness — this term is made up."),
        ("Embedding", true, "A numerical representation of data (words, images) in a format AI can process."),
        ("Sentience Protocol", false, "AI doesn't have sentience — there's no such protocol!"),
        ("Epoch", true, "One complete pass through the entire training dataset during model training."),
        ("Deep Intuition Framework", false, "AI doesn't have intuition — this is a fabricated buzzword.")
    ]
    
    @State private var shuffled: [(term: String, isReal: Bool, explanation: String)] = []
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffled.count) {
                let t = shuffled[round]
                VStack(spacing: 20) {
                    HStack {
                        Button { dismiss() } label: { Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary) }
                        Spacer()
                        Text("Round \(round + 1)/\(totalRounds)").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                        Spacer()
                        Text("Score: \(score)").font(.aiRounded(.body, weight: .bold)).foregroundColor(.aiPrimary)
                    }.padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Is this a real AI term?").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                        Text(t.term).font(.system(size: 32, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
                    }
                    
                    if showResult {
                        HStack {
                            Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(lastCorrect ? "Correct!" : "Wrong!")
                        }.font(.aiHeadline()).foregroundColor(lastCorrect ? .aiSuccess : .aiError)
                        Text(t.explanation).font(.aiCaption()).foregroundColor(.aiTextSecondary).multilineTextAlignment(.center).padding(.horizontal, 24)
                        
                        Button { showResult = false; round += 1; if round >= totalRounds { endGame() } } label: {
                            Text("Next").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                        }.padding(.horizontal)
                    } else {
                        HStack(spacing: 16) {
                            Button { answer(real: true) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill").font(.title)
                                    Text("Real Term").font(.aiHeadline())
                                }.foregroundColor(.aiSuccess).frame(maxWidth: .infinity).padding(.vertical, 20).background(RoundedRectangle(cornerRadius: 16).fill(Color.aiSuccess.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.aiSuccess.opacity(0.3), lineWidth: 1)))
                            }
                            Button { answer(real: false) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "xmark.seal.fill").font(.title)
                                    Text("Made Up").font(.aiHeadline())
                                }.foregroundColor(.aiError).frame(maxWidth: .infinity).padding(.vertical, 20).background(RoundedRectangle(cornerRadius: 16).fill(Color.aiError.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.aiError.opacity(0.3), lineWidth: 1)))
                            }
                        }.padding(.horizontal)
                    }
                    
                    Spacer()
                }.padding(.vertical)
            }
        }
        .onAppear { shuffled = terms.shuffled() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "textformat.abc").font(.system(size: 50)).foregroundColor(.aiSecondary)
            Text("Buzzword Master!").font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["buzzwordBuster"] ?? 0) { Text("🎉 New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning) }
            VStack(spacing: 12) {
                Button { round = 0; score = 0; isGameOver = false; shuffled = terms.shuffled() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }.padding(.horizontal, 30)
        }
    }
    
    private func answer(real: Bool) {
        lastCorrect = shuffled[round].isReal == real
        if lastCorrect { score += 1; HapticService.shared.success() } else { HapticService.shared.error() }
        showResult = true
    }
    
    private func endGame() {
        let xp = score * 8; user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["buzzwordBuster"] ?? 0) { user.gameHighScores["buzzwordBuster"] = score }
        isGameOver = true
    }
}
