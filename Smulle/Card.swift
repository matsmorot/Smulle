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
    var cardImageBack: UIImage
    var cardImage: UIImage
    var cardImageView: UIImageView
    var faceUp: Bool
    var origin: CGPoint
    
    init(rank: Rank, suit: Suit) {
        
        self.rank = rank
        self.suit = suit
        cardImageBack = UIImage(named: "Back")!
        cardImage = UIImage(named: "\(self.rank.simpleDescription())_\(self.suit)")!
        cardImageView = UIImageView(image: cardImage)
        faceUp = false
        origin = CGPoint(x: 0, y: 0)
        
        super.init(frame: CGRectMake(0, 0, 0, 0)) // Initialize a dummy UIView
        
        addBorder(cardImageView)
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
        
        case AceOnTable = 1
        case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
        case Jack, Queen, King, Ace
        
        func simpleDescription() -> String {
            switch self {
            case .Ace, .AceOnTable:
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
        
        func changeAceValue() -> Rank {
            switch self {
            case .AceOnTable:
                return .Ace
            default:
                return .AceOnTable
            }
        }
    }
    
    func getCardPoints(card: Card) -> Int {
        
        switch card {
        case _ where card.rank == .Ace || card.rank == .AceOnTable:
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
        cardImage.layer.shadowOpacity = 0.3
        cardImage.layer.shadowOffset = CGSizeZero
        cardImage.layer.shadowRadius = 0.5
        
    }
    
    func addBorder(cardImage: UIImageView) {
        
        cardImage.layer.borderWidth = 0.2
        cardImage.layer.cornerRadius = 2
        let borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).CGColor
        cardImage.layer.borderColor = borderColor
        
    }
    
    
}
