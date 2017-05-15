//
//  EndViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2017-04-11.
//  Copyright © 2017 pixlig.se. All rights reserved.
//

import UIKit

class EndViewController: ModalViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var winnerPointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(modalTapped(_:)))
        view.addGestureRecognizer(tap)
        
        var winner = Player(name: "No one", faceUpCards: true)
        var winningPoints: Int = 0
        
        for player in players {
            if player.roundPoints > winningPoints {
                winningPoints = player.roundPoints
                winner = player
            } else if player.roundPoints == winningPoints {
                winningPoints = player.roundPoints
                winner = Player(name: "No one", faceUpCards: true)
            }
        }
        
        winnerLabel.text = "\(winner.name) won!"
        winnerPointsLabel.text = "\(winner.roundPoints) points"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func modalTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
