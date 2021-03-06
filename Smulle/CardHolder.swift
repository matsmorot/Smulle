//
//  CardHolder.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-23.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation
import UIKit

class CardHolder {
    
    var hand: Array<Card> = []
    
    func takeCardsFromDeck(_ numCards: Int, fromDeck: Deck) {
        for _ in 1...numCards {
            hand.append(fromDeck.getTopCardFromDeck())
        }
    }
    
    // Not implemented
    /*
    func moveCard(_ player: Player, fromView: UIView, toView: UIView) {
        UIView.transition(from: fromView, to: toView, duration: 1, options: UIViewAnimationOptions.curveEaseOut, completion: nil)
    }
    */
}
