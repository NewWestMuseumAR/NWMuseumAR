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
            UIStoryboard(name: "Vuforia", bundle: nil).instantiateViewController(withIdentifier: "vuforia"),
            UIStoryboard(name: "ARScene", bundle: nil).instantiateViewController(withIdentifier: "camera")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = subViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard subViewControllers.count > previousIndex else {
            return nil
        }
        
        return subViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = subViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let subViewControllersCount = subViewControllers.count
        
        guard subViewControllersCount != nextIndex else {
            return nil
        }
        
        guard subViewControllersCount > nextIndex else {
            return nil
        }
        
        return subViewControllers[nextIndex]
    }
}
