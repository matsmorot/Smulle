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
    @IBOutlet weak var player2SmulleView: UIStackView!
    @IBOutlet weak var tableCardsEmptyCardView: UIStackView!
    
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var cardHolderIsActive = false
    let numberOfRounds = 4
    var sumOfHighlightedCards = 0
    var highlightedCards: Array<Card> = []
    let player1 = Player(name: "You", faceUpCards: true)
    let player2 = Player(name: "Komp Jutah", faceUpCards: false)
    var players: Array<Player> = []
    var activePlayer: Player = Player(name: "Dummy", faceUpCards: false)
    let tableCards = CardHolder()
    var deckPosition: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    let decks = Deck(numDecks: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.setBackgroundImage(UIImage(named: "top_bar"), forBarMetrics: UIBarMetrics.Default)
        
        
        // Assign stack views to players
        player1.stackView = player1StackView
        player1.stockView = player1StockView
        player1.smulleView = player1SmulleView
        player2.stackView = player2StackView
        player2.stockView = player2StockView
        player2.smulleView = player2SmulleView
        
        // Populate variable players with players
        players = [player1, player2]
        
        // Select player to act first manually, for now
        activePlayer = player1
        
        decks.shuffleDeck()
        
        player1.takeCardsFromDeck(4, fromDeck: decks)
        player2.takeCardsFromDeck(4, fromDeck: decks)
        tableCards.takeCardsFromDeck(4, fromDeck: decks)
        
        // Show deck next to the player who is currently dealer (needs improvement)
        //showDeck()
        
        // Display cards in play
        updateView()
        
        // Add a tappable, empty card holder to use when no cards can be taken
        addCardHolder()
        
        
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
    
    // Show remaining cards in deck next to the player who is currently dealer (for later version)
    func showDeck() {
        let cardImage = UIImage(named: "Back")
        let cardObject = UIImageView(image: cardImage)
        
        if activePlayer.name == player1.name {
            player2.isDealer = true
            player1.isDealer = false
        } else if activePlayer.name == player2.name {
            player1.isDealer = true
            player2.isDealer = false
        }
        
        if player2.isDealer {
            let startY = navigationBar.frame.height + 25
            cardObject.frame.origin.y = startY
            cardObject.frame.origin.x = view.layoutMargins.left
        } else if player1.isDealer {
            let startY = view.frame.height - 125
            cardObject.frame.origin.y = startY
            cardObject.frame.origin.x = view.layoutMargins.left
        }
        
        for _ in 0..<decks.deck.count {
            
            view.addSubview(cardObject)
        }
        deckPosition = cardObject.frame
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

    func displayHandCards(player: Player) {
        
        for card in player.hand {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))

            /*if player.faceUpCards == false {
                
                let cardBackImage = UIImage(named: "Back")
                card.cardImageView = UIImageView(image: cardBackImage)
                //card.addShadow(card.cardImageView)
                
            } else {
            */
                card.userInteractionEnabled = true
                
            //}
            
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
            
            card.addSubview(card.cardImageView)
            
            player.stackView.addArrangedSubview(card)
        }
        
        // Show top stock card if it exists. It also has to be tappable.
        for card in player.stock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            
            card.userInteractionEnabled = true
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
            
            player.stockView.addArrangedSubview(card)
        }
        
        // Show top Smulle card, cropped, to save space
        if player.smulleCards.count > 0 {
            let lastCard = player.smulleCards.last
            let cardImage = UIImageView(image: lastCard!.cardImage)
            player.smulleView.contentMode = UIViewContentMode.Top
            player.smulleView.clipsToBounds = true
            player.smulleView.frame.size.height = cardImage.frame.height / 3
            player.smulleView.frame.origin.x = cardImage.frame.origin.x
            player.smulleView.frame.origin.y = cardImage.frame.origin.y
            
            cardImage.contentMode = UIViewContentMode.Top
            cardImage.clipsToBounds = true
            cardImage.frame.size.height = cardImage.frame.height / 3
            
            player.smulleView.addSubview(cardImage)
        }
        
    }
    
    func addCardHolder() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardHolderTapped(_:)))
        //doubletap.numberOfTapsRequired = 2
        
        let cardImage = UIImage(named: "Back")
        let cardHolder = UIImageView(image: cardImage)
        cardHolder.image = cardHolder.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cardHolder.userInteractionEnabled = true
        cardHolder.addGestureRecognizer(tap)
        cardHolder.alpha = 0.3
        cardHolder.highlighted = false
        cardHolder.layer.borderColor = UIColor.cyanColor().CGColor
        cardHolder.layer.borderWidth = 2.0
        cardHolder.layer.cornerRadius = 4.0
        
        tableCardsEmptyCardView.addArrangedSubview(cardHolder)
    }
    
    func cardTapped(sender: UITapGestureRecognizer) { // Tappee will always be player1
        
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
                
                sumOfHighlightedCards += card.rank.rawValue
                highlightedCards.append(card)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            } else if card.highlighted == true {
                
                // Move tapped card 20p down and decrease shadow
                card.frame.offsetInPlace(dx: 0, dy: 20)
                card.layer.shadowRadius = 1
                card.highlighted = false
                
                sumOfHighlightedCards -= card.rank.rawValue
                highlightedCards.removeAtIndex(highlightedCards.indexOf(card)!)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            }
        } else {
            if highlightedCards.count > 0 {
                if cardsAreCorrectlyChosen(card) {
                    takeSmulle(card) // Check if a Smulle is present and if so, add it to player.smulleCards
                    player1.stock.append(card) // Add chosen hand card to stock
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!) // ...and remove it from hand
                    collectCards(highlightedCards, player: player1)
                    
                } else {
                    print("Chosen cards do not match your hand card!")
                }
            } else {
                if cardHolderIsActive == true {
                    tableCards.hand.append(card)
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
                    displayTableCards()
                    displayHandCards(player1)
                    cardHolderIsActive = false
                    nextPlayer()
                    
                } else {
                    print("Choose table cards first!")
                }
            }
        }
        
    }
    
    func cardHolderTapped(sender: UITapGestureRecognizer) {
        let cardHolder = sender.view as! UIImageView
        
        if cardHolder.highlighted == false {
            UIView.animateWithDuration(0.2) {
                cardHolder.alpha = 1
            }
            cardHolder.highlighted = true
            cardHolderIsActive = true
            
        } else {
            UIView.animateWithDuration(0.2) {
                cardHolder.alpha = 0.3
            }
            cardHolder.highlighted = false
            cardHolderIsActive = false
        }
    }
    
    func cardsAreCorrectlyChosen(card: Card) -> Bool {
        
        for c in highlightedCards {
            if c.rank.rawValue > card.rank.rawValue { // hand card has to be greater than or eq to each table card chosen
                return false
            }
        }
        
        if sumOfHighlightedCards == card.rank.rawValue || // x number of cards equals hand card, OR
            sumOfHighlightedCards / highlightedCards.count == card.rank.rawValue || // ...x number of equal values equals hand card, OR
            sumOfHighlightedCards % card.rank.rawValue == 0 { // ...no remainder exists
        return true
        }
        return false
    }
    
    func takeSmulle(handCard: Card) {
        var hcIndex = 1 // Set index to 1
        for hc in highlightedCards {
            // Check all highlighted cards for SMULLAR within themselves
            for _ in hcIndex..<highlightedCards.count {
                let h = highlightedCards[hcIndex]
                if h.rank == hc.rank && h.suit == hc.suit {
                    print("\(h.rank) of \(h.suit) == \(hc.rank) of \(hc.suit) is a SMULLE!")
                    activePlayer.smulleCards.append(h)
                    activePlayer.points += 5
                    //tableCards.hand.removeAtIndex(highlightedCards.indexOf(h)!)
                    break
                }
            }
            hcIndex += 1
            
            // Check for SMULLE with hand card
            if hc.rank == handCard.rank && hc.suit == handCard.suit {
                activePlayer.smulleCards.append(hc)
                activePlayer.points += 5
                //tableCards.hand.removeAtIndex(highlightedCards.indexOf(hc)!)
            }
        }
        
        print("\(activePlayer.name) HAR \(activePlayer.smulleCards.count) SMULLAR!")
    }
    
    func collectCards(cards: Array<Card>, player: Player) {
        
        // Loop through collected cards, insert them in stock and remove them from stack views and table hand
        for card in cards {
            player.stock.insert(card, atIndex: 0)
            //tableCardsStackView.removeArrangedSubview(card)
            tableCards.hand.removeAtIndex(tableCards.hand.indexOf(card)!)
            print("\(card.rank) of \(card.suit) taken!")
        }
        
        // If no cards exist on table you get a TABBE
        if tableCardsStackView.arrangedSubviews.count == 0 {
            player.points += 1
            print("TABBE!")
        }
        
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        
        updateView()
        print("\(activePlayer.name) has \(activePlayer.stock.count) cards in stock")
        
        // Move on to next player
        nextPlayer()
    }
    
    func updateView() {
        player1NameLabel.text = "\(player1.name): \(player1.points) p"
        player2NameLabel.text = "\(player2.name): \(player2.points) p"
        displayHandCards(player1)
        displayHandCards(player2)
        displayTableCards()
    }
    
    func nextPlayer() {
        if activePlayer.name == player1.name {
            activePlayer = player2
            print("Now it's \(activePlayer.name)'s turn!")
            playAI()
        } else if activePlayer.name == player2.name {
            activePlayer = player1
            print("Now it's \(activePlayer.name)'s turn!")
        }
        
        if activePlayer.hand.count == 0 {
            dealNewCards()
        }
    }
    
    func playAI() {
        // Check for SMULLE or cards with equal rank to collect. Else discard one card.
        var hcIndex = 0
        var handCard = Card(rank: .Ace, suit: .H) // Create dummy for handcard for use outside of handloop
        handLoop: for var hc in player2.hand {
            handCard = hc
            
            hcIndex = player2.hand.indexOf(hc)!
            for tc in tableCards.hand {
                if hc.rank == tc.rank && hc.suit == tc.suit { // Smulle?
                    highlightedCards.append(tc)
                    sumOfHighlightedCards += tc.rank.rawValue
                    hc = flipCard(hc)
                    
                    takeSmulle(hc) // Will append card to smulleCards
                    player2.hand.removeAtIndex(hcIndex) // ...and remove it from hand
                    player2StackView.removeArrangedSubview(hc)
                    break handLoop
                    
                } else if hc.rank == tc.rank { // Equal rank?
                    highlightedCards.append(tc)
                    sumOfHighlightedCards += tc.rank.rawValue
                    hc = flipCard(hc)
                    
                    player2.stock.append(hc) // Add chosen card from hand to stock
                    player2.hand.removeAtIndex(hcIndex) // ...and remove it from hand
                    break handLoop
                }
            }
            
        }
        
        if highlightedCards.count > 0 {
            print("\(player2.name) chose \(highlightedCards.count) cards from table")
            if cardsAreCorrectlyChosen(handCard) {
                collectCards(highlightedCards, player: player2)
            } else {
                print("Miscalculation?")
                print("handCard: \(handCard.rank) of \(handCard.suit)\n")
            }
        } else {
            print("\(player2.name) didn't find any cards to collect!")
            var disCard = player2.hand[0]
            disCard = flipCard(disCard)
            tableCards.hand.append(disCard)
            player2.hand.removeAtIndex(0)
            player2StackView.removeArrangedSubview(disCard)
            updateView()
            
            nextPlayer()
        }
        
    }
    
    func flipCard(card: Card) -> Card {
        card.cardImage = UIImage(named: "\(card.rank.simpleDescription())_\(card.suit)")
        card.cardImageView = UIImageView(image: card.cardImage)
        card.addShadow(card.cardImageView)
        card.frame.size.width = 200
        return card
    }
    
    func dealNewCards() {
        if decks.deck.count > 4 {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            player2.takeCardsFromDeck(4, fromDeck: decks)
        } else {
            tableCards.takeCardsFromDeck(4, fromDeck: decks)
            // New round
            
        }
        updateView()
    }

}

