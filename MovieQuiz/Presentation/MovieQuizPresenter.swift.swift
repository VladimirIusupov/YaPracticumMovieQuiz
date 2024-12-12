import SwiftUI

final class MovieQuizPresenter {
    
    // MARK: - Private Properties
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    var currentQuestionIndex = 0
    
    
    // MARK: - IB Actions
    
    func yesButtonClicked() {
        didAnswer(isYes:true)
    }

    func noButtonClicked() {
        didAnswer(isYes:false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func swithToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // MARK: - Controller Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}
