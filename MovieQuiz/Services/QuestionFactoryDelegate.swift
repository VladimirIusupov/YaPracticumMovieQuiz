import UIKit

protocol QuestionFactoryDelegate:AnyObject{
    func didRecieveNextQuestion(question: QuizQuestion?)
}
