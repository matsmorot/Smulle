//
//  Player.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-02.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation

protocol PlayerType {
    var name: String { get }
    var points: Int { get set }
    var wins: Int { get set }
    var hand: Array<Card> { get set }
    var faceUpCards: Bool { get }
}

class Player: PlayerType {
    var name: String
    var points: Int
    var wins: Int
    var hand: Array<Card>
    var faceUpCards: Bool
    
    init(name: String, faceUpCards: Bool) {
        self.name = name
        points = 0
        wins = 0
        hand = []
        self.faceUpCards = faceUpCards
    }
    
    func takeCards(numCards: Int, fromDeck: Deck) {
        for _ in 1...numCards {
            hand.append(fromDeck.getTopCardFromDeck())
        }
    }
}