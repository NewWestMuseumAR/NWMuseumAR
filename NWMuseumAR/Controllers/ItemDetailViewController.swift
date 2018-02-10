//
//  ItemDetailViewController.swift
//  Displays an item in detail
//  NWMuseumAR
//
//  Created by Quincy Lam on 2018-02-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController{
    
    //Targets the Detail Tex
    @IBOutlet weak var ItemTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let item1 = ItemDetail(id: 1, name: "Ducks")
        item1.setDescription(desc: "ducks are cool")
        item1.setImagePath(path: "SomewhereLand")

        item1.toString()
        
      }
  }

