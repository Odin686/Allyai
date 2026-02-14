import SwiftUI

struct PromptCraftGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showResult = false
    @State private var lastCorrect = false
    
    private let totalRounds = 8
    
    private let challenges: [(task: String, options: [String], best: String, explanation: String)] = [
        ("You want a recipe for chocolate cake", ["Write a recipe for a moist chocolate cake with buttercream frosting, serves 8, with step-by-step instructions", "cake recipe", "make something yummy"], "Write a recipe for a moist chocolate cake with buttercream frosting, serves 8, with step-by-step instructions", "Specific details about type, frosting, servings, and format make this prompt most effective."),
        ("You need a cover letter for a marketing job", ["Write a professional cover letter for a Digital Marketing Manager position at a tech startup, emphasizing 5 years of SEO and social media experience", "write cover letter", "help me get a job"], "Write a professional cover letter for a Digital Marketing Manager position at a tech startup, emphasizing 5 years of SEO and social media experience", "Specifying the role, company type, and relevant skills guides the AI to produce a tailored cover letter."),
        ("You want to understand quantum computing", ["Explain quantum computing to a high school student using everyday analogies, in 200 words or less", "tell me about quantum stuff", "what is science"], "Explain quantum computing to a high school student using everyday analogies, in 200 words or less", "Specifying audience, approach (analogies), and length constraints produces the most useful explanation."),
        ("You want help debugging code", ["I have a Python function that should return the sum of a list but returns None. Here's the code: [code]. What's wrong and how do I fix it?", "fix my code", "code broken help"], "I have a Python function that should return the sum of a list but returns None. Here's the code: [code]. What's wrong and how do I fix it?", "Including the language, expected vs actual behavior, and the actual code gives AI everything it needs to help."),
        ("You need a bedtime story for a 5-year-old", ["Write a 3-minute bedtime story about a friendly dragon who learns to share, with a gentle moral and happy ending, suitable for a 5-year-old", "tell me a story", "something for kids"], "Write a 3-minute bedtime story about a friendly dragon who learns to share, with a gentle moral and happy ending, suitable for a 5-year-old", "Length, character, theme, moral, and age-appropriateness are all specified for the best result."),
        ("You want to plan a trip to Japan", ["Create a 7-day Tokyo itinerary for a first-time visitor interested in food, temples, and anime culture, with daily schedules and budget tips", "tell me about Japan", "plan trip"], "Create a 7-day Tokyo itinerary for a first-time visitor interested in food, temples, and anime culture, with daily schedules and budget tips", "Duration, city, interests, experience level, and desired format make this prompt comprehensive."),
        ("You need email subject lines for a sale", ["Generate 10 email subject lines for a 40% off summer sale at an online fashion store, targeting women 25-35, tone: excited but not spammy", "write some emails", "help with marketing"], "Generate 10 email subject lines for a 40% off summer sale at an online fashion store, targeting women 25-35, tone: excited but not spammy", "Quantity, discount, audience, and tone guidelines produce the most usable output."),
        ("You want to learn about AI bias", ["Explain 3 real-world examples of AI bias in hiring, healthcare, and criminal justice, including what caused the bias and how it could be prevented, in bullet points", "what is AI bias", "bias stuff"], "Explain 3 real-world examples of AI bias in hiring, healthcare, and criminal justice, including what caused the bias and how it could be prevented, in bullet points", "Specifying domains, number of examples, and format produces structured, educational content.")
    ]
    
    @State private var shuffled: [(task: String, options: [String], best: String, explanation: String)] = []
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffled.count) {
                let ch = shuffled[round]
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HStack {
                            Button { dismiss() } label: { Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary) }
                            Spacer()
                            Text("Round \(round + 1)/\(totalRounds)").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            Spacer()
                            Text("Score: \(score)").font(.aiRounded(.body, weight: .bold)).foregroundColor(.aiPrimary)
                        }
                        
                        VStack(spacing: 6) {
                            Text("Your Task:").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            Text(ch.task).font(.aiTitle3()).foregroundColor(.aiTextPrimary).multilineTextAlignment(.center)
                        }
                        
                        Text("Pick the best prompt:").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                        
                        if showResult {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Perfect Pick!" : "Not the best choice")
                            }.font(.aiHeadline()).foregroundColor(lastCorrect ? .aiSuccess : .aiError)
                            Text(ch.explanation).font(.aiCaption()).foregroundColor(.aiTextSecondary).multilineTextAlignment(.center)
                            
                            Button { showResult = false; round += 1; if round >= totalRounds { endGame() } } label: {
                                Text("Next").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                            }
                        } else {
                            ForEach(ch.options, id: \.self) { opt in
                                Button {
                                    lastCorrect = opt == ch.best
                                    if lastCorrect { score += 1; HapticService.shared.success() } else { HapticService.shared.error() }
                                    showResult = true
                                } label: {
                                    Text(opt).font(.aiCaption()).foregroundColor(.aiTextPrimary).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)))
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear { shuffled = challenges.shuffled() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.cursor").font(.system(size: 50)).foregroundColor(.aiSuccess)
            Text("Prompt Master!").font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["promptCraft"] ?? 0) { Text("🎉 New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning) }
            VStack(spacing: 12) {
                Button { round = 0; score = 0; isGameOver = false; shuffled = challenges.shuffled() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }.padding(.horizontal, 30)
        }
    }
    
    private func endGame() {
        let xp = score * 10; user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["promptCraft"] ?? 0) { user.gameHighScores["promptCraft"] = score }
        isGameOver = true
    }
}
