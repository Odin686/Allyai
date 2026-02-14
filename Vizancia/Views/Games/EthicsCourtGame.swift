import SwiftUI

struct EthicsCourtGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showResult = false
    @State private var lastCorrect = false
    @State private var selectedVerdict = ""
    
    private let totalRounds = 8
    
    private let cases: [(scenario: String, options: [String], correct: String, explanation: String)] = [
        ("A hospital wants to use AI to triage emergency patients based on predicted survival rates.", ["Approve with oversight", "Reject entirely", "Need more info"], "Approve with oversight", "AI triage can save lives but requires human oversight to avoid bias and handle edge cases."),
        ("A school uses AI to predict which students will drop out and intervenes early.", ["Approve with safeguards", "Reject — too invasive", "Need more info"], "Approve with safeguards", "Early intervention helps students, but safeguards must prevent stigmatization and ensure data privacy."),
        ("A company uses AI to monitor employees' emotions during video calls.", ["Reject — privacy violation", "Approve for safety", "Need more info"], "Reject — privacy violation", "Monitoring employees' emotions without consent is a significant privacy invasion."),
        ("A police force uses AI facial recognition to identify suspects in crowds.", ["Reject — civil liberties concern", "Approve for public safety", "Need more info"], "Need more info", "This requires careful analysis — balancing security benefits with civil liberties and bias risks."),
        ("An insurance company uses AI to set premiums based on social media activity.", ["Reject — unfair practice", "Approve — data-driven pricing", "Need more info"], "Reject — unfair practice", "Using social media for insurance pricing can be discriminatory and invades privacy."),
        ("A dating app uses AI to match people but the AI was found to separate matches by race.", ["Reject and fix immediately", "It's just preference data", "Need more info"], "Reject and fix immediately", "AI perpetuating racial segregation in dating — even based on 'data' — is discriminatory and must be fixed."),
        ("A government uses AI to automatically approve or deny visa applications.", ["Reject — needs human review", "Approve for efficiency", "Need more info"], "Reject — needs human review", "Automated decisions affecting immigration require human review due to the life-changing impact."),
        ("A news platform uses AI to fact-check articles before publication.", ["Approve with human editors", "Reject — limits free speech", "Need more info"], "Approve with human editors", "AI fact-checking is valuable but needs human editors to handle nuance and avoid censorship."),
        ("A bank uses AI to approve small loans instantly but large loans require humans.", ["Approve — balanced approach", "Reject — still risky", "Need more info"], "Approve — balanced approach", "This tiered approach uses AI for efficiency while maintaining human oversight for high-stakes decisions."),
        ("A toy company uses AI to analyze children's play patterns without parental consent.", ["Reject — children's privacy", "Approve for product improvement", "Need more info"], "Reject — children's privacy", "Collecting data from children without parental consent violates privacy laws and ethical norms.")
    ]
    
    @State private var shuffled: [(scenario: String, options: [String], correct: String, explanation: String)] = []
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffled.count) {
                let c = shuffled[round]
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack {
                            Button { dismiss() } label: { Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary) }
                            Spacer()
                            Text("Case \(round + 1)/\(totalRounds)").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            Spacer()
                            Text("Score: \(score)").font(.aiRounded(.body, weight: .bold)).foregroundColor(.aiPrimary)
                        }
                        
                        VStack(spacing: 8) {
                            Image(systemName: "building.columns.fill").font(.title).foregroundColor(.aiPrimary)
                            Text("The Case").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                        }
                        
                        Text(c.scenario).font(.aiBody()).foregroundColor(.aiTextPrimary).multilineTextAlignment(.center)
                        
                        if showResult {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Good Judgment!" : "Different perspective needed")
                            }.font(.aiHeadline()).foregroundColor(lastCorrect ? .aiSuccess : .aiError)
                            
                            Text(c.explanation).font(.aiCaption()).foregroundColor(.aiTextSecondary).multilineTextAlignment(.center)
                            
                            Button { showResult = false; round += 1; if round >= totalRounds { endGame() } } label: {
                                Text("Next Case").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                            }
                        } else {
                            Text("Your Verdict:").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            ForEach(c.options, id: \.self) { opt in
                                Button {
                                    selectedVerdict = opt
                                    lastCorrect = opt == c.correct
                                    if lastCorrect { score += 1; HapticService.shared.success() } else { HapticService.shared.error() }
                                    showResult = true
                                } label: {
                                    Text(opt).font(.aiBody()).foregroundColor(.aiTextPrimary).frame(maxWidth: .infinity).padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)))
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear { shuffled = cases.shuffled() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.columns.fill").font(.system(size: 50)).foregroundColor(.aiPrimary)
            Text("Court Adjourned").font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["ethicsCourt"] ?? 0) { Text("🎉 New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning) }
            VStack(spacing: 12) {
                Button { round = 0; score = 0; isGameOver = false; shuffled = cases.shuffled() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }.padding(.horizontal, 30)
        }
    }
    
    private func endGame() {
        let xp = score * 10; user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["ethicsCourt"] ?? 0) { user.gameHighScores["ethicsCourt"] = score }
        isGameOver = true
    }
}
