//
//  OverlayView.swift
//  NWMuseumAR
//
//  Created by Sheldon Lynn on 2018-04-10.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    @IBAction func continueButton(_ sender: Any) {
        performSeque()
    }
    weak var parentController: UIViewController?
    
    var caption: String? {
        get { return labelView?.text }
        set { labelView.text = newValue }
    }
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
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
    }
    
    func performSeque() {
        let progressViewController = UIStoryboard(name: "Progress", bundle: nil).instantiateViewController(withIdentifier: "progress") as! ProgressViewController
        parentController?.show(progressViewController, sender: nil)
    }

}
