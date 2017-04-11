//
//  TestViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2017-03-16.
//  Copyright © 2017 pixlig.se. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    
    let deck = Deck(numDecks: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = ColorPalette.pink
        
        
        
        for card in deck.deck {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(firstTap(_:)))
            
            card.isUserInteractionEnabled = true
            card.addGestureRecognizer(tap)
            card.cardImageView = UIImageView(image: card.cardImageBack)
            
            card.setContentHuggingPriority(1000, for: .horizontal)
            card.setContentCompressionResistancePriority(1000, for: .horizontal)
            
            card.heightAnchor.constraint(equalToConstant: card.cardImageView.frame.height).isActive = true
            card.widthAnchor.constraint(equalToConstant: card.cardImageView.frame.width).isActive = true
            
            card.addSubview(card.cardImageView)
            stack1.addArrangedSubview(card)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firstTap(_ sender: UITapGestureRecognizer) {
        let card = sender.view as! Card
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(nextTap(_:)))
        card.gestureRecognizers?.removeAll()
        card.flipCard()
        card.addGestureRecognizer(nextTap)
        
        UIView.animate(withDuration: 2, animations: {
            card.frame.origin = self.stack1.arrangedSubviews.last!.frame.origin
        }, completion: { (finished: Bool) -> Void in
            self.stack2.addArrangedSubview(card)
        })
        
        
    }
    
    func nextTap(_ sender: UITapGestureRecognizer) {
        let card = sender.view as! Card
        
        if stack1.arrangedSubviews.contains(card) {
            UIView.animate(withDuration: 2, animations: {
                card.center = self.stack2.center
            }, completion: { (finished: Bool) -> Void in
                self.stack2.addArrangedSubview(card)
            })
        } else {
            UIView.animate(withDuration: 2, animations: {
                card.center = self.stack1.center
            }, completion: { (finished: Bool) -> Void in
                self.stack1.addArrangedSubview(card)
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
