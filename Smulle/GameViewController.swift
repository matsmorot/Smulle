//
//  GameViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit
import AVFoundation
import GameplayKit

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
    
    @IBAction func restartButton(_ sender: UIBarButtonItem) {
        
        endCard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EndViewController") as! EndViewController
        endCard.delegate = self
        endCard.modalPresentationStyle = .overCurrentContext
        endCard.players = players
        
        present(endCard, animated: true, completion: nil)
    }
    
    @IBAction func helpButton(_ sender: UIBarButtonItem) {
        
        let rulesModal = ModalViewController()
        rulesModal.modalPresentationStyle = .overCurrentContext
        rulesModal.addHelpText()
        
        present(rulesModal, animated: true, completion: nil)
    }
    
    var statCard = ModalViewController()
    var endCard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EndViewController") as! EndViewController
    
    let gradientLayer = CAGradientLayer()
    let color1 = UIColor(red: 0x0A, green: 0xC9, blue: 0x5F)
    let color2 = UIColor(red: 0x09, green: 0xA0, blue: 0x43)
    
    var deckHolder = UIView()
    var numberOfRounds = 4
    var roundNumber = 0
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
        //infoLabel.alpha = 0
        infoLabel.textColor = UIColor.lightText
        roundLabel.textColor = ColorPalette.mint
        
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
        
        // Select initial dealer randomly
        let dealers = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: players) as! [Player]
        dealers.first?.isDealer = true
        
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        gradientLayer.frame = view.frame
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        //tableCardsStackView.setContentCompressionResistancePriority(1000, for: .horizontal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Start game
        beginNewRound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Show remaining cards in deck next to the player who is currently dealer, if big enough screen
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
            
            card.setContentHuggingPriority(1000, for: .horizontal)
            card.setContentCompressionResistancePriority(1000, for: .horizontal)
            
            card.heightAnchor.constraint(lessThanOrEqualToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(lessThanOrEqualToConstant: card.cardImageView.frame.width).isActive = true
            
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
            //card.setContentHuggingPriority(1000, for: .horizontal)
            //card.setContentCompressionResistancePriority(1000, for: .horizontal)
            card.addGestureRecognizer(tap)
            card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
            card.translatesAutoresizingMaskIntoConstraints = false
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
            
            //card.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
            //card.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            
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
            let cardImageView = UIImageView(image: lastCard!.cardImage)
            //player.smulleView.contentMode = UIViewContentMode.top
            //player.smulleView.clipsToBounds = true
            //player.smulleView.frame.size.height = cardImage.frame.height / 3
            //player.smulleView.frame.origin.x = cardImage.frame.origin.x
            //player.smulleView.frame.origin.y = cardImage.frame.origin.y
            
            cardImageView.contentMode = UIViewContentMode.top
            cardImageView.clipsToBounds = true
            cardImageView.frame.size.height = cardImageView.frame.height / 3
            
            player.smulleView.addSubview(cardImageView)
        }
        
    }
    
    func cardTapped(_ sender: UITapGestureRecognizer) { // Tapper will always be player1
        
        let card = sender.view as! Card
        
        // Card selection
        if tableCardsStackView.arrangedSubviews.contains(card) {
            if card.isHighlighted == false {
                
                // Move tapped card 20p up and increase shadow
                card.frame = card.frame.offsetBy(dx: 0.0, dy: -20.0)
                card.origin = view.convert(card.frame.origin, to: player1.stockView) // Save origin value for collect animation
                card.layer.shadowOpacity = 0.6
                card.layer.shadowOffset = CGSize.zero
                card.layer.shadowRadius = 5
                card.isHighlighted = true
                playSound(soundEffect: "shift")
                
                sumOfHighlightedCards += card.rank.rawValue
                highlightedCards.append(card)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
                
            } else if card.isHighlighted == true {
                
                // Move tapped card 20p down and decrease shadow
                card.frame = card.frame.offsetBy(dx: 0.0, dy: 20.0)
                card.layer.shadowRadius = 0
                card.isHighlighted = false
                playSound(soundEffect: "unshift")
                
                sumOfHighlightedCards -= card.rank.rawValue
                highlightedCards.remove(at: highlightedCards.index(of: card)!)
                
                print("\(highlightedCards.count) cards chosen")
                print("Sum of chosen cards: \(sumOfHighlightedCards)\n")
            }
        } else {
            if highlightedCards.count > 0 {
                if cardsAreCorrectlyChosen(card) {
                    UIView.animate(withDuration: 1, animations: {
                        card.origin.y = -200
                    })
                    takeSmulle(card) // Check for smulle
                    player1.stock.append(card)
                    player1.roundPoints += card.getCardPoints()
                    pointsToAnimate.append(card.getCardPoints())
                    //animatePointsTaken(card.getCardPoints(), origin: card.center)
                    
                    player1.hand.remove(at: player1.hand.index(of: card)!) // ...and remove it from hand
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    
                    collectCards(highlightedCards, player: player1)
                    
                } else {
                    print("Chosen cards do not match your hand card!")
                }
            } else {
                
                // If same card in hand as top card in stock, you can take a smulle with that
                if player1.stock.last?.rank == card.rank && player1.stock.last?.suit == card.suit {
                    UIView.animate(withDuration: 1, animations: {
                        
                    })
                    player1.smulleCards.append(card)
                    player1.roundPoints += card.getCardPoints() + 5
                    pointsToAnimate += [card.getCardPoints(), 5]
                    animatePointsTaken(pointsToAnimate, origin: card.center)
                    player1.hand.remove(at: player1.hand.index(of: card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    nextPlayer()
                    
                    // and if you have opponent's top stock card on hand you steal whole stock and also a smulle
                } else if player2.stock.last?.rank == card.rank && player2.stock.last?.suit == card.suit {
                    UIView.animate(withDuration: 1, animations: {
                        
                    })
                    player1.stock.append(card)
                    player2.stock.removeLast()
                    for card in player2.stock {
                        player1.stock.insert(card, at: 0)
                        player1.roundPoints += card.getCardPoints()
                        pointsToAnimate.append(card.getCardPoints())
                        //animatePointsTaken(card.getCardPoints(), origin: card.center)
                        player2.roundPoints -= card.getCardPoints()
                    }
                    player2.stock.removeAll()
                    player1.smulleCards.append(card)
                    player1.roundPoints += card.getCardPoints() + 5
                    pointsToAnimate += [card.getCardPoints(), 5]
                    animatePointsTaken(pointsToAnimate, origin: card.center)
                    player1.hand.remove(at: player1.hand.index(of: card)!)
                    player1StackView.arrangedSubviews[player1StackView.arrangedSubviews.index(of: card)!].removeFromSuperview()
                    nextPlayer()
                    
                } else {
                    tapCount += 1
                    if tapCount == 3 {
                        // Visual indication of where action should be taken
                        UIView.animate(withDuration: 0.2, delay: 0, options: [.autoreverse], animations: {
                            self.tableCardsStackView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            }, completion: { (finished: Bool) -> Void in
                                self.tableCardsStackView.transform = .identity
                            })
                        
                        print("Choose table cards first!")
                        tapCount = 0
                    }
                }
            }
        }
    }
    
    func cardSwipedUp(_ sender: UISwipeGestureRecognizer) {
        
        playSound(soundEffect: "discard")
        
        let card = sender.view as! Card
        
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
        
        //let cardCenter = view.convert(card.center, to: self.tableCardsStackView)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            
            card.center = CGPoint(x: 100, y: -150)
            
        }, completion: { (finished: Bool) -> Void in
            self.nextPlayer()
        })
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
                    
                    activePlayer.roundPoints += h.getCardPoints() + 5
                    
                    pointsToAnimate += [h.getCardPoints(), 5]
                    //animatePointsTaken(pointsToAnimate, origin: h.frame.origin)
                    
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
                
                activePlayer.roundPoints += hc.getCardPoints() + 5
                
                pointsToAnimate += [hc.getCardPoints(), 5]
                //animatePointsTaken(pointsToAnimate, origin: hc.frame.origin)
                break
            }
        }
        
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to));
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    func collectCards(_ cards: Array<Card>, player: Player) {
        
        var delay = 0.0
        var cardPoints = 0
        
        
        // Loop through collected cards, insert them in stock and remove them from table hand
        for card in cards {
            
            UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: {
                
                card.frame.origin.x = 140
                card.frame.origin.y = 190
                
            }, completion: { (finished: Bool) -> Void in
                //player.stockView.addArrangedSubview(card)
            })
            
            card.layer.shadowRadius = 0
            player.stock.insert(card, at: 0)
            playSound(soundEffect: "collect")
            tableCards.hand.remove(at: tableCards.hand.index(of: card)!)
            
            cardPoints += card.getCardPoints()
            
            card.addLabel()
            
            pointsToAnimate.append(card.getCardPoints())
            //cardOrigin = card.frame.origin
            
            delay += 0.1
            lastPlayerToCollectCards = player
            print("\(card.rank) of \(card.suit) taken! \(card.getCardPoints()) points! Origin: \(card.frame.origin)")
        }
        
        // If no cards exist on table you get a TABBE
        if tableCards.hand.count == 0 {
            cardPoints += 1
            player.numberOfTabbeCards += 1
            
            pointsToAnimate.append(1)
            
            print("TABBE!")
        }
        
        player.roundPoints += cardPoints
        
        animatePointsTaken(pointsToAnimate, origin: CGPoint.zero)
        
        
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
    }
    
    func nextPlayer() {
        // Only for two players at the moment
        
        // Reset variables for next player
        highlightedCards.removeAll()
        sumOfHighlightedCards = 0
        
        var nameLabel = UILabel()
        
        nextPlayerLoop: if activePlayer == player1 {
            activePlayer = player2
            
            nameLabel = player2NameLabel
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
            nameLabel = player1NameLabel
            print("Now it's \(activePlayer.name)'s turn!")
        }
        
        if activePlayer.hand.count == 0 && decks.deck.count > 0 {
            dealNewCards()
        } else if activePlayer.hand.count == 0 && decks.deck.count == 0 && !statCard.isBeingPresented {
            endRound()
        }
        updateView()
        nameLabel.text = "\(nameLabel.text!) <-"
    }

    
    func playAI() {
        
        //infoLabel.alpha = 0
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1, delay: 0.2, options: [], animations: {
            
            self.infoLabel.alpha = 1
            self.infoLabel.text = "Now it's \(self.player2.name)´s turn!"
            
        }, completion: { (finished: Bool) -> Void in
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                
                self.infoLabel.alpha = 0
            
            }, completion: { (finished: Bool) -> Void in
                self.view.isUserInteractionEnabled = true
            })
            
            var tookCards = false
            
            // Check for SMULLE or cards with equal rank to collect. Else discard one card.
            var hcIndex = 0
            var handCard = Card(rank: .ace, suit: .h) // Create dummy for handcard for use outside of handloop
            var p1LastCard = Card(rank: .ace, suit: .s)
            if self.player1.stock.last != nil {
                p1LastCard = self.player1.stock.last!
            }
            
            handLoop: for hc in self.player2.hand {
                handCard = hc
                
                hcIndex = self.player2.hand.index(of: hc)!
                tableLoop: for tc in self.tableCards.hand {
                    
                    // If you have opponent's top stock card on hand you steal whole stock and also a smulle (prio 1)
                    if p1LastCard.rank == hc.rank && p1LastCard.suit == hc.suit {
                        hc.flipCard()
                        self.player2.stock.append(hc)
                        self.player2.roundPoints += hc.getCardPoints()
                        self.player1.roundPoints -= p1LastCard.getCardPoints()
                        self.player1.stock.removeLast()
                        for card in self.player1.stock {
                            self.player2.stock.insert(card, at: 0)
                            self.player2.roundPoints += card.getCardPoints()
                            self.pointsToAnimate.append(card.getCardPoints())
                            //animatePointsTaken(card.getCardPoints(), origin: card.center)
                            self.player1.roundPoints -= card.getCardPoints()
                        }
                        self.player1.stock.removeAll()
                        self.player2.smulleCards.append(hc)
                        self.player2.roundPoints += hc.getCardPoints() + 5
                        self.pointsToAnimate += [hc.getCardPoints(), 5]
                        self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                        self.player2.hand.remove(at: self.player2.hand.index(of: hc)!)
                        self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                        
                        tookCards = true
                        print("Player2 took your stock with \(hc.rank.rawValue) of \(hc.suit)!")
                        break handLoop
                        
                    // and if you have the top card of your stock in your hand, take smulle (prio 2)
                    } else if self.player2.stock.last?.rank == hc.rank && self.player2.stock.last?.suit == hc.suit {
                        self.player2.smulleCards.append(hc)
                        self.player2.roundPoints += hc.getCardPoints() + 5
                        self.pointsToAnimate += [hc.getCardPoints(), 5]
                        self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                        self.player2.hand.remove(at: self.player2.hand.index(of: hc)!)
                        self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                        tookCards = true
                        print("Player2 took a smulle with top card of stock")
                        break handLoop
                    
                    // Is there a smulle on the table? (prio 3)
                    } else if hc.rank == tc.rank && hc.suit == tc.suit {
                        
                        self.player2.smulleCards.append(tc)
                        self.player2.roundPoints += tc.getCardPoints() + 5
                        self.pointsToAnimate += [tc.getCardPoints(), 5]
                        //animatePointsTaken(tc.getCardPoints(tc) + 5, origin: tc.center)
                        self.tableCards.hand.remove(at: self.tableCards.hand.index(of: tc)!)
                        self.tableCardsStackView.arrangedSubviews[self.tableCardsStackView.arrangedSubviews.index(of: tc)!].removeFromSuperview()
                        hc.flipCard()
                        self.player2.stock.append(hc)
                        self.player2.roundPoints += hc.getCardPoints()
                        self.pointsToAnimate.append(hc.getCardPoints())
                        self.animatePointsTaken(self.pointsToAnimate, origin: hc.center)
                        self.player2.hand.remove(at: hcIndex) // ...and remove it from hand
                        self.player2StackView.arrangedSubviews[self.player2StackView.arrangedSubviews.index(of: hc)!].removeFromSuperview()
                        
                        tookCards = true
                        print("Player2 took a smulle!")
                        break handLoop
                        
                    } else if hc.rank == tc.rank && hc.rank.rawValue != 1 { // Equal rank, but not an ace?
                        self.highlightedCards.append(tc)
                        self.sumOfHighlightedCards += tc.rank.rawValue
                        
                        hc.flipCard()
                        
                        self.player2.stock.append(hc) // Add chosen card from hand to stock
                        self.player2.hand.remove(at: hcIndex) // ...and remove it from hand
                        self.player2.roundPoints += hc.getCardPoints()
                        self.pointsToAnimate.append(hc.getCardPoints())
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
                disCard.flipCard()
                
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
    
    func pickCards() {
        // TO DO: Making AI smarter
        // Can we take all of the table cards?
        var sumOfTableCards: Int = 0
        let bestCardIndex = findCardIndexToUse(player2.hand) // Begin with the best card in hand
        
        for tableCard in tableCards.hand {
            sumOfTableCards += tableCard.rank.rawValue
        }
        
        
        if player2.hand[bestCardIndex].rank.rawValue == sumOfTableCards {
            highlightedCards = tableCards.hand
        }
    }
    
    
    
    func dealNewCards() {
        // If in play, give cards to players
        if decks.deck.count > 12 && decks.deck.count < 104 {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            for card in player1.hand {
                card.flipCard()
            }
            player2.takeCardsFromDeck(4, fromDeck: decks)
            player2.hand.sort { $0.rank.rawValue < $1.rank.rawValue }
            for card in player2.hand {
                if card.faceUp {
                    card.flipCard()
                }
            }
        // If deck is new or there are less than 12 cards left, deal to players and table
        } else {
            player1.takeCardsFromDeck(4, fromDeck: decks)
            for card in player1.hand {
                card.flipCard()
            }
            player2.takeCardsFromDeck(4, fromDeck: decks)
            player2.hand.sort { $0.rank.rawValue < $1.rank.rawValue }
            for card in player2.hand {
                if card.faceUp {
                    card.flipCard()
                }
            }
            
            tableCards.takeCardsFromDeck(4, fromDeck: decks)
            for card in tableCards.hand {
                if !card.faceUp {
                    card.flipCard()
                }
            }
        }
        
        updateView()
    }
    
    func findCardIndexToDiscard(_ cards: Array<Card>) -> Int {
        var values: Array<Int> = []
        for card in cards {
            if card.getCardPoints() > 0 {
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
            if card.getCardPoints() == 1 {
                values.append(15)
            } else if card.getCardPoints() == 2 {
                values.append(16)
            } else {
                values.append(card.rank.rawValue)
            }
        }
        let maxValueIndex = values.index(of: values.max()!)
        return maxValueIndex!
    }
    /*
    func flipCard(_ card: Card) {
        
        playSound(soundEffect: "flipcard2")
        
        let back = UIImageView(image: card.cardImageBack)
        let front = UIImageView(image: card.cardImage)
        
        if card.faceUp {
            
            card.addSubview(back)
            UIView.transition(from: card.cardImageView, to: back, duration: 0.32, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
            
                // Should something happen after card has been flipped?
            
            })
            card.faceUp = false
            print("Card flipped from front to back! \(card.faceUp)")
        } else {
            
            card.addSubview(front)
            card.setNeedsDisplay()
            card.layoutIfNeeded()
            UIView.transition(from: card.cardImageView, to: front, duration: 0.32, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { (finished: Bool) -> Void in
                
                // Should something happen after card has been flipped?
                
            })
            card.addBorder(card)
            card.faceUp = true
            print("Card flipped from back to front! \(card.faceUp)")
        }
        
    }*/
    
    func animatePointsTaken(_ points: [Int], origin: CGPoint) {
        
        if activePlayer == player2 {
            pointsLabel.textColor = ColorPalette.pink
        } else {
            pointsLabel.textColor = ColorPalette.mint
        }
        
        // Filter out all occurencies of 0 points
        let points = points.filter{ $0 != 0 }
        
        // Fix: Sequential animations
        for point in points {
            
            if point == 1 || point == 2 {
                playSound(soundEffect: "1p")
            } else if point == 5 {
                playSound(soundEffect: "5p")
            }
            
            if points.count > 0 {
                pointsLabel.center = origin
                pointsLabel.text = "\(point)"
                pointsLabel.alpha = 1
                pointsLabel.transform = .identity
                
                UIView.animate(withDuration: 2, delay: 0.3, options: [], animations: {
                    self.pointsLabel.alpha = 0
                    //self.pointsLabel.center.y -= 200
                    self.pointsLabel.transform = CGAffineTransform(scaleX: 40, y: 40)
                }, completion: { (finished: Bool) -> Void in
                     /*
                     while point != points.endIndex {
                     self.pointsLabel.center = origin
                     self.pointsLabel.text = "\(point)"
                     self.pointsLabel.alpha = 1
                     self.pointsLabel.transform = .identity
                     
                     UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
                     self.pointsLabel.alpha = 0
                     self.pointsLabel.center.y -= 200
                     self.pointsLabel.transform = CGAffineTransform(scaleX: 40, y: 40)
                     }, completion: { (finished: Bool) -> Void in
                        self.pointsToAnimate.removeAll() // Empty pointsToAnimate after animations are done
                     })}*/})
            }
        }
        self.pointsToAnimate.removeAll()
    }
    
    func checkForMostSpades() {
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
        
        if player1.numberOfSpades > player2.numberOfSpades {
            player1.spadePoints = 6
            player2.spadePoints = 0
            
        } else if player1.numberOfSpades < player2.numberOfSpades {
            player2.spadePoints = 6
            player1.spadePoints = 0
            
        } else {
            player1.spadePoints = 3
            player2.spadePoints = 3
            
        }
        
        for player in players {
            player.roundPoints += player.spadePoints
        }
        
        /*
         if player1.numberOfSpades != player2.numberOfSpades {
         var largest = 0
         var playerWithMostSpades: Player = Player(name: "Dummy", faceUpCards: false)
         for (player, value) in playersNumberOfSpades {
         if value > largest {
         largest = value
         playerWithMostSpades = player
         player.hasMostSpades = true
         } else {
         player.hasMostSpades = false
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
         */

    }
    
    func beginNewRound() {
        roundNumber += 1
        roundLabel.text = "Round \(roundNumber)"
        
        for player in players {
            player.roundPoints = 0
            player.spadePoints = 0
            player.numberOfTabbeCards = 0
        }
        
        decks = Deck(numDecks: 2)
        
        decks.shuffleDeck()
        playSound(soundEffect: "shuffle")
        
        changeDealer()
        
        // Show deck next to the player who is currently dealer
        showDeck()
        
        // Deal cards
        dealNewCards()
        
        if activePlayer == player2 {
            infoLabel.text = "\(activePlayer.name) will start!"
            infoLabel.alpha = 1
            UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
                self.infoLabel.alpha = 0
                self.infoLabel.transform = CGAffineTransform.init(scaleX: 40, y: 40)
            }, completion: { (finished: Bool) -> Void in
                self.infoLabel.transform = .identity
            })
            playAI()
        } else if activePlayer == player1 {
            infoLabel.text = "\(activePlayer.name) will start!"
            infoLabel.alpha = 1
            UIView.animate(withDuration: 2, delay: 1, options: [], animations: {
                self.infoLabel.alpha = 0
                self.infoLabel.transform = CGAffineTransform.init(scaleX: 40, y: 40)
            }, completion: { (finished: Bool) -> Void in
                self.infoLabel.transform = .identity
            })
        }
    }
    
    func endRound() {
        
        // The leftover cards on table are given to the player who was last to collect cards
        if tableCards.hand.count > 0 {
            
            var nextCardIndex = 1
            for card in tableCards.hand {
                var tookSmulle: Bool = false
                // Check the remaining cards for smullar
                smulleLoop: for index in nextCardIndex..<tableCards.hand.count {
                    
                    if card.rank.rawValue == tableCards.hand[index].rank.rawValue && card.suit == tableCards.hand[index].suit {
                        lastPlayerToCollectCards.roundPoints += 5
                        lastPlayerToCollectCards.roundPoints += card.getCardPoints()
                        lastPlayerToCollectCards.smulleCards.append(card)
                        tookSmulle = true
                        break smulleLoop // Don't look any further if a pair is found
                    }
                }
                
                if nextCardIndex < tableCards.hand.count {
                    nextCardIndex += 1
                }
                
                if !tookSmulle {
                    lastPlayerToCollectCards.stock.append(card)
                    lastPlayerToCollectCards.roundPoints += card.getCardPoints()
                    pointsToAnimate.append(card.getCardPoints())
                }
                
                //animatePointsTaken(card.getCardPoints(), origin: card.center)
            }
            lastPlayerToCollectCards.roundPoints += 1 // Tabbe
            lastPlayerToCollectCards.numberOfTabbeCards += 1
            pointsToAnimate.append(1)
            animatePointsTaken(pointsToAnimate, origin: self.view.center)
        }
        
        tableCards.hand.removeAll()
        
        checkForMostSpades()
        
        // Add points from round to total points
        for player in players {
            player.points += player.roundPoints
        }
        
        // Sanity check. Should add up to 20.
        /*
        var totalCardPoints = 0
        
        totalCardPoints = player1.roundPoints - player1.spadePoints - player1.numberOfTabbeCards - (player1.smulleCards.count * 5) + player2.roundPoints - player2.spadePoints - player2.numberOfTabbeCards - (player2.smulleCards.count * 5)
        
        assert(totalCardPoints == 20, "Total points don't add up! \(totalCardPoints)")
        */
        
        
        // Present stats modally
        
        statCard = ModalViewController()
        statCard.delegate = self
        statCard.modalPresentationStyle = .overCurrentContext
        statCard.players = players
        statCard.roundNumber = roundNumber
        statCard.addStats()
        
        present(statCard, animated: true, completion: nil)
    }
    
    func endGame() {
        // Show modal of end state
        endCard.delegate = self
        endCard.modalPresentationStyle = .overCurrentContext
        endCard.players = players
        
        present(endCard, animated: true, completion: nil)
        
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
    
    func clearTable() {
        
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

    }
    
    public func playSound(soundEffect: String) {
        let url = Bundle.main.url(forResource: soundEffect, withExtension: "m4a")
            let player = AVAudioPlayerPool.playerWithURL(url: url!)
            player?.play()
    }
}

