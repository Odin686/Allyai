import SwiftUI

struct AIOrNotGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showResult = false
    @State private var lastCorrect = false
    
    private let totalRounds = 10
    
    private let statements: [(text: String, isAI: Bool, explanation: String)] = [
        ("I think, therefore I am.", false, "René Descartes said this in 1637, long before AI existed."),
        ("The purpose of education is to replace an empty mind with an open one.", false, "Malcolm Forbes, not an AI, made this observation about education."),
        ("I believe AI will be the most transformative technology humanity has ever created.", false, "Many tech leaders have expressed this sentiment, but this is a human quote."),
        ("As a language model, I don't experience consciousness or emotions.", true, "This is a typical AI self-description about its limitations."),
        ("In my analysis of the dataset, I identified 47 statistically significant correlations.", true, "This technical, data-focused language is characteristic of AI-generated reports."),
        ("Every child deserves a chance to learn, regardless of where they're born.", false, "This is a human value statement about educational equity."),
        ("I can process and analyze millions of data points in seconds.", true, "This describes a factual AI capability in typical AI language."),
        ("Music speaks what cannot be expressed, soothes the mind and gives it rest.", false, "This poetic expression about music reflects human emotional experience."),
        ("Based on the patterns in the training data, I can generate responses that appear contextually relevant.", true, "This is a technical self-description typical of AI systems."),
        ("The smell of rain on dry earth is one of life's simple pleasures.", false, "This sensory, experiential observation reflects human lived experience."),
        ("I don't have personal experiences, but I can provide information about that topic.", true, "This is a common AI disclaimer about lacking personal experience."),
        ("Watching my daughter take her first steps was the happiest moment of my life.", false, "This deeply personal, emotional memory is uniquely human."),
        ("I was trained on a diverse dataset of text from the internet.", true, "This is a factual description of how language models are trained."),
        ("The stock market reflects human psychology more than economic fundamentals.", false, "This insightful observation about markets comes from human financial analysis."),
        ("I can help you with that! Let me provide some information on this topic.", true, "This eager-to-help format is characteristic of AI assistants.")
    ]
    
    @State private var shuffled: [(text: String, isAI: Bool, explanation: String)] = []
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffled.count) {
                let statement = shuffled[round]
                VStack(spacing: 20) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        Text("Round \(round + 1)/\(totalRounds)")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                        Spacer()
                        Text("Score: \(score)")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(.aiPrimary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("\"" + statement.text + "\"")
                        .font(.aiTitle3())
                        .foregroundColor(.aiTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .italic()
                    
                    if showResult {
                        Text(statement.explanation)
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(lastCorrect ? "Correct!" : "Wrong!")
                        }
                        .font(.aiHeadline())
                        .foregroundColor(lastCorrect ? .aiSuccess : .aiError)
                    }
                    
                    Spacer()
                    
                    if showResult {
                        Button {
                            showResult = false
                            round += 1
                            if round >= totalRounds { endGame() }
                        } label: {
                            Text("Next")
                                .font(.aiHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                        }
                        .padding(.horizontal)
                    } else {
                        HStack(spacing: 16) {
                            Button { answer(isAI: true) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "cpu").font(.title)
                                    Text("AI Said This").font(.aiHeadline())
                                }
                                .foregroundColor(.aiPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.aiPrimary.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.aiPrimary.opacity(0.3), lineWidth: 1)))
                            }
                            Button { answer(isAI: false) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "person.fill").font(.title)
                                    Text("Human Said This").font(.aiHeadline())
                                }
                                .foregroundColor(.aiOrange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.aiOrange.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.aiOrange.opacity(0.3), lineWidth: 1)))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear { shuffled = statements.shuffled() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile").font(.system(size: 50)).foregroundColor(.aiPrimary)
            Text("Game Over!").font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["aiOrNot"] ?? 0) {
                Text("🎉 New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning)
            }
            VStack(spacing: 12) {
                Button { round = 0; score = 0; isGameOver = false; shuffled = statements.shuffled() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func answer(isAI: Bool) {
        lastCorrect = shuffled[round].isAI == isAI
        if lastCorrect { score += 1; HapticService.shared.success() } else { HapticService.shared.error() }
        showResult = true
    }
    
    private func endGame() {
        let xp = score * 8
        user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["aiOrNot"] ?? 0) { user.gameHighScores["aiOrNot"] = score }
        isGameOver = true
    }
}
