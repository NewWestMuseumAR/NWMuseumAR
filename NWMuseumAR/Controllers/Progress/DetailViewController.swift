//
//  DetailViewController.swift
//  NWMuseumAR
//
//  Created by Castiel Li on 2018-03-02.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var artifactImageView: UIImageView!
    @IBOutlet weak var artifactTitle: UILabel!
    @IBOutlet weak var artifactDesc: UILabel!
    
    var artifact : Artifact?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        self.navigationController?.navigationBar.backItem?.title = "Back"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //set up the UI by using the Artifact object was pssed in from master view
    func setUI() {
        artifactImageView.image = UIImage(named: artifact!.icon!)
        artifactTitle.text = artifact?.desc
        artifactDesc.text = artifact?.desc
    }
}

