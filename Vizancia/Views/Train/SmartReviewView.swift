import SwiftUI

struct SmartReviewView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var selectedAnswer = ""
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @State private var showingResult = false
    @State private var xpEarned = 0
    @State private var isComplete = false

    private let spacedRep = SpacedRepetitionService.shared

    private var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                if questions.isEmpty || isComplete {
                    completionView
                } else if let question = currentQuestion {
                    VStack(spacing: 0) {
                        topBar
                        progressBar

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                // Box indicator
                                if let card = user.spacedRepetitionCards[question.id] {
                                    boxIndicator(box: card.box)
                                }

                                questionContent(question)
                                    .padding(.top, 10)

                                if showingResult {
                                    resultFeedback(question)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }

                        bottomAction
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Box Indicator
    private func boxIndicator(box: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { b in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(b <= box ? boxColor(b) : Color.aiTextSecondary.opacity(0.15))
                        .frame(height: 4)
                    if b == box {
                        Text(spacedRep.boxLabel(b))
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(boxColor(b))
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func boxColor(_ box: Int) -> Color {
        switch box {
        case 1: return .aiError
        case 2: return .aiOrange
        case 3: return .aiWarning
        case 4: return .aiSecondary
        case 5: return .aiSuccess
        default: return .aiTextSecondary
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.aiPrimary)
                Text("Smart Review")
                    .font(.aiCaption())
                    .foregroundColor(.aiPrimary)
            }
            Spacer()
            Text("\(currentIndex + 1)/\(questions.count)")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aiPrimary.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aiPrimary)
                    .frame(width: geo.size.width * (Double(currentIndex) / Double(max(questions.count, 1))))
                    .animation(.spring(response: 0.4), value: currentIndex)
            }
        }
        .frame(height: 8)
        .padding(.horizontal)
    }

    // MARK: - Question Content
    @ViewBuilder
    private func questionContent(_ question: Question) -> some View {
        switch question.type {
        case .multipleChoice:
            MultipleChoiceView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .trueFalse:
            TrueFalseView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .matchPairs:
            MatchPairsView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .fillInBlank:
            FillInBlankView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .sortOrder:
            SortOrderView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        case .scenarioJudgment:
            ScenarioJudgmentView(question: question, selectedAnswer: $selectedAnswer, hasAnswered: hasAnswered, isCorrect: isCorrect)
        }
    }

    // MARK: - Result Feedback
    private func resultFeedback(_ question: Question) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isCorrect ? "Correct! Moving up ⬆️" : "Back to Box 1 ⬇️")
                        .font(.aiHeadline())
                        .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                    if let card = user.spacedRepetitionCards[question.id] {
                        Text("Now in: \(spacedRep.boxLabel(card.box))")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                }
                Spacer()
            }
            Text(question.explanation)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill((isCorrect ? Color.aiSuccess : Color.aiError).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke((isCorrect ? Color.aiSuccess : Color.aiError).opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Bottom Action
    private var bottomAction: some View {
        VStack {
            Divider()
            Button {
                if showingResult {
                    moveToNext()
                } else {
                    checkAnswer()
                }
            } label: {
                Text(showingResult ? (currentIndex < questions.count - 1 ? "Continue" : "Finish") : "Check")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedAnswer.isEmpty && !showingResult ? AnyShapeStyle(Color.aiPrimary.opacity(0.4)) : AnyShapeStyle(Color.aiPrimary))
                    )
            }
            .disabled(selectedAnswer.isEmpty && !showingResult)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.aiBackground)
    }

    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: questions.isEmpty ? "checkmark.circle.fill" : "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(questions.isEmpty ? .aiSuccess : .aiPrimary)

            Text(questions.isEmpty ? "All Caught Up!" : "Review Complete!")
                .font(.aiLargeTitle)
                .foregroundColor(.aiTextPrimary)

            if questions.isEmpty {
                Text("No questions due for review right now.\nCome back later!")
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("You got \(correctCount) out of \(questions.count) correct.")
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)

                // Mastery progress
                let mastery = spacedRep.masteryPercentage(for: user)
                VStack(spacing: 6) {
                    Text("Mastery: \(Int(mastery * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiPrimary.opacity(0.15))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiPrimary)
                                .frame(width: geo.size.width * mastery)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 40)
            }

            if xpEarned > 0 {
                Text("+\(xpEarned) XP")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
            }

            Button { dismiss() } label: {
                Text("Done")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }

    // MARK: - Logic

    private func checkAnswer() {
        guard let question = currentQuestion, !selectedAnswer.isEmpty else { return }

        let correct: Bool
        if question.type == .sortOrder {
            correct = selectedAnswer == question.correctAnswers.joined(separator: "||")
        } else if question.type == .matchPairs {
            correct = selectedAnswer == "matched"
        } else {
            correct = selectedAnswer == question.correctAnswer
        }

        isCorrect = correct
        hasAnswered = true
        showingResult = true

        // Update spaced repetition
        spacedRep.recordAnswer(for: user, questionId: question.id, correct: correct)

        if correct {
            correctCount += 1
            let xp = 5
            xpEarned += xp
            user.addXP(xp)
            user.todayXP += xp
            user.removeMissedQuestion(question.id)
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }
    }

    private func moveToNext() {
        if currentIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                selectedAnswer = ""
                hasAnswered = false
                showingResult = false
                isCorrect = false
            }
        } else {
            isComplete = true
        }
    }
}
