//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Vladimir Iusupov on 12.10.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(model: AlertModel?)
}
