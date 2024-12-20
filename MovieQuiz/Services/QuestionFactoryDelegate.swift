import UIKit

protocol QuestionFactoryDelegate {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
