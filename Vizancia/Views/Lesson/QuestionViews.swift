import SwiftUI

// MARK: - Multiple Choice
struct MultipleChoiceView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question.questionText)
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: hasAnswered && option == question.correctAnswer,
                        isWrong: hasAnswered && selectedAnswer == option && option != question.correctAnswer,
                        disabled: hasAnswered
                    ) {
                        selectedAnswer = option
                        HapticService.shared.lightTap()
                    }
                }
            }
        }
    }
}

// MARK: - True/False
struct TrueFalseView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text(question.questionText)
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 16) {
                ForEach(["True", "False"], id: \.self) { option in
                    Button {
                        selectedAnswer = option
                        HapticService.shared.lightTap()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: option == "True" ? "checkmark.circle" : "xmark.circle")
                                .font(.system(size: 36))
                            Text(option)
                                .font(.aiHeadline())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tfColor(option))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(tfBorderColor(option), lineWidth: selectedAnswer == option ? 3 : 1)
                        )
                    }
                    .disabled(hasAnswered)
                    .foregroundColor(tfTextColor(option))
                }
            }
        }
    }
    
    private func tfColor(_ option: String) -> Color {
        if hasAnswered && option == question.correctAnswer { return Color.aiSuccess.opacity(0.12) }
        if hasAnswered && selectedAnswer == option && option != question.correctAnswer { return Color.aiError.opacity(0.12) }
        if selectedAnswer == option { return Color.aiPrimary.opacity(0.12) }
        return Color.aiCard
    }
    
    private func tfBorderColor(_ option: String) -> Color {
        if hasAnswered && option == question.correctAnswer { return .aiSuccess }
        if hasAnswered && selectedAnswer == option && option != question.correctAnswer { return .aiError }
        if selectedAnswer == option { return .aiPrimary }
        return Color.aiTextSecondary.opacity(0.15)
    }
    
    private func tfTextColor(_ option: String) -> Color {
        if hasAnswered && option == question.correctAnswer { return .aiSuccess }
        if hasAnswered && selectedAnswer == option && option != question.correctAnswer { return .aiError }
        if selectedAnswer == option { return .aiPrimary }
        return .aiTextPrimary
    }
}

// MARK: - Fill in the Blank
struct FillInBlankView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(question.questionText)
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: hasAnswered && option == question.correctAnswer,
                        isWrong: hasAnswered && selectedAnswer == option && option != question.correctAnswer,
                        disabled: hasAnswered
                    ) {
                        selectedAnswer = option
                        HapticService.shared.lightTap()
                    }
                }
            }
        }
    }
}

// MARK: - Scenario Judgment
struct ScenarioJudgmentView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.aiWarning)
                    Text("Scenario")
                        .font(.aiCaption())
                        .foregroundColor(.aiWarning)
                    Spacer()
                }
                
                Text(question.questionText)
                    .font(.aiBody())
                    .foregroundColor(.aiTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.aiWarning.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.aiWarning.opacity(0.2), lineWidth: 1)
                    )
            )
            
            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: hasAnswered && option == question.correctAnswer,
                        isWrong: hasAnswered && selectedAnswer == option && option != question.correctAnswer,
                        disabled: hasAnswered
                    ) {
                        selectedAnswer = option
                        HapticService.shared.lightTap()
                    }
                }
            }
        }
    }
}

// MARK: - Match Pairs
struct MatchPairsView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    @State private var selectedTerm: String?
    @State private var matchedPairs: [String: String] = [:]
    @State private var shuffledDefinitions: [String] = []
    
    private var pairs: [MatchPair] { question.matchPairs }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question.questionText)
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 12) {
                ForEach(pairs, id: \.term) { pair in
                    HStack(spacing: 10) {
                        // Term button
                        Button {
                            if !hasAnswered && matchedPairs[pair.term] == nil {
                                selectedTerm = pair.term
                                HapticService.shared.lightTap()
                            }
                        } label: {
                            Text(pair.term)
                                .font(.aiCaption())
                                .foregroundColor(termColor(pair.term))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(termBg(pair.term))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(termBorder(pair.term), lineWidth: selectedTerm == pair.term ? 2 : 1)
                                        )
                                )
                        }
                        .disabled(hasAnswered || matchedPairs[pair.term] != nil)
                        
                        Image(systemName: matchedPairs[pair.term] != nil ? "link" : "arrow.right")
                            .font(.caption)
                            .foregroundColor(.aiTextSecondary)
                        
                        // Definition (find corresponding shuffled)
                        let defIndex = pairs.firstIndex(where: { $0.term == pair.term }) ?? 0
                        let definition = defIndex < shuffledDefinitions.count ? shuffledDefinitions[defIndex] : pair.definition
                        
                        Button {
                            if !hasAnswered, let term = selectedTerm {
                                matchedPairs[term] = definition
                                selectedTerm = nil
                                HapticService.shared.lightTap()
                                if matchedPairs.count == pairs.count {
                                    checkMatches()
                                }
                            }
                        } label: {
                            Text(definition)
                                .font(.aiCaption())
                                .foregroundColor(defColor(definition))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(defBg(definition))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                                        )
                                )
                        }
                        .disabled(hasAnswered || selectedTerm == nil || matchedPairs.values.contains(definition))
                    }
                }
            }
            
            if !matchedPairs.isEmpty && !hasAnswered {
                Button("Reset") {
                    matchedPairs = [:]
                    selectedTerm = nil
                    selectedAnswer = ""
                }
                .font(.aiCaption())
                .foregroundColor(.aiError)
            }
        }
        .onAppear {
            shuffledDefinitions = pairs.map(\.definition).shuffled()
        }
    }
    
    private func checkMatches() {
        let allCorrect = pairs.allSatisfy { pair in
            matchedPairs[pair.term] == pair.definition
        }
        selectedAnswer = allCorrect ? "matched" : "wrong"
    }
    
    private func termColor(_ term: String) -> Color {
        if selectedTerm == term { return .aiPrimary }
        if matchedPairs[term] != nil { return .aiSuccess }
        return .aiTextPrimary
    }
    
    private func termBg(_ term: String) -> Color {
        if selectedTerm == term { return Color.aiPrimary.opacity(0.1) }
        if matchedPairs[term] != nil { return Color.aiSuccess.opacity(0.08) }
        return Color.aiCard
    }
    
    private func termBorder(_ term: String) -> Color {
        if selectedTerm == term { return .aiPrimary }
        if matchedPairs[term] != nil { return .aiSuccess.opacity(0.3) }
        return Color.aiTextSecondary.opacity(0.15)
    }
    
    private func defColor(_ def: String) -> Color {
        if matchedPairs.values.contains(def) { return .aiSuccess }
        return .aiTextPrimary
    }
    
    private func defBg(_ def: String) -> Color {
        if matchedPairs.values.contains(def) { return Color.aiSuccess.opacity(0.08) }
        return Color.aiCard
    }
}

// MARK: - Sort Order
struct SortOrderView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let hasAnswered: Bool
    let isCorrect: Bool
    
    @State private var items: [String] = []
    
    private var correctOrder: [String] { question.correctAnswers }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question.questionText)
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Tap items in the correct order")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
            
            VStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    HStack {
                        Text("\(index + 1)")
                            .font(.aiRounded(.caption, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(Color.aiPrimary))
                        
                        Text(item)
                            .font(.aiBody())
                            .foregroundColor(.aiTextPrimary)
                        
                        Spacer()
                        
                        if hasAnswered {
                            let isInCorrectPosition = index < correctOrder.count && correctOrder[index] == item
                            Image(systemName: isInCorrectPosition ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isInCorrectPosition ? .aiSuccess : .aiError)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.aiCard)
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
                    )
                }
            }
            
            if !hasAnswered {
                VStack(spacing: 8) {
                    Text("Available items:")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                    
                    let remaining = (question.options ?? []).filter { !items.contains($0) }
                    ForEach(remaining, id: \.self) { option in
                        Button {
                            items.append(option)
                            HapticService.shared.lightTap()
                            if items.count == question.options.count {
                                selectedAnswer = items.joined(separator: "||")
                            }
                        } label: {
                            Text(option)
                                .font(.aiBody())
                                .foregroundColor(.aiPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.aiPrimary.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.aiPrimary.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    
                    if !items.isEmpty {
                        Button("Reset Order") {
                            items = []
                            selectedAnswer = ""
                        }
                        .font(.aiCaption())
                        .foregroundColor(.aiError)
                    }
                }
            }
        }
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.aiBody())
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.aiSuccess)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.aiError)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .disabled(disabled)
    }
    
    private var textColor: Color {
        if isCorrect { return .aiSuccess }
        if isWrong { return .aiError }
        if isSelected { return .aiPrimary }
        return .aiTextPrimary
    }
    
    private var bgColor: Color {
        if isCorrect { return Color.aiSuccess.opacity(0.1) }
        if isWrong { return Color.aiError.opacity(0.1) }
        if isSelected { return Color.aiPrimary.opacity(0.08) }
        return Color.aiCard
    }
    
    private var borderColor: Color {
        if isCorrect { return .aiSuccess }
        if isWrong { return .aiError }
        if isSelected { return .aiPrimary }
        return Color.aiTextSecondary.opacity(0.15)
    }
}
