import UIKit

final class MovieQuizViewController:UIViewController,
                                    AlertPresenterDelegate,
                                    MovieQuizViewControllerProtocol{
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var presenter: MovieQuizPresenter!
    var alertPresenter:AlertPresenter?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        
    }
        func presentAlert() {
            presenter = MovieQuizPresenter(viewController: self)
            alertPresenter = AlertPresenter(viewController: self)
            alertPresenter?.delegate = self
        }
    @IBAction private func yesButtonClocked(_ sender: UIButton) {
        presenter.yesButtonClocked()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    private func show(currentIndex: Int){
        presenter.restartGame()
        }
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
        self.presenter.restartGame()
        }
        alertPresenter?.presentAlert(with: model)
    }
    func hideLoadIndicator(){
        activityIndicator.isHidden = true
    }
    func proceedWithAnswer(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presenter.proceedToNextQuestionOrResult()
        }
    }
    func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
                    title: result.title,
                    message: result.text,
                    preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.presenter.restartGame()
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
        
    }
}
