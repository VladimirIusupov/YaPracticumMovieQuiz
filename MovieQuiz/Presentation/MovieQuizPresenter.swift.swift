import UIKit
final class MovieQuizPresenter: QuestionFactoryDelegate{
   
    
    
    private let statisticService: StatisticServiceProtocol!
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    let questionsAmount:Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers:Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer(){
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    func didRecieveNextQuestion(question: QuizQuestion?){
        guard let question = question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {[weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func isLastQuestion()->Bool{
        currentQuestionIndex == questionsAmount - 1
    }
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer{
            correctAnswers+=1
        }
    }
    func restartGame(){
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    func switchToNextQuestion(){
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    func yesButtonClocked() {
        didAnswer(isYes:true)
    }
    func noButtonClicked() {
        didAnswer(isYes:false)
    }
    private func didAnswer(isYes:Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    private func proceedWithAnswer(isCorrect: Bool){
        didAnswer(isCorrectAnswer: isCorrect)

                viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.proceedToNextQuestionOrResult()
                }
    }
    func proceedToNextQuestionOrResult() {
        if self.isLastQuestion() {
            let currentDate = Date()
            let gameResult = GameResult(correct: correctAnswers,
                                        total: questionsAmount,
                                        date: currentDate)
            
            statisticService.store(gameResult)
            guard let gamesCount = statisticService?.gamesCount,
                  let bestGame = statisticService?.bestGame,
                  let totalAccuracy = statisticService?.totalAccuracy else {return}
            
            let bestGameDate = bestGame.date.dateTimeString
            
            let message: [String] = [
            "Ваш результат: \(correctAnswers)",
            "Количество сыгранных квизов: \(gamesCount)",
            "Рекорд: \(bestGame.correct)/10 (\(bestGameDate))",
            "Средняя точность: \("\(String(format: "%.2f", totalAccuracy))%")"
            ]
            
            let text = message.joined(separator: "\n")
            
            let alertModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                  text: text,
                                                  buttonText: "Сыграть еще раз")
            self.viewController?.show(quiz:alertModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
}
