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
    
    let textView: UITextView
    let blurView: UIVisualEffectView
    
    init(parentView: UIView) {
        
        textView = UITextView()
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.frame = CGRect(origin: CGPoint(x: parentView.frame.width, y: 10), size: CGSize(width: parentView.frame.width - 20, height: parentView.frame.height - 20))
        let tap = UITapGestureRecognizer(target: self, action: #selector(modalTapped(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(modalSwipedRight(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(swipeRight)
        
        let textFile = Bundle.main.path(forResource: "smulle_rules", ofType: "txt")
        var textString = ""
        do {
            textString = try String(contentsOfFile: textFile!)
        } catch let error as NSError {
            print("Failed reading from \(textFile). Error: " + error.localizedDescription)
        }
        
        textView.frame = self.frame
        textView.clipsToBounds = true
        textView.text = textString
        textView.backgroundColor = .none
        textView.textColor = UIColor.white
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 25)
        
        self.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20)
        
        blurView.frame = self.bounds
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.alpha = 0.94
        
        self.layer.cornerRadius = 20
        
        addSubview(blurView)
        blurView.addSubview(textView)
        
        if #available(iOS 10.0, *) {
            
        } else {
            self.alpha = 0.97 // defining alpha < 1 will break blur effect in iOS10
        }
        parentView.addSubview(self)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentModal() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: 10, y: 10)
            self.textView.frame = self.frame
        }, completion: nil)
        
        //self.addSubview(self.blurView)
        //self.addSubview(self.textView)
    }
    
    func modalSwipedRight(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: self.frame.width, y: 10)
            self.textView.frame = self.frame
        }, completion: { (finished: Bool) -> Void in
            
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        })
        
    }
    
    func modalTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: self.frame.width, y: 10)
            self.textView.frame = self.frame
        }, completion: { (finished: Bool) -> Void in
            
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        })
    }

 
}
