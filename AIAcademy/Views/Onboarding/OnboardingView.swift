import SwiftUI

struct OnboardingView: View {
    @Bindable var user: UserProfile
    @State private var currentPage = 0
    @State private var selectedGoal: DailyGoalTier = .casual
    @State private var enableNotifications = true
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                valuePropPage.tag(1)
                goalPage.tag(2)
                reminderPage.tag(3)
                readyPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Page dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(i == currentPage ? Color.aiPrimary : Color.aiPrimary.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Page 1: Welcome
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.aiPrimary)
            Text("Welcome to\nVizancia")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.aiTextPrimary)
            Text("Learn AI the fun way")
                .font(.aiTitle3())
                .foregroundColor(.aiTextSecondary)
            Spacer()
            nextButton { currentPage = 1 }
        }
        .padding(30)
    }
    
    // MARK: - Page 2: Value Prop
    private var valuePropPage: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 20) {
                featureRow(icon: "sparkles", color: .aiPrimary, title: "10 AI Topics", subtitle: "From basics to future trends")
                featureRow(icon: "gamecontroller.fill", color: .aiOrange, title: "5 Mini-Games", subtitle: "Learn while playing")
                featureRow(icon: "flame.fill", color: .aiError, title: "Daily Streaks", subtitle: "Build a learning habit")
                featureRow(icon: "trophy.fill", color: .aiWarning, title: "20+ Achievements", subtitle: "Unlock milestones")
            }
            
            Spacer()
            nextButton { currentPage = 2 }
        }
        .padding(30)
    }
    
    // MARK: - Page 3: Goal
    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(.aiSuccess)
            Text("Set Your Daily Goal")
                .font(.aiTitle())
            Text("How much time can you dedicate?")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
            
            VStack(spacing: 10) {
                ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                    Button {
                        selectedGoal = tier
                        HapticService.shared.lightTap()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.rawValue.capitalized).font(.aiHeadline()).foregroundColor(.aiTextPrimary)
                                Text("\(tier.xpTarget) XP per day").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            }
                            Spacer()
                            if selectedGoal == tier {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.aiSuccess)
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
            
            Spacer()
            nextButton { user.dailyGoalTier = selectedGoal; user.dailyXPGoal = selectedGoal.xpTarget; currentPage = 3 }
        }
        .padding(30)
    }
    
    // MARK: - Page 4: Reminder
    private var reminderPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiOrange)
            Text("Stay on Track")
                .font(.aiTitle())
            Text("Get a daily reminder to keep learning")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
            
            Toggle(isOn: $enableNotifications) {
                Label("Daily Reminders", systemImage: "bell.badge.fill")
                    .font(.aiHeadline())
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard))
            
            Spacer()
            nextButton {
                user.notificationsEnabled = enableNotifications
                if enableNotifications {
                    NotificationService.shared.requestPermission { granted in
                        if granted {
                            NotificationService.shared.scheduleDailyReminder(hour: 19, minute: 0)
                        }
                    }
                }
                currentPage = 4
            }
        }
        .padding(30)
    }
    
    // MARK: - Page 5: Ready
    private var readyPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "rocket.fill")
                .font(.system(size: 80))
                .foregroundColor(.aiPrimary)
            Text("You're Ready!")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text("Start your AI learning journey")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
            Spacer()
            Button {
                withAnimation {
                    user.onboardingCompleted = true
                }
                HapticService.shared.success()
            } label: {
                Text("Let's Go! 🚀")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.aiPrimaryGradient))
            }
        }
        .padding(30)
    }
    
    // MARK: - Helpers
    private func nextButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Continue")
                .font(.aiHeadline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
        }
    }
    
    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Circle().fill(color.opacity(0.12)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.aiHeadline()).foregroundColor(.aiTextPrimary)
                Text(subtitle).font(.aiCaption()).foregroundColor(.aiTextSecondary)
            }
            Spacer()
        }
    }
}
