//
//  ItemDetail.swift
//  A model for the details of the items
//  NWMuseumAR
//
//  Created by Quincy Lam on 2018-02-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import Foundation

class ItemDetail {
  
    //Item Id
    var itemId: Int
    
    //Item Name
    var itemName: String?
    
    //Item Description
    var description: String?
    
    //Image Path
    var imagePath: String?
    
    //Initialize item Id and name
    init(id: Int, name: String?) {
        itemId = id
        itemName = name
    }
    
    //Set the description for the item
    func setDescription(desc: String) {
        self.description = desc
    }
    
    //Set the image path for the item
    func setImagePath(path: String) {
        self.imagePath = path
    }
    
    func toString() {
        let stringId = String(itemId)
        let id = "Id: " + stringId
        let name = " ItemName: " + itemName!
        let description = " Description: " + self.description!
        let image = " Image: " + self.imagePath!
        
        print(id + name + description + image)
    }
}
