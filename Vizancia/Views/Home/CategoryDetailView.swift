import SwiftUI

struct CategoryDetailView: View {
    @Bindable var user: UserProfile
    let category: CategoryData
    @Environment(\.dismiss) private var dismiss
    @State private var showLesson: LessonData?
    
    private var progress: CategoryProgress? {
        user.categoryProgressList.first { $0.categoryId == category.id }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Category Header
                    VStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.aiPrimary)
                        Text(category.name)
                            .font(.aiTitle())
                        Text(category.description)
                            .font(.aiBody())
                            .foregroundColor(.aiTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    // Lessons List
                    VStack(spacing: 10) {
                        ForEach(Array(category.lessons.enumerated()), id: \.element.id) { index, lesson in
                            let completed = progress?.completedLessonIds.contains(lesson.id) ?? false
                            let locked = isLessonLocked(index: index)
                            let stars = progress?.lessonStars[lesson.id] ?? 0
                            LessonRow(
                                lesson: lesson,
                                isCompleted: completed,
                                isLocked: locked,
                                stars: stars
                            ) {
                                showLesson = lesson
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .fullScreenCover(item: $showLesson) { lesson in
                LessonView(user: user, lesson: lesson, category: category)
            }
        }
    }
    
    private func isLessonLocked(index: Int) -> Bool {
        if index == 0 { return false }
        let prevLesson = category.lessons[index - 1]
        return !(progress?.completedLessonIds.contains(prevLesson.id) ?? false)
    }
}
