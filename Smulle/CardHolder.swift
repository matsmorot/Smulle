//
//  CardHolder.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-23.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation

class CardHolder {
    var hand: Array<Card> = []
    
    func takeCardsFromDeck(numCards: Int, fromDeck: Deck) {
        for _ in 1...numCards {
            hand.append(fromDeck.getTopCardFromDeck())
        }
    }
}