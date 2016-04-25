//
//  Deck.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation
import UIKit

class Card: UIImageView {
    
    var rank: Rank
    var suit: Suit
    var cardImage = UIImage(named: "Back")
    var cardImageView: UIImageView
    
    init(rank: Rank, suit: Suit) {
        
        self.rank = rank
        self.suit = suit
        cardImage = UIImage(named: "\(self.rank.simpleDescription())_\(self.suit)")
        cardImageView = UIImageView(image: cardImage)
        
        super.init(frame: CGRectMake(0, 0, 0, 0)) // Initialize a dummy UIView
        
        addShadow(cardImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Suit {
        case H //Hearts
        case S //Spades
        case D //Diamonds
        case C //Clubs
    }
    
    enum Rank: Int {
        case Ace = 1
        case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
        case Jack, Queen, King
        
        func simpleDescription() -> String {
            switch self {
            case .Ace:
                return "A"
            case .Jack:
                return "J"
            case .Queen:
                return "Q"
            case .King:
                return "K"
            default:
                return String(self.rawValue)
            }
        }
    }
    
    func getCardPoints(card: Card) -> Int {
        
        switch card {
        case _ where card.rank == .Ace:
            return 1
        case _ where card.rank == .Two && card.suit == .S:
            return 1
        case _ where card.rank == .Ten && card.suit == .D:
            return 2
        default:
            return 0
        }
    
    }
    
    func addShadow(cardImage: UIImageView) {
        
        cardImage.layer.shadowPath = UIBezierPath(rect: cardImage.bounds).CGPath //reduce cost of rendering
        // Create a shadow
        cardImage.layer.shadowColor = UIColor.blackColor().CGColor
        cardImage.layer.shadowOpacity = 0.6
        cardImage.layer.shadowOffset = CGSizeZero
        cardImage.layer.shadowRadius = 1
        
    }
}
