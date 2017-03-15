//
//  StartViewController.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-09-15.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class StartViewController: UIViewController {
    
    let gradientLayer = CAGradientLayer()
    let color1 = UIColor(red: 0x0A, green: 0xC9, blue: 0x5F)
    let color2 = UIColor(red: 0x09, green: 0xA0, blue: 0x43)
    
    
    @IBAction func unwindToStartViewController(unwindSegue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        let modal = ModalViewController()
        modal.addHelpText()
        
        present(modal, animated: true, completion: nil)
 */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gradientLayer.frame = view.frame
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        
        view.layer.insertSublayer(gradientLayer, at: 0)

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
