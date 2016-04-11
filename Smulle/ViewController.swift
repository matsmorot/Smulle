//
//  ViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardPlace: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let decks = Deck(numDecks: 2)
       
        decks.shuffleDeck()
        
        let player1 = Player(name: "Nisse")
        let player2 = Player(name: "Albert")
        player1.takeCards(4, fromDeck: decks)
        player2.takeCards(4, fromDeck: decks)
    

        let cardHolder = UIImageView()
        var cardHolders = Array(count: decks.deck.count, repeatedValue: cardHolder)
        cardHolders[0].frame.offsetInPlace(dx: cardPlace.frame.origin.x, dy: cardPlace.frame.origin.y)
        self.view.addSubview(cardHolders[0])
        
        // Print out all cards in deck in ViewController
        /*
        for i in 1..<decks.deck.count {
            let cardImage = UIImage(named: "\(decks.deck[i].rank.simpleDescription())_\(decks.deck[i].suit)")

            cardHolders[i] = UIImageView(image: cardImage)
        
            cardHolders[i].frame.offsetInPlace(dx: cardHolders[i-1].frame.origin.x + 2, dy: cardHolders[i-1].frame.origin.y)
            self.view.addSubview(cardHolders[i])
        }
        */
        
        // Display cards in players hands
        let player1Card1Image = UIImageView(image: player1.hand[0].cardImage)
        let player1Card2Image = UIImageView(image: player1.hand[1].cardImage)
        let player1Card3Image = UIImageView(image: player1.hand[2].cardImage)
        let player1Card4Image = UIImageView(image: player1.hand[3].cardImage)
        
        let player2Card1Image = UIImageView(image: player2.hand[0].cardImage)
        let player2Card2Image = UIImageView(image: player2.hand[1].cardImage)
        let player2Card3Image = UIImageView(image: player2.hand[2].cardImage)
        let player2Card4Image = UIImageView(image: player2.hand[3].cardImage)
        
        let player1CardPlaceX = self.view.frame.width / 2 - (player1Card1Image.frame.width * 2)
        let player1CardPlaceY = self.view.frame.height - self.view.frame.height / 5
        
        let player2CardPlaceX = player1CardPlaceX
        let player2CardPlaceY = (self.view.frame.height / 5) - player2Card1Image.frame.height
        
        player1Card1Image.frame.offsetInPlace(dx: player1CardPlaceX, dy: player1CardPlaceY)
        player1Card2Image.frame.offsetInPlace(dx: player1CardPlaceX + player1Card2Image.frame.width, dy: player1CardPlaceY)
        player1Card3Image.frame.offsetInPlace(dx: player1CardPlaceX + player1Card3Image.frame.width * 2, dy: player1CardPlaceY)
        player1Card4Image.frame.offsetInPlace(dx: player1CardPlaceX + player1Card4Image.frame.width * 3, dy: player1CardPlaceY)
        
        player2Card1Image.frame.offsetInPlace(dx: player2CardPlaceX, dy: player2CardPlaceY)
        player2Card2Image.frame.offsetInPlace(dx: player2CardPlaceX + player2Card2Image.frame.width, dy: player2CardPlaceY)
        player2Card3Image.frame.offsetInPlace(dx: player2CardPlaceX + player2Card3Image.frame.width * 2, dy: player2CardPlaceY)
        player2Card4Image.frame.offsetInPlace(dx: player2CardPlaceX + player2Card4Image.frame.width * 3, dy: player2CardPlaceY)
        
        self.view.addSubview(player1Card1Image)
        self.view.addSubview(player1Card2Image)
        self.view.addSubview(player1Card3Image)
        self.view.addSubview(player1Card4Image)
        
        self.view.addSubview(player2Card1Image)
        self.view.addSubview(player2Card2Image)
        self.view.addSubview(player2Card3Image)
        self.view.addSubview(player2Card4Image)
            
        // Debug prints
        print(decks)
        for card in decks.deck {
            print("\(card.rank.simpleDescription()) of \(card.suit)")
        }
        print(decks.deck.count)
        print("Top card in deck: \(decks.deck[0].rank.simpleDescription())_\(decks.deck[0].suit)")
        print("\(player1.name) has \(player1.hand)")
        for c in player1.hand {
            print("Hand: \(c.rank.simpleDescription()) of \(c.suit)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

