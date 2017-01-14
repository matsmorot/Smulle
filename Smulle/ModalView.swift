//
//  ModalView.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-11-06.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

class ModalView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /*
    init() {
        self.frame = CGRect(origin: CGPoint(x: self.view.frame.width, y: 10), size: CGSize(width: view.frame.width - 20, height: view.frame.height - 20))
        let tap = UITapGestureRecognizer(target: self, action: #selector(rulesCardTapped(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rulesCardSwipedRight(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(swipeRight)
        
        let rulesTextFile = Bundle.main.path(forResource: "smulle_rules", ofType: "txt")
        var rulesTextString = ""
        do {
            rulesTextString = try String(contentsOfFile: rulesTextFile!)
        } catch let error as NSError {
            print("Failed reading from \(rulesTextFile). Error: " + error.localizedDescription)
        }
        
        rulesTextView.frame = rulesCard.frame
        rulesTextView.clipsToBounds = true
        rulesTextView.text = rulesTextString
        rulesTextView.backgroundColor = .none
        rulesTextView.textColor = UIColor.white
        rulesTextView.isEditable = false
        rulesTextView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 25)
        
        self.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20)
        blurView.frame = rulesCard.bounds
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.alpha = 0.94
        
        self.layer.cornerRadius = 20
        
        if #available(iOS 10.0, *) {
            
        } else {
            self.alpha = 0.97 // defining alpha < 1 will break blur effect in iOS10
        }
        view.addSubview(self)
        //dump(rulesCard.bounds)
        /*
         
         let deck = Deck(numDecks: 1)
         var cardYPosition = rulesCard.frame.origin.y + 20
         var cardXPosition = rulesCard.frame.origin.x
         
         for card in deck.deck {
         if card.getCardPoints(card) == 1 {
         
         card.frame.origin = CGPoint(x: cardXPosition, y: rulesCard.frame.origin.y)
         rulesCard.addSubview(card)
         flipCard(card)
         card.addShadow(card.cardImageView)
         cardXPosition += 20
         cardYPosition = card.cardImageView.frame.height + 20
         
         }
         if card.getCardPoints(card) > 1 {
         
         card.frame.origin = CGPoint(x: rulesCard.frame.origin.x, y: cardYPosition)
         self.view.addSubview(card)
         flipCard(card)
         card.addShadow(card.cardImageView)
         cardYPosition += card.cardImageView.frame.height + 20
         }
         }*/
    }
    
    func presentModal() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: 10, y: 10)
            self.rulesTextView.frame = self.rulesCard.frame
        }, completion: nil)
        
        self.rulesCard.addSubview(self.blurView)
        self.rulesCard.addSubview(self.rulesTextView)
    }
    
    func rulesCardSwipedRight(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.rulesCard.frame.origin = CGPoint(x: self.view.frame.width, y: 10)
            self.rulesTextView.frame = self.rulesCard.frame
        }, completion: { (finished: Bool) -> Void in
            
            self.rulesCard.subviews.forEach({ $0.removeFromSuperview() })
            self.rulesCard.removeFromSuperview()
        })
        
    }
    
    func modalTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.rulesCard.frame.origin = CGPoint(x: self.view.frame.width, y: 10)
            self.rulesTextView.frame = self.rulesCard.frame
        }, completion: { (finished: Bool) -> Void in
            
            self.rulesCard.subviews.forEach({ $0.removeFromSuperview() })
            self.rulesCard.removeFromSuperview()
        })
    }

    */
}
