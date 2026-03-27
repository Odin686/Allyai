import Foundation

struct FunFacts {
    static func random() -> String {
        let index = Int.random(in: 0..<all.count)
        return all[index]
    }

    static let all: [String] = [
        "The word 'robot' comes from the Czech word 'robota', meaning forced labor.",
        "The first AI program, the Logic Theorist, was created in 1956 and could prove mathematical theorems.",
        "GPT-3 was trained on about 45 terabytes of text data — roughly the size of the entire Library of Congress.",
        "AlphaFold predicted the 3D structure of over 200 million proteins, a task that took scientists decades to do manually.",
        "The term 'artificial intelligence' was coined by John McCarthy in 1956 at Dartmouth College.",
        "Deep Blue, the chess AI that beat Garry Kasparov, could evaluate 200 million positions per second.",
        "Your smartphone's face recognition uses a neural network with millions of parameters.",
        "AI can now detect certain cancers in medical scans more accurately than some radiologists.",
        "The Transformer architecture behind modern AI was invented at Google in 2017 — in a paper called 'Attention Is All You Need'.",
        "Anthropic, the company behind Claude, was founded by former OpenAI researchers focused on AI safety.",
        "Meta's LLaMA models are open-source, meaning anyone can download and run them locally.",
        "AI image generators like DALL-E and Midjourney learn from billions of image-text pairs.",
        "The AI in your email's spam filter is one of the oldest and most successful AI applications.",
        "AlphaGo's move 37 in its match against Lee Sedol was so creative that experts called it 'beautiful'.",
        "It takes roughly 1,720 MWh to train a large AI model — enough to power 160 US homes for a year.",
        "The first chatbot, ELIZA, was created in 1966 and could simulate a therapist's conversation.",
        "Neural networks are loosely inspired by how neurons connect in your brain.",
        "AI can now generate music, but it still can't truly understand why a song makes you feel a certain way.",
        "Over 80% of Fortune 500 companies now use some form of AI in their operations.",
        "The EU AI Act is the world's first comprehensive AI regulation law, passed in 2024.",
        "Reinforcement learning — how AI learns from trial and error — is inspired by how dogs learn tricks.",
        "A single Google search uses about 0.3 Wh of energy. Training GPT-4 used an estimated 50 GWh.",
        "Fei-Fei Li created ImageNet, a dataset of 14 million labeled images that revolutionized computer vision.",
        "AI hallucinations happen because language models predict the most likely next word, not the most true one.",
        "Geoffrey Hinton, the 'godfather of AI', left Google in 2023 to speak freely about AI risks.",
        "Stable Diffusion was one of the first powerful AI image generators released as open source.",
        "The Turing Test, proposed in 1950, asks whether a machine can fool a human into thinking it's human too.",
        "AI assistants process your voice by converting sound waves into text, understanding meaning, then generating a response.",
        "Japan is using AI robots to care for its aging population in nursing homes.",
        "The average smartphone now has a dedicated AI chip for tasks like photo enhancement and voice recognition.",
    ]
}
