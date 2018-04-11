//
//  ArtifactDetailView.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-04-11.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import Lottie

class ArtifactDetailOverlay: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var contButton: UIButton!
    
    @IBOutlet weak var topTextView: UILabel!
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var victoryMessageView: UITextView!
    @IBOutlet weak var artifactTitleView: UILabel!
    @IBOutlet weak var artifactImageView: UIImageView!
    
    // title.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.heavy)
    
    @IBAction func continueButton(_ sender: Any) {
        performSeque()
    }
    weak var parentController: UIViewController?
    
    var artifact: String? {
        get { return artifactTitleView?.text }
        set { artifactTitleView.text = newValue }
    }
    
    var image: UIImage? {
        get { return artifactImageView.image }
        set { artifactImageView.image = newValue }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "OverlayView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setupViewsLayout()
    }
    
    fileprivate func setupViewsLayout()
    {
        setupTopTextView()
        setupLottieAnimation()
        setupArtifactImage()
        setupArtifactTitle()
        setupVictoryMessage()
        setupContinueButton()
    }
    
    func setupTopTextView() {
        topTextView.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.heavy)
    }
    
    func setupLottieAnimation() {
        let animationView: LOTAnimationView = LOTAnimationView(name: "lottie_confetti_data")
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: 0, y: 0, width: lottieView.frame.width, height: lottieView.frame.height)
        lottieView.addSubview(animationView)
        animationView.loopAnimation = true
        animationView.play()
    }
    
    func setupArtifactImage() {
        //lottieView.bringSubview(toFront: artifactImageView)
        //artifactImageView.image = UIImage(named: "ARTIFACT - Fire.png")
    }
    
    func setupArtifactTitle() {
        artifactTitleView.font = UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.heavy)
    }
    
    func setupVictoryMessage() {
        victoryMessageView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        victoryMessageView.backgroundColor = nil
        victoryMessageView.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        victoryMessageView.textAlignment = .center
    }
    
    func setupContinueButton() {
        contButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal)
        contButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        contButton.layer.cornerRadius = 24
    }
    
    func performSeque() {
        let progressViewController = ProgressViewController()
        parentController?.show(progressViewController, sender: nil)
    }
}
