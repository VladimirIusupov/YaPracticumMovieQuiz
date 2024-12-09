import UIKit

final class MovieQuizViewController:UIViewController,
                                    QuestionFactoryDelegate,
                                    AlertPresenterDelegate {
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
            let givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            yesButton.isEnabled = false
            noButton.isEnabled = false
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
            let givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            yesButton.isEnabled = false
            noButton.isEnabled = false
    }
    
    // MARK: - Private Properties
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory

        alertPresenter = AlertPresenter(viewController: self)
        alertPresenter?.delegate = self
        
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory.loadData()
        show(currentIndex: currentQuestionIndex)
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        //DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        //}
        
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
    // MARK: - AlertPresenterDelegate
    
        func presentAlert() {
            currentQuestionIndex = 0
            correctAnswers = 0
            show(currentIndex: currentQuestionIndex)
        }


    // MARK: - Private Methods
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func show(currentIndex: Int){
            questionFactory?.requestNextQuestion()
        }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect{
            correctAnswers+=1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1{
            let currentDate = Date()
            let gameResult = GameResult(correct: correctAnswers,
                                        total: questionsAmount,
                                        date: currentDate)
            statisticService.store(gameResult)
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let bestGameDate = bestGame.date.dateTimeString
            let message: [String] = [
            "Ваш результат: \(correctAnswers)",
            "Количество сыгранных квизов: \(gamesCount)",
            "Рекорд: \(bestGame.correct)/10 (\(bestGameDate))",
            "Средняя точность: \("\(String(format: "%.2f", totalAccuracy))%")"
            ]
            let text = message.joined(separator: "\n")
            let alertModel = QuizResultsViewModel(title: "Этот раунд закончен!",
                                                  text: text,
                                                  buttonText: "Сыграть еще раз")
            show(quiz:alertModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
                    title: result.title,
                    message: result.text,
                    preferredStyle: .alert)
                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.show(currentIndex: self.currentQuestionIndex)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentAlert(with: model)
    }

}
