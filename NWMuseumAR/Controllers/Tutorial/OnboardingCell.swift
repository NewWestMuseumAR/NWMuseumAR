//
//  OnboardingCell.swift
//  NewWestAr
//
//  Created by Justin Leung on 4/10/18.
//  Copyright © 2018 Justin Leung. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    /** Top image  */
    let tutorialImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Onboarding_1"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /** Title */
    let titleTextView: UITextView = {
        let title = UITextView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 26)
        title.textColor = .mainTitleDark
        title.isEditable = false
        title.isScrollEnabled = false
        title.isSelectable = false
        title.backgroundColor = nil
        return title
    }()
    
    /** Subtitle */
    let subtitleTextView: UITextView = {
        let subtitle = UITextView()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textAlignment = .center
        subtitle.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.ultraLight)
        subtitle.textColor = .mainGray
        subtitle.isEditable = false
        subtitle.isScrollEnabled = false
        subtitle.isSelectable = false
        subtitle.backgroundColor = nil
        return subtitle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    /**
     * Sets up the layout.
     */
    private func setupLayout()
    {
        // Add title and subtitles.
        addSubview(titleTextView)
        addSubview(subtitleTextView)
        
        // Image Container Layout.
        let topImageContainerView = UIView()
        addSubview(topImageContainerView)
        topImageContainerView.addSubview(tutorialImageView)
        topImageContainerView.backgroundColor = nil
        topImageContainerView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        topImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topImageContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            topImageContainerView.topAnchor.constraint(equalTo: topAnchor),
            topImageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topImageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
        // Image Layout.
        NSLayoutConstraint.activate([
            tutorialImageView.topAnchor.constraint(equalTo: topAnchor, constant: 110),
            tutorialImageView.centerXAnchor.constraint(equalTo: topImageContainerView.centerXAnchor),
            tutorialImageView.centerYAnchor.constraint(equalTo: topImageContainerView.centerYAnchor),
            tutorialImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.36)
            ])
        
        // Title Layout and Text Set.
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: tutorialImageView.bottomAnchor, constant: 28),
            titleTextView.leftAnchor.constraint(equalTo: leftAnchor),
            titleTextView.rightAnchor.constraint(equalTo: rightAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: subtitleTextView.topAnchor, constant: 11)
            ])
        
        // Set title the tutorial pages title.
        let attributedString = NSMutableAttributedString(string: "DISCOVER")
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .center
        attributedString.addAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 48, weight: UIFont.Weight.black),
            NSAttributedStringKey.kern: 3,
            NSAttributedStringKey.foregroundColor: UIColor(red: 0.26, green: 0.28, blue: 0.37, alpha: 1.0),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attributedString.length))
        titleTextView.attributedText = attributedString
        
        // Subtitle Layout.
        NSLayoutConstraint.activate([
            subtitleTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor),
            subtitleTextView.leftAnchor.constraint(equalTo: leftAnchor),
            subtitleTextView.rightAnchor.constraint(equalTo: rightAnchor),
            subtitleTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ])
        subtitleTextView.text = "Walk Around and Explore The Museum"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Problem")
    }
}

/**
 * Extension for UIColor to help provide easier access
 * to primary application colors.
 */
extension UIColor
{
    static var mainRed = UIColor(red: 0.93, green: 0.51, blue: 0.51, alpha: 1.0)
    static var mainLightRed = UIColor(red:0.98, green: 0.90, blue: 0.90, alpha: 1.0)
    static var mainTitleDark = UIColor(red: 0.26, green: 0.28, blue: 0.37, alpha: 1.0)
    static var mainGray = UIColor(red: 0.67, green: 0.69, blue: 0.73, alpha: 1.0)
    static var mainBackground = UIColor(red: 0.9765, green: 0.9765, blue: 0.9804, alpha: 1.0)
}
