import SwiftUI

struct PromptCraftGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showResult = false
    @State private var lastCorrect = false
    
    private let totalRounds = 8
    
    private let challenges: [(task: String, options: [String], best: String, explanation: String)] = [
        (
            "You want a recipe for chocolate cake",
            [
                "Write a recipe for a moist chocolate cake with buttercream frosting, serves 8, with step-by-step instructions",
                "Write a detailed chocolate cake recipe, making sure it's really good and tastes amazing with lots of chocolate flavor throughout",
                "Write a chocolate cake recipe that's professional-grade, using advanced baking techniques and gourmet ingredients"
            ],
            "Write a recipe for a moist chocolate cake with buttercream frosting, serves 8, with step-by-step instructions",
            "The best prompt specifies the type (moist), frosting (buttercream), servings (8), and format (step-by-step). The others sound detailed but lack actionable specifics."
        ),
        (
            "You need a cover letter for a marketing job",
            [
                "Write a professional cover letter for a Digital Marketing Manager position at a tech startup, emphasizing 5 years of SEO and social media experience",
                "Write a compelling and professional cover letter that will impress hiring managers and help me stand out from other candidates",
                "Write a cover letter for a marketing role that highlights my strengths, achievements, and passion for the industry"
            ],
            "Write a professional cover letter for a Digital Marketing Manager position at a tech startup, emphasizing 5 years of SEO and social media experience",
            "The best prompt names the exact role, company type, and specific skills. The others sound professional but are too generic for AI to tailor the output."
        ),
        (
            "You want to understand quantum computing",
            [
                "Explain quantum computing to a high school student using everyday analogies, in 200 words or less",
                "Give me a thorough and comprehensive explanation of quantum computing that covers all the important concepts clearly",
                "Explain quantum computing in a way that's easy to understand, breaking down the complex topics into simpler terms"
            ],
            "Explain quantum computing to a high school student using everyday analogies, in 200 words or less",
            "Specifying the audience (high school), method (analogies), and length (200 words) gives the AI clear constraints. The others ask for simplicity but don't define what level."
        ),
        (
            "You want help debugging code",
            [
                "I have a Python function that should return the sum of a list but returns None. Here's the code: [code]. What's wrong and how do I fix it?",
                "I'm having trouble with my code and it's not working correctly. Can you take a look and help me figure out what's going wrong?",
                "Debug my Python code for me. It has a bug somewhere and I need you to find it and explain the solution step by step"
            ],
            "I have a Python function that should return the sum of a list but returns None. Here's the code: [code]. What's wrong and how do I fix it?",
            "The best prompt includes the language, expected behavior, actual behavior, and the code itself. The others mention debugging but don't provide the AI enough context to help."
        ),
        (
            "You need a bedtime story for a 5-year-old",
            [
                "Write a 3-minute bedtime story about a friendly dragon who learns to share, with a gentle moral and happy ending, suitable for a 5-year-old",
                "Write a creative and engaging bedtime story for a young child that teaches an important life lesson in a fun way",
                "Create a bedtime story with lovable characters and an imaginative plot that will help a child fall asleep peacefully"
            ],
            "Write a 3-minute bedtime story about a friendly dragon who learns to share, with a gentle moral and happy ending, suitable for a 5-year-old",
            "The best prompt specifies length (3 min), character (dragon), theme (sharing), tone (gentle), ending (happy), and age (5). The others are pleasant but vague."
        ),
        (
            "You want to plan a trip to Japan",
            [
                "Create a 7-day Tokyo itinerary for a first-time visitor interested in food, temples, and anime culture, with daily schedules and budget tips",
                "Help me plan an amazing trip to Japan with all the best things to see, eat, and experience as a tourist",
                "Plan a detailed Japan vacation covering the must-visit destinations, local cuisine recommendations, and cultural experiences"
            ],
            "Create a 7-day Tokyo itinerary for a first-time visitor interested in food, temples, and anime culture, with daily schedules and budget tips",
            "The best prompt specifies duration (7 days), city (Tokyo), experience level (first-time), interests (food, temples, anime), and format (daily schedules + budget)."
        ),
        (
            "You need email subject lines for a sale",
            [
                "Generate 10 email subject lines for a 40% off summer sale at an online fashion store, targeting women 25-35, tone: excited but not spammy",
                "Write creative and attention-grabbing email subject lines for a promotional sale that will maximize open rates",
                "Come up with email subject lines for our upcoming sale that are catchy, professional, and drive customer engagement"
            ],
            "Generate 10 email subject lines for a 40% off summer sale at an online fashion store, targeting women 25-35, tone: excited but not spammy",
            "The best prompt specifies quantity (10), discount (40%), season (summer), business type, audience (women 25-35), and tone constraints."
        ),
        (
            "You want to learn about AI bias",
            [
                "Explain 3 real-world examples of AI bias in hiring, healthcare, and criminal justice, including what caused the bias and how it could be prevented, in bullet points",
                "Give me a comprehensive overview of AI bias, explaining why it happens, where it shows up, and what we can do about it",
                "Write an in-depth analysis of bias in artificial intelligence systems, covering the key issues and potential solutions"
            ],
            "Explain 3 real-world examples of AI bias in hiring, healthcare, and criminal justice, including what caused the bias and how it could be prevented, in bullet points",
            "The best prompt specifies the number of examples (3), domains (hiring, healthcare, justice), what to cover (cause + prevention), and format (bullet points)."
        ),
        (
            "You want to write a LinkedIn post about your new job",
            [
                "Write a LinkedIn post announcing my new role as Senior Data Analyst at Google, thanking my previous team at IBM, tone: humble and professional, under 150 words",
                "Help me write a LinkedIn post about starting a new job that will get lots of engagement and make a great impression on my network",
                "Write a professional LinkedIn announcement about my career move that conveys excitement while maintaining a polished tone"
            ],
            "Write a LinkedIn post announcing my new role as Senior Data Analyst at Google, thanking my previous team at IBM, tone: humble and professional, under 150 words",
            "The best prompt includes the role, company, what to mention (previous team), tone (humble, professional), and length constraint (150 words)."
        ),
        (
            "You want AI to help you study for a biology exam",
            [
                "Create 15 flashcard-style Q&A pairs on cell biology for a college freshman, covering mitosis, organelles, and cell membrane transport",
                "Help me study for my biology exam by creating comprehensive study materials that cover all the important topics",
                "Generate study questions for biology that test my understanding of the key concepts and help me prepare for my exam"
            ],
            "Create 15 flashcard-style Q&A pairs on cell biology for a college freshman, covering mitosis, organelles, and cell membrane transport",
            "The best prompt specifies quantity (15), format (flashcard Q&A), subject (cell biology), level (college freshman), and exact topics to cover."
        )
    ]
    
    @State private var shuffled: [(task: String, options: [String], best: String, explanation: String)] = []
    @State private var currentShuffledOptions: [String] = []
    @State private var showTutorial = true

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Prompt Craft",
                    icon: "text.cursor",
                    color: .aiSuccess,
                    rules: [
                        "You'll see a task you want AI to do",
                        "Pick the best prompt from 3 options",
                        "Better prompts are specific and detailed",
                        "8 rounds — become a prompt master!"
                    ]
                ) { showTutorial = false }
            } else if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffled.count) {
                let ch = shuffled[round]
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HStack {
                            Button { dismiss() } label: { Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary) }
                            Spacer()
                            Text("Round \(round + 1)/\(totalRounds)").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            Spacer()
                            Text("Score: \(score)").font(.aiRounded(.body, weight: .bold)).foregroundColor(.aiPrimary)
                        }
                        
                        VStack(spacing: 6) {
                            Text("Your Task:").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                            Text(ch.task).font(.aiTitle3()).foregroundColor(.aiTextPrimary).multilineTextAlignment(.center)
                        }
                        
                        Text("Pick the best prompt:").font(.aiCaption()).foregroundColor(.aiTextSecondary)
                        
                        if showResult {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Perfect Pick!" : "Not the best choice")
                            }.font(.aiHeadline()).foregroundColor(lastCorrect ? .aiSuccess : .aiError)
                            Text(ch.explanation).font(.aiCaption()).foregroundColor(.aiTextSecondary).multilineTextAlignment(.center)
                            
                            Button {
                                showResult = false
                                round += 1
                                if round >= totalRounds { endGame() }
                                else if round < shuffled.count { currentShuffledOptions = shuffled[round].options.shuffled() }
                            } label: {
                                Text("Next").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                            }
                        } else {
                            ForEach(currentShuffledOptions, id: \.self) { opt in
                                Button {
                                    lastCorrect = opt == ch.best
                                    if lastCorrect { score += 1; HapticService.shared.success() } else { HapticService.shared.error() }
                                    showResult = true
                                } label: {
                                    Text(opt).font(.aiCaption()).foregroundColor(.aiTextPrimary).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiCard).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)))
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            shuffled = challenges.shuffled()
            if !shuffled.isEmpty { currentShuffledOptions = shuffled[0].options.shuffled() }
        }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.cursor").font(.system(size: 50)).foregroundColor(.aiSuccess)
            Text("Prompt Master!").font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["promptCraft"] ?? 0) { Text("🎉 New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning) }
            VStack(spacing: 12) {
                Button { round = 0; score = 0; isGameOver = false; shuffled = challenges.shuffled(); currentShuffledOptions = shuffled[0].options.shuffled() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }.padding(.horizontal, 30)
        }
    }
    
    private func endGame() {
        let xp = score * 10; user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["promptCraft"] ?? 0) { user.gameHighScores["promptCraft"] = score }
        isGameOver = true
    }
}
