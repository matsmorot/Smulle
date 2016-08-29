//
//  ViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var player2StackView: UIStackView!
    @IBOutlet weak var tableCardsStackView: UIStackView!
    @IBOutlet weak var player1StackView: UIStackView!
    @IBOutlet weak var player1StockView: UIStackView!
    @IBOutlet weak var player2StockView: UIStackView!
    @IBOutlet weak var player1StockAndSmulleView: UIStackView!
    @IBOutlet weak var player1SmulleView: UIStackView!
    @IBOutlet weak var player2SmulleView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player2NameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var deckHolder: UIView = UIView()
    var cardHolderIsActive = false
    var numberOfRounds = 4
    var sumOfHighlightedCards = 0
    var highlightedCards: Array<Card> = []
    let player1 = Player(name: "You", faceUpCards: true)
    let player2 = Player(name: "Komp Jutah", faceUpCards: false)
    var players: Array<Player> = []
    var activePlayer: Player = Player(name: "Dummy", faceUpCards: false)
    let tableCards = CardHolder()
    var deckPosition = CGPoint(x: 0, y: 0)
    var lastPlayerToCollectCards: Player = Player(name: "Dummy", faceUpCards: false)
    var playersNumberOfSpades: [Player : Int] = [:]
    
    var decks: Deck = Deck(numDecks: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.setBackgroundImage(UIImage(named: "top_bar"), forBarMetrics: UIBarMetrics.Default)
        pointsLabel.alpha = 0
        
        // Assign stack views to players
        player1.stackView = player1StackView
        player1.stockView = player1StockView
        player1.smulleView = player1SmulleView
        player2.stackView = player2StackView
        player2.stockView = player2StockView
        player2.smulleView = player2SmulleView
        
        player1.stockView.spacing = -50.5
        player2.stockView.spacing = -50.5
        
        
        // Populate variable players with players
        players = [player1, player2]
        
        // Select initial dealer, manually for now
        player2.isDealer = true
        
        // Start game
        beginNewRound()
        
        // Debugging
        
        //let testCard = Card(rank: .Queen, suit: .H)
        
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
        
        if player2.isDealer {
            let startY = navigationBar.frame.height + 25
            deckHolder.frame.origin.y = startY
            deckHolder.frame.origin.x = view.layoutMargins.left
        } else if player1.isDealer {
            let startY = view.frame.height - 125
            deckHolder.frame.origin.y = startY
            deckHolder.frame.origin.x = view.layoutMargins.left
        }
        
        view.addSubview(deckHolder)
        
        for card in decks.deck {
            card.cardImageView = UIImageView(image: card.cardImageBack)
            
            //let tap = UITapGestureRecognizer(target: self, action: #selector(testCardTapped(_:)))
            card.userInteractionEnabled = true
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            //card.addGestureRecognizer(tap)
            card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
            
            card.addSubview(card.cardImageView)
            deckHolder.addSubview(card)
            card.origin = card.frame.origin
        }
        deckPosition = CGPoint(x: deckHolder.frame.origin.x, y: deckHolder.frame.origin.y)
        print("deckPosition: \(deckPosition)")
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
        // Prepare stockviews for new display of the cards by clearing them
        player.stockView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for card in player.hand {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cardLongPressed(_:)))
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(cardSwipedUp(_:)))
            swipeUp.direction = .Up
            
            if player.faceUpCards {
                card.userInteractionEnabled = true
                card.addGestureRecognizer(tap)
                card.addGestureRecognizer(swipeUp)
            }
            
            card.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            card.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            
            card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
            card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
            
            card.addSubview(card.cardImageView)
            
            player.stackView.addArrangedSubview(card)
        }
        
        // Show stock cards. Also has to be tappable.
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
    
    func cardTapped(sender: UITapGestureRecognizer) { // Tappee will always be player1
        
        let card = sender.view as! Card
        
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
                card.layer.shadowRadius = 0
                card.highlighted = false
                
                sumOfHighlightedCards -= card.rank.rawValue
                highlightedCards.removeAtIndex(highlightedCards.indexOf(card)!)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            }
        } else {
            if highlightedCards.count > 0 {
                if cardsAreCorrectlyChosen(card) {
                    
                    takeSmulle(card) // Check for smulle
                    player1.stock.append(card)
                    player1.points += card.getCardPoints(card)
                    animatePointsTaken(card.getCardPoints(card), origin: card.center)
                    
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!) // ...and remove it from hand
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.indexOf(card)!].removeFromSuperview()
                    
                    collectCards(highlightedCards, player: player1)
                    
                } else {
                    print("Chosen cards do not match your hand card!")
                }
            } else {
                
                // If same card in hand as top card in stock, you can take a smulle with that
                if player1.stock.last?.rank == card.rank && player1.stock.last?.suit == card.suit {
                    player1.smulleCards.append(card)
                    player1.points += card.getCardPoints(card) + 5
                    animatePointsTaken(card.getCardPoints(card) + 5, origin: card.center)
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.indexOf(card)!].removeFromSuperview()
                    nextPlayer()
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if player2.stock.last?.rank == card.rank && player2.stock.last?.suit == card.suit {
                    player1.smulleCards.append(card)
                    for card in player2.stock {
                        player1.stock.insert(card, atIndex: 0)
                        player1.points += card.getCardPoints(card)
                        animatePointsTaken(card.getCardPoints(card), origin: card.center)
                        player2.points -= card.getCardPoints(card)
                    }
                    player2.stock.removeAll()
                    player1.smulleCards.append(card)
                    player1.points += card.getCardPoints(card) + 5
                    player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.indexOf(card)!].removeFromSuperview()
                    nextPlayer()
                    
                } else {
                    print("Choose table cards first!")
                    
                }
                
            }
        }
    }
    
    func cardSwipedUp(sender: UISwipeGestureRecognizer) {
        let card = sender.view as! Card
        UIView.animateWithDuration(0.3, delay: 0, options: [], animations: {
            
            card.center = card.convertPoint(card.center, toView: self.view)
            
            }, completion: nil)
        
        card.gestureRecognizers?.removeAll()
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        
        card.userInteractionEnabled = true
        card.addGestureRecognizer(tap)
        card.heightAnchor.constraintEqualToConstant(card.cardImageView.frame.height).active = true
        card.widthAnchor.constraintEqualToConstant(card.cardImageView.frame.width).active = true
        
        tableCards.hand.append(card)
        player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
        tableCardsStackView.addArrangedSubview(card)
        
        // If there are cards chosen when you discard, put them back and remove from highlightedCards
        if highlightedCards.count > 0 {
            for card in highlightedCards {
                card.frame.offsetInPlace(dx: 0, dy: 20)
                card.layer.shadowRadius = 0
                card.highlighted = false
            }
            highlightedCards.removeAll()
        }
        
        nextPlayer()
    }
    
    func cardLongPressed(sender: UILongPressGestureRecognizer) {
        print("LongPress!")
        let card = sender.view as! Card
        
        if sender.state == .Began {
            
            UIView.animateWithDuration(0.3, delay: 0.5, options: [], animations: {
                
                card.frame.origin = self.player1StackView.frame.origin
                
                }, completion: nil)
            
            tableCards.hand.append(card)
            player1.hand.removeAtIndex(player1.hand.indexOf(card)!)
            
            nextPlayer()
            
        } else if sender.state == .Ended {
            print("LongPress ended!")
        }
    }
    
    func cardsAreCorrectlyChosen(handCard: Card) -> Bool {
        
        for card in highlightedCards {
            if card.rank.rawValue > handCard.rank.rawValue { // hand card has to be greater than or eq to each table card chosen
                return false
            }
        }
        
        if sumOfHighlightedCards == handCard.rank.rawValue || // x number of cards equals hand card, OR
            sumOfHighlightedCards / highlightedCards.count == handCard.rank.rawValue || // ...x number of equal values equals hand card, OR
            sumOfHighlightedCards % handCard.rank.rawValue == 0 { // ...no remainder exists
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
                    
                    activePlayer.points += h.getCardPoints(h) + 5
                    
                    animatePointsTaken(h.getCardPoints(h) + 5, origin: h.origin)
                    
                }
            }
            hcIndex += 1
            
            // Check for SMULLE with hand card
            if hc.rank == handCard.rank && hc.suit == handCard.suit {
                
                activePlayer.smulleCards.append(hc)
                //highlightedCards.removeAtIndex(highlightedCards.indexOf(hc)!)
                //tableCards.hand.removeAtIndex(tableCards.hand.indexOf(hc)!)
                
                activePlayer.points += hc.getCardPoints(hc) + 5
                
                animatePointsTaken(hc.getCardPoints(hc) + 5, origin: hc.origin)
                
            }
        }
        
    }
    
    func collectCards(cards: Array<Card>, player: Player) {
        
        var delay = 0.1
        var cardPoints = 0
        var cardOrigin = CGPointZero
        
        // Loop through collected cards, insert them in stock and remove them from table hand
        for card in cards {
            
            UIView.animateWithDuration(0.3, delay: delay, options: [], animations: {
                
                card.center = self.tableCardsStackView.center
                
                }, completion: nil)
            
            card.layer.shadowRadius = 0
            player.stock.insert(card, atIndex: 0)
            tableCards.hand.removeAtIndex(tableCards.hand.indexOf(card)!)
            
            cardPoints += card.getCardPoints(card)
            cardOrigin = card.origin
            
            delay += 0.1
            lastPlayerToCollectCards = player
            print("\(card.rank) of \(card.suit) taken! \(card.getCardPoints(card)) points! Origin: \(card.frame.origin)")
        }
        
        player.points += cardPoints
        if cardPoints > 0 {
            animatePointsTaken(cardPoints, origin: cardOrigin)
        }
        
        // If no cards exist on table you get a TABBE
        if tableCards.hand.count == 0 {
            player.points += 1
            
            pointsLabel.center = self.view.center
            pointsLabel.text = "TABBE, +1"
            pointsLabel.alpha = 1
            pointsLabel.transform = CGAffineTransformMakeScale(1, 1)
            
            UIView.animateWithDuration(2, animations: {
                self.pointsLabel.alpha = 0
                self.pointsLabel.center.y -= 200
                self.pointsLabel.transform = CGAffineTransformMakeScale(4, 4)
            })
            
            print("TABBE!")
        }
        
        //updateView()
        print("\(activePlayer.name) has \(activePlayer.stock.count) cards in stock\n")
        print("\(tableCardsStackView.arrangedSubviews.count) cards on table")
        
        // Move on to next player
        nextPlayer()
        
    }
    
    func updateView() {
        
        self.player1NameLabel.text = "\(self.player1.name): \(self.player1.points) p (\(self.player1.smulleCards.count) smullar)"
        self.player2NameLabel.text = "\(self.player2.name): \(self.player2.points) p (\(self.player2.smulleCards.count) smullar)"
        self.displayHandCards(self.player1)
        self.displayHandCards(self.player2)
        self.displayTableCards()
        
        print("\(decks.deck.count) cards left in decks.")
        print(player1.smulleCards.count + player1.hand.count + player1.stock.count + player2.smulleCards.count + player2.hand.count + player2.stock.count + tableCards.hand.count + decks.deck.count)
    }
    
    func nextPlayer() {
        // Only for two players for the moment
        
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        
        nextPlayerLoop: if activePlayer.name == player1.name {
            activePlayer = player2
            if player2.hand.count > 0 {
                print("Now it's \(activePlayer.name)'s turn!")
                playAI()
            } else if decks.deck.count == 0 && activePlayer.hand.count == 0 {
                endRound()
                beginNewRound()
                break nextPlayerLoop
            } else {
                print("Now it's \(activePlayer.name)'s turn!")
                dealNewCards()
                playAI()
            }
        } else if activePlayer.name == player2.name {
            activePlayer = player1
            print("Now it's \(activePlayer.name)'s turn!")
        }
        
        if activePlayer.hand.count == 0 && decks.deck.count > 0 {
            dealNewCards()
        } else if decks.deck.count == 0 && activePlayer.hand.count == 0 {
            endRound()
            beginNewRound()
        }
        updateView()
    }
    
    func playAI() {
        // Check for SMULLE or cards with equal rank to collect. Else discard one card.
        var hcIndex = 0
        var handCard = Card(rank: .Ace, suit: .H) // Create dummy for handcard for use outside of handloop
        handLoop: for hc in player2.hand {
            handCard = hc
            
            hcIndex = player2.hand.indexOf(hc)!
            tableLoop: for tc in tableCards.hand {
                if hc.rank == tc.rank && hc.suit == tc.suit { // Smulle?
                    highlightedCards.append(tc)
                    sumOfHighlightedCards += tc.rank.rawValue
                    
                    takeSmulle(hc) // Will append card to smulleCards
                    
                    player2.hand.removeAtIndex(hcIndex) // ...and remove it from hand
                    player2StackView.removeArrangedSubview(hc)
                    player2StackView.subviews[hcIndex].removeFromSuperview()
                    
                    break handLoop
                    
                } else if hc.rank == tc.rank { // Equal rank?
                    highlightedCards.append(tc)
                    sumOfHighlightedCards += tc.rank.rawValue
                    
                    flipCard(hc)
                    
                    player2.stock.append(hc) // Add chosen card from hand to stock
                    player2.hand.removeAtIndex(hcIndex) // ...and remove it from hand
                    player2.points += hc.getCardPoints(hc)
                    
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
            let cardIndexToDiscard = findCardIndexToDiscard(player2.hand)
            let disCard = player2.hand[cardIndexToDiscard]
            flipCard(disCard)
            //tableCardsStackView.addArrangedSubview(disCard)
            tableCards.hand.append(disCard)
            player2.hand.removeAtIndex(cardIndexToDiscard)
            
            updateView()
            nextPlayer()
        }
        
    }
    
    
    
    func dealNewCards() {
        // If in play, give cards to players
        if decks.deck.count > 12 && decks.deck.count < 104 {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            for card in player1.hand {
                flipCard(card)
            }
            player2.takeCardsFromDeck(4, fromDeck: decks)
        // If deck is new or there are less than 12 cards left, deal to players and table
        } else {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            for card in player1.hand {
                flipCard(card)
            }
            player2.takeCardsFromDeck(4, fromDeck: decks)
            
            tableCards.takeCardsFromDeck(4, fromDeck: decks)
            
            for card in tableCards.hand {
                if !card.faceUp {
                    flipCard(card)
                }
            }
        }
        
        updateView()
    }
    
    func findCardIndexToDiscard(cards: Array<Card>) -> Int {
        var values: Array<Int> = []
        for card in cards {
            if card.getCardPoints(card) > 0 {
                values.append(15) // If card has points, make sure it will be picked last
            } else {
                values.append(card.rank.rawValue)
            }
        }
        let minValueIndex = values.indexOf(values.minElement()!)
        return minValueIndex!
    }
    
    func flipCard(card: Card) {
        
        let back = UIImageView(image: card.cardImageBack)
        let front = UIImageView(image: card.cardImage)
        
        if card.faceUp == true {
            
            card.addSubview(back)
            UIView.transitionFromView(card.cardImageView, toView: back, duration: 0.5, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (finished: Bool) -> Void in
            
                
            
            })
            card.faceUp = false
            print("Card flipped from front to back! \(card.faceUp)")
        } else {
            
            card.addSubview(front)
            UIView.transitionFromView(card.cardImageView, toView: front, duration: 0.5, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (finished: Bool) -> Void in
                
                // Should something happen after card has been flipped?
                
            })
            card.addBorder(card)
            card.faceUp = true
            print("Card flipped from back to front! \(card.faceUp)")
        }
        
    }
    
    func animatePointsTaken(points: Int, origin: CGPoint) {
        if points > 0 {
            pointsLabel.center = origin
            pointsLabel.text = "+\(points)"
            pointsLabel.alpha = 1
            pointsLabel.transform = CGAffineTransformMakeScale(1, 1)
        
            UIView.animateWithDuration(2, delay: 0, options: [], animations: {
                self.pointsLabel.alpha = 0
                self.pointsLabel.center.y -= 200
                self.pointsLabel.transform = CGAffineTransformMakeScale(4, 4)
                }, completion: nil)
        }
    }
    
    func beginNewRound() {
        roundLabel.text = "Rounds left: \(numberOfRounds)"
        
        decks = Deck(numDecks: 2)
        
        decks.shuffleDeck()
        
        changeDealer()
        
        // Show deck next to the player who is currently dealer (needs improvement)
        showDeck()
        
        // Deal cards
        dealNewCards()
        
        if activePlayer.name == player2.name {
            print("\(activePlayer.name) will start!")
            playAI()
        } else if activePlayer.name == player1.name {
            print("\(activePlayer.name) will start!")
        }
    }
    
    func endRound() {
        
        // The leftover cards on table are given to the player who were last to collect cards
        if tableCards.hand.count > 0 {
            for card in tableCards.hand {
                lastPlayerToCollectCards.hand.append(card)
                lastPlayerToCollectCards.points += card.getCardPoints(card)
                animatePointsTaken(card.getCardPoints(card), origin: card.center)
            }
            lastPlayerToCollectCards.points += 1
            animatePointsTaken(1, origin: self.view.center)
        }
        
        // The player with the most spades in stock will get 6 points
        for player in players {
            for card in player.stock {
                if card.suit == Card.Suit.S {
                    player.numberOfSpades += 1
                }
            }
            playersNumberOfSpades[player] = player.numberOfSpades
        }
        
        var largest = 0
        var playerWithMostSpades: Player = Player(name: "Dummy", faceUpCards: false)
        for (player, value) in playersNumberOfSpades {
            if value > largest {
                largest = value
                playerWithMostSpades = player
            }
        }
        
        print("\(playerWithMostSpades.name) has got the most spades!")
        playerWithMostSpades.points += 6
        animatePointsTaken(6, origin: self.view.center)
        
        // Clear the table and hands
        tableCards.hand.removeAll()
        player1.hand.removeAll()
        player1.stock.removeAll()
        player1.smulleCards.removeAll()
        player2.hand.removeAll()
        player2.stock.removeAll()
        player2.smulleCards.removeAll()
        decks.deck.removeAll()
        
        tableCardsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        player1SmulleView.subviews.forEach({ $0.removeFromSuperview() })
        player1StackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        player1StockView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        player2SmulleView.subviews.forEach({ $0.removeFromSuperview() })
        player2StackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        player2StockView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        numberOfRounds -= 1
        roundLabel.text = "Rounds left: \(numberOfRounds)"
        updateView()
    }
    
    func changeDealer() {
        // Repeat through players to choose dealer
        for i in 0..<players.count {
            if players[i].isDealer {
                players[i].isDealer = false
                if i < (players.count-1) {
                    players[i + 1].isDealer = true
                } else {
                    players[0].isDealer = true
                }
            break
            }
        }
        for i in 0..<players.count {
            // Set the player after the dealer to be first to act
            if players[i].isDealer {
                if i < (players.count-1) {
                    activePlayer = players[i + 1]
                } else {
                    activePlayer = players[0]
                }
            }
        }
        
    }

}

