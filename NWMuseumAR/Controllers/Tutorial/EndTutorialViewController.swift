//
//  EndTutorialViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-02-15.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class EndTutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func navigate(_ sender: UIButton) {
        
        // This instantiates a page viewcontroller for the main pages, and inits the transition style to not look bad
        let viewController = NavigationViewController.init()
        
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        // Present our viewcontroller to the screen
        self.present(viewController, animated: false, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        // This instantiates a page viewcontroller for the main pages, and inits the transition style to not look bad
        let viewController = MainPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        // Present our viewcontroller to the screen
        self.present(viewController, animated: false, completion: nil)
    }
}
