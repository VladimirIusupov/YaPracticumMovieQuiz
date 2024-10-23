//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Vladimir Iusupov on 12.10.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
