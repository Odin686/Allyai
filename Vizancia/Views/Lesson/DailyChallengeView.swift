import SwiftUI

struct DailyChallengeView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var question: Question?
    @State private var selectedAnswer = ""
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @State private var showResult = false
    @State private var xpAwarded = 0

    private let bonusXP = 25
    private let perfectBonusXP = 50

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                if let q = question {
                    if showResult {
                        resultView(q)
                    } else {
                        challengeView(q)
                    }
                } else {
                    ProgressView()
                        .onAppear { loadChallenge() }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Challenge Header
    private var challengeHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.aiWarning)
                Text("Daily Challenge")
                    .font(.aiCaption())
                    .foregroundColor(.aiWarning)
            }
            Spacer()
            Text("+\(bonusXP) XP")
                .font(.aiCaption())
                .foregroundColor(.aiPrimary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Challenge Title
    private var challengeTitle: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.aiWarning)
            Text("Question of the Day")
                .font(.aiTitle())
                .foregroundColor(.aiTextPrimary)
            if user.dailyChallengeStreak > 0 {
                Text("Challenge streak: \(user.dailyChallengeStreak) days")
                    .font(.aiCaption())
                    .foregroundColor(.aiOrange)
            }
        }
        .padding(.top, 10)
    }

    // MARK: - Check Button
    private func checkButton(_ q: Question) -> some View {
        VStack {
            Divider()
            Button {
                checkAnswer(q)
            } label: {
                Text("Check")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedAnswer.isEmpty ? Color.aiWarning.opacity(0.4) : Color.aiWarning)
                    )
            }
            .disabled(selectedAnswer.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.aiBackground)
    }

    // MARK: - Challenge View
    private func challengeView(_ q: Question) -> some View {
        VStack(spacing: 0) {
            challengeHeader

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    challengeTitle
                    questionContent(q)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }

            checkButton(q)
        }
    }

    // MARK: - Result View
    private func resultView(_ q: Question) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(isCorrect ? .aiSuccess : .aiError)

            Text(isCorrect ? "Brilliant!" : "Nice Try!")
                .font(.aiLargeTitle)
                .foregroundColor(.aiTextPrimary)

            Text(q.explanation)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if xpAwarded > 0 {
                Text("+\(xpAwarded) XP")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.aiWarning)
            }

            if user.dailyChallengeStreak > 1 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.aiOrange)
                    Text("\(user.dailyChallengeStreak)-day challenge streak!")
                        .font(.aiHeadline())
                        .foregroundColor(.aiOrange)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Question Content
    @ViewBuilder
    private func questionContent(_ question: Question) -> some View {
        switch question.type {
        case .multipleChoice:
            MultipleChoiceView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .trueFalse:
            TrueFalseView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .fillInBlank:
            FillInBlankView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .scenarioJudgment:
            ScenarioJudgmentView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        default:
            MultipleChoiceView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        }
    }

    // MARK: - Logic
    private func loadChallenge() {
        let categories = LessonContentProvider.shared.allCategories
        let lessons = categories.flatMap { $0.lessons }
        let questions = lessons.flatMap { $0.questions }
        let eligible: [Question] = questions.filter { q in
            q.type == .multipleChoice || q.type == .trueFalse || q.type == .scenarioJudgment
        }
        guard !eligible.isEmpty else { return }
        let dayIndex: Int = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        question = eligible[dayIndex % eligible.count]
    }

    private func checkAnswer(_ q: Question) {
        guard !selectedAnswer.isEmpty else { return }

        let correct = selectedAnswer == q.correctAnswer
        isCorrect = correct
        hasAnswered = true

        if correct {
            xpAwarded = perfectBonusXP
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            xpAwarded = bonusXP
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }

        user.completeDailyChallenge(xp: xpAwarded)
        showResult = true
    }
}
