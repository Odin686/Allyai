import Foundation

struct CategoryContent2 {
    static let howAILearns = CategoryData(
        id: "how_ai_learns", name: "How AI Learns", icon: "graduationcap", colorName: "aiPurple",
        description: "Supervised/unsupervised learning, reinforcement learning, overfitting",
        lessons: [lesson1, lesson2, lesson3, lesson4, lesson5, lesson6], order: 1,
        unlockRequirement: .completeCategory("ai_basics")
    )
    
    static let lesson1 = LessonData(id: "hal_l1", title: "Supervised Learning", description: "Learning from labeled examples", categoryId: "how_ai_learns", questions: [
        Question(id: "hal1_q1", type: .multipleChoice, questionText: "In supervised learning, the model learns from:", options: ["Labeled data with known answers", "Unlabeled random data", "Its own imagination", "The internet freely"], correctAnswer: "Labeled data with known answers", explanation: "Supervised learning uses datasets where each example has a correct answer (label) so the model can learn the mapping."),
        Question(id: "hal1_q2", type: .trueFalse, questionText: "Email spam detection is an example of supervised learning.", options: ["True", "False"], correctAnswer: "True", explanation: "Spam filters are trained on emails labeled as 'spam' or 'not spam' — a classic supervised learning task."),
        Question(id: "hal1_q3", type: .matchPairs, questionText: "Match supervised learning tasks:", matchPairs: [
            MatchPair(term: "Classification", definition: "Sorting into categories"),
            MatchPair(term: "Regression", definition: "Predicting a number"),
            MatchPair(term: "Label", definition: "The correct answer tag"),
            MatchPair(term: "Feature", definition: "Input variable for prediction")
        ], explanation: "Classification and regression are the two main types of supervised learning."),
        Question(id: "hal1_q4", type: .fillInBlank, questionText: "In supervised learning, a __________ is the correct answer provided for each training example.", options: ["label", "feature", "node", "layer"], correctAnswer: "label", explanation: "Labels are the ground truth answers that the model learns to predict."),
        Question(id: "hal1_q5", type: .multipleChoice, questionText: "Which is a classification task?", options: ["Detecting if a photo shows a cat or dog", "Predicting tomorrow's temperature", "Grouping similar documents", "Compressing a video file"], correctAnswer: "Detecting if a photo shows a cat or dog", explanation: "Classification assigns inputs to discrete categories — cat vs dog is a binary classification problem."),
        Question(id: "hal1_q6", type: .scenarioJudgment, questionText: "You want to predict house prices based on size, location, and age. Is supervised learning appropriate?", options: ["Yes, this is ideal", "No, not suitable", "It depends"], correctAnswer: "Yes, this is ideal", explanation: "Predicting house prices is a regression task, which is a core supervised learning application.")
    ], order: 0, difficulty: .beginner)
    
    static let lesson2 = LessonData(id: "hal_l2", title: "Unsupervised Learning", description: "Finding hidden patterns", categoryId: "how_ai_learns", questions: [
        Question(id: "hal2_q1", type: .multipleChoice, questionText: "Unsupervised learning works with:", options: ["Unlabeled data", "Perfectly labeled data", "No data at all", "Only images"], correctAnswer: "Unlabeled data", explanation: "Unsupervised learning finds patterns in data without pre-existing labels or correct answers."),
        Question(id: "hal2_q2", type: .trueFalse, questionText: "Clustering is a type of unsupervised learning.", options: ["True", "False"], correctAnswer: "True", explanation: "Clustering groups similar data points together without knowing the categories in advance."),
        Question(id: "hal2_q3", type: .multipleChoice, questionText: "Which is an example of unsupervised learning?", options: ["Grouping customers by shopping behavior", "Translating English to French", "Detecting spam emails", "Grading exam papers"], correctAnswer: "Grouping customers by shopping behavior", explanation: "Customer segmentation discovers natural groupings without predefined categories — classic unsupervised learning."),
        Question(id: "hal2_q4", type: .fillInBlank, questionText: "__________ is a technique that groups similar data points together without labels.", options: ["Clustering", "Labeling", "Compiling", "Encrypting"], correctAnswer: "Clustering", explanation: "Clustering algorithms like K-means group data points based on similarity."),
        Question(id: "hal2_q5", type: .matchPairs, questionText: "Match unsupervised techniques:", matchPairs: [
            MatchPair(term: "Clustering", definition: "Group similar items together"),
            MatchPair(term: "Anomaly Detection", definition: "Find unusual data points"),
            MatchPair(term: "Dimensionality Reduction", definition: "Simplify complex data"),
            MatchPair(term: "Association", definition: "Find rules between items")
        ], explanation: "These are the main categories of unsupervised learning techniques."),
        Question(id: "hal2_q6", type: .multipleChoice, questionText: "Why is unsupervised learning useful?", options: ["It can discover patterns humans haven't noticed", "It's always more accurate than supervised learning", "It never makes mistakes", "It doesn't need any data"], correctAnswer: "It can discover patterns humans haven't noticed", explanation: "Unsupervised learning can reveal hidden structures and relationships in data that humans might miss.")
    ], order: 1, difficulty: .beginner)
    
    static let lesson3 = LessonData(id: "hal_l3", title: "Reinforcement Learning", description: "Learning through trial and error", categoryId: "how_ai_learns", questions: [
        Question(id: "hal3_q1", type: .multipleChoice, questionText: "Reinforcement learning is best described as:", options: ["Learning by trying actions and receiving rewards", "Learning from labeled examples", "Learning by grouping similar data", "Learning by reading textbooks"], correctAnswer: "Learning by trying actions and receiving rewards", explanation: "RL agents learn by taking actions in an environment and receiving reward or penalty signals."),
        Question(id: "hal3_q2", type: .trueFalse, questionText: "AlphaGo, which beat the world Go champion, used reinforcement learning.", options: ["True", "False"], correctAnswer: "True", explanation: "AlphaGo used reinforcement learning to play millions of games against itself and improve."),
        Question(id: "hal3_q3", type: .fillInBlank, questionText: "In reinforcement learning, the AI receives a __________ signal to know if its action was good.", options: ["reward", "label", "cluster", "feature"], correctAnswer: "reward", explanation: "Reward signals tell the agent whether its actions lead to good or bad outcomes."),
        Question(id: "hal3_q4", type: .multipleChoice, questionText: "Which scenario best fits reinforcement learning?", options: ["Training a robot to walk", "Sorting emails into folders", "Grouping news articles by topic", "Converting speech to text"], correctAnswer: "Training a robot to walk", explanation: "A robot learning to walk through trial and error, getting rewards for balance, is a classic RL application."),
        Question(id: "hal3_q5", type: .matchPairs, questionText: "Match RL concepts:", matchPairs: [
            MatchPair(term: "Agent", definition: "The learner that takes actions"),
            MatchPair(term: "Environment", definition: "The world the agent acts in"),
            MatchPair(term: "Reward", definition: "Feedback signal for actions"),
            MatchPair(term: "Policy", definition: "Strategy for choosing actions")
        ], explanation: "These are the key components of any reinforcement learning system."),
        Question(id: "hal3_q6", type: .scenarioJudgment, questionText: "A game company wants AI to learn to play their new game without human demonstrations. Is RL a good choice?", options: ["Yes, this is ideal", "No, not suitable", "It depends"], correctAnswer: "Yes, this is ideal", explanation: "Reinforcement learning excels at learning game strategies through self-play without human examples.")
    ], order: 2, difficulty: .intermediate)
    
    static let lesson4 = LessonData(id: "hal_l4", title: "Overfitting & Underfitting", description: "When models learn too much or too little", categoryId: "how_ai_learns", questions: [
        Question(id: "hal4_q1", type: .multipleChoice, questionText: "Overfitting means a model:", options: ["Memorizes training data but fails on new data", "Learns perfectly and always works", "Doesn't learn anything", "Uses too much electricity"], correctAnswer: "Memorizes training data but fails on new data", explanation: "An overfit model has essentially memorized the training data but can't generalize to new, unseen data."),
        Question(id: "hal4_q2", type: .trueFalse, questionText: "A model that performs well on training data but poorly on test data is likely overfitting.", options: ["True", "False"], correctAnswer: "True", explanation: "This gap between training and test performance is the hallmark of overfitting."),
        Question(id: "hal4_q3", type: .fillInBlank, questionText: "__________ occurs when a model is too simple to capture the patterns in the data.", options: ["Underfitting", "Overfitting", "Clustering", "Labeling"], correctAnswer: "Underfitting", explanation: "Underfitting means the model hasn't learned enough from the data and performs poorly everywhere."),
        Question(id: "hal4_q4", type: .multipleChoice, questionText: "Which technique helps prevent overfitting?", options: ["Using a validation set", "Adding more layers indefinitely", "Training for as long as possible", "Using only one data point"], correctAnswer: "Using a validation set", explanation: "A validation set lets you monitor the model's performance on unseen data during training to detect overfitting."),
        Question(id: "hal4_q5", type: .sortOrder, questionText: "Order these from underfitting to overfitting:", options: ["Good fit model", "Memorizing all training data", "Too simple model", "Slightly complex model"], correctAnswers: ["Too simple model", "Good fit model", "Slightly complex model", "Memorizing all training data"], explanation: "The goal is to find the sweet spot between underfitting and overfitting."),
        Question(id: "hal4_q6", type: .multipleChoice, questionText: "What is the 'sweet spot' between underfitting and overfitting called?", options: ["Good generalization", "Perfect memory", "Data compression", "Feature extraction"], correctAnswer: "Good generalization", explanation: "A well-generalized model performs well on both training data and new, unseen data.")
    ], order: 3, difficulty: .intermediate)
    
    static let lesson5 = LessonData(id: "hal_l5", title: "Model Evaluation", description: "How to measure AI performance", categoryId: "how_ai_learns", questions: [
        Question(id: "hal5_q1", type: .multipleChoice, questionText: "Accuracy in ML means:", options: ["Percentage of correct predictions", "Speed of the model", "Size of the dataset", "Cost of computing"], correctAnswer: "Percentage of correct predictions", explanation: "Accuracy measures how often the model's predictions match the actual correct answers."),
        Question(id: "hal5_q2", type: .trueFalse, questionText: "High accuracy always means a model is good.", options: ["True", "False"], correctAnswer: "False", explanation: "In imbalanced datasets, a model could predict the majority class every time and have high accuracy but be useless."),
        Question(id: "hal5_q3", type: .matchPairs, questionText: "Match evaluation metrics:", matchPairs: [
            MatchPair(term: "Precision", definition: "Of predicted positives, how many are correct"),
            MatchPair(term: "Recall", definition: "Of actual positives, how many were found"),
            MatchPair(term: "F1 Score", definition: "Balance of precision and recall"),
            MatchPair(term: "Accuracy", definition: "Overall correct predictions percentage")
        ], explanation: "Different metrics capture different aspects of model performance."),
        Question(id: "hal5_q4", type: .fillInBlank, questionText: "A __________ set is data held back from training to evaluate the model's performance.", options: ["test", "training", "bias", "weight"], correctAnswer: "test", explanation: "The test set is never used during training, ensuring a fair evaluation of the model."),
        Question(id: "hal5_q5", type: .scenarioJudgment, questionText: "A cancer detection AI has 95% accuracy but misses 40% of actual cancer cases. Is this model good enough?", options: ["No, recall is too low", "Yes, 95% is great", "It depends"], correctAnswer: "No, recall is too low", explanation: "For medical diagnosis, recall (sensitivity) matters enormously — missing 40% of cancers could be life-threatening."),
        Question(id: "hal5_q6", type: .multipleChoice, questionText: "What is cross-validation?", options: ["Testing the model on multiple different data splits", "Validating data across countries", "Having two models compete", "Checking if data is encrypted"], correctAnswer: "Testing the model on multiple different data splits", explanation: "Cross-validation trains and tests on different subsets of data to get a more reliable performance estimate.")
    ], order: 4, difficulty: .intermediate)
    
    static let lesson6 = LessonData(id: "hal_l6", title: "Transfer Learning", description: "Building on existing knowledge", categoryId: "how_ai_learns", questions: [
        Question(id: "hal6_q1", type: .multipleChoice, questionText: "Transfer learning means:", options: ["Using knowledge from one task to help with another", "Transferring data between computers", "Moving a model to a different country", "Copying homework answers"], correctAnswer: "Using knowledge from one task to help with another", explanation: "Transfer learning reuses a model trained on one task as the starting point for a different but related task."),
        Question(id: "hal6_q2", type: .trueFalse, questionText: "Transfer learning can reduce the amount of training data needed.", options: ["True", "False"], correctAnswer: "True", explanation: "Since the model already learned general features, it needs less data to adapt to the new specific task."),
        Question(id: "hal6_q3", type: .fillInBlank, questionText: "In transfer learning, a model trained on a large dataset is __________ on a smaller, specific dataset.", options: ["fine-tuned", "deleted", "compressed", "encrypted"], correctAnswer: "fine-tuned", explanation: "Fine-tuning adjusts the pre-trained model's parameters slightly to adapt to the new task."),
        Question(id: "hal6_q4", type: .multipleChoice, questionText: "Which is a good analogy for transfer learning?", options: ["A musician learning a new instrument faster", "Starting from scratch every time", "Forgetting everything you learned", "Using a calculator for math"], correctAnswer: "A musician learning a new instrument faster", explanation: "Just as musical skills transfer between instruments, learned features transfer between AI tasks."),
        Question(id: "hal6_q5", type: .scenarioJudgment, questionText: "You have limited medical images but want to build a diagnosis model. Should you use transfer learning from a model trained on millions of general images?", options: ["Yes, this is ideal", "No, not suitable", "It depends"], correctAnswer: "Yes, this is ideal", explanation: "Transfer learning is perfect here — the model already knows general image features and can be fine-tuned for medical images."),
        Question(id: "hal6_q6", type: .multipleChoice, questionText: "Which AI breakthrough heavily relies on transfer learning?", options: ["ChatGPT and other LLMs", "Traditional calculators", "Basic spreadsheets", "Simple if-else programs"], correctAnswer: "ChatGPT and other LLMs", explanation: "LLMs like GPT are pre-trained on massive text data, then fine-tuned for specific tasks — a prime example of transfer learning.")
    ], order: 5, difficulty: .advanced)
}
