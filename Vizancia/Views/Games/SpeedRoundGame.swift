import SwiftUI

struct SpeedRoundGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining = 60
    @State private var score = 0
    @State private var currentQ: Question?
    @State private var selectedAnswer = ""
    @State private var isGameOver = false
    @State private var timer: Timer?
    @State private var allQuestions: [Question] = []
    @State private var flashColor: Color = .clear
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            if isGameOver {
                gameOverView
            } else {
                VStack(spacing: 16) {
                    // Timer & Score
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(timeRemaining <= 10 ? .aiError : .aiOrange)
                            Text("\(timeRemaining)s")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(timeRemaining <= 10 ? .aiError : .aiOrange)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(score)")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(.aiTextPrimary)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let q = currentQ {
                        Text(q.questionText)
                            .font(.aiTitle3())
                            .foregroundColor(.aiTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 10) {
                            ForEach(q.options ?? [], id: \.self) { option in
                                Button {
                                    checkAnswer(option, for: q)
                                } label: {
                                    Text(option)
                                        .font(.aiBody())
                                        .foregroundColor(.aiTextPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color.aiCard)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            
            // Flash overlay
            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onAppear { startGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)
            Text("Time's Up!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
            
            if score > (user.gameHighScores["speedRound"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }
            
            VStack(spacing: 12) {
                Button {
                    isGameOver = false
                    startGame()
                } label: {
                    Text("Play Again")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func startGame() {
        allQuestions = LessonContentProvider.shared.allCategories
            .flatMap { $0.lessons }
            .flatMap { $0.questions }
            .filter { $0.type == .multipleChoice || $0.type == .trueFalse }
            .shuffled()
        score = 0
        timeRemaining = 60
        nextQuestion()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func nextQuestion() {
        if allQuestions.isEmpty {
            allQuestions = LessonContentProvider.shared.allCategories.flatMap { $0.lessons }.flatMap { $0.questions }.filter { $0.type == .multipleChoice || $0.type == .trueFalse }.shuffled()
        }
        currentQ = allQuestions.removeFirst()
    }
    
    private func checkAnswer(_ answer: String, for question: Question) {
        if answer == question.correctAnswer {
            score += 1
            flashColor = .aiSuccess
            HapticService.shared.success()
        } else {
            flashColor = .aiError
            HapticService.shared.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { flashColor = .clear }
        nextQuestion()
    }
    
    private func endGame() {
        timer?.invalidate()
        let xp = score * 5
        user.addXP(xp)
        user.todayXP += xp
        if score > (user.gameHighScores["speedRound"] ?? 0) {
            user.gameHighScores["speedRound"] = score
        }
        user.gamesPlayed += 1
        isGameOver = true
    }
}
