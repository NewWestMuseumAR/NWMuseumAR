//
//  MainPageViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-02-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    // Any new pages you want go in here
    // name: refers to the storyboard name,
    // withIdentifier refers to the identifier you gave it in the storyboard
    lazy var subViewControllers:[UIViewController] = {
        return [
            UIStoryboard(name: "Progress", bundle: nil).instantiateViewController(withIdentifier: "progress"),
            UIStoryboard(name: "ARScene", bundle: nil).instantiateViewController(withIdentifier: "camera")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        setViewControllers([subViewControllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if currentIndex <= 0 {
            return nil
        }
        return subViewControllers[currentIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if currentIndex >= subViewControllers.count - 1 {
            return nil
        }
        return subViewControllers[currentIndex + 1]
    }
}
