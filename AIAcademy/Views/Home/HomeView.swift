import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?
    @State private var xpFloatText = ""
    @State private var showXPFloat = false
    
    private let provider = LessonContentProvider.shared
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Stats
                    headerSection
                    
                    // Daily Goal
                    DailyGoalWidget(user: user)
                        .padding(.horizontal)
                    
                    // Categories Grid
                    categoriesSection
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Vizancia")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { headerToolbar }
            .sheet(item: $showCategoryDetail) { cat in
                CategoryDetailView(user: user, category: cat)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            XPProgressBar(
                currentXP: user.totalXP,
                progress: user.levelProgress,
                level: user.currentLevel
            )
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                HeartsDisplay(hearts: user.hearts)
                Spacer()
                StreakBadge(streak: user.currentStreak)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var headerToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            LevelBadge(level: user.currentLevel, size: 34)
        }
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Learning Paths")
                .font(.aiTitle())
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ], spacing: 14) {
                ForEach(provider.allCategories) { category in
                    let locked = isCategoryLocked(category)
                    let progress = user.categoryProgressList.first { $0.categoryId == category.id }
                    CategoryCard(
                        category: category,
                        progress: progress,
                        isLocked: locked
                    ) {
                        showCategoryDetail = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helpers
    private func isCategoryLocked(_ category: CategoryData) -> Bool {
        switch category.unlockRequirement {
        case .none:
            return false
        case .completeCategory(let id):
            return !(user.categoryProgressList.first { $0.categoryId == id }?.isComplete ?? false)
        case .completeCategoryMinimum(let id):
            let progress = user.categoryProgressList.first { $0.categoryId == id }
            return (progress?.completedLessonIds.count ?? 0) < 2
        }
    }
}
