// ==========================================
// QUESTION MODEL
// A single challenge topic the user can be asked to explain
// (Feynman-technique style), plus the built-in topic bank.
// Swap `topicBank` for a real API call whenever there's a backend.
// ==========================================

class ChallengeTopic {
  final String title;
  final String difficulty;

  const ChallengeTopic({required this.title, required this.difficulty});
}

const List<ChallengeTopic> topicBank = [
  // Science
  ChallengeTopic(title: 'What is Photosynthesis?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Water?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Newton\'s Third Law?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Gravity?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is DNA?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is an Ecosystem?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is the Water Cycle?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Natural Selection?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Quantum Entanglement?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is the Theory of Relativity?',
    difficulty: 'Hard',
  ),
  ChallengeTopic(title: 'What is a Black Hole?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is CRISPR Gene Editing?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is the Greenhouse Effect?', difficulty: 'Medium'),

  // Technology / Computer Science
  ChallengeTopic(title: 'What is Blockchain?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Machine Learning?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Database Index?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is an API?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Cloud Computing?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Encryption?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Neural Network?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is Object-Oriented Programming?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is a Recursive Function?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is the Internet of Things?', difficulty: 'Easy'),

  // Math
  ChallengeTopic(title: 'What is the Pythagorean Theorem?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is a Derivative?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Compound Interest?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is a Prime Number?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Probability?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Standard Deviation?', difficulty: 'Hard'),

  // History / Social Studies
  ChallengeTopic(title: 'What caused World War I?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What was the Renaissance?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Democracy?', difficulty: 'Easy'),
  ChallengeTopic(
    title: 'What was the Industrial Revolution?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is Inflation?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Supply and Demand?', difficulty: 'Easy'),

  // General / Everyday concepts
  ChallengeTopic(
    title: 'What is Emotional Intelligence?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is Compound Growth?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Placebo Effect?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Time Zones?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Cognitive Bias?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is Sustainable Development?',
    difficulty: 'Medium',
  ),
];
