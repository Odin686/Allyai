import Foundation

struct CategoryContent1 {
    static let aiBasics = CategoryData(
        id: "ai_basics", name: "AI Basics", icon: "brain", colorName: "aiBlue",
        description: "What is AI, ML, deep learning, neural networks, training data",
        lessons: [lesson1, lesson2, lesson3, lesson4, lesson5, lesson6], order: 0,
        unlockRequirement: .none
    )
    
    static let lesson1 = LessonData(id: "ab_l1", title: "What is Artificial Intelligence?", description: "Learn the fundamentals of AI", categoryId: "ai_basics", questions: [
        Question(id: "ab1_q1", type: .multipleChoice, questionText: "What does 'AI' stand for?", options: ["Artificial Intelligence", "Automated Integration", "Advanced Interface", "Analytical Iteration"], correctAnswer: "Artificial Intelligence", explanation: "AI stands for Artificial Intelligence — the simulation of human intelligence by computer systems."),
        Question(id: "ab1_q2", type: .trueFalse, questionText: "AI can truly think and feel emotions just like humans do.", options: ["True", "False"], correctAnswer: "False", explanation: "Current AI systems process data and recognize patterns but do not have consciousness or genuine emotions."),
        Question(id: "ab1_q3", type: .multipleChoice, questionText: "Which of these is an example of AI in daily life?", options: ["A voice assistant like Siri", "A calculator app", "A flashlight app", "A paper notebook"], correctAnswer: "A voice assistant like Siri", explanation: "Voice assistants use natural language processing and machine learning to understand and respond to your voice."),
        Question(id: "ab1_q4", type: .fillInBlank, questionText: "The goal of AI is to create machines that can perform tasks that typically require __________ intelligence.", options: ["human", "animal", "plant", "digital"], correctAnswer: "human", explanation: "AI aims to replicate cognitive functions typically associated with human minds, such as learning and problem-solving."),
        Question(id: "ab1_q5", type: .multipleChoice, questionText: "Which field does AI NOT typically belong to?", options: ["Geology", "Computer Science", "Mathematics", "Linguistics"], correctAnswer: "Geology", explanation: "AI is an interdisciplinary field rooted in computer science, mathematics, linguistics, and philosophy."),
        Question(id: "ab1_q6", type: .trueFalse, questionText: "AI is a single technology.", options: ["True", "False"], correctAnswer: "False", explanation: "AI is an umbrella term covering many technologies including machine learning, NLP, computer vision, and robotics.")
    ], order: 0, difficulty: .beginner)
    
    static let lesson2 = LessonData(id: "ab_l2", title: "Machine Learning Fundamentals", description: "How machines learn from data", categoryId: "ai_basics", questions: [
        Question(id: "ab2_q1", type: .multipleChoice, questionText: "What is Machine Learning?", options: ["A subset of AI where systems learn from data", "A type of robot", "A programming language", "A hardware component"], correctAnswer: "A subset of AI where systems learn from data", explanation: "Machine Learning is a branch of AI focused on building systems that learn from and make decisions based on data."),
        Question(id: "ab2_q2", type: .fillInBlank, questionText: "In machine learning, the data used to teach a model is called __________ data.", options: ["training", "testing", "random", "output"], correctAnswer: "training", explanation: "Training data is the dataset used to teach a machine learning model to recognize patterns."),
        Question(id: "ab2_q3", type: .trueFalse, questionText: "Machine Learning requires explicit programming for every possible scenario.", options: ["True", "False"], correctAnswer: "False", explanation: "ML learns patterns from data rather than being explicitly programmed for each scenario."),
        Question(id: "ab2_q4", type: .multipleChoice, questionText: "What does a machine learning model produce after training?", options: ["Predictions or classifications", "Physical objects", "Electricity", "Internet connections"], correctAnswer: "Predictions or classifications", explanation: "After training, ML models can make predictions or classify new, unseen data based on learned patterns."),
        Question(id: "ab2_q5", type: .matchPairs, questionText: "Match each ML concept with its description:", matchPairs: [
            MatchPair(term: "Algorithm", definition: "Set of rules for learning"),
            MatchPair(term: "Dataset", definition: "Collection of data for training"),
            MatchPair(term: "Model", definition: "Learned representation of patterns"),
            MatchPair(term: "Feature", definition: "Individual measurable property")
        ], explanation: "These are the core building blocks of any machine learning system."),
        Question(id: "ab2_q6", type: .multipleChoice, questionText: "Which is the best analogy for how ML works?", options: ["Learning from many examples, like a student studying", "Following a recipe step by step", "Randomly guessing until correct", "Copying answers from another computer"], correctAnswer: "Learning from many examples, like a student studying", explanation: "ML models learn by processing many examples, gradually improving their understanding, much like a student.")
    ], order: 1, difficulty: .beginner)
    
    static let lesson3 = LessonData(id: "ab_l3", title: "Neural Networks", description: "Computing systems inspired by the brain", categoryId: "ai_basics", questions: [
        Question(id: "ab3_q1", type: .multipleChoice, questionText: "Neural networks are inspired by:", options: ["The human brain", "The solar system", "Plant roots", "River networks"], correctAnswer: "The human brain", explanation: "Artificial neural networks are loosely modeled on biological neural networks in the human brain."),
        Question(id: "ab3_q2", type: .trueFalse, questionText: "A neural network is made up of layers of interconnected nodes.", options: ["True", "False"], correctAnswer: "True", explanation: "Neural networks consist of an input layer, hidden layers, and an output layer of interconnected nodes (neurons)."),
        Question(id: "ab3_q3", type: .sortOrder, questionText: "Put these neural network layers in order from input to output:", options: ["Output Layer", "Hidden Layer 1", "Input Layer", "Hidden Layer 2"], correctAnswers: ["Input Layer", "Hidden Layer 1", "Hidden Layer 2", "Output Layer"], explanation: "Data flows from the input layer through hidden layers to produce results at the output layer."),
        Question(id: "ab3_q4", type: .multipleChoice, questionText: "What do 'weights' in a neural network represent?", options: ["The strength of connections between neurons", "The physical mass of the computer", "The number of layers", "The speed of processing"], correctAnswer: "The strength of connections between neurons", explanation: "Weights determine how much influence one neuron has on another, and they're adjusted during training."),
        Question(id: "ab3_q5", type: .fillInBlank, questionText: "A neural network with many hidden layers is called a __________ neural network.", options: ["deep", "wide", "flat", "simple"], correctAnswer: "deep", explanation: "Deep neural networks have multiple hidden layers, which is where the term 'deep learning' comes from."),
        Question(id: "ab3_q6", type: .multipleChoice, questionText: "What is the process of adjusting weights in a neural network called?", options: ["Training", "Installing", "Compiling", "Downloading"], correctAnswer: "Training", explanation: "Training is the process of feeding data through the network and adjusting weights to improve accuracy.")
    ], order: 2, difficulty: .beginner)
    
    static let lesson4 = LessonData(id: "ab_l4", title: "Deep Learning", description: "The power of deep neural networks", categoryId: "ai_basics", questions: [
        Question(id: "ab4_q1", type: .multipleChoice, questionText: "Deep Learning is:", options: ["A subset of Machine Learning using deep neural networks", "A meditation technique", "A type of database", "A search engine algorithm"], correctAnswer: "A subset of Machine Learning using deep neural networks", explanation: "Deep Learning uses neural networks with many layers to learn complex patterns from large amounts of data."),
        Question(id: "ab4_q2", type: .trueFalse, questionText: "Deep Learning typically requires large amounts of data to work well.", options: ["True", "False"], correctAnswer: "True", explanation: "Deep learning models generally need massive datasets to learn the complex patterns they're designed to capture."),
        Question(id: "ab4_q3", type: .matchPairs, questionText: "Match each deep learning application to its domain:", matchPairs: [
            MatchPair(term: "Image Recognition", definition: "Identifying objects in photos"),
            MatchPair(term: "Speech Recognition", definition: "Converting voice to text"),
            MatchPair(term: "NLP", definition: "Understanding human language"),
            MatchPair(term: "Autonomous Driving", definition: "Self-driving vehicles")
        ], explanation: "Deep learning powers many cutting-edge applications across multiple domains."),
        Question(id: "ab4_q4", type: .multipleChoice, questionText: "What hardware advancement helped enable modern deep learning?", options: ["GPUs (Graphics Processing Units)", "Floppy disk drives", "CRT monitors", "Dial-up modems"], correctAnswer: "GPUs (Graphics Processing Units)", explanation: "GPUs can perform many calculations in parallel, making them ideal for training deep neural networks."),
        Question(id: "ab4_q5", type: .fillInBlank, questionText: "Deep learning excels at finding __________ in data that are too complex for humans to program manually.", options: ["patterns", "errors", "files", "emails"], correctAnswer: "patterns", explanation: "Deep learning automatically discovers intricate patterns and representations in raw data."),
        Question(id: "ab4_q6", type: .scenarioJudgment, questionText: "A company wants to automatically detect defective products on an assembly line using cameras. Should they consider deep learning?", options: ["Yes, this is ideal", "No, not suitable", "It depends"], correctAnswer: "Yes, this is ideal", explanation: "Computer vision powered by deep learning excels at visual inspection tasks and is widely used in manufacturing.")
    ], order: 3, difficulty: .intermediate)
    
    static let lesson5 = LessonData(id: "ab_l5", title: "Training Data & Bias", description: "Why data quality matters", categoryId: "ai_basics", questions: [
        Question(id: "ab5_q1", type: .multipleChoice, questionText: "Why is training data important for AI?", options: ["It determines what the model learns", "It makes computers faster", "It reduces electricity usage", "It improves internet speed"], correctAnswer: "It determines what the model learns", explanation: "The quality and content of training data directly shapes what an AI model can and cannot do."),
        Question(id: "ab5_q2", type: .trueFalse, questionText: "If training data contains biases, the AI model will likely also be biased.", options: ["True", "False"], correctAnswer: "True", explanation: "AI models learn from their training data — if the data is biased, the model will reproduce those biases."),
        Question(id: "ab5_q3", type: .scenarioJudgment, questionText: "A facial recognition system was trained mostly on photos of light-skinned people. It performs poorly on darker-skinned individuals. Is this a data problem?", options: ["Yes, clearly", "No, it's fine", "It depends"], correctAnswer: "Yes, clearly", explanation: "This is a classic example of training data bias — the dataset wasn't representative of all skin tones."),
        Question(id: "ab5_q4", type: .multipleChoice, questionText: "What is 'labeled data'?", options: ["Data with correct answers attached", "Data stored in folders", "Data from labels on products", "Data that has been printed"], correctAnswer: "Data with correct answers attached", explanation: "Labeled data includes both the input and the correct output, used in supervised learning."),
        Question(id: "ab5_q5", type: .fillInBlank, questionText: "The phrase 'garbage in, garbage out' means that poor quality __________ leads to poor AI results.", options: ["data", "code", "hardware", "electricity"], correctAnswer: "data", explanation: "No matter how good your model is, it can only be as good as the data it's trained on."),
        Question(id: "ab5_q6", type: .multipleChoice, questionText: "Which is NOT a way to reduce bias in training data?", options: ["Using less data overall", "Ensuring diverse representation", "Auditing data for imbalances", "Collecting data from varied sources"], correctAnswer: "Using less data overall", explanation: "Simply using less data doesn't fix bias — you need diverse, representative, and carefully curated datasets.")
    ], order: 4, difficulty: .intermediate)
    
    static let lesson6 = LessonData(id: "ab_l6", title: "Types of AI: Narrow vs General", description: "Understanding AI's current limits", categoryId: "ai_basics", questions: [
        Question(id: "ab6_q1", type: .multipleChoice, questionText: "What type of AI exists today?", options: ["Narrow AI (ANI)", "General AI (AGI)", "Super AI (ASI)", "Conscious AI"], correctAnswer: "Narrow AI (ANI)", explanation: "All current AI systems are Narrow AI — designed for specific tasks. General AI that can do anything a human can does not yet exist."),
        Question(id: "ab6_q2", type: .trueFalse, questionText: "A chess-playing AI can also write poetry equally well.", options: ["True", "False"], correctAnswer: "False", explanation: "Narrow AI systems are specialized. A chess AI knows nothing about poetry — it can only play chess."),
        Question(id: "ab6_q3", type: .matchPairs, questionText: "Match each AI type to its description:", matchPairs: [
            MatchPair(term: "Narrow AI", definition: "Excels at one specific task"),
            MatchPair(term: "General AI", definition: "Hypothetical human-level intelligence"),
            MatchPair(term: "Super AI", definition: "Theoretical beyond-human intelligence"),
            MatchPair(term: "Reactive AI", definition: "No memory, responds to current input")
        ], explanation: "Understanding these categories helps set realistic expectations for what AI can and cannot do."),
        Question(id: "ab6_q4", type: .multipleChoice, questionText: "Which is an example of Narrow AI?", options: ["Spam email filter", "A robot that can do any human job", "A sentient computer", "A conscious machine"], correctAnswer: "Spam email filter", explanation: "A spam filter is a perfect example of Narrow AI — it does one specific task (classify emails) very well."),
        Question(id: "ab6_q5", type: .scenarioJudgment, questionText: "Someone claims their product uses 'AGI' (Artificial General Intelligence). Should you be skeptical?", options: ["Yes, be skeptical", "No, trust them", "It depends"], correctAnswer: "Yes, be skeptical", explanation: "AGI does not exist yet. Any product claiming to use AGI is likely using marketing hype rather than accurate terminology."),
        Question(id: "ab6_q6", type: .fillInBlank, questionText: "The AI that beat the world champion in Go is an example of __________ AI.", options: ["narrow", "general", "super", "conscious"], correctAnswer: "narrow", explanation: "AlphaGo is narrow AI — it mastered Go but cannot do other tasks like drive a car or write code.")
    ], order: 5, difficulty: .intermediate)
}
