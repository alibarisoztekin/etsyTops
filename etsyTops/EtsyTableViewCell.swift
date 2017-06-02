//
//  EtsyTableViewCell.swift
//  Wiivv Assignment-1
//
//  Created by Ali Barış Öztekin on 2017-05-18.
//  Copyright © 2017 Ali Barış Öztekin. All rights reserved.
//

import UIKit


class EtsyTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var listingPrice: UILabel!
    @IBOutlet fileprivate weak var listingTitle: UILabel!
    @IBOutlet fileprivate weak var listingImageView: UIImageView!
    
    var listing:Listing!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listingImageView.image = #imageLiteral(resourceName: "Placeholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWith(_ newListing:Listing) {
        listing = newListing
    
        listingImageView.image = listing.image
        
        listingTitle.text = listing.title
        listingPrice.text = listing.price

    }
    

    
 
    
     
    
}
