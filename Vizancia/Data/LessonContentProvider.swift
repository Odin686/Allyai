import Foundation

class LessonContentProvider {
    static let shared = LessonContentProvider()
    
    lazy var allCategories: [CategoryData] = [
        CategoryContent1.aiBasics,
        CategoryContent2.howAILearns,
        CategoryContent3.generativeAI,
        CategoryContent4.promptEngineering,
        CategoryContent5.aiEthics,
        CategoryContent6.aiAtWork,
        CategoryContent7.aiHealthcare,
        CategoryContent8.aiCreativeArts,
        CategoryContent9.aiHistory,
        CategoryContent10.futureOfAI
    ]
    
    func category(byId id: String) -> CategoryData? {
        allCategories.first(where: { $0.id == id })
    }
    
    func lesson(byId id: String) -> LessonData? {
        allCategories.flatMap { $0.lessons }.first(where: { $0.id == id })
    }
    
    func lessons(forCategory categoryId: String) -> [LessonData] {
        category(byId: categoryId)?.lessons ?? []
    }
    
    func nextLesson(after lessonId: String) -> LessonData? {
        guard let lesson = lesson(byId: lessonId),
              let cat = category(byId: lesson.categoryId) else { return nil }
        return cat.lessons.first(where: { $0.order == lesson.order + 1 })
    }
}
