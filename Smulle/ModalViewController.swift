//
//  ModalViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2017-01-30.
//  Copyright © 2017 pixlig.se. All rights reserved.
//

import UIKit

@IBDesignable class ModalViewController: UIViewController {
    
    weak var delegate: GameViewController!
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    var players: Array<Player> = []
    var textView = UITextView()
    var roundNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        blurView.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: view.frame.width - 20, height: view.frame.height - 20))
        
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.alpha = 0.94
        
        view.addSubview(blurView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func helpCardSwipedDown(_ sender: UISwipeGestureRecognizer) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    func helpCardTapped(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    func statCardSwipedDown(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            self.delegate.clearTable()
            self.delegate.beginNewRound()
        })
    }
    
    func statCardTapped(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            self.delegate.clearTable()
            self.delegate.beginNewRound()
        })
    }
    
    func addHelpText() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(helpCardTapped(_:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(helpCardSwipedDown(_:)))
        swipeDown.direction = .down
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
        
        let textFile = Bundle.main.path(forResource: "smulle_rules", ofType: "txt")
        var textString = ""
        do {
            textString = try String(contentsOfFile: textFile!)
        } catch let error as NSError {
            print("Failed reading from \(textFile). Error: " + error.localizedDescription)
        }
        
        textView.frame = view.frame
        textView.clipsToBounds = true
        textView.text = textString
        textView.backgroundColor = .none
        textView.textColor = UIColor.darkText
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsetsMake(40, 25, 25, 40)
        
        //view.layoutMargins = UIEdgeInsetsMake(0, 20, 20, 20)
        
        view.addSubview(textView)
    }
    
    func addStats() {
        // Programatically made stack views and content for learning purposes
        // Not the most readable code...
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(statCardTapped(_:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(statCardSwipedDown(_:)))
        swipeDown.direction = .down
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
        
        let roundLabel = UILabel()
        
        roundLabel.text = "Round \(roundNumber)"
        roundLabel.font = Fonts.biggerBold
        roundLabel.textAlignment = .center
        roundLabel.setContentCompressionResistancePriority(1000, for: .vertical)
        
        let mainStackView = UIStackView(frame: CGRect(x: 30, y: 25, width: view.frame.width - 60, height: view.frame.height - 50))
        
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillProportionally
        mainStackView.alignment = .fill
        mainStackView.spacing = 5
        
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(roundLabel)
        
        /*
        mainStackView.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
        */
        
        // Loop through players and lay out stack views and labels for each one
        // This will probably look crazy with more than 2 players
        
        for player in players {
            
            // Use a transparent card to make the stack views fill evenly even without cards
            let noCard = Card(rank: .ace, suit: .s)
            noCard.cardImageView.alpha = 0
            
            // Points for summary
            let pointsCardPoints = player.roundPoints - (player.spadePoints + player.numberOfTabbeCards + (player.smulleCards.count * 5))
            let smulleCardPoints = player.smulleCards.count * 5
            
            let scale = CGFloat(0.8) // Used to scale card images a bit to save space
            
            let nameLabel = UILabel()
            let pointsLabel = UILabel()
            let smulleLabel = UILabel()
            let spadeLabel = UILabel()
            let tabbeLabel = UILabel()
            let totalLabel = UILabel()
            let pointsCardPointsLabel = UILabel()
            let smulleCardPointsLabel = UILabel()
            let spadePointsLabel = UILabel()
            let tabbePointsLabel = UILabel()
            let totalPointsLabel = UILabel()
            
            nameLabel.text = "\(player.name)"
            nameLabel.font = Fonts.big
            nameLabel.textAlignment = .center
            nameLabel.setContentCompressionResistancePriority(1000, for: .vertical)
            
            pointsLabel.text = "Point cards"
            pointsCardPointsLabel.text = "\(pointsCardPoints)"
            smulleLabel.text = "Smulle cards"
            smulleCardPointsLabel.text = "\(smulleCardPoints)"
            spadeLabel.text = "Spade cards"
            spadePointsLabel.text = "\(player.spadePoints)"
            tabbeLabel.text = "Tabs x \(player.numberOfTabbeCards)"
            tabbePointsLabel.text = "\(player.numberOfTabbeCards)"
            totalLabel.text = "Total:"
            totalPointsLabel.text = "\(player.roundPoints)"
            
            smulleLabel.font = Fonts.medium
            smulleCardPointsLabel.font = Fonts.medium
            pointsLabel.font = Fonts.medium
            pointsCardPointsLabel.font = Fonts.medium
            spadeLabel.font = Fonts.medium
            spadePointsLabel.font = Fonts.medium
            tabbeLabel.font = Fonts.medium
            tabbePointsLabel.font = Fonts.medium
            totalLabel.font = Fonts.big
            totalPointsLabel.font = Fonts.big
            
            
            // Add player stack views in main stack view and nest even more stack views!
            
            let playerStackView = UIStackView()
            
            playerStackView.axis = .vertical
            playerStackView.distribution = .fillEqually
            //playerStackView.alignment = .leading
            
            mainStackView.addArrangedSubview(nameLabel)
            mainStackView.addArrangedSubview(playerStackView)
            
            let splitStackView1 = UIStackView()
            let splitStackView2 = UIStackView()
            let splitStackView3 = UIStackView()
            let splitStackView4 = UIStackView()
            let splitStackView5 = UIStackView()
            
            let splitStackViews: Array<UIStackView> = [
                splitStackView1,
                splitStackView2,
                splitStackView3,
                splitStackView4,
                splitStackView5]
            
            for splitStackView in splitStackViews {
                
                splitStackView.axis = .horizontal
                splitStackView.distribution = .equalCentering
            }
        
            let pointCardsStackView = UIStackView()
            let spadeCardsStackView = UIStackView()
            let smulleCardsStackView = UIStackView()
            
            let horizontalStackViews: Array<UIStackView> = [
                pointCardsStackView,
                smulleCardsStackView,
                spadeCardsStackView]
            
            for stackView in horizontalStackViews {
                
                stackView.axis = .horizontal
                stackView.distribution = .fill
                stackView.spacing = -43
                stackView.alignment = .leading
            }
            
            // Fetch cards with points and add to pointCardsStackView
            let collectedCards = player.stock + player.smulleCards
            
            for card in collectedCards {
                if card.getCardPoints(card) > 0 {
                    let pointCard = Card(rank: card.rank, suit: card.suit)
                    let cardImageView = UIImageView(image: pointCard.cardImage)
                    pointCard.flipCard()
                    cardImageView.contentMode = .top
                    cardImageView.clipsToBounds = true
                    //cardImageView.frame.size.height = cardImageView.frame.height / 3
                    //cardImageView.setContentCompressionResistancePriority(1000, for: .vertical)
                    
                    cardImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    
                    pointCardsStackView.addArrangedSubview(cardImageView)
                }
            }
            
            // Add a "transparent card" to make the player stack views equal in height
            if pointCardsStackView.arrangedSubviews.count == 0 {
                pointCardsStackView.addArrangedSubview(noCard.cardImageView)
            }
            
            // Add smulle card copy to smulleCardsStackView
            for card in player.smulleCards {
                let smulleCard = Card(rank: card.rank, suit: card.suit)
                let cardImageView = UIImageView(image: smulleCard.cardImage)
                smulleCard.flipCard()
                cardImageView.contentMode = .top
                cardImageView.clipsToBounds = true
                //cardImageView.frame.size.height = cardImageView.frame.height / 3
                
                cardImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                smulleCardsStackView.addArrangedSubview(cardImageView)
            }
            
            // Add spade card copy to spadeCardsStackView
            for card in collectedCards {
                if card.suit == .s {
                    let spadeCard = Card(rank: card.rank, suit: card.suit)
                    let cardImageView = UIImageView(image: spadeCard.cardImage)
                    spadeCard.flipCard()
                    cardImageView.contentMode = .top
                    cardImageView.clipsToBounds = true
                    //cardImageView.frame.size.height = cardImageView.frame.height / 3
                    
                    cardImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    spadeCardsStackView.addArrangedSubview(cardImageView)
                }
            }
            
            playerStackView.addArrangedSubview(pointsLabel)
            playerStackView.addArrangedSubview(splitStackView1)
            splitStackView1.addArrangedSubview(pointCardsStackView)
            splitStackView1.addArrangedSubview(pointsCardPointsLabel)
            
            playerStackView.addArrangedSubview(smulleLabel)
            playerStackView.addArrangedSubview(splitStackView2)
            splitStackView2.addArrangedSubview(smulleCardsStackView)
            splitStackView2.addArrangedSubview(smulleCardPointsLabel)
            
            playerStackView.addArrangedSubview(spadeLabel)
            playerStackView.addArrangedSubview(splitStackView3)
            splitStackView3.addArrangedSubview(spadeCardsStackView)
            splitStackView3.addArrangedSubview(spadePointsLabel)
            
            playerStackView.addArrangedSubview(splitStackView4)
            splitStackView4.addArrangedSubview(tabbeLabel)
            splitStackView4.addArrangedSubview(tabbePointsLabel)
            
            playerStackView.addArrangedSubview(splitStackView5)
            splitStackView5.addArrangedSubview(totalLabel)
            splitStackView5.addArrangedSubview(totalPointsLabel)
        }
    }
}
