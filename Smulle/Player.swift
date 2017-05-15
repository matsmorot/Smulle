//
//  Player.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-02.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation
import UIKit

// Equatable

func ==(lhs: Player, rhs: Player) -> Bool {
    return
        lhs.hashValue == rhs.hashValue &&
        lhs.points == rhs.points
}

protocol PlayerType {
    var name: String { get }
    var points: Int { get set }
    var wins: Int { get set }
    var hand: Array<Card> { get set }
    var faceUpCards: Bool { get }
}

class Player: CardHolder, PlayerType, Hashable {
    var name: String
    var points: Int
    var roundPoints: Int {
        didSet {
            if roundPoints - oldValue == 1 {
                // Play sound from here instead?
                
            }
        }
    }
    var wins: Int
    var numberOfSpades: Int
    var hasMostSpades: Bool
    var spadePoints: Int
    var stock: Array<Card>
    var smulleCards: Array<Card>
    var numberOfTabbeCards: Int
    var faceUpCards: Bool
    var isDealer: Bool
    var stackView: UIStackView
    var stockView: UIStackView
    var smulleView: UIStackView
    var hashValue: Int {
        get {
            return self.name.hashValue
        }
    }
    
    init(name: String, faceUpCards: Bool) {
        self.name = name
        points = 0
        roundPoints = 0
        wins = 0
        numberOfSpades = 0
        hasMostSpades = false
        spadePoints = 0
        stock = []
        smulleCards = []
        numberOfTabbeCards = 0
        self.faceUpCards = faceUpCards
        isDealer = false
        stackView = UIStackView()
        stockView = UIStackView()
        smulleView = UIStackView()
    }
}
