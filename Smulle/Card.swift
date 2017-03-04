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
    
    init(rank: Rank, suit: Suit) {
        
        self.rank = rank
        self.suit = suit
        cardImageBack = UIImage(named: "Back")!
        cardImage = UIImage(named: "\(rank.simpleDescription())_\(suit)")!
        cardImageView = UIImageView(image: cardImageBack)
        faceUp = false
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) // Initialize a dummy UIView
        
        //addBorder(cardImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Suit {
        case h //Hearts
        case s //Spades
        case d //Diamonds
        case c //Clubs
    }
    
    enum Rank: Int {
        
        case aceOnTable = 1
        case two, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
        
        func simpleDescription() -> String {
            switch self {
            case .ace, .aceOnTable:
                return "A"
            case .jack:
                return "J"
            case .queen:
                return "Q"
            case .king:
                return "K"
            default:
                return String(self.rawValue)
            }
        }
        
        func changeAceValue() -> Rank {
            switch self {
            case .aceOnTable:
                return .ace
            default:
                return .aceOnTable
            }
        }
    }
    
    func getCardPoints(_ card: Card) -> Int {
        
        switch card {
        case _ where card.rank == .ace || card.rank == .aceOnTable:
            return 1
        case _ where card.rank == .two && card.suit == .s:
            return 1
        case _ where card.rank == .ten && card.suit == .d:
            return 2
        default:
            return 0
        }
    
    }
    
    func addShadow(_ cardImage: UIImageView) {
        
        cardImage.layer.shadowPath = UIBezierPath(rect: cardImage.bounds).cgPath //reduce cost of rendering
        // Create a shadow
        cardImage.layer.shadowColor = UIColor.black.cgColor
        cardImage.layer.shadowOpacity = 0.3
        cardImage.layer.shadowOffset = CGSize.zero
        cardImage.layer.shadowRadius = 5
        
    }
    
    func addBorder(_ cardImageView: UIImageView) {
        
        cardImageView.layer.borderWidth = 0.2
        cardImageView.layer.cornerRadius = 2
        let borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
        cardImageView.layer.borderColor = borderColor
        cardImageView.setContentCompressionResistancePriority(1000, for: .horizontal)
    }
    
    func flipCard() {
        
        //playSound(soundEffect: "flipcard2")
        
        let back = UIImageView(image: self.cardImageBack)
        let front = UIImageView(image: self.cardImage)
        
        if self.faceUp {
            
            self.addSubview(back)
            UIView.transition(from: self.cardImageView, to: back, duration: 0.32, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
                
                // Should something happen after card has been flipped?
                
            })
            self.faceUp = false
            print("Card flipped from front to back!")
        } else {
            
            self.addSubview(front)
            
            UIView.transition(from: self.cardImageView, to: front, duration: 0.32, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
                
                // Should something happen after card has been flipped?
                
            })
            self.addBorder(front)
            self.faceUp = true
            print("Card flipped from back to front!")
        }
        
    }
    
    
}
