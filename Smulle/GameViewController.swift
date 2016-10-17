//
//  GameViewController.swift
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
    @IBOutlet weak var toolBar: UIToolbar!
    @IBAction func helpButton(_ sender: UIBarButtonItem) {
        presentRulesCard()
    }
    
    var deckHolder = UIView()
    var rulesCard = UIView()
    let rulesTextView = UITextView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
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
    var timer = Timer()
    var tapCount = 0
    
    var decks: Deck = Deck(numDecks: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationBar.setBackgroundImage(UIImage(named: "top_bar"), for: UIBarMetrics.default)
        toolBar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        
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
        
        
        // Populate array players with players
        players = [player1, player2]
        
        // Select initial dealer, manually for now
        player2.isDealer = true
        
        // Start game
        beginNewRound()
        
        // Debugging
        print(rulesCard.bounds)
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
        
        if self.view.frame.width > 320.0 {
            if player2.isDealer {
                let startY = navigationBar.frame.height + 25
                deckHolder.frame.origin.y = startY
                deckHolder.frame.origin.x = view.layoutMargins.left
            } else if player1.isDealer {
                let startY = view.frame.height - 125
                deckHolder.frame.origin.y = startY
                deckHolder.frame.origin.x = view.layoutMargins.left
            }
            
        } else {
            deckHolder.isHidden = true
        }
        
        view.addSubview(deckHolder)
        
        for card in decks.deck {
            card.cardImageView = UIImageView(image: card.cardImageBack)
            
            card.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
            card.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            
            card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
            
            card.addSubview(card.cardImageView)
            deckHolder.addSubview(card)
        }
        
        deckPosition = CGPoint(x: deckHolder.frame.origin.x, y: deckHolder.frame.origin.y)
        print("deckPosition: \(deckPosition)")
    }
    
    func displayTableCards() {
        
        for card in tableCards.hand {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.isUserInteractionEnabled = true
            card.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
            card.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
            card.addSubview(card.cardImageView)
            tableCardsStackView.addArrangedSubview(card)
        }
        
    }

    func displayHandCards(_ player: Player) {
        // Prepare stockviews for new display of the cards by clearing them
        player.stockView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for card in player.hand {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(cardSwipedUp(_:)))
            swipeUp.direction = .up
            
            if player.faceUpCards {
                card.isUserInteractionEnabled = true
                card.addGestureRecognizer(tap)
                card.addGestureRecognizer(swipeUp)
            }
            
            card.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
            card.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            
            card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
            
            card.addSubview(card.cardImageView)
            
            player.stackView.addArrangedSubview(card)
        }
        
        // Show stock cards
        for card in player.stock {
            
            card.gestureRecognizers?.removeAll() // Remove gestures
            
            player.stockView.addArrangedSubview(card)
        }
        
        // Show top Smulle card, cropped, to save space
        if player.smulleCards.count > 0 {
            let lastCard = player.smulleCards.last
            let cardImage = UIImageView(image: lastCard!.cardImage)
            player.smulleView.contentMode = UIViewContentMode.top
            player.smulleView.clipsToBounds = true
            player.smulleView.frame.size.height = cardImage.frame.height / 3
            player.smulleView.frame.origin.x = cardImage.frame.origin.x
            player.smulleView.frame.origin.y = cardImage.frame.origin.y
            
            cardImage.contentMode = UIViewContentMode.top
            cardImage.clipsToBounds = true
            cardImage.frame.size.height = cardImage.frame.height / 3
            
            player.smulleView.addSubview(cardImage)
        }
        
    }
    
    func cardTapped(_ sender: UITapGestureRecognizer) { // Tappee will always be player1
        
        let card = sender.view as! Card
        
        // Card selection
        if tableCardsStackView.arrangedSubviews.contains(card) {
            if card.isHighlighted == false {
                
                // Move tapped card 20p up and increase shadow
                card.frame = card.frame.offsetBy(dx: 0.0, dy: -20.0)
                card.layer.shadowOpacity = 0.6
                card.layer.shadowOffset = CGSize.zero
                card.layer.shadowRadius = 5
                card.isHighlighted = true
                
                sumOfHighlightedCards += card.rank.rawValue
                highlightedCards.append(card)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
                
            } else if card.isHighlighted == true {
                
                // Move tapped card 20p down and decrease shadow
                card.frame = card.frame.offsetBy(dx: 0.0, dy: 20.0)
                card.layer.shadowRadius = 0
                card.isHighlighted = false
                
                sumOfHighlightedCards -= card.rank.rawValue
                highlightedCards.remove(at: highlightedCards.index(of: card)!)
                
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
                    
                    player1.hand.remove(at: player1.hand.index(of: card)!) // ...and remove it from hand
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    
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
                    player1.hand.remove(at: player1.hand.index(of: card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    nextPlayer()
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if player2.stock.last?.rank == card.rank && player2.stock.last?.suit == card.suit {
                    player1.stock.append(card)
                    player2.stock.removeLast()
                    for card in player2.stock {
                        player1.stock.insert(card, at: 0)
                        player1.points += card.getCardPoints(card)
                        animatePointsTaken(card.getCardPoints(card), origin: card.center)
                        player2.points -= card.getCardPoints(card)
                    }
                    player2.stock.removeAll()
                    player1.smulleCards.append(card)
                    player1.points += card.getCardPoints(card) + 5
                    player1.hand.remove(at: player1.hand.index(of: card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    nextPlayer()
                    
                } else {
                    tapCount += 1
                    if tapCount == 3 {
                        
                        UIView.animate(withDuration: 0.2, delay: 0, options: [.autoreverse], animations: {
                            self.tableCardsStackView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            }, completion: { (finished: Bool) -> Void in
                                self.tableCardsStackView.transform = CGAffineTransform(scaleX: 1, y: 1)
                            })
                        
                        print("Choose table cards first!")
                        tapCount = 0
                    }
                }
            }
        }
    }
    
    func cardSwipedUp(_ sender: UISwipeGestureRecognizer) {
        let card = sender.view as! Card
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            
            card.center = self.view.center
            
            }, completion: nil)
        
        card.gestureRecognizers?.removeAll()
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(tap)
        card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
        card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
        
        tableCards.hand.append(card)
        player1.hand.remove(at: player1.hand.index(of: card)!)
        tableCardsStackView.addArrangedSubview(card)
        
        // If there are cards chosen when you discard, put them back and remove from highlightedCards
        if highlightedCards.count > 0 {
            for card in highlightedCards {
                card.frame.offsetBy(dx: 0, dy: 20)
                card.layer.shadowRadius = 0
                card.isHighlighted = false
            }
            highlightedCards.removeAll()
        }
        
        nextPlayer()
    }
    
    func cardsAreCorrectlyChosen(_ handCard: Card) -> Bool {
        var handCardValue = 0
        
        if handCard.rank.rawValue == 1 { // If handCard is an ace, change value to 14
            handCardValue = handCard.rank.changeAceValue().rawValue
        } else {
            handCardValue = handCard.rank.rawValue
        }
        
        for card in highlightedCards {
            if card.rank == handCard.rank && card.suit == handCard.suit && card.rank.rawValue == 1 { // If the card is a Smulle, it's OK to take ace with an ace
                sumOfHighlightedCards += (-1+14) // Make the table ace value 14 instead of 1
                //handCardValue = handCard.rank.rawValue
            }
            if card.rank.rawValue > handCardValue { // hand card has to be greater than or eq to each table card chosen
                return false
            }
        }
        
        if sumOfHighlightedCards == handCardValue || // x number of cards equals hand card, OR
            sumOfHighlightedCards / highlightedCards.count == handCardValue || // ...x number of equal values equals hand card, OR
            sumOfHighlightedCards % handCardValue == 0 { // ...no remainder exists
        return true
        }
    return false
    }
    
    func takeSmulle(_ handCard: Card) {
        
        var hcIndex = 1 // Set index to 1
        for hc in highlightedCards {
            // Check all highlighted cards for SMULLAR within themselves
            for _ in hcIndex..<highlightedCards.count {
                let h = highlightedCards[hcIndex]
                if h.rank == hc.rank && h.suit == hc.suit {
                    print("\(h.rank) of \(h.suit) == \(hc.rank) of \(hc.suit) is a SMULLE!")
                    activePlayer.smulleCards.append(h)
                    highlightedCards.remove(at: hcIndex)
                    tableCards.hand.remove(at: tableCards.hand.index(of: h)!)
                    tableCardsStackView.arrangedSubviews[tableCardsStackView.arrangedSubviews.index(of: h)!].removeFromSuperview()
                    
                    activePlayer.points += h.getCardPoints(h) + 5
                    
                    animatePointsTaken(h.getCardPoints(h) + 5, origin: h.frame.origin)
                    
                }
            }
            
            if hcIndex < highlightedCards.count {
                hcIndex += 1
            }
            
            // Check for SMULLE with hand card
            if hc.rank == handCard.rank && hc.suit == handCard.suit {
                
                activePlayer.smulleCards.append(hc)
                highlightedCards.remove(at: highlightedCards.index(of: hc)!)
                tableCards.hand.remove(at: tableCards.hand.index(of: hc)!)
                tableCardsStackView.arrangedSubviews[tableCardsStackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                
                activePlayer.points += hc.getCardPoints(hc) + 5
                
                animatePointsTaken(hc.getCardPoints(hc) + 5, origin: hc.frame.origin)
                
            }
        }
        
    }
    
    func collectCards(_ cards: Array<Card>, player: Player) {
        
        var delay = 0.5
        var cardPoints = 0
        var cardOrigin = CGPoint.zero
        
        // Loop through collected cards, insert them in stock and remove them from table hand
        for card in cards {
            
            UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: {
                
                card.center = self.tableCardsStackView.center
                
                }, completion: nil)
            
            card.layer.shadowRadius = 0
            player.stock.insert(card, at: 0)
            tableCards.hand.remove(at: tableCards.hand.index(of: card)!)
            
            cardPoints += card.getCardPoints(card)
            cardOrigin = card.frame.origin
            
            delay += 0.1
            lastPlayerToCollectCards = player
            print("\(card.rank) of \(card.suit) taken! \(card.getCardPoints(card)) points! Origin: \(card.frame.origin)")
        }
        
        // If no cards exist on table you get a TABBE
        if tableCards.hand.count == 0 {
            cardPoints += 1
            player.numberOfTabbeCards += 1
            
            animatePointsTaken(1, origin: self.view.center)
            
            print("TABBE!")
        }
        
        player.points += cardPoints
        if cardPoints > 0 {
            animatePointsTaken(cardPoints, origin: cardOrigin)
        }
        
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
        // Only for two players at the moment
        
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        
        nextPlayerLoop: if activePlayer == player1 {
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
        } else if activePlayer == player2 {
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
        
        var tookCards = false
        
        // Check for SMULLE or cards with equal rank to collect. Else discard one card.
        var hcIndex = 0
        var handCard = Card(rank: .ace, suit: .h) // Create dummy for handcard for use outside of handloop
        handLoop: for hc in player2.hand {
            handCard = hc
            
            hcIndex = player2.hand.index(of: hc)!
            tableLoop: for tc in tableCards.hand {
                
                // If same card in hand as top card in stock, you can take a smulle with that
                if player2.stock.last?.rank == hc.rank && player2.stock.last?.suit == hc.suit {
                    player2.smulleCards.append(hc)
                    player2.points += hc.getCardPoints(hc) + 5
                    animatePointsTaken(hc.getCardPoints(hc) + 5, origin: hc.center)
                    player2.hand.remove(at: player2.hand.index(of: hc)!)
                    player2StackView.arrangedSubviews[player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    tookCards = true
                    print("Player2 took a smulle with top card of stock")
                    break handLoop
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if player1.stock.last?.rank == hc.rank && player1.stock.last?.suit == hc.suit {
                    flipCard(hc)
                    player2.stock.append(hc)
                    player1.stock.removeLast()
                    for card in player1.stock {
                        player2.stock.insert(card, at: 0)
                        player2.points += card.getCardPoints(card)
                        animatePointsTaken(card.getCardPoints(card), origin: card.center)
                        player1.points -= card.getCardPoints(card)
                    }
                    player1.stock.removeAll()
                    player2.smulleCards.append(hc)
                    player2.points += hc.getCardPoints(hc) + 5
                    animatePointsTaken(hc.getCardPoints(hc) + 5, origin: hc.center)
                    player2.hand.remove(at: player2.hand.index(of: hc)!)
                    player2StackView.arrangedSubviews[player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    
                    tookCards = true
                    print("Player2 took your stock with \(hc.rank.rawValue) of \(hc.suit)!")
                    break handLoop
                    
                } else if hc.rank == tc.rank && hc.suit == tc.suit { // Smulle?
                    
                    player2.smulleCards.append(tc)
                    player2.points += tc.getCardPoints(tc) + 5
                    animatePointsTaken(tc.getCardPoints(tc) + 5, origin: tc.center)
                    tableCards.hand.remove(at: tableCards.hand.index(of: tc)!)
                    tableCardsStackView.arrangedSubviews[tableCardsStackView.arrangedSubviews.index(of: tc)!].removeFromSuperview()
                    flipCard(hc)
                    player2.stock.append(hc)
                    player2.points += hc.getCardPoints(hc)
                    animatePointsTaken(hc.getCardPoints(hc), origin: hc.center)
                    player2.hand.remove(at: hcIndex) // ...and remove it from hand
                    player2StackView.arrangedSubviews[player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    
                    tookCards = true
                    print("Player2 took a smulle!")
                    break handLoop
                    
                } else if hc.rank == tc.rank && hc.rank.rawValue != 1 { // Equal rank, but not an ace?
                    highlightedCards.append(tc)
                    sumOfHighlightedCards += tc.rank.rawValue
                    
                    flipCard(hc)
                    
                    player2.stock.append(hc) // Add chosen card from hand to stock
                    player2.hand.remove(at: hcIndex) // ...and remove it from hand
                    player2.points += hc.getCardPoints(hc)
                    animatePointsTaken(hc.getCardPoints(hc), origin: hc.center)
                    
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
        
        } else if !tookCards {
            print("\(player2.name) didn't find any cards to collect!")
            let cardIndexToDiscard = findCardIndexToDiscard(player2.hand)
            let disCard = player2.hand[cardIndexToDiscard]
            flipCard(disCard)
            
            //tableCardsStackView.addArrangedSubview(disCard)
            tableCards.hand.append(disCard)
            player2.hand.remove(at: cardIndexToDiscard)
            
            //updateView()
            nextPlayer()
        } else {
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
            for card in player2.hand {
                if card.faceUp {
                    flipCard(card)
                }
            }
        // If deck is new or there are less than 12 cards left, deal to players and table
        } else {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            for card in player1.hand {
                flipCard(card)
            }
            player2.takeCardsFromDeck(4, fromDeck: decks)
            for card in player2.hand {
                if card.faceUp {
                    flipCard(card)
                }
            }
            
            tableCards.takeCardsFromDeck(4, fromDeck: decks)
            for card in tableCards.hand {
                if !card.faceUp {
                    flipCard(card)
                }
            }
        }
        
        updateView()
    }
    
    func findCardIndexToDiscard(_ cards: Array<Card>) -> Int {
        var values: Array<Int> = []
        for card in cards {
            if card.getCardPoints(card) > 0 {
                values.append(15) // If card has points, make sure it will be picked last
            } else {
                values.append(card.rank.rawValue)
            }
        }
        let minValueIndex = values.index(of: values.min()!)
        return minValueIndex!
    }
    
    func findCardIndexToUse(_ cards: Array<Card>) -> Int {
        // If card has points, make sure it will be picked first
        var values: Array<Int> = []
        for card in cards {
            if card.getCardPoints(card) == 1 {
                values.append(15)
            } else if card.getCardPoints(card) == 2 {
                values.append(16)
            } else {
                values.append(card.rank.rawValue)
            }
        }
        let maxValueIndex = values.index(of: values.max()!)
        return maxValueIndex!
    }
    
    func flipCard(_ card: Card) {
        
        let back = UIImageView(image: card.cardImageBack)
        let front = UIImageView(image: card.cardImage)
        
        if card.faceUp == true {
            
            card.addSubview(back)
            UIView.transition(from: card.cardImageView, to: back, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
            
                // Should something happen after card has been flipped?
            
            })
            card.faceUp = false
            print("Card flipped from front to back! \(card.faceUp)")
        } else {
            
            card.addSubview(front)
            UIView.transition(from: card.cardImageView, to: front, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
                
                // Should something happen after card has been flipped?
                
            })
            card.addBorder(card)
            card.faceUp = true
            print("Card flipped from back to front! \(card.faceUp)")
        }
        
    }
    
    func animatePointsTaken(_ points: Int, origin: CGPoint) {
        
        var delay = 0.1
        
        if activePlayer == player2 {
            pointsLabel.textColor = UIColor.red
        } else {
            pointsLabel.textColor = UIColor.green
        }
        
        if points > 0 {
            pointsLabel.center = origin
            pointsLabel.text = "+\(points)"
            pointsLabel.alpha = 1
            pointsLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        
            UIView.animate(withDuration: 2, delay: delay, options: [], animations: {
                self.pointsLabel.alpha = 0
                //self.pointsLabel.center.y -= 200
                self.pointsLabel.transform = CGAffineTransform(scaleX: 20, y: 20)
                }, completion: { (finished: Bool) -> Void in
                    delay += 0.1
            })
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
        
        if activePlayer == player2 {
            print("\(activePlayer.name) will start!")
            playAI()
        } else if activePlayer == player1 {
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
            lastPlayerToCollectCards.points += 1 // Tabbe
            lastPlayerToCollectCards.numberOfTabbeCards += 1
            animatePointsTaken(1, origin: self.view.center)
        }
        
        // The player with the most spades in stock will get 6 points
        for player in players {
            for card in player.stock {
                if card.suit == Card.Suit.s {
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
        
        // Sanity check. Should add up to 20.
        var totalCardPoints = 0
        totalCardPoints = player1.points - player1.numberOfTabbeCards - (player1.smulleCards.count * 5) + player2.points - player2.numberOfTabbeCards - (player2.smulleCards.count * 5)
        print("Total card points of round: \(totalCardPoints)")
        
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
    
    
    func createRulesCard() {
        
        rulesCard.frame = CGRect(origin: CGPoint(x: self.view.frame.width, y: 10), size: CGSize(width: view.frame.width - 20, height: view.frame.height - 20))
        let tap = UITapGestureRecognizer(target: self, action: #selector(rulesCardTapped(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rulesCardSwipedRight(_:)))
        swipeRight.direction = .right
        rulesCard.addGestureRecognizer(tap)
        rulesCard.addGestureRecognizer(swipeRight)
        
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
        
        rulesCard.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20)
        blurView.frame = rulesCard.bounds
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.alpha = 0.97
        
        rulesCard.layer.cornerRadius = 20
        
        if #available(iOS 10.0, *) {
            
        } else {
            rulesCard.alpha = 0.97 // defining alpha < 1 will break blur effect in iOS10
        }
        view.addSubview(rulesCard)
        print(rulesCard.bounds)
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

    
    func presentRulesCard() {
        createRulesCard()
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.rulesCard.frame.origin = CGPoint(x: 10, y: 10)
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
    
    func rulesCardTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.rulesCard.frame.origin = CGPoint(x: self.view.frame.width, y: 10)
            self.rulesTextView.frame = self.rulesCard.frame
            }, completion: { (finished: Bool) -> Void in
                
                self.rulesCard.subviews.forEach({ $0.removeFromSuperview() })
                self.rulesCard.removeFromSuperview()
        })
    }
    
}

