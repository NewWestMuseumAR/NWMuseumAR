//
//  VuforiaView.swift
//  NWMuseumAR
//
//  Created by Hamish Brindle on 2018-03-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class VuforiaView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // Do stuff here
    }
}
