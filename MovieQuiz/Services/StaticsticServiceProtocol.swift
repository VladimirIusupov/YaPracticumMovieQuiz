//
//  StaticsticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Vladimir Iusupov on 23.10.2024.
//

import UIKit

protocol StatisticServiceProtocol{
    var gamesCount: Int {get}
    var bestGame: GameResult {get}
    var totalAccuracy: Double {get}
    
    func store(_ currentGameResult: GameResult)
}
