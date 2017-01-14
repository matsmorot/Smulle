//
//  StartViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-09-15.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    let gradientLayer = CAGradientLayer()
    let color1 = UIColor.green
    let color2 = UIColor.purple
    
    @IBAction func unwindToStartViewController(unwindSegue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gradientLayer.frame = view.frame
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        
        //view.layer.addSublayer(gradientLayer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //let gVC = segue.destination
        
    //}
 

}
