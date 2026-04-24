import SwiftUI

struct OnboardingView: View {
    @Bindable var user: UserProfile
    @State private var currentPage = 0
    @State private var selectedGoal: DailyGoalTier = .casual
    @State private var enableNotifications = true
    @State private var nameText = ""
    @State private var selectedExperience: UserProfile.ExperienceLevel = .beginner
    @State private var selectedRole: UserProfile.UserRole = .curious
    @State private var selectedOccupation = ""

    // Animation states
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var particlePhase: CGFloat = 0

    private let totalPages = 7

    var body: some View {
        ZStack {
            // Animated gradient background
            backgroundGradient
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                nameInputPage.tag(1)
                experiencePage.tag(2)
                whyHerePage.tag(3)
                occupationPage.tag(4)
                goalPage.tag(5)
                readyPage.tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.4), value: currentPage)

            // Page indicator
            VStack {
                Spacer()
                pageIndicator
                    .padding(.bottom, 30)
            }
        }
        .onChange(of: currentPage) { _, _ in
            resetAnimations()
            triggerPageAnimations()
        }
    }

    // MARK: - Animated Background
    private var backgroundGradient: some View {
        ZStack {
            Color.aiBackground

            // Subtle animated orbs
            Circle()
                .fill(Color.aiPrimary.opacity(0.04))
                .frame(width: 300, height: 300)
                .offset(x: -50, y: -200 + particlePhase * 20)
                .blur(radius: 60)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: particlePhase)

            Circle()
                .fill(Color.aiGradientEnd.opacity(0.03))
                .frame(width: 250, height: 250)
                .offset(x: 80, y: 150 - particlePhase * 15)
                .blur(radius: 50)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true).delay(1), value: particlePhase)
        }
        .onAppear { particlePhase = 1 }
    }

    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.aiPrimary : Color.aiPrimary.opacity(0.2))
                    .frame(width: i == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    // MARK: - Animation Helpers
    private func resetAnimations() {
        iconScale = 0.3
        iconOpacity = 0
        titleOffset = 30
        titleOpacity = 0
        contentOpacity = 0
        buttonOpacity = 0
    }

    private func triggerPageAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            titleOffset = 0
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
            contentOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.6)) {
            buttonOpacity = 1
        }
    }

    // MARK: - Page 1: Welcome
    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()

            // Animated icon
            ZStack {
                // Glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.aiPrimary.opacity(0.08 - Double(i) * 0.02), lineWidth: 2)
                        .frame(width: CGFloat(120 + i * 40), height: CGFloat(120 + i * 40))
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                }

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.aiPrimary, .aiGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("Vizancia")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.aiPrimary, .aiGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            Text("Master AI, one lesson at a time.\nLet's personalize your journey!")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .opacity(contentOpacity)

            // Feature pills
            HStack(spacing: 12) {
                featurePill(icon: "🧠", text: "Learn")
                featurePill(icon: "🎮", text: "Play")
                featurePill(icon: "⚔️", text: "Compete")
            }
            .opacity(contentOpacity)

            Spacer()
            nextButton { withAnimation { currentPage = 1 } }
                .opacity(buttonOpacity)
        }
        .padding(30)
        .onAppear { triggerPageAnimations() }
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
        )
    }

    // MARK: - Page 2: Name
    private var nameInputPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.08))
                    .frame(width: 90, height: 90)
                    .scaleEffect(iconScale)
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.aiPrimary)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            Text("What should I call you?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            TextField("Your name", text: $nameText)
                .font(.system(size: 18, design: .rounded))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.aiPrimary.opacity(0.3), lineWidth: 1)
                        )
                )
                .autocorrectionDisabled()
                .submitLabel(.continue)
                .onSubmit {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .opacity(contentOpacity)

            Text("This is how we'll greet you 👋")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .opacity(contentOpacity)

            Spacer()
            nextButton {
                user.userName = nameText.isEmpty ? "Learner" : nameText
                user.name = user.userName
                withAnimation { currentPage = 2 }
            }
            .opacity(buttonOpacity)
        }
        .padding(30)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Page 3: Experience Level
    private var experiencePage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .scaleEffect(iconScale)
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundColor(.aiPrimary)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            VStack(spacing: 6) {
                Text("Have you used AI before?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                Text("Like ChatGPT, Siri, or other AI tools")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            VStack(spacing: 10) {
                experienceOption(.beginner, emoji: "🌱", label: "Never used AI", detail: "I'm completely new to this")
                experienceOption(.familiar, emoji: "👋", label: "A few times", detail: "I've tried ChatGPT or similar")
                experienceOption(.regular, emoji: "💻", label: "I use AI regularly", detail: "It's part of my routine")
                experienceOption(.builder, emoji: "🛠️", label: "I build with AI", detail: "I create AI apps or models")
            }
            .opacity(contentOpacity)

            Spacer()
            nextButton {
                user.experienceLevel = selectedExperience
                withAnimation { currentPage = 3 }
            }
            .opacity(buttonOpacity)
        }
        .padding(30)
    }

    // MARK: - Page 4: Why Are You Here?
    private var whyHerePage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .scaleEffect(iconScale)
                Image(systemName: "target")
                    .font(.system(size: 36))
                    .foregroundColor(.aiPrimary)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            VStack(spacing: 6) {
                Text("Why are you here?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                Text("This helps personalize your journey")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            VStack(spacing: 10) {
                roleOption(.curious, emoji: "🔍", label: "Just curious", detail: "I want to understand AI better")
                roleOption(.student, emoji: "📚", label: "School or study", detail: "Learning for class or self-study")
                roleOption(.professional, emoji: "💼", label: "Career growth", detail: "AI skills for my job or career")
                roleOption(.fun, emoji: "🎮", label: "Just for fun", detail: "I like learning new things")
            }
            .opacity(contentOpacity)

            Spacer()
            nextButton {
                user.userRole = selectedRole
                withAnimation { currentPage = 4 }
            }
            .opacity(buttonOpacity)
        }
        .padding(30)
    }

    // MARK: - Page 5: Occupation
    private var occupationPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.aiPrimary.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .scaleEffect(iconScale)
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 36))
                    .foregroundColor(.aiPrimary)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            Text("What describes you best?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            let occupations = [
                ("🎒", "Student"),
                ("👩‍💻", "Working professional"),
                ("🎓", "Teacher / Educator"),
                ("🧒", "Young learner"),
                ("🔄", "Career changer"),
                ("🧠", "Lifelong learner"),
            ]

            VStack(spacing: 10) {
                ForEach(occupations, id: \.1) { emoji, label in
                    selectionRow(
                        emoji: emoji,
                        label: label,
                        isSelected: selectedOccupation == label
                    ) {
                        selectedOccupation = label
                        HapticService.shared.lightTap()
                    }
                }
            }
            .opacity(contentOpacity)

            Spacer()
            nextButton { withAnimation { currentPage = 5 } }
                .opacity(buttonOpacity)
        }
        .padding(30)
    }

    // MARK: - Page 6: Daily Goal
    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.aiSuccess.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .scaleEffect(iconScale)
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.aiOrange)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            VStack(spacing: 6) {
                Text("Set Your Daily Goal")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                Text(vizGoalMessage)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            VStack(spacing: 10) {
                ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                    Button {
                        selectedGoal = tier
                        HapticService.shared.lightTap()
                    } label: {
                        HStack {
                            Text(tier.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.rawValue.capitalized)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.aiTextPrimary)
                                Text("\(tier.xpTarget) XP per day")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.aiTextSecondary)
                            }
                            Spacer()
                            if selectedGoal == tier {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.aiSuccess)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedGoal == tier ? Color.aiSuccess.opacity(0.08) : Color.aiCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedGoal == tier ? Color.aiSuccess : Color.aiTextSecondary.opacity(0.15), lineWidth: selectedGoal == tier ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .opacity(contentOpacity)

            Spacer()
            nextButton {
                user.dailyGoalTier = selectedGoal
                user.dailyXPGoal = selectedGoal.xpTarget
                if enableNotifications {
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            NotificationService.shared.scheduleDailyReminder(hour: 19, minute: 0)
                        }
                    }
                }
                withAnimation { currentPage = 6 }
            }
            .opacity(buttonOpacity)
        }
        .padding(30)
    }

    // MARK: - Page 7: Launch!
    private var readyPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Celebration rings
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.aiPrimary.opacity(0.1), .aiGradientEnd.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: CGFloat(100 + i * 30), height: CGFloat(100 + i * 30))
                        .scaleEffect(iconScale)
                }
                Image(systemName: "rocket.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.aiPrimary, .aiGradientEnd],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }

            VStack(spacing: 8) {
                Text(vizReadyMessage)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text(vizReadySubtitle)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            // Quick summary
            VStack(spacing: 8) {
                summaryRow(emoji: "🎯", text: "Goal: \(selectedGoal.rawValue.capitalized) (\(selectedGoal.xpTarget) XP/day)")
                summaryRow(emoji: "🧠", text: "Experience: \(selectedExperience.displayName)")
                summaryRow(emoji: "📚", text: "16 categories, 96+ lessons ready")
            }
            .opacity(contentOpacity)

            // Notification toggle
            Toggle(isOn: $enableNotifications) {
                Label("Daily Reminders", systemImage: "bell.badge.fill")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))
            .opacity(contentOpacity)

            Spacer()
            Button {
                user.notificationsEnabled = enableNotifications
                withAnimation(.spring(response: 0.4)) {
                    user.onboardingCompleted = true
                }
                HapticService.shared.success()
            } label: {
                HStack(spacing: 8) {
                    Text("Let's Go!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.aiPrimaryGradient))
                .shadow(color: Color.aiPrimary.opacity(0.3), radius: 8, y: 4)
            }
            .opacity(buttonOpacity)
        }
        .padding(30)
    }

    private func summaryRow(emoji: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(emoji).font(.system(size: 16))
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.aiCard.opacity(0.7))
        )
    }

    // MARK: - Contextual Messages
    private var vizGoalMessage: String {
        switch selectedExperience {
        case .beginner: return "Since you're new to AI, I'd suggest starting casual!"
        case .familiar: return "You've got some experience — regular is a great pace!"
        case .regular: return "You're already using AI — let's go serious!"
        case .builder: return "A builder! Intense mode will keep you challenged."
        }
    }

    private var vizReadyMessage: String {
        let name = nameText.isEmpty ? "friend" : nameText
        return "Ready, \(name)!"
    }

    private var vizReadySubtitle: String {
        switch selectedRole {
        case .curious: return "Let's explore the world of AI together. I'll make it fun!"
        case .student: return "I'll help you ace AI topics for school. Let's learn!"
        case .professional: return "Let's build your AI skills for career growth!"
        case .fun: return "Time to have fun while learning something amazing!"
        }
    }

    // MARK: - Reusable Components
    private func experienceOption(_ level: UserProfile.ExperienceLevel, emoji: String, label: String, detail: String) -> some View {
        selectionRow(emoji: emoji, label: label, detail: detail, isSelected: selectedExperience == level) {
            selectedExperience = level
            HapticService.shared.lightTap()
        }
    }

    private func roleOption(_ role: UserProfile.UserRole, emoji: String, label: String, detail: String) -> some View {
        selectionRow(emoji: emoji, label: label, detail: detail, isSelected: selectedRole == role) {
            selectedRole = role
            HapticService.shared.lightTap()
        }
    }

    private func selectionRow(emoji: String, label: String, detail: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    if let detail {
                        Text(detail)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.aiSuccess)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.aiSuccess.opacity(0.08) : Color.aiCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.aiSuccess : Color.aiTextSecondary.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.aiPrimaryGradient)
                    .shadow(color: Color.aiPrimary.opacity(0.2), radius: 6, y: 3)
            )
        }
    }
}
