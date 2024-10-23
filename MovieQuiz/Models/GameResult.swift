//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Vladimir Iusupov on 23.10.2024.
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
} 
