import SwiftUI

struct GlossaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var expandedTermId: String?

    private var filteredEntries: [GlossaryEntry] {
        var results = GlossaryData.entries
        if selectedCategory != "All" {
            results = results.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.term.lowercased().contains(query) ||
                $0.definition.lowercased().contains(query)
            }
        }
        return results
    }

    private var groupedEntries: [(letter: String, entries: [GlossaryEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            String(entry.term.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }.map { (letter: $0.key, entries: $0.value) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(GlossaryData.categories, id: \.self) { category in
                            chipButton(category)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                // Term count
                HStack {
                    Text("\(filteredEntries.count) terms")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 6)

                // Term list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedEntries, id: \.letter) { group in
                            Section {
                                ForEach(group.entries) { entry in
                                    termRow(entry)
                                }
                            } header: {
                                sectionHeader(group.letter)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("AI Glossary")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search terms...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Components

    private func chipButton(_ category: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(category)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.aiPrimary : Color.aiCard)
                )
                .foregroundColor(isSelected ? .white : .aiTextSecondary)
        }
    }

    private func sectionHeader(_ letter: String) -> some View {
        HStack {
            Text(letter)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.aiBackground)
    }

    private func termRow(_ entry: GlossaryEntry) -> some View {
        let isExpanded = expandedTermId == entry.id
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedTermId = isExpanded ? nil : entry.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(entry.term)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.aiTextSecondary.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 12)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.definition)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(entry.category)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.aiPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.aiPrimary.opacity(0.1))
                            )
                    }
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal)
            .background(Color.aiCard)
        }
        .buttonStyle(.plain)
    }
}
