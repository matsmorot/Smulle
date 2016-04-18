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
    @IBOutlet weak var player1StockView: UIStackView!
    
    
    
    
    
    let numberOfRounds = 4
    var numberOfCardsHighlighted = 0
    var sumOfHighlightedCards = 0
    var highlightedCards: Array<Card> = []
    let player1 = Player(name: "Nisse", faceUpCards: true)
    let player2 = Player(name: "Albert", faceUpCards: false)
    let tableCards = Player(name: "Table", faceUpCards: true)
    
    let decks = Deck(numDecks: 2)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        decks.shuffleDeck()
        
        player1.takeCardsFromDeck(4, fromDeck: decks)
        player2.takeCardsFromDeck(4, fromDeck: decks)
        tableCards.takeCardsFromDeck(4, fromDeck: decks)
    
        
        // Display cards in play
        
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
        
        print(decks.deck.count)
        
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

    func displayCards(player: Player, stack: UIStackView) {
        for card in 0..<player.hand.count {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            
            let cardObject = player.hand[card]
            var cardImage = UIImageView(image: player.hand[card].cardImage)
            
            addShadow(cardImage)

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
        
        // Show top stock card if it exists
        for card in 0..<player.stock.count {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            
            let cardObject = player.stock[card]
            let cardImage = UIImageView(image: player.stock[card].cardImage)
            
            //addShadow(cardImage)
            
            cardObject.userInteractionEnabled = true
            cardObject.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            cardObject.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            
            cardObject.addGestureRecognizer(tap)
            cardObject.heightAnchor.constraintEqualToConstant(cardImage.frame.height).active = true
            cardObject.widthAnchor.constraintEqualToConstant(cardImage.frame.width).active = true
            cardObject.addSubview(cardImage)
            
            player1StockView.addArrangedSubview(cardObject)
            
        }
        
    }
    
    func cardTapped(sender: UITapGestureRecognizer) {
        
        let card = sender.view as! Card
        
        card.layer.shadowPath = UIBezierPath(rect: card.bounds).CGPath //reduce cost of rendering shadow
        
        // Card selection
        if tableCardsStackView.arrangedSubviews.contains(card) {
            if card.highlighted == false {
                
                // Move tapped card 20p up and increase shadow
                card.frame.offsetInPlace(dx: 0, dy: -20)
                card.layer.shadowOpacity = 0.6
                card.layer.shadowOffset = CGSizeZero
                card.layer.shadowRadius = 5
                card.highlighted = true
                numberOfCardsHighlighted += 1
                sumOfHighlightedCards += card.rank.rawValue
                highlightedCards.append(card)
                
                print("\(numberOfCardsHighlighted) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            } else if card.highlighted == true {
                
                // Move tapped card 20p down and decrease shadow
                card.frame.offsetInPlace(dx: 0, dy: 20)
                card.layer.shadowRadius = 1
                card.highlighted = false
                numberOfCardsHighlighted -= 1
                sumOfHighlightedCards -= card.rank.rawValue
                highlightedCards.removeAtIndex(highlightedCards.indexOf(card)!)
                
                print("\(numberOfCardsHighlighted) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            }
        } else {
            if numberOfCardsHighlighted > 0 {
                if sumOfHighlightedCards == card.rank.rawValue {
                    print("YES! Korten är dina!")
                    highlightedCards.append(card) // Add chosen card from hand to be collected
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
                    collectCards(highlightedCards, player: player1)
                    
                } else {
                    print("Nej nu har du räknat fel!")
                }
            } else {
                print("Choose table cards first!\n")
            }
        }
        print("\(card.rank) of \(card.suit) tapped! Points: \(card.getCardPoints(card))\n")
        
    }
    
    func collectCards(cards: Array<Card>, player: Player) {
        
        player.stock = cards
        
        // Loop through collected cards and remove them from stack views
        for card in 0..<player.stock.count {
            tableCardsStackView.removeArrangedSubview(player.stock[card])
            player1StackView.removeArrangedSubview(player.stock[card])
        }
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        numberOfCardsHighlighted = 0
        
        displayCards(player1, stack: player1StackView)
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

