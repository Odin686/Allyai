import SwiftUI

struct GamesHubView: View {
    @Bindable var user: UserProfile
    @State private var showGame: GameType?
    
    private let games: [(type: GameType, title: String, description: String, icon: String, color: Color)] = [
        (.speedRound, "Speed Round", "Answer as many questions as you can in 60 seconds!", "bolt.fill", .aiOrange),
        (.aiOrNot, "AI or Not?", "Guess if a statement was made by AI or a human.", "questionmark.circle.fill", .aiPrimary),
        (.ethicsCourt, "Ethics Court", "Judge ethical dilemmas involving AI.", "building.columns.fill", .aiError),
        (.promptCraft, "Prompt Craft", "Pick the best prompt for each scenario.", "text.cursor", .aiSuccess),
        (.buzzwordBuster, "Buzzword Buster", "True or false: Is this AI term real or made up?", "textformat.abc", .aiSecondary)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(games, id: \.type) { game in
                        GameCard(
                            title: game.title,
                            description: game.description,
                            icon: game.icon,
                            color: game.color,
                            highScore: user.gameHighScores[game.type.rawValue] ?? 0
                        ) {
                            showGame = game.type
                        }
                    }
                }
                .padding()
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Mini-Games")
            .fullScreenCover(item: $showGame) { type in
                gameView(for: type)
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for type: GameType) -> some View {
        switch type {
        case .speedRound: SpeedRoundGame(user: user)
        case .aiOrNot: AIOrNotGame(user: user)
        case .ethicsCourt: EthicsCourtGame(user: user)
        case .promptCraft: PromptCraftGame(user: user)
        case .buzzwordBuster: BuzzwordBusterGame(user: user)
        }
    }
}

// MARK: - Game Card
struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let highScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    Text(description)
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    if highScore > 0 {
                        Text("Best")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        Text("\(highScore)")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(color)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.aiTextSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
        }
    }
}
