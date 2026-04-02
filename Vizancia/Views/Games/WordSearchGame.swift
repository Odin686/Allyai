import SwiftUI

struct WordSearchGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var grid: [[Character]] = []
    @State private var words: [String] = []
    @State private var foundWords: Set<String> = []
    @State private var selectedPositions: [(Int, Int)] = []
    @State private var highlightedPositions: Set<String> = []
    @State private var score = 0
    @State private var timeRemaining = 90
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var timer: Timer?
    @State private var flashColor: Color = .clear

    private let gridSize = 10

    private let wordSets: [[String]] = [
        ["TOKEN", "MODEL", "TRAIN", "AGENT", "LAYER"],
        ["EPOCH", "BATCH", "BIAS", "NEURAL", "CLOUD"],
        ["LEARN", "DATA", "PROMPT", "SCALE", "EMBED"],
        ["WEIGHT", "LOSS", "NODE", "TENSOR", "INPUT"],
        ["PIXEL", "LABEL", "MASK", "VECTOR", "CHAIN"],
        ["BERT", "LLAMA", "ALIGN", "FUSE", "DEPTH"],
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Word Search",
                    icon: "magnifyingglass",
                    color: .aiPrimary,
                    rules: [
                        "Find 5 hidden AI terms in the grid",
                        "Tap letters in sequence to spell a word",
                        "Words can be horizontal, vertical, or diagonal",
                        "Find all words before time runs out!"
                    ]
                ) { showTutorial = false; startGame() }
            } else if isGameOver {
                gameOverView
            } else {
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(timeRemaining <= 15 ? .aiError : .aiPrimary)
                            Text("\(timeRemaining)s")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(timeRemaining <= 15 ? .aiError : .aiPrimary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(score)")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(.aiTextPrimary)
                        }
                    }
                    .padding(.horizontal)

                    // Selected letters display
                    Text(selectedString)
                        .font(.aiRounded(.title3, weight: .bold))
                        .foregroundColor(.aiPrimary)
                        .frame(height: 30)

                    // Grid
                    VStack(spacing: 2) {
                        ForEach(0..<gridSize, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<gridSize, id: \.self) { col in
                                    letterCell(row: row, col: col)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)

                    // Clear selection button
                    if !selectedPositions.isEmpty {
                        Button {
                            selectedPositions.removeAll()
                        } label: {
                            Text("Clear Selection")
                                .font(.aiCaption())
                                .foregroundColor(.aiError)
                        }
                    }

                    // Word list
                    VStack(spacing: 8) {
                        Text("Find these words:")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 6) {
                            ForEach(words, id: \.self) { word in
                                Text(word)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(foundWords.contains(word) ? .aiSuccess : .aiTextPrimary)
                                    .strikethrough(foundWords.contains(word), color: .aiSuccess)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(foundWords.contains(word) ? Color.aiSuccess.opacity(0.15) : Color.aiCard)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onAppear { if !showTutorial { startGame() } }
        .onDisappear { timer?.invalidate() }
    }

    private var selectedString: String {
        String(selectedPositions.map { grid[$0.0][$0.1] })
    }

    private func posKey(_ row: Int, _ col: Int) -> String {
        "\(row),\(col)"
    }

    private func letterCell(row: Int, col: Int) -> some View {
        let key = posKey(row, col)
        let isHighlighted = highlightedPositions.contains(key)
        let isSelected = selectedPositions.contains(where: { $0.0 == row && $0.1 == col })
        let letter = grid.isEmpty ? " " : String(grid[row][col])

        return Button {
            tapLetter(row: row, col: col)
        } label: {
            Text(letter)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? .white : (isSelected ? .white : .aiTextPrimary))
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHighlighted ? Color.aiSuccess : (isSelected ? Color.aiPrimary.opacity(0.7) : Color.aiCard))
                )
        }
        .disabled(isHighlighted)
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)
            Text(foundWords.count == words.count ? "All Found!" : "Time's Up!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            Text("\(foundWords.count)/\(words.count) words found")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)

            if score > (user.gameHighScores["wordSearch"] ?? 0) {
                Text("New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }

            VStack(spacing: 12) {
                Button {
                    isGameOver = false
                    startGame()
                } label: {
                    Text("Play Again")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal, 30)
        }
    }

    private func startGame() {
        words = wordSets.randomElement()!
        foundWords.removeAll()
        selectedPositions.removeAll()
        highlightedPositions.removeAll()
        score = 0
        timeRemaining = 90
        generateGrid()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }

    private func generateGrid() {
        // Initialize empty grid
        var g = Array(repeating: Array(repeating: Character(" "), count: gridSize), count: gridSize)

        // Place words
        for word in words {
            placeWord(word, in: &g)
        }

        // Fill empty cells with deceptive letters (weighted toward letters common in AI terms)
        let letters = "AADDEEIILLMNNOORRSTTAEIONTLRM"
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                if g[r][c] == " " {
                    g[r][c] = letters.randomElement()!
                }
            }
        }

        grid = g
    }

    private func placeWord(_ word: String, in grid: inout [[Character]]) {
        let chars = Array(word)
        let len = chars.count

        // Directions: horizontal, vertical, diagonal down-right, diagonal down-left
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]

        // Also try reversed words for extra difficulty
        let variants: [[Character]] = [chars, chars.reversed()]

        for _ in 0..<200 {
            let variant = variants.randomElement()!
            let dir = directions.randomElement()!
            let row = Int.random(in: 0..<gridSize)
            let col = Int.random(in: 0..<gridSize)

            let endRow = row + (len - 1) * dir.0
            let endCol = col + (len - 1) * dir.1

            guard endRow >= 0 && endRow < gridSize && endCol >= 0 && endCol < gridSize else { continue }

            if canPlace(variant, in: grid, row: row, col: col, dRow: dir.0, dCol: dir.1) {
                for i in 0..<len {
                    grid[row + i * dir.0][col + i * dir.1] = variant[i]
                }
                return
            }
        }

        // Fallback: force place horizontally
        for row in 0..<gridSize {
            for col in 0...(gridSize - len) {
                if canPlace(chars, in: grid, row: row, col: col, dRow: 0, dCol: 1) {
                    for i in 0..<len {
                        grid[row][col + i] = chars[i]
                    }
                    return
                }
            }
        }
    }

    private func canPlace(_ chars: [Character], in grid: [[Character]], row: Int, col: Int, dRow: Int, dCol: Int) -> Bool {
        for i in 0..<chars.count {
            let r = row + i * dRow
            let c = col + i * dCol
            if r >= gridSize || c >= gridSize { return false }
            let existing = grid[r][c]
            if existing != " " && existing != chars[i] { return false }
        }
        return true
    }

    private func tapLetter(row: Int, col: Int) {
        let alreadySelected = selectedPositions.contains(where: { $0.0 == row && $0.1 == col })

        if alreadySelected {
            // Deselect by removing from the tap point onward
            if let idx = selectedPositions.firstIndex(where: { $0.0 == row && $0.1 == col }) {
                selectedPositions.removeSubrange(idx...)
            }
            HapticService.shared.lightTap()
            return
        }

        // Enforce adjacency: must be in same row or same column as all other selections
        if !selectedPositions.isEmpty {
            let isInLine = isValidNextPosition(row: row, col: col)
            if !isInLine {
                HapticService.shared.error()
                return
            }
        }

        selectedPositions.append((row, col))
        HapticService.shared.lightTap()

        // Check if the selected letters form a valid word
        let current = selectedString
        if words.contains(current) && !foundWords.contains(current) {
            foundWords.insert(current)
            score += 10
            flashColor = .aiSuccess
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }
            HapticService.shared.success()

            // Highlight found positions
            for pos in selectedPositions {
                highlightedPositions.insert(posKey(pos.0, pos.1))
            }
            selectedPositions.removeAll()

            if foundWords.count == words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    endGame()
                }
            }
        }
    }

    private func isValidNextPosition(row: Int, col: Int) -> Bool {
        guard let first = selectedPositions.first else { return true }

        if selectedPositions.count == 1 {
            // Second letter: must be adjacent horizontally, vertically, or diagonally
            let dr = abs(row - first.0)
            let dc = abs(col - first.1)
            return dr <= 1 && dc <= 1 && (dr + dc) > 0
        }

        // Determine direction from existing selections
        let second = selectedPositions[1]
        let dRow = second.0 - first.0
        let dCol = second.1 - first.1

        let last = selectedPositions.last!
        let expectedRow = last.0 + dRow
        let expectedCol = last.1 + dCol

        return row == expectedRow && col == expectedCol
    }

    private func endGame() {
        timer?.invalidate()
        let xp = score * 2
        user.addXP(xp)
        user.todayXP += xp
        if score > (user.gameHighScores["wordSearch"] ?? 0) {
            user.gameHighScores["wordSearch"] = score
        }
        user.gamesPlayed += 1
        isGameOver = true
    }
}
