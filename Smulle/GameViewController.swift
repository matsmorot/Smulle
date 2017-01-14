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
    @IBOutlet weak var infoLabel: UILabel!
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
    var pointsToAnimate: Array<Int> = []
    var timer = Timer()
    var tapCount = 0
    
    var decks: Deck = Deck(numDecks: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationBar.setBackgroundImage(UIImage(named: "top_bar"), for: UIBarMetrics.default)
        toolBar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        
        pointsLabel.alpha = 0
        infoLabel.alpha = 0
        infoLabel.textColor = UIColor.white
        
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
    
    func cardTapped(_ sender: UITapGestureRecognizer) { // Tapper will always be player1
        
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
                    player1.roundPoints += card.getCardPoints(card)
                    pointsToAnimate.append(card.getCardPoints(card))
                    //animatePointsTaken(card.getCardPoints(card), origin: card.center)
                    
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
                    player1.roundPoints += card.getCardPoints(card) + 5
                    pointsToAnimate += [card.getCardPoints(card), 5]
                    animatePointsTaken(pointsToAnimate, origin: card.center)
                    player1.hand.remove(at: player1.hand.index(of: card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    nextPlayer()
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if player2.stock.last?.rank == card.rank && player2.stock.last?.suit == card.suit {
                    player1.stock.append(card)
                    player2.stock.removeLast()
                    for card in player2.stock {
                        player1.stock.insert(card, at: 0)
                        player1.roundPoints += card.getCardPoints(card)
                        pointsToAnimate.append(card.getCardPoints(card))
                        //animatePointsTaken(card.getCardPoints(card), origin: card.center)
                        player2.roundPoints -= card.getCardPoints(card)
                    }
                    player2.stock.removeAll()
                    player1.smulleCards.append(card)
                    player1.roundPoints += card.getCardPoints(card) + 5
                    pointsToAnimate += [card.getCardPoints(card), 5]
                    animatePointsTaken(pointsToAnimate, origin: card.center)
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
                if highlightedCards.count == 1 {
                    sumOfHighlightedCards += (-1+14) // Make the table ace value 14 instead of 1, if it's the only chosen card
                }
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
        
        var hcIndex = 1 // Set index to 1 to compare the next card
        //let numberOfHighlightedCards = highlightedCards.count
        for hc in highlightedCards {
            
            // Check all highlighted cards for SMULLAR within themselves
            for _ in hcIndex..<highlightedCards.count {
                let h: Card = highlightedCards[hcIndex]
                if h.rank == hc.rank && h.suit == hc.suit {
                    print("\(h.rank) of \(h.suit) == \(hc.rank) of \(hc.suit) is a SMULLE!")
                    activePlayer.smulleCards.append(h)
                    highlightedCards.remove(at: hcIndex)
                    tableCards.hand.remove(at: tableCards.hand.index(of: h)!)
                    tableCardsStackView.arrangedSubviews[tableCardsStackView.arrangedSubviews.index(of: h)!].removeFromSuperview()
                    
                    activePlayer.roundPoints += h.getCardPoints(h) + 5
                    
                    pointsToAnimate += [h.getCardPoints(h), 5]
                    animatePointsTaken(pointsToAnimate, origin: h.frame.origin)
                    
                }
            }
            
            if hcIndex < highlightedCards.count {
                hcIndex += 1
            } else {
                hcIndex = 1
            }
            
            // Check for SMULLE with hand card
            if hc.rank == handCard.rank && hc.suit == handCard.suit {
                
                activePlayer.smulleCards.append(hc)
                highlightedCards.remove(at: highlightedCards.index(of: hc)!)
                tableCards.hand.remove(at: tableCards.hand.index(of: hc)!)
                tableCardsStackView.arrangedSubviews[tableCardsStackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                
                activePlayer.roundPoints += hc.getCardPoints(hc) + 5
                
                pointsToAnimate += [hc.getCardPoints(hc), 5]
                animatePointsTaken(pointsToAnimate, origin: hc.frame.origin)
                break
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
            pointsToAnimate.append(card.getCardPoints(card))
            cardOrigin = card.frame.origin
            
            delay += 0.1
            lastPlayerToCollectCards = player
            print("\(card.rank) of \(card.suit) taken! \(card.getCardPoints(card)) points! Origin: \(card.frame.origin)")
        }
        
        // If no cards exist on table you get a TABBE
        if tableCards.hand.count == 0 {
            cardPoints += 1
            player.numberOfTabbeCards += 1
            
            pointsToAnimate.append(1)
            
            //animatePointsTaken([1], origin: self.view.center)
            
            print("TABBE!")
        }
        
        player.roundPoints += cardPoints
        if cardPoints > 0 {
            animatePointsTaken(pointsToAnimate, origin: cardOrigin)
        }
        
        print("\(activePlayer.name) has \(activePlayer.stock.count) cards in stock\n")
        print("\(tableCardsStackView.arrangedSubviews.count) cards on table")
        
        // Move on to next player
        nextPlayer()
        
    }
    
    func updateView() {
        
        player1NameLabel.text = "\(player1.name): \(player1.roundPoints) p (\(player1.smulleCards.count) s, \(player1.numberOfTabbeCards) t) total: \(player1.points)"
        player2NameLabel.text = "\(player2.name): \(player2.roundPoints) p (\(player2.smulleCards.count) s, \(player2.numberOfTabbeCards) t) total: \(player2.points)"
        displayHandCards(player1)
        displayHandCards(player2)
        displayTableCards()
        
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
        }
        updateView()
    }

    
    func playAI() {
        
        
        //infoLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse], animations: {
            
            self.infoLabel.alpha = 1
            self.infoLabel.text = "Now it's \(self.player2.name)´s turn!"
            
        }, completion: { (finished: Bool) -> Void in
        
            self.view.isUserInteractionEnabled = true
            self.infoLabel.alpha = 0
            
        var tookCards = false
        
        // Check for SMULLE or cards with equal rank to collect. Else discard one card.
        var hcIndex = 0
        var handCard = Card(rank: .ace, suit: .h) // Create dummy for handcard for use outside of handloop
        handLoop: for hc in self.player2.hand {
            handCard = hc
            
            hcIndex = self.player2.hand.index(of: hc)!
            tableLoop: for tc in self.tableCards.hand {
                
                // If same card in hand as top card in stock, you can take a smulle with that
                if self.player2.stock.last?.rank == hc.rank && self.player2.stock.last?.suit == hc.suit {
                    self.player2.smulleCards.append(hc)
                    self.player2.roundPoints += hc.getCardPoints(hc) + 5
                    self.pointsToAnimate += [hc.getCardPoints(hc), 5]
                    self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                    self.player2.hand.remove(at: self.player2.hand.index(of: hc)!)
                    self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    tookCards = true
                    print("Player2 took a smulle with top card of stock")
                    break handLoop
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if self.player1.stock.last?.rank == hc.rank && self.player1.stock.last?.suit == hc.suit {
                    self.flipCard(hc)
                    self.player2.stock.append(hc)
                    self.player1.stock.removeLast()
                    for card in self.player1.stock {
                        self.player2.stock.insert(card, at: 0)
                        self.player2.roundPoints += card.getCardPoints(card)
                        self.pointsToAnimate.append(card.getCardPoints(card))
                        //animatePointsTaken(card.getCardPoints(card), origin: card.center)
                        self.player1.roundPoints -= card.getCardPoints(card)
                    }
                    self.player1.stock.removeAll()
                    self.player2.smulleCards.append(hc)
                    self.player2.roundPoints += hc.getCardPoints(hc) + 5
                    self.pointsToAnimate += [hc.getCardPoints(hc), 5]
                    self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                    self.player2.hand.remove(at: self.player2.hand.index(of: hc)!)
                    self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    
                    tookCards = true
                    print("Player2 took your stock with \(hc.rank.rawValue) of \(hc.suit)!")
                    break handLoop
                    
                } else if hc.rank == tc.rank && hc.suit == tc.suit { // Smulle?
                    
                    self.player2.smulleCards.append(tc)
                    self.player2.roundPoints += tc.getCardPoints(tc) + 5
                    self.pointsToAnimate += [tc.getCardPoints(hc), 5]
                    //animatePointsTaken(tc.getCardPoints(tc) + 5, origin: tc.center)
                    self.tableCards.hand.remove(at: self.tableCards.hand.index(of: tc)!)
                    self.tableCardsStackView.arrangedSubviews[self.tableCardsStackView.arrangedSubviews.index(of: tc)!].removeFromSuperview()
                    self.flipCard(hc)
                    self.player2.stock.append(hc)
                    self.player2.roundPoints += hc.getCardPoints(hc)
                    self.pointsToAnimate.append(hc.getCardPoints(hc))
                    self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                    self.player2.hand.remove(at: hcIndex) // ...and remove it from hand
                    self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                    
                    tookCards = true
                    print("Player2 took a smulle!")
                    break handLoop
                    
                } else if hc.rank == tc.rank && hc.rank.rawValue != 1 { // Equal rank, but not an ace?
                    self.highlightedCards.append(tc)
                    self.sumOfHighlightedCards += tc.rank.rawValue
                    
                    self.flipCard(hc)
                    
                    self.player2.stock.append(hc) // Add chosen card from hand to stock
                    self.player2.hand.remove(at: hcIndex) // ...and remove it from hand
                    self.player2.roundPoints += hc.getCardPoints(hc)
                    self.pointsToAnimate.append(hc.getCardPoints(hc))
                    self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                    
                    break handLoop
                }
            }
            
        }
            
        
        if self.highlightedCards.count > 0 {
            print("\(self.player2.name) chose \(self.highlightedCards.count) cards from table")
            if self.cardsAreCorrectlyChosen(handCard) {
                self.collectCards(self.highlightedCards, player: self.player2)
            } else {
                print("Miscalculation?")
                print("handCard: \(handCard.rank) of \(handCard.suit)\n")
            }
        
        } else if !tookCards {
            print("\(self.player2.name) didn't find any cards to collect!")
            let cardIndexToDiscard = self.findCardIndexToDiscard(self.player2.hand)
            let disCard = self.player2.hand[cardIndexToDiscard]
            self.flipCard(disCard)
            
            //tableCardsStackView.addArrangedSubview(disCard)
            self.tableCards.hand.append(disCard)
            self.player2.hand.remove(at: cardIndexToDiscard)
            
            //updateView()
            self.nextPlayer()
        } else {
            self.nextPlayer()
        }
        })
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
    
    func animatePointsTaken(_ points: [Int], origin: CGPoint) {
        
        if activePlayer == player2 {
            pointsLabel.textColor = UIColor.red
        } else {
            pointsLabel.textColor = UIColor.green
        }
        
        // Filter out all occurencies of 0 points
        let points = points.filter{ $0 != 0 }
        
        // Well, this is quite an ugly solution, but it's what works right now
        for point in points {
        
        if points.count > 0 {
            pointsLabel.center = origin
            pointsLabel.text = "\(point)"
            pointsLabel.alpha = 1
            pointsLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: {
                self.pointsLabel.alpha = 0
                //self.pointsLabel.center.y -= 200
                self.pointsLabel.transform = CGAffineTransform(scaleX: 20, y: 20)
            }, completion: nil /*{ (finished: Bool) -> Void in
                
                if points.count > 1 {
                    self.pointsLabel.center = origin
                    self.pointsLabel.text = "\(points[1])"
                    self.pointsLabel.alpha = 1
                    self.pointsLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    
                    UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                        self.pointsLabel.alpha = 0
                        //self.pointsLabel.center.y -= 200
                        self.pointsLabel.transform = CGAffineTransform(scaleX: 20, y: 20)
                    }, completion: { (finished: Bool) -> Void in
                        
                        if points.count > 2 {
                            self.pointsLabel.center = origin
                            self.pointsLabel.text = "\(points[2])"
                            self.pointsLabel.alpha = 1
                            self.pointsLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                            
                            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                                self.pointsLabel.alpha = 0
                                //self.pointsLabel.center.y -= 200
                                self.pointsLabel.transform = CGAffineTransform(scaleX: 20, y: 20)
                            }, completion: { (finished: Bool) -> Void in
                                
                                if points.count > 3 {
                                    self.pointsLabel.center = origin
                                    self.pointsLabel.text = "\(points[3])"
                                    self.pointsLabel.alpha = 1
                                    self.pointsLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                                    
                                    UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                                        self.pointsLabel.alpha = 0
                                        //self.pointsLabel.center.y -= 200
                                        self.pointsLabel.transform = CGAffineTransform(scaleX: 20, y: 20)
                                    }, completion: { (finished: Bool) -> Void in
                                        
                                    })
                                }
                            })
                        }
                    })
                }
            }*/)
        }
        }
        
        pointsToAnimate.removeAll() // Empty pointsToAnimate after animations are done
    }
    
    func beginNewRound() {
        roundLabel.text = "Rounds left: \(numberOfRounds)"
        
        player1.roundPoints = 0
        player1.numberOfTabbeCards = 0
        player2.roundPoints = 0
        player2.numberOfTabbeCards = 0
        
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
        
        // The leftover cards on table are given to the player who was last to collect cards
        if tableCards.hand.count > 0 {
            var nextCardIndex = 1
            for card in tableCards.hand {
                // Check the remaining cards for smullar
                smulleLoop: for _ in nextCardIndex..<tableCards.hand.count {
                    if card.rank.rawValue == tableCards.hand[nextCardIndex].rank.rawValue && card.suit == tableCards.hand[nextCardIndex].suit {
                        lastPlayerToCollectCards.roundPoints += 5
                        lastPlayerToCollectCards.smulleCards.append(card)
                        break smulleLoop
                    }
                }
                
                if nextCardIndex < tableCards.hand.count {
                    nextCardIndex += 1
                }
                
                lastPlayerToCollectCards.hand.append(card)
                lastPlayerToCollectCards.roundPoints += card.getCardPoints(card)
                pointsToAnimate.append(card.getCardPoints(card))
                //animatePointsTaken(card.getCardPoints(card), origin: card.center)
            }
            lastPlayerToCollectCards.roundPoints += 1 // Tabbe
            lastPlayerToCollectCards.numberOfTabbeCards += 1
            pointsToAnimate.append(1)
            animatePointsTaken(pointsToAnimate, origin: self.view.center)
        }
        
        // The player with the most spades in stock will get 6 points
        // If equal, 3 points each is given
        
        for player in players {
            for card in player.stock {
                if card.suit == Card.Suit.s {
                    player.numberOfSpades += 1
                }
            }
            playersNumberOfSpades[player] = player.numberOfSpades
        }
        
        if player1.numberOfSpades != player2.numberOfSpades {
            var largest = 0
            var playerWithMostSpades: Player = Player(name: "Dummy", faceUpCards: false)
            for (player, value) in playersNumberOfSpades {
                if value > largest {
                    largest = value
                    playerWithMostSpades = player
                }
            }
            
            print("\(playerWithMostSpades.name) has got the most spades!")
            playerWithMostSpades.roundPoints += 6
            pointsToAnimate.append(6)
            animatePointsTaken(pointsToAnimate, origin: self.view.center)
        } else {
            print("Both players have equal amount of spades. 3 points each!")
            player1.roundPoints += 3
            player2.roundPoints += 3
        }
        
        // Add points from round to total points
        player1.points += player1.roundPoints
        player2.points += player2.roundPoints
        
        // Sanity check. Should add up to 20.
        
        var totalCardPoints = 0
        
        totalCardPoints = player1.roundPoints - player1.numberOfTabbeCards - (player1.smulleCards.count * 5) + player2.roundPoints - player2.numberOfTabbeCards - (player2.smulleCards.count * 5)
        dump(player1.roundPoints)
        dump(player1.numberOfTabbeCards)
        dump(player1.smulleCards.count)
        dump(player2.roundPoints)
        dump(player2.numberOfTabbeCards)
        dump(player2.smulleCards.count)
        
        assert(totalCardPoints == 20, "Total points don't add up! \(totalCardPoints)")
        //print(totalCardPoints)
        
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
        
        if numberOfRounds > 0 {
            numberOfRounds -= 1
            // TODO: Modal of round stats
            beginNewRound()
        } else {
            endGame()
        }
    }
    
    func endGame() {
        // Fix: Show modal of end state
        
        if player1.points > player2.points {
            infoLabel.text = "Game over! \(player1.name) won!"
            print("Game over! \(player1.name) won!")
        } else if player1.points == player2.points {
            infoLabel.text = "Game over! It's a tie!"
            print("Game over! It's a tie!")
        } else {
            infoLabel.text = "Game over! \(player2.name) won!"
            print("Game over! \(player2.name) won!")
        }
        
        infoLabel.alpha = 1
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
        blurView.alpha = 0.94
        
        rulesCard.layer.cornerRadius = 20
        
        if #available(iOS 10.0, *) {
            
        } else {
            rulesCard.alpha = 0.97 // defining alpha < 1 will break blur effect in iOS10
        }
        view.addSubview(rulesCard)
        dump(rulesCard.bounds)
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

