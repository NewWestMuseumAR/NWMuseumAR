//
//  ProgressController.swift
//  NewWestAr
//
//  Created by Justin Leung on 4/10/18.
//  Copyright © 2018 Justin Leung. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var artifacts: [Artifact]?
    
    var overlayMode = false
    var overlayView: ArtifactDetailOverlay?
    
    /** View Loaded */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        artifacts = Artifact.getAll()
        
        setupViewsLayout()
        
        artifactCollectionView.dataSource = self
        artifactCollectionView.delegate = self
        
        view.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.98, alpha: 1.0)
    }
    
    /** Artifacts Collection View */
    let artifactCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.98, alpha: 1.0)
        collectionView.register(ArtifactCell.self, forCellWithReuseIdentifier: "cellId")
        return collectionView
    }()
    
    /** Top Container Wrapper */
    lazy var topContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 310)
        container.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Top Page Container"))
        return container
    }()
    
    /** Title */
    let topContainerTitle: UITextView = {
        let title = UITextView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.textColor = .mainTitleDark
        title.isEditable = false
        title.isScrollEnabled = false
        title.isSelectable = false
        title.backgroundColor = nil
        let attributedString = NSMutableAttributedString(string: "ARTIFACTS")
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.heavy),
            NSAttributedStringKey.kern: 3,
            NSAttributedStringKey.foregroundColor: UIColor(red: 0.26, green: 0.28, blue: 0.37, alpha: 1.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attributedString.length))
        title.attributedText = attributedString
        return title
    }()
    
    /** Subtitle */
    let topContainerSubtitle: UITextView = {
        let subtitle = UITextView()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.isEditable = false
        subtitle.isScrollEnabled = false
        subtitle.isSelectable = false
        subtitle.backgroundColor = nil
        subtitle.text = "0 COLLECTED"
        
        let attributedString = NSMutableAttributedString(string: "\(Artifact.countCompleted()) COMPLETED")
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium),
            NSAttributedStringKey.kern: 2.5,
            NSAttributedStringKey.foregroundColor: UIColor(red: 0.67, green: 0.69, blue: 0.73, alpha: 1.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attributedString.length))
        subtitle.attributedText = attributedString
        
        return subtitle
    }()
    
    fileprivate func setupViewsLayout()
    {
        // Top container
        let topContainer = UIView()
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        topContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 310)
        topContainer.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Top Page Container"))
        view.addSubview(topContainer)
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 310)
            ])
        
        // Top title.
        topContainer.addSubview(topContainerTitle)
        NSLayoutConstraint.activate([
            topContainerTitle.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -33),
            topContainerTitle.leftAnchor.constraint(equalTo: topContainer.leftAnchor),
            topContainerTitle.rightAnchor.constraint(equalTo: topContainer.rightAnchor)
            ])
        
        // Number of artifacts collected.
        topContainer.addSubview(topContainerSubtitle)
        NSLayoutConstraint.activate([
            topContainerSubtitle.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -14),
            topContainerSubtitle.leftAnchor.constraint(equalTo: topContainer.leftAnchor),
            topContainerSubtitle.rightAnchor.constraint(equalTo: topContainer.rightAnchor)
            ])
        
        // Artifact Collection View
        view.addSubview(artifactCollectionView)
        NSLayoutConstraint.activate([
            artifactCollectionView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            artifactCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            artifactCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            artifactCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func showOverlay(artifactName: String, description: String) {
        self.overlayBlurredBackgroundView()
        overlayMode = true
        
        instantiateOverlayContainer(artifactName: artifactName, description: description)
        
        // Set detected artifact back to nil to disable click
    }
    
    func dismissOverlay() {
        
        if let viewWithTag = self.view.viewWithTag(10) {
            viewWithTag.removeFromSuperview()
        }else{
            print("No!")
        }
        
        if let view = self.view.viewWithTag(100) {
            view.removeFromSuperview()
        }else{
            print("No!")
        }
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.tag = 100
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
    }
    
    func instantiateOverlayContainer(artifactName: String, description: String) {
        overlayView = ArtifactDetailOverlay(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        overlayView!.artifact = artifactName
        overlayView!.artifactDescription = description
        overlayView!.tag = 10
        overlayView!.image = UIImage.init(named: "" + artifactName + "Icon")
        overlayView!.parentController = self
        overlayView?.victoryMessageView.text = description
        debugPrint(description)
        view.addSubview(overlayView!)
    }
    
    /** Sets the spacing between collection views. */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /** Sets the number of cells in the collection view. */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artifacts?.count ?? 0
    }
    
    /** Create the sells in the collection view. */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ArtifactCell
        
        let artifact = artifacts![indexPath.item]
        debugPrint(artifact.hint!)
        cell.completed = artifact.completed
        cell.imageName = artifact.title
        
        // Assign artifact details here.
        cell.artifactIcon.image = UIImage(named: artifact.image!)
        cell.artifactTitle.text = artifact.title?.uppercased()
        cell.artifactDescription = artifact.hint!
        cell.artifactSubtitle.text = artifact.completed ? "COLLECTED" : "SCAN TO UNLOCK"
        cell.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.98, alpha: 1.0)
        cell.parentViewController = self
        cell.setupLayout()
        return cell
    }
    
    /** Sets the size of each cell. */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
    /** Hide Status Bar */
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
