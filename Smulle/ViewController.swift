//
//  ViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var player2StackView: UIStackView!
    @IBOutlet weak var tableCardsStackView: UIStackView!
    @IBOutlet weak var player1StackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let decks = Deck(numDecks: 2)
       
        decks.shuffleDeck()
        
        let player1 = Player(name: "Nisse", faceUpCards: true)
        let player2 = Player(name: "Albert", faceUpCards: false)
        let tableCards = Player(name: "Table", faceUpCards: true)
        player1.takeCards(4, fromDeck: decks)
        player2.takeCards(4, fromDeck: decks)
        tableCards.takeCards(4, fromDeck: decks)
    
        
        // Display cards in play
        
        func displayCards(player: Player, stack: UIStackView) {
            for card in 0..<player.hand.count {
                let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.cardTapped(_:)))
                
                var cardImage = UIImageView(image: player.hand[card].cardImage)
                let cardObject = player.hand[card]
                
                // Create a shadow for each card
                cardImage.layer.shadowPath = UIBezierPath(rect: cardImage.bounds).CGPath
                cardImage.layer.shadowColor = UIColor.blackColor().CGColor
                cardImage.layer.shadowOpacity = 0.6
                cardImage.layer.shadowOffset = CGSizeZero
                cardImage.layer.shadowRadius = 1
                
                if player.faceUpCards == false {
                    let cardBackImage = UIImage(named: "Back")
                    cardImage = UIImageView(image: cardBackImage)
                    cardObject.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
                    cardObject.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
                } else {
                
                cardObject.userInteractionEnabled = true
                cardObject.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
                cardObject.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
                }
                cardObject.addGestureRecognizer(tap)
                cardObject.heightAnchor.constraintEqualToConstant(cardImage.frame.height).active = true
                cardObject.widthAnchor.constraintEqualToConstant(cardImage.frame.width).active = true
                cardObject.addSubview(cardImage)
                stack.addArrangedSubview(cardObject)
                
            }
        }
        
        displayCards(player1, stack: player1StackView)
        displayCards(tableCards, stack: tableCardsStackView)
        displayCards(player2, stack: player2StackView)
        
        
        // Debugging
        
        let testCard = UIImageView(image: decks.deck[0].cardImage)
        let testCardOverlayImage = testCard.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //testCard.image = testCard.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        //testCard.tintColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
        testCard.highlightedImage = testCardOverlayImage
        testCard.alpha = 0.2
        testCard.highlighted = true
        testCard.layer.borderWidth = 2.0
        self.view.addSubview(testCard)
        
        print(decks)
        for card in decks.deck {
            print("\(card.rank.simpleDescription()) of \(card.suit)")
        }
        print(decks.deck.count)
        print("Top card in deck: \(decks.deck[0].rank.simpleDescription())_\(decks.deck[0].suit)")

        print(tableCardsStackView.arrangedSubviews.count)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            case .Portrait:
                print("Portrait")
                self.tableCardsStackView.distribution = .FillEqually
            default:
                print("Anything But Portrait")
                self.tableCardsStackView.distribution = .EqualSpacing
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                print("rotation completed")
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cardTapped(sender: UITapGestureRecognizer) {
        
        let card = sender.view as! Card
        
        if card.highlighted == false {
            // Move tapped card 20p up and increase shadow
            card.frame.offsetInPlace(dx: 0, dy: -20)
            card.layer.shadowPath = UIBezierPath(rect: card.bounds).CGPath
            card.layer.shadowOpacity = 0.6
            card.layer.shadowOffset = CGSizeZero
            card.layer.shadowRadius = 5
            card.highlighted = true
        } else {
            // Move tapped card 20p down and decrease shadow
            card.frame.offsetInPlace(dx: 0, dy: 20)
            //card.layer.shadowPath = UIBezierPath(rect: card.bounds).CGPath
            //card.layer.shadowOpacity = 0.6
            //card.layer.shadowOffset = CGSizeZero
            card.layer.shadowRadius = 1
            card.highlighted = false
        }
        print("\(card.rank) of \(card.suit) tapped! Points: \(card.getCardPoints(card))")
    }
    

}

