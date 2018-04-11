//
//  OnboardingController.swift
//  NewWestAr
//
//  Created by Justin Leung on 4/10/18.
//  Copyright © 2018 Justin Leung. All rights reserved.
//

import UIKit

class DeviceNotSupportedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    /** Onboarding icons.  */
    var icons = [
        "Onboarding_1",
    ]
    
    /** Onboarding titles. */
    var titles = [
        "NOT SUPPORTED",
    ]
    
    /** Onboarding Subtitles. */
    var subtitles = [
        "THIS APP REQUIRES IOS 11.3 AS WELL AS A DEVICE CAPABLE OF RUNNING ARKIT",
    ]
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .mainBackground
        collectionView?.register(OnboardingCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView?.isPagingEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! OnboardingCell
        
        let imageName = icons[indexPath.item]
        cell.tutorialImageView.image = UIImage(named: imageName)
        cell.titleTextView.text = titles[indexPath.item]
        cell.subtitleTextView.text = subtitles[indexPath.item]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
