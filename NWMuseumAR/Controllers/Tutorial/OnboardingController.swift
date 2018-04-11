//
//  OnboardingController.swift
//  NewWestAr
//
//  Created by Justin Leung on 4/10/18.
//  Copyright © 2018 Justin Leung. All rights reserved.
//

import UIKit

class OnboardingController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    /** Onboarding icons.  */
    var icons = [
        "Onboarding_1",
        "Onboarding_2",
        "Onboarding_3",
        "Onboarding_4",
        "Onboarding_5",
        ]
    
    /** Onboarding titles. */
    var titles = [
        "DISCOVER",
        "INTERACT",
        "HAVE FUN",
        "ACCESS",
        "ACCESS"
    ]
    
    /** Onboarding Subtitles. */
    var subtitles = [
        "EXPLORE THE MUSEUM",
        "UNLOCK UNIQUE ARTIFACTS",
        "FIND ARTIFACTS WITH FRIENDS",
        "FOR THE FULL EXPERIENCE",
        "ALLOW CAMERA & LOCATION\nACCESS IN YOUR SETTINGS"
    ]
    
    /** Prev Button */
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PREV", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.mainGray, for: .normal)
        button.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        return button
    }()
    
    /** Next Button */
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.mainRed, for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private var permissionService: PermissionService?
    
    @objc private func handleNext()
    {
        let nextIndex = min(pageControl.currentPage + 1, icons.count - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        
        pageControl.currentPage = nextIndex
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func handlePrev()
    {
        let nextIndex = max(pageControl.currentPage - 1, 0)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func handleSegue() {
        let mainPageController = MainPageViewController()
        show(mainPageController, sender: nil)
    }
    
    /** Page Control */
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = icons.count
        pc.pageIndicatorTintColor = .mainLightRed
        pc.currentPageIndicatorTintColor = .mainRed
        return pc
    }()
    
    /**
     * Setup the bottom controls.
     */
    fileprivate func setupBottomControls()
    {
        // Bottom controls white background container.
        let bottomControlBackground = UIView()
        bottomControlBackground.backgroundColor = .white
        bottomControlBackground.translatesAutoresizingMaskIntoConstraints = false
        bottomControlBackground.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.addSubview(bottomControlBackground)
        
        // Previous Button Constraints.
        NSLayoutConstraint.activate([
            bottomControlBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomControlBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlBackground.heightAnchor.constraint(equalToConstant: 115)
            ])
        
        // Bottom Control Container
        let bottomControlsStackView = UIStackView(arrangedSubviews: [previousButton, pageControl, nextButton])
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.distribution = .fillEqually
        view.addSubview(bottomControlsStackView)
        
        // Previous Button Constraints.
        NSLayoutConstraint.activate([
            bottomControlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomControlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlsStackView.heightAnchor.constraint(equalToConstant: 115)
            ])
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomControls()
        
        permissionService = PermissionService()
        permissionService?.delegate = self
        
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
        
        if indexPath.row == icons.count - 1 {
            permissionService?.requestCameraPermission()
            permissionService?.requestLocationPermission()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

extension OnboardingController: PermissionServiceDelegate {
    
    func permissionService(didGrant permission: PermissionType) {
        
        switch permission {
        case .location:
            print("Location granted")
        case .camera:
            handleSegue()
            print("camera granted")
        }
    }
    
    func permissionService(didDeny permission: PermissionType) {
        
        switch permission {
        case .location:
            print("Location Denied")
        case .camera:
            print("camera denied")
        }
    }
    
    func permissionService(didFail permission: PermissionType) {
        
        switch permission {
        case .location:
            print("Location failed")
        case .camera:
            print("camera failed")
        }
    }
}
