import UIKit

final class StatisticService: StatisticServiceProtocol {

    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get { return storage.double(forKey: Keys.totalAccuracy.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalAccuracy.rawValue) }
    }
    
    private var correctAnswers:Int {
        get { return storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }
    
    private var totalAnswers: Int {
        get { return storage.integer(forKey: Keys.totalAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalAnswers.rawValue) }
    }
    
    func store(_ currentGameResult: GameResult) {
        
        //totalAccuracy = 0.0 // итоговый процент прираниваем к нулю
        let newGamesCount = gamesCount + 1 // счет игр +1
        gamesCount = newGamesCount // сохраняем счетчик игр
        
        let totalQuestionsCount = Double(gamesCount) * 10.0 // счетчик игр общий
        
        let correctAnswersCount = Double(correctAnswers) // забираем из авмяти счетчик правильных ответов
        let newCorrectAnswersCount = correctAnswersCount + Double(currentGameResult.correct) // прибавляем ткущий результат
        correctAnswers = Int(newCorrectAnswersCount) // сохраняем результат для рачета
        //let correctAnswersCount = totalAccuracy * totalQuestionsCount / 100.0 + Double(currentGameResult.correct)
        //print(totalAccuracy, totalQuestionsCount, currentGameResult.correct, correctAnswers)
        // счет правильных ответов = итоговый процент умножаем на общеее количество ответов делим на 100 и прибаляем текущее количество текущих ответов
        totalAnswers = Int(totalQuestionsCount) // обрачиваем в инт количество вопросов
        guard gamesCount != 0 else {return}
        let newAccuracy = (newCorrectAnswersCount/totalQuestionsCount) * 100 // формула верная из ТЗ
        totalAccuracy = newAccuracy
        if currentGameResult.isBetterThan(bestGame) { bestGame = currentGameResult }
    }
    
    private enum Keys: String {
        case correct
        case gamesCount
        case total
        case date
        case totalAnswers
        case correctAnswers
        case totalAccuracy
    }
}
