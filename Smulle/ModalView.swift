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
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(modalTapped(_:)))
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(modalSwipedRight(_:)))
    
    let mainStackView = UIStackView()
    let player1StackView = UIStackView()
    let player2StackView = UIStackView()
    
    init(parentView: UIView, players: [Player]) {
        textView = UITextView()
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        super.init(frame: CGRect())
        
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        player1StackView.axis = .vertical
        player1StackView.distribution = .fillEqually
        player1StackView.alignment = .center
        player1StackView.spacing = 10
        
        player2StackView.axis = .vertical
        player2StackView.distribution = .fillEqually
        player2StackView.alignment = .center
        player2StackView.spacing = 10
        
        self.frame = CGRect(origin: CGPoint(x: parentView.frame.width, y: 10), size: CGSize(width: parentView.frame.width - 20, height: parentView.frame.height - 20))
        
        swipeRight.direction = .right
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(swipeRight)
        
        blurView.frame = self.bounds
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.alpha = 0.94
        
        addSubview(blurView)
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(player1StackView)
        mainStackView.addArrangedSubview(player2StackView)
        
        mainStackView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
        
        showCardsWithPoints(players)
        
        parentView.addSubview(self)
        
        
    }
    
    init(parentView: UIView, textFile: String) {
        
        textView = UITextView()
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        
        super.init(frame: CGRect())
        
        self.frame = CGRect(origin: CGPoint(x: parentView.frame.width, y: 10), size: CGSize(width: parentView.frame.width - 20, height: parentView.frame.height - 20))
        
        swipeRight.direction = .right
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(swipeRight)
        
        let textFile = Bundle.main.path(forResource: textFile, ofType: "txt")
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
        textView.textColor = UIColor.darkText
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 25)
        
        self.layoutMargins = UIEdgeInsetsMake(0, 20, 20, 20)
        
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
    }
    
    func modalSwipedRight(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: self.frame.width, y: 10)
            
        }, completion: { (finished: Bool) -> Void in
            
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        })
    }
    
    func modalTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.frame.origin = CGPoint(x: self.frame.width, y: 10)
            
        }, completion: { (finished: Bool) -> Void in
            
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        })
    }

    func showCardsWithPoints(_ players: [Player]) {
        
        for player in players {
            let pointCards = player.stock + player.smulleCards
            
            for card in pointCards {
                if card.getCardPoints(card) > 0 {
                    
                    let pointCard = Card(rank: card.rank, suit: card.suit)
                    
                    if player == players[0] {
                        player1StackView.addArrangedSubview(pointCard)
                    } else {
                        player2StackView.addArrangedSubview(pointCard)
                    }
                    
                    pointCard.flipCard()
                    pointCard.addBorder(pointCard)
                }
            }
        }
    }
}
