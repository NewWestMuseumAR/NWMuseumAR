//
//  ArtifactCell.swift
//  NewWestAr
//
//  Created by Justin Leung on 4/10/18.
//  Copyright © 2018 Justin Leung. All rights reserved.
//

import UIKit

class ArtifactCell: UICollectionViewCell
{
    /** Artifact Image  */
    let artifactIcon: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "ARTIFACT - Wayfinding"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    /** Artifact Status Icon */
    let artifactStatusIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        image.image = #imageLiteral(resourceName: "Locked")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    /** Artifact Title */
    let artifactTitle: UITextView = {
        let title = UITextView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.heavy)
        title.textColor = UIColor(red: 0.44, green: 0.46, blue: 0.53, alpha: 1.0)
        title.isEditable = false
        title.isScrollEnabled = false
        title.isSelectable = false
        title.text = "WAYFINDING"
        return title
    }()
    
    /** Article Button TBD With Artifact Status */
    var artifactButton: UIButton?
    
    /** Subtitle */
    let artifactSubtitle: UITextView = {
        let subtitle = UITextView()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textAlignment = .center
        subtitle.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        subtitle.textColor = UIColor(red: 0.73, green: 0.73, blue: 0.74, alpha: 1.0)
        subtitle.isEditable = false
        subtitle.isScrollEnabled = false
        subtitle.isSelectable = false
        subtitle.text = "GET TO THE MUSEUM"
        return subtitle
    }()
    
    /** Button Wayfinding Style */
    let artifactButtonWayfinding: UIButton = {
        let button = UIButton()
        button.setTitle("START", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 0.69, green: 0.73, blue: 0.76, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        button.layer.cornerRadius = 17
        return button
    }()
    
    /** Button Unlocked Style */
    let artifactButtonUnlocked: UIButton = {
        let button = UIButton()
        button.setTitle("VIEW", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 0.69, green: 0.73, blue: 0.76, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        button.layer.cornerRadius = 17
        return button
    }()
    
    /** Button Locked Style */
    let artifactButtonLocked: UIButton = {
        let button = UIButton()
        button.setTitle("UNLOCK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 0.99, green: 0.50, blue: 0.51, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor(red: 0.99, green: 0.93, blue: 0.91, alpha: 1.0)
        button.layer.cornerRadius = 17
        return button
    }()
    
    /** Artifact Cell Container */
    let artifactCellContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.03
        container.layer.shadowOffset = CGSize.zero
        container.layer.shadowRadius = 4
        container.layer.cornerRadius = 10
        return container
    }()
    
    /** Container for the icon */
    let iconContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    /** Container for the titles */
    let titleContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    /** Container for the button */
    let buttonContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    /** Initial Load. */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    /** Required for overridding cell. */
    required init?(coder aDecoder: NSCoder) {
        fatalError("Problem")
    }
    
    /** Setup layout for artifact cell. */
    fileprivate func setupLayout()
    {
        // TODO: Add more logic to decide button.
        artifactButton = artifactButtonWayfinding
        artifactButton = artifactButtonUnlocked
        artifactButton = artifactButtonLocked
        
        // TODO: Add more logic to decide locked/unlocked icon.
        artifactStatusIcon.image = #imageLiteral(resourceName: "Locked")
        artifactStatusIcon.image = #imageLiteral(resourceName: "Unlocked")
        
        /** Add Views */
        addSubview(artifactCellContainer)
        artifactCellContainer.addSubview(iconContainer)
        iconContainer.addSubview(artifactIcon)
        artifactCellContainer.addSubview(titleContainer)
        titleContainer.addSubview(artifactTitle)
        titleContainer.addSubview(artifactSubtitle)
        artifactCellContainer.addSubview(buttonContainer)
        buttonContainer.addSubview(artifactButton!)
        iconContainer.addSubview(artifactStatusIcon)
        
        /** Constraints */
        NSLayoutConstraint.activate([
            
            // Cell background/containter.
            artifactCellContainer.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            artifactCellContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            artifactCellContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -25),
            artifactCellContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            // Icon Container
            iconContainer.leftAnchor.constraint(equalTo: artifactCellContainer.leftAnchor),
            iconContainer.topAnchor.constraint(equalTo: artifactCellContainer.topAnchor),
            iconContainer.bottomAnchor.constraint(equalTo: artifactCellContainer.bottomAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 90),
            
            // Artifact Icon Overlay Status
            artifactStatusIcon.leftAnchor.constraint(equalTo: iconContainer.leftAnchor, constant: 30),
            artifactStatusIcon.rightAnchor.constraint(equalTo: iconContainer.rightAnchor, constant: -24),
            artifactStatusIcon.topAnchor.constraint(equalTo: iconContainer.topAnchor, constant: 30),
            artifactStatusIcon.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: -30),
            
            // Icon
            artifactIcon.leftAnchor.constraint(equalTo: iconContainer.leftAnchor, constant: 10),
            artifactIcon.rightAnchor.constraint(equalTo: iconContainer.rightAnchor, constant: -4),
            artifactIcon.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            artifactIcon.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            
            // Title container
            titleContainer.leftAnchor.constraint(equalTo: artifactCellContainer.leftAnchor, constant: 93),
            titleContainer.topAnchor.constraint(equalTo: artifactCellContainer.topAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: artifactCellContainer.bottomAnchor),
            titleContainer.widthAnchor.constraint(equalToConstant: 123),
            
            // Title
            artifactTitle.leftAnchor.constraint(equalTo: titleContainer.leftAnchor, constant: -6),
            artifactTitle.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 17),
            artifactTitle.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            
            // Subtitle
            artifactSubtitle.leftAnchor.constraint(equalTo: titleContainer.leftAnchor, constant: -5),
            artifactSubtitle.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 45),
            artifactSubtitle.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            
            // Button Container
            buttonContainer.rightAnchor.constraint(equalTo: artifactCellContainer.rightAnchor),
            buttonContainer.topAnchor.constraint(equalTo: artifactCellContainer.topAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: artifactCellContainer.bottomAnchor),
            buttonContainer.widthAnchor.constraint(equalToConstant: 115),
            
            // Button
            artifactButton!.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor),
            artifactButton!.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor, constant: -22),
            artifactButton!.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 30),
            artifactButton!.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: -30),
            ])
    }
    
}
