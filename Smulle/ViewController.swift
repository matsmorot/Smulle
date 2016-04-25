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
    @IBOutlet weak var player2StockView: UIStackView!
    @IBOutlet weak var player1StockAndSmulleView: UIStackView!
    @IBOutlet weak var player1SmulleView: UIStackView!
    @IBOutlet weak var tableCardsEmptyCardView: UIStackView!
    
    
    
    var cardHolderIsActive = false
    let numberOfRounds = 4
    var numberOfCardsHighlighted = 0
    var sumOfHighlightedCards = 0
    var highlightedCards: Array<Card> = []
    let player1 = Player(name: "You", faceUpCards: true)
    let player2 = Player(name: "Komp Jutah", faceUpCards: false)
    let tableCards = CardHolder()
    
    let decks = Deck(numDecks: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        decks.shuffleDeck()
        
        showDeck()
        
        player1.takeCardsFromDeck(4, fromDeck: decks)
        player2.takeCardsFromDeck(4, fromDeck: decks)
        tableCards.takeCardsFromDeck(4, fromDeck: decks)
        
        // Display cards in play
        
        displayHandCards(player1, stack: player1StackView, stockView: player1StockView)
        displayTableCards()
        // Add a tappable, empty card holder to use when no cards can be taken
        addCardHolder()
        displayHandCards(player2, stack: player2StackView, stockView: player2StockView)
        
        
        // Debugging
        
        //player1.smulleCards.append(Card(rank: .Queen, suit: .H))
        
        print(decks.deck.count)
        
    }
    
    /*
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
 */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDeck() {
        let startY = UIApplication.sharedApplication().statusBarFrame.height
        let cardImage = UIImage(named: "Back")
        let cardObject = UIImageView(image: cardImage)
        cardObject.frame.origin.y = startY
        cardObject.frame.origin.x = view.layoutMargins.left
        
        for _ in 0..<decks.deck.count {
            
            view.addSubview(cardObject)
        }
    }
    
    func displayTableCards() {
        for card in tableCards.hand {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.userInteractionEnabled = true
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
            card.addSubview(card.cardImageView)
            tableCardsStackView.addArrangedSubview(card)
        }
    }

    func displayHandCards(player: Player, stack: UIStackView, stockView: UIStackView?) {
        
        for card in 0..<player.hand.count {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            let cardObject = player.hand[card]
            var cardImage = UIImageView(image: player.hand[card].cardImage)

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
        
        // Show top stock card if it exists. It also has to be tappable.
        for card in player.stock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))

            let cardImage = UIImageView(image: card.cardImage)
            
            card.userInteractionEnabled = true
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraintEqualToConstant(cardImage.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(cardImage.frame.width).active = true
            card.addSubview(cardImage)
            
            stockView!.removeArrangedSubview(card)
            stockView!.addArrangedSubview(card)
        }
        
        // Show top Smulle card, cropped, to save space
        if player.smulleCards.count > 0 {
            let lastCard = player.smulleCards.last
            let cardImage = UIImageView(image: lastCard!.cardImage)
            player1SmulleView.contentMode = UIViewContentMode.Top
            player1SmulleView.clipsToBounds = true
            player1SmulleView.frame.size.height = cardImage.frame.height / 3
            player1SmulleView.frame.origin.x = cardImage.frame.origin.x
            player1SmulleView.frame.origin.y = cardImage.frame.origin.y
            
            cardImage.contentMode = UIViewContentMode.Top
            cardImage.clipsToBounds = true
            cardImage.frame.size.height = cardImage.frame.height / 3
            
            //player1SmulleView.removeArrangedSubview(cardImage)
            //player1SmulleView.addArrangedSubview(cardImage)
            player1SmulleView.addSubview(cardImage)
        }
        
    }
    
    func addCardHolder() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardHolderTapped(_:)))
        //doubletap.numberOfTapsRequired = 2
        
        let cardImage = UIImage(named: "Back")
        let cardHolder = UIImageView(image: cardImage)
        cardHolder.userInteractionEnabled = true
        cardHolder.addGestureRecognizer(tap)
        cardHolder.alpha = 0.5
        cardHolder.highlighted = false
        cardHolder.layer.borderWidth = 1.0
        cardHolder.layer.cornerRadius = 5.0
        
        tableCardsEmptyCardView.addArrangedSubview(cardHolder)
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
                if cardsAreCorrectlyChosen(card) {
                    takeSmulle(card) // Check if a Smulle is present and if so, add it to player.smulleCards
                    player1.stock.insert(card, atIndex: 0) // Add chosen card from hand to stock
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!) // ...and remove it from hand
                    collectCards(highlightedCards, player: player1, stack: player1StackView)
                    
                } else {
                    print("Nej nu har du räknat fel!")
                }
            } else {
                if cardHolderIsActive == true {
                    tableCards.hand.append(card)
                    displayTableCards()
                    
                    cardHolderIsActive = false
                } else {
                    print("Choose table cards first!")
                }
            }
        }
        
    }
    
    func cardHolderTapped(sender: UITapGestureRecognizer) {
        let cardHolder = sender.view as! UIImageView
        
        if cardHolder.highlighted == false {
            cardHolder.alpha = 1
            cardHolder.highlighted = true
            cardHolderIsActive = true
        } else {
            cardHolder.alpha = 0.5
            cardHolder.highlighted = false
            cardHolderIsActive = false
        }
    }
    
    func collectCards(cards: Array<Card>, player: Player, stack: UIStackView) {
        
        // Loop through collected cards and remove them from stack views and table hand
        for card in cards {
            player.stock.insert(card, atIndex: 0)
            tableCardsStackView.removeArrangedSubview(card)
            tableCards.hand.removeAtIndex(tableCards.hand.indexOf(card)!)
            print("\(card.rank) of \(card.suit)")
        }
        
        // If no cards exist on table you get a TABBE
        if tableCardsStackView.arrangedSubviews.count == 0 {
            player.tabbeCards += 1
            print("TABBE!")
        }
        
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        numberOfCardsHighlighted = 0
        
        displayHandCards(player, stack: stack, stockView: player1StockView)
        print(player1.stock.count)
        // Move on to next player
    }
    
    func cardsAreCorrectlyChosen(card: Card) -> Bool {
        
        for c in highlightedCards {
            if c.rank.rawValue > card.rank.rawValue { // hand card has to be greater than or eq to each table card chosen
                return false
            }
        }
        
        if sumOfHighlightedCards == card.rank.rawValue || // x number of cards equals hand card, OR
            sumOfHighlightedCards / numberOfCardsHighlighted == card.rank.rawValue || // ...x number of equal values equals hand card, OR
            sumOfHighlightedCards % card.rank.rawValue == 0 { // ...no remainder exists
        return true
        }
        return false
    }
    
    func takeSmulle(card: Card) {
        var cIndex = 1
        for c in highlightedCards {
            
            for _ in cIndex..<highlightedCards.count {
                let h = highlightedCards[cIndex]
                if h.rank == c.rank && h.suit == c.suit {
                    print("\(h.rank) of \(h.suit) == \(c.rank) of \(c.suit) is a SMULLE!")
                    player1.smulleCards.append(h)
                    break
                }
            }
            cIndex += 1
            
            if c.rank == card.rank && c.suit == card.suit { //||
                
                player1.smulleCards.append(card)
            }
        }
        
        print("DU HAR \(player1.smulleCards.count) SMULLAR!")
    }

}

