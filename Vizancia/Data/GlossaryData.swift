import Foundation

struct GlossaryEntry: Identifiable {
    let id: String
    let term: String
    let definition: String
    let category: String

    init(_ term: String, definition: String, category: String = "General") {
        self.id = term.lowercased().replacingOccurrences(of: " ", with: "_")
        self.term = term
        self.definition = definition
        self.category = category
    }
}

struct GlossaryData {
    static let categories = [
        "All", "Core Concepts", "Machine Learning", "Generative AI",
        "Ethics & Safety", "Tools & Models", "History", "Technical"
    ]

    static let entries: [GlossaryEntry] = [
        // Core Concepts
        GlossaryEntry("Artificial Intelligence", definition: "Technology that lets computers do things that normally require human thinking, like understanding language, recognizing images, or making decisions.", category: "Core Concepts"),
        GlossaryEntry("Algorithm", definition: "A set of step-by-step instructions that tells a computer how to solve a problem or complete a task.", category: "Core Concepts"),
        GlossaryEntry("Machine Learning", definition: "A type of AI where computers learn patterns from data instead of being told exactly what to do.", category: "Core Concepts"),
        GlossaryEntry("Deep Learning", definition: "A powerful kind of machine learning that uses neural networks with many layers to learn very complex patterns.", category: "Core Concepts"),
        GlossaryEntry("Neural Network", definition: "A computer system loosely inspired by the human brain, made up of connected nodes that process information in layers.", category: "Core Concepts"),
        GlossaryEntry("Model", definition: "The result of training an AI system — it's the 'brain' that has learned patterns and can make predictions.", category: "Core Concepts"),
        GlossaryEntry("Dataset", definition: "A collection of information (text, images, numbers, etc.) used to train an AI model.", category: "Core Concepts"),
        GlossaryEntry("Training", definition: "The process of feeding data to an AI so it can learn patterns and improve at a task.", category: "Core Concepts"),
        GlossaryEntry("Inference", definition: "When a trained AI model makes a prediction or generates output based on new input.", category: "Core Concepts"),
        GlossaryEntry("Parameter", definition: "A number inside an AI model that gets adjusted during training. Large models have billions of parameters.", category: "Core Concepts"),
        GlossaryEntry("Narrow AI", definition: "AI designed for one specific task, like playing chess or filtering spam. Also called weak AI.", category: "Core Concepts"),
        GlossaryEntry("General AI", definition: "A theoretical AI that could understand and learn any task a human can — it doesn't exist yet.", category: "Core Concepts"),
        GlossaryEntry("Automation", definition: "Using technology to perform tasks without human help, like sorting emails or scheduling posts.", category: "Core Concepts"),

        // Machine Learning
        GlossaryEntry("Supervised Learning", definition: "Training an AI with labeled examples, like showing it photos tagged 'cat' or 'dog' so it learns to tell them apart.", category: "Machine Learning"),
        GlossaryEntry("Unsupervised Learning", definition: "Training where the AI finds patterns on its own without being told the right answers.", category: "Machine Learning"),
        GlossaryEntry("Reinforcement Learning", definition: "AI learns by trial and error, getting rewards for good actions and penalties for bad ones — like how a dog learns tricks.", category: "Machine Learning"),
        GlossaryEntry("Classification", definition: "An AI task where the model sorts things into categories, like 'spam' vs 'not spam'.", category: "Machine Learning"),
        GlossaryEntry("Regression", definition: "An AI task where the model predicts a number, like tomorrow's temperature or a house price.", category: "Machine Learning"),
        GlossaryEntry("Overfitting", definition: "When an AI memorizes the training data too well and does poorly on new data it hasn't seen before.", category: "Machine Learning"),
        GlossaryEntry("Feature", definition: "A measurable piece of information the AI uses to make decisions, like the color of a pixel or the length of a word.", category: "Machine Learning"),
        GlossaryEntry("Epoch", definition: "One full pass through the entire training dataset. Models often train for many epochs.", category: "Machine Learning"),
        GlossaryEntry("Accuracy", definition: "How often an AI gets the right answer, usually shown as a percentage.", category: "Machine Learning"),
        GlossaryEntry("Computer Vision", definition: "AI that can understand and analyze images and videos, used in face recognition and self-driving cars.", category: "Machine Learning"),
        GlossaryEntry("Natural Language Processing", definition: "AI that understands, interprets, and generates human language — the tech behind chatbots and translators.", category: "Machine Learning"),
        GlossaryEntry("Sentiment Analysis", definition: "AI that figures out the emotion or opinion in text, like whether a review is positive or negative.", category: "Machine Learning"),
        GlossaryEntry("Clustering", definition: "Grouping similar items together without labels — like sorting photos by faces without knowing who's who.", category: "Machine Learning"),
        GlossaryEntry("Transfer Learning", definition: "Taking a model trained on one task and reusing it for a different but related task, saving time and data.", category: "Machine Learning"),

        // Generative AI
        GlossaryEntry("Generative AI", definition: "AI that creates new content — text, images, music, or code — rather than just analyzing existing data.", category: "Generative AI"),
        GlossaryEntry("Large Language Model", definition: "A big AI model trained on huge amounts of text that can understand and generate human language. ChatGPT and Claude are examples.", category: "Generative AI"),
        GlossaryEntry("Transformer", definition: "The AI architecture behind modern language models. It uses 'attention' to understand how words relate to each other.", category: "Generative AI"),
        GlossaryEntry("Attention Mechanism", definition: "A technique that helps AI focus on the most relevant parts of the input, like how you focus on key words in a sentence.", category: "Generative AI"),
        GlossaryEntry("Token", definition: "A small piece of text (a word, part of a word, or punctuation) that an AI model processes. 'Chatbot' might be one or two tokens.", category: "Generative AI"),
        GlossaryEntry("Context Window", definition: "The amount of text an AI can 'see' at once. A bigger context window means it can handle longer conversations.", category: "Generative AI"),
        GlossaryEntry("Prompt", definition: "The input or question you give to an AI to get a response. Better prompts usually lead to better answers.", category: "Generative AI"),
        GlossaryEntry("Prompt Engineering", definition: "The skill of writing clear, specific prompts to get the best possible output from an AI.", category: "Generative AI"),
        GlossaryEntry("Hallucination", definition: "When an AI confidently generates information that sounds real but is actually made up or incorrect.", category: "Generative AI"),
        GlossaryEntry("Fine-tuning", definition: "Taking a pre-trained model and training it a bit more on specific data to make it better at a particular task.", category: "Generative AI"),
        GlossaryEntry("Temperature", definition: "A setting that controls how creative or random an AI's responses are. Low = predictable, high = creative.", category: "Generative AI"),
        GlossaryEntry("Diffusion Model", definition: "An AI that creates images by starting with random noise and gradually refining it into a clear picture.", category: "Generative AI"),
        GlossaryEntry("Multimodal AI", definition: "AI that can understand and work with multiple types of input — text, images, audio, and video.", category: "Generative AI"),
        GlossaryEntry("Chatbot", definition: "An AI program designed to have conversations with people, like a virtual assistant.", category: "Generative AI"),
        GlossaryEntry("Foundation Model", definition: "A large AI model trained on broad data that can be adapted for many different tasks.", category: "Generative AI"),

        // Ethics & Safety
        GlossaryEntry("AI Bias", definition: "When an AI makes unfair decisions because it learned patterns from biased data — like favoring one group over another.", category: "Ethics & Safety"),
        GlossaryEntry("AI Ethics", definition: "The study of right and wrong when building and using AI, including fairness, privacy, and transparency.", category: "Ethics & Safety"),
        GlossaryEntry("Deepfake", definition: "AI-generated fake videos or images that make it look like someone said or did something they didn't.", category: "Ethics & Safety"),
        GlossaryEntry("AI Alignment", definition: "Making sure an AI's goals and behavior match what humans actually want — a major research challenge.", category: "Ethics & Safety"),
        GlossaryEntry("Explainability", definition: "How well humans can understand why an AI made a particular decision. Also called interpretability.", category: "Ethics & Safety"),
        GlossaryEntry("Black Box", definition: "An AI system whose internal workings are hidden or too complex to understand — you can see the output but not the reasoning.", category: "Ethics & Safety"),
        GlossaryEntry("Data Privacy", definition: "Protecting personal information used to train or interact with AI systems.", category: "Ethics & Safety"),
        GlossaryEntry("Responsible AI", definition: "Building and using AI in ways that are fair, transparent, safe, and respect people's rights.", category: "Ethics & Safety"),
        GlossaryEntry("AI Safety", definition: "Research focused on making sure AI systems are reliable, controllable, and don't cause harm.", category: "Ethics & Safety"),
        GlossaryEntry("Guardrails", definition: "Rules and limits built into an AI to prevent it from generating harmful, biased, or inappropriate content.", category: "Ethics & Safety"),
        GlossaryEntry("Watermarking", definition: "Hidden markers added to AI-generated content so people can tell it was made by AI.", category: "Ethics & Safety"),

        // Tools & Models
        GlossaryEntry("ChatGPT", definition: "A popular AI chatbot made by OpenAI, powered by the GPT family of language models.", category: "Tools & Models"),
        GlossaryEntry("Claude", definition: "An AI assistant made by Anthropic, designed with a focus on being helpful, harmless, and honest.", category: "Tools & Models"),
        GlossaryEntry("GPT", definition: "Generative Pre-trained Transformer — OpenAI's family of language models (GPT-3, GPT-4, etc.).", category: "Tools & Models"),
        GlossaryEntry("Gemini", definition: "Google's family of AI models, designed to be multimodal — understanding text, images, and more.", category: "Tools & Models"),
        GlossaryEntry("LLaMA", definition: "Meta's open-source family of large language models that anyone can download and use.", category: "Tools & Models"),
        GlossaryEntry("Mistral", definition: "A French AI company known for efficient, high-quality open-source language models.", category: "Tools & Models"),
        GlossaryEntry("DALL-E", definition: "OpenAI's AI that generates images from text descriptions — 'draw a cat on the moon' and it creates it.", category: "Tools & Models"),
        GlossaryEntry("Midjourney", definition: "An AI art tool that creates stunning images from text prompts, popular with artists and designers.", category: "Tools & Models"),
        GlossaryEntry("Stable Diffusion", definition: "An open-source AI image generator that can run on personal computers.", category: "Tools & Models"),
        GlossaryEntry("GitHub Copilot", definition: "An AI coding assistant that suggests code as you type, trained on public code repositories.", category: "Tools & Models"),
        GlossaryEntry("Siri", definition: "Apple's AI voice assistant built into iPhones, iPads, and Macs.", category: "Tools & Models"),
        GlossaryEntry("AlphaGo", definition: "Google DeepMind's AI that beat the world champion at the board game Go in 2016.", category: "Tools & Models"),
        GlossaryEntry("AlphaFold", definition: "DeepMind's AI that predicts protein structures, a breakthrough for biology and medicine.", category: "Tools & Models"),

        // History
        GlossaryEntry("Turing Test", definition: "A test proposed by Alan Turing in 1950: can a machine fool a human into thinking it's a person?", category: "History"),
        GlossaryEntry("ELIZA", definition: "One of the first chatbots, created in 1966. It mimicked a therapist by reflecting questions back.", category: "History"),
        GlossaryEntry("Dartmouth Conference", definition: "The 1956 workshop where the term 'artificial intelligence' was first used — considered the birth of AI.", category: "History"),
        GlossaryEntry("AI Winter", definition: "Periods in the 1970s-90s when AI research slowed down due to lack of progress and funding.", category: "History"),
        GlossaryEntry("Deep Blue", definition: "IBM's chess computer that beat world champion Garry Kasparov in 1997.", category: "History"),
        GlossaryEntry("ImageNet", definition: "A massive dataset of labeled images created by Fei-Fei Li that sparked the modern AI revolution.", category: "History"),
        GlossaryEntry("Moore's Law", definition: "The observation that computing power roughly doubles every two years, helping AI grow faster.", category: "History"),
        GlossaryEntry("Attention Is All You Need", definition: "The famous 2017 Google paper that introduced the Transformer architecture, powering today's AI.", category: "History"),

        // Technical
        GlossaryEntry("API", definition: "Application Programming Interface — a way for apps to talk to AI services and use their abilities.", category: "Technical"),
        GlossaryEntry("GPU", definition: "Graphics Processing Unit — special chips that are great at the math needed to train AI models.", category: "Technical"),
        GlossaryEntry("Cloud Computing", definition: "Running AI on powerful remote servers instead of your own device — lets you use big models without big hardware.", category: "Technical"),
        GlossaryEntry("Edge AI", definition: "Running AI directly on your device (phone, camera, car) instead of sending data to the cloud.", category: "Technical"),
        GlossaryEntry("Open Source", definition: "Software or AI models whose code is freely available for anyone to use, modify, and share.", category: "Technical"),
        GlossaryEntry("Embedding", definition: "A way to represent words, images, or other data as lists of numbers so AI can understand similarities.", category: "Technical"),
        GlossaryEntry("Latency", definition: "The delay between sending a request to an AI and getting a response back.", category: "Technical"),
        GlossaryEntry("Benchmark", definition: "A standardized test used to compare how well different AI models perform on specific tasks.", category: "Technical"),
        GlossaryEntry("RLHF", definition: "Reinforcement Learning from Human Feedback — training AI to give better answers by learning from human ratings.", category: "Technical"),
        GlossaryEntry("RAG", definition: "Retrieval-Augmented Generation — AI that looks up real information before answering, reducing hallucinations.", category: "Technical"),
        GlossaryEntry("Synthetic Data", definition: "Fake data generated by AI to train other AI models, useful when real data is scarce or private.", category: "Technical"),
        GlossaryEntry("Tokenizer", definition: "The tool that breaks text into tokens (small pieces) before feeding it to an AI model.", category: "Technical"),
        GlossaryEntry("Weight", definition: "A number in a neural network that gets adjusted during training — similar to a parameter.", category: "Technical"),
        GlossaryEntry("Batch Size", definition: "How many examples an AI looks at before updating its knowledge during training.", category: "Technical"),
        GlossaryEntry("Loss Function", definition: "A math formula that measures how wrong an AI's predictions are — training tries to make this number smaller.", category: "Technical"),
        GlossaryEntry("Neural Network Layer", definition: "One level in a neural network where data gets processed. Deep networks have many layers stacked together.", category: "Technical"),
    ]
}
