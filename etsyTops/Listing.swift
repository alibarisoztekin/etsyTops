//
//  Listing.swift
//  Wiivv Assignment-1
//
//  Created by Ali Barış Öztekin on 2017-05-18.
//  Copyright © 2017 Ali Barış Öztekin. All rights reserved.
//

import UIKit


enum currencyCode: String{
    case USD = "USD", CAD = "CAD", GBP = "GBP", EUR = "EUR"
}



class Listing: NSObject {
    
    var listingID: Int
    var title: String
    var price: String
    var image: UIImage?
    var imageURL: URL?
    var currency: currencyCode
    
    init(id:Int, title: String, price: String, currency:currencyCode){
        self.listingID = id
        self.title = title
        self.price = price
        self.currency = currency
        super.init()
    }
    

}
