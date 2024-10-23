//
//  StaticService.swift
//  MovieQuiz
//
//  Created by Vladimir Iusupov on 23.10.2024.
//

import UIKit

final class StatisticService: StatisticServiceProtocol{

    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
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
        get {
            return storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    private var correctAnswers:Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    private var totalAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    func store(_ currentGameResult: GameResult) {
        totalAccuracy = 0.0
        let newGamesCount = gamesCount + 1
        gamesCount = newGamesCount
        let totalQuestionsCount = Double(gamesCount) * 10.0
        let correctAnswersCount = totalAccuracy * totalQuestionsCount / 100.0 + Double(currentGameResult.correct)
        totalAnswers = Int(totalQuestionsCount)
        guard gamesCount != 0 else {return}
        let newAccuracy = (correctAnswersCount/totalQuestionsCount) * 100
        totalAccuracy = newAccuracy
        if currentGameResult.isBetterThan(bestGame){
            bestGame = currentGameResult
        }
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
