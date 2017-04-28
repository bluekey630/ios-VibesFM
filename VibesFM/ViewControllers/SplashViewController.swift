//
//  SplashViewController.swift
//  VibesFM
//
//  Created by Admin on 24/01/2017.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.performSelector(#selector(SplashViewController.goToMainScreen), withObject: nil, afterDelay: 3.0)
    }

    func goToMainScreen() {
        self.performSegueWithIdentifier("goMain", sender: self)
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

}
