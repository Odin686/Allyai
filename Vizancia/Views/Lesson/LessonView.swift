import SwiftUI

struct LessonView: View {
    @Bindable var user: UserProfile
    let lesson: LessonData
    let category: CategoryData
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var firstTryCount = 0
    @State private var xpEarned = 0
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var hasAnsweredCurrent = false
    @State private var selectedAnswer = ""
    @State private var shakeAttempts: CGFloat = 0
    @State private var showXPFloat = false
    @State private var xpFloatText = ""
    @State private var showLessonComplete = false
    @State private var showNoHeartsAlert = false
    
    private var questions: [Question] { lesson.questions }
    private var currentQuestion: Question { questions[currentIndex] }
    private var progressValue: Double { Double(currentIndex) / Double(questions.count) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar
                    topBar
                    
                    // Progress bar
                    progressBar
                    
                    // Question content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            questionView
                                .padding(.top, 20)
                            
                            if showingResult {
                                resultFeedback
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    
                    // Bottom action
                    bottomAction
                }
                
                // XP floating text
                if showXPFloat {
                    Text(xpFloatText)
                        .font(.aiXP())
                        .foregroundColor(.aiSuccess)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showLessonComplete) {
                LessonCompleteView(
                    user: user,
                    lesson: lesson,
                    category: category,
                    correctCount: correctCount,
                    totalQuestions: questions.count,
                    xpEarned: xpEarned,
                    firstTryCount: firstTryCount
                )
            }
            .alert("No Hearts Left!", isPresented: $showNoHeartsAlert) {
                Button("Leave Lesson") { dismiss() }
                Button("Wait for Refill", role: .cancel) { }
            } message: {
                Text("You've run out of hearts. Hearts refill over time, or complete this lesson correctly to earn them back!")
            }
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
            HeartsDisplay(hearts: user.hearts)
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
                    .fill(Color.aiPrimaryGradient)
                    .frame(width: geo.size.width * progressValue)
                    .animation(.spring(response: 0.4), value: progressValue)
            }
        }
        .frame(height: 8)
        .padding(.horizontal)
    }
    
    // MARK: - Question View
    @ViewBuilder
    private var questionView: some View {
        switch currentQuestion.type {
        case .multipleChoice:
            MultipleChoiceView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        case .trueFalse:
            TrueFalseView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        case .matchPairs:
            MatchPairsView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        case .fillInBlank:
            FillInBlankView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        case .sortOrder:
            SortOrderView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        case .scenarioJudgment:
            ScenarioJudgmentView(
                question: currentQuestion,
                selectedAnswer: $selectedAnswer,
                hasAnswered: hasAnsweredCurrent,
                isCorrect: isCorrect
            )
        }
    }
    
    // MARK: - Result Feedback
    private var resultFeedback: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                    .font(.title2)
                Text(isCorrect ? "Correct!" : "Not Quite")
                    .font(.aiHeadline())
                    .foregroundColor(isCorrect ? .aiSuccess : .aiError)
                Spacer()
            }
            
            Text(currentQuestion.explanation)
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
                            .fill(selectedAnswer.isEmpty && !showingResult ? AnyShapeStyle(Color.aiPrimary.opacity(0.4)) : AnyShapeStyle(Color.aiPrimaryGradient))
                    )
            }
            .disabled(selectedAnswer.isEmpty && !showingResult)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.aiBackground)
    }
    
    // MARK: - Logic
    private func checkAnswer() {
        guard !selectedAnswer.isEmpty else { return }
        
        let correct: Bool
        if currentQuestion.type == .sortOrder {
            correct = selectedAnswer == currentQuestion.correctAnswers.joined(separator: "||")
        } else if currentQuestion.type == .matchPairs {
            correct = selectedAnswer == "matched"
        } else {
            correct = selectedAnswer == currentQuestion.correctAnswer
        }
        
        isCorrect = correct
        hasAnsweredCurrent = true
        showingResult = true
        
        if correct {
            correctCount += 1
            if !hasAnsweredCurrent { firstTryCount += 1 }
            let xp = XPService.shared.xpForCorrectAnswer(firstTry: true)
            xpEarned += xp
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
            user.loseHeart()
            if user.hearts <= 0 {
                showNoHeartsAlert = true
            }
        }
        
        withAnimation(.spring(response: 0.3)) { }
    }
    
    private func moveToNext() {
        if currentIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                resetQuestionState()
            }
        } else {
            completeLessonAndShow()
        }
    }
    
    private func resetQuestionState() {
        selectedAnswer = ""
        hasAnsweredCurrent = false
        showingResult = false
        isCorrect = false
    }
    
    private func completeLessonAndShow() {
        // Bonus XP
        let isPerfect = correctCount == questions.count
        xpEarned += XPService.shared.lessonBonus
        if isPerfect { xpEarned += XPService.shared.perfectLessonBonus }
        
        user.addXP(xpEarned)
        user.totalLessonsCompleted += 1
        user.totalCorrectAnswers += correctCount
        user.totalQuestionsAnswered += questions.count
        
        // Update category progress
        if let idx = user.categoryProgressList.firstIndex(where: { $0.categoryId == category.id }) {
            if !user.categoryProgressList[idx].completedLessonIds.contains(lesson.id) {
                user.categoryProgressList[idx].completedLessonIds.append(lesson.id)
            }
            let stars = correctCount == questions.count ? 3 : correctCount >= questions.count - 1 ? 2 : 1
            user.categoryProgressList[idx].lessonStars[lesson.id] = max(stars, user.categoryProgressList[idx].lessonStars[lesson.id] ?? 0)
            user.categoryProgressList[idx].isComplete = user.categoryProgressList[idx].completedLessonIds.count >= category.lessons.count
        } else {
            let stars = correctCount == questions.count ? 3 : correctCount >= questions.count - 1 ? 2 : 1
            var newProgress = CategoryProgress(categoryId: category.id)
            newProgress.completedLessonIds.append(lesson.id)
            newProgress.lessonStars[lesson.id] = stars
            newProgress.isComplete = category.lessons.count <= 1
            user.categoryProgressList.append(newProgress)
        }
        
        user.todayXP += xpEarned
        user.lastActiveDate = Date()
        StreakService.shared.updateStreak(for: user)
        
        showLessonComplete = true
    }
}
