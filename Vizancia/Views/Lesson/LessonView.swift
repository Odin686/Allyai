import SwiftUI

struct LessonView: View {
    @Bindable var user: UserProfile
    let lesson: LessonData
    let category: CategoryData
    var onNextLesson: ((LessonData) -> Void)?
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
    @State private var comboCount = 0
    @State private var showCombo = false
    @State private var comboText = ""
    @State private var showFunFact = false
    @State private var currentFunFact = ""
    @State private var showHeartGame = false
    @State private var showIntro = true
    
    @State private var shuffledQuestions: [Question] = []
    private var questions: [Question] { shuffledQuestions.isEmpty ? lesson.questions : shuffledQuestions }
    private var currentQuestion: Question { questions[currentIndex] }
    private var progressValue: Double { Double(currentIndex) / Double(questions.count) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                if showIntro {
                    lessonIntro
                } else {

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
                                .id(currentIndex)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))

                            if showingResult {
                                resultFeedback
                                    .transition(.move(edge: .bottom).combined(with: .opacity))

                                Text("Tap anywhere to continue")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.aiTextSecondary.opacity(0.5))
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .onTapGesture {
                        if showingResult { moveToNext() }
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

                // Fun fact card
                if showFunFact {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.aiWarning)
                            Text(currentFunFact)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiWarning.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.aiWarning.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 120)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .allowsHitTesting(false)
                }

                // Combo streak banner
                if showCombo {
                    VStack {
                        Spacer()
                        Text(comboText)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.aiOrange)
                                    .shadow(color: .aiOrange.opacity(0.4), radius: 8, y: 4)
                            )
                            .transition(.scale.combined(with: .opacity))
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
            }

            } // end else (not showIntro)
            .navigationBarHidden(true)
            .onAppear {
                if shuffledQuestions.isEmpty {
                    shuffledQuestions = buildQuestionList()
                }
            }
            .fullScreenCover(isPresented: $showLessonComplete) {
                LessonCompleteView(
                    user: user,
                    lesson: lesson,
                    category: category,
                    correctCount: correctCount,
                    totalQuestions: questions.count,
                    xpEarned: xpEarned,
                    firstTryCount: firstTryCount,
                    onNextLesson: { nextLesson in
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onNextLesson?(nextLesson)
                        }
                    }
                )
            }
            .alert("No Hearts Left!", isPresented: $showNoHeartsAlert) {
                Button("Play for Hearts") { showHeartGame = true }
                Button("Keep Trying", role: .cancel) { }
                Button("Leave Lesson", role: .destructive) { dismiss() }
            } message: {
                Text("Score 3+ in Jargon Match to earn a heart back!")
            }
            .fullScreenCover(isPresented: $showHeartGame) {
                HeartEarnGameView(user: user)
            }
        }
    }
    
    // MARK: - Lesson Intro
    private var lessonIntro: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: category.icon)
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)

            Text(lesson.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)

            Text(lesson.description)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            HStack(spacing: 20) {
                Label("\(lesson.questionCount) questions", systemImage: "questionmark.circle")
                Label("~\(max(lesson.questionCount / 2, 2)) min", systemImage: "clock")
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.aiTextSecondary)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3)) { showIntro = false }
                SoundService.shared.play(.whoosh)
                HapticService.shared.mediumTap()
            } label: {
                Text("Start Lesson")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)

            Button { dismiss() } label: {
                Text("Back")
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.bottom, 20)
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
    
    private var heartsRefillMessage: String {
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let remaining = tomorrow.timeIntervalSince(Date())
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "You've run out of hearts. Hearts refill in \(hours)h \(minutes)m. You can keep trying this lesson, but be careful!"
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
        let wasFirstAttempt = !hasAnsweredCurrent
        hasAnsweredCurrent = true
        showingResult = true
        user.recordCategoryAnswer(categoryId: category.id, correct: correct)

        if correct {
            correctCount += 1
            comboCount += 1
            if wasFirstAttempt { firstTryCount += 1 }
            let xp = XPService.shared.xpForCorrectAnswer(firstTry: wasFirstAttempt)
            xpEarned += xp
            user.removeMissedQuestion(currentQuestion.id)
            HapticService.shared.success()
            SoundService.shared.play(.correct)

            // Combo celebration
            if comboCount >= 3 {
                comboText = comboCount == 3 ? "3 in a row!" : comboCount == 4 ? "4 in a row!" : comboCount == 5 ? "5 in a row! On fire!" : "\(comboCount)x Combo!"
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showCombo = true }
                HapticService.shared.comboPulse()
                SoundService.shared.play(.comboTick)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showCombo = false }
                }
            }
        } else {
            comboCount = 0
            user.addMissedQuestion(currentQuestion.id)
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
            let nextIndex = currentIndex + 1
            // Show fun fact after questions 2 and 4 (indices 1 and 3)
            if (currentIndex == 1 || currentIndex == 3) && currentIndex < questions.count - 1 {
                showFunFactBriefly {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentIndex = nextIndex
                        resetQuestionState()
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentIndex = nextIndex
                    resetQuestionState()
                }
            }
        } else {
            completeLessonAndShow()
        }
    }

    private func showFunFactBriefly(then action: @escaping () -> Void) {
        currentFunFact = FunFacts.random()
        withAnimation(.spring(response: 0.4)) { showFunFact = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showFunFact = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { action() }
        }
    }
    
    // MARK: - Spaced Repetition & Difficulty Adaptation
    private func buildQuestionList() -> [Question] {
        // Sort by difficulty based on user's category accuracy
        let accuracy = user.categoryAccuracy(for: category.id)
        var questions: [Question]
        if accuracy >= 0.85 {
            // High accuracy: put harder questions first
            questions = lesson.questions.sorted { q1, q2 in
                difficultyRank(q1.difficulty) > difficultyRank(q2.difficulty)
            }
        } else if accuracy <= 0.5 && accuracy > 0 {
            // Low accuracy: put easier questions first
            questions = lesson.questions.sorted { q1, q2 in
                difficultyRank(q1.difficulty) < difficultyRank(q2.difficulty)
            }
        } else {
            questions = lesson.questions.shuffled()
        }

        // Inject up to 2 missed questions from other lessons for spaced repetition
        let missedFromOtherLessons = LessonContentProvider.shared.missedQuestions(for: user.missedQuestionIds)
            .filter { q in !lesson.questions.contains(where: { $0.id == q.id }) }
            .prefix(2)
        if !missedFromOtherLessons.isEmpty {
            for (i, q) in missedFromOtherLessons.enumerated() {
                let insertIndex = min(questions.count, 2 + i * 2)
                questions.insert(q, at: insertIndex)
            }
        }
        return questions
    }

    private func difficultyRank(_ difficulty: Difficulty) -> Int {
        switch difficulty {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
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
