//
//  NetworkManager.swift
//  Wiivv Assignment-1
//
//  Created by Ali Barış Öztekin on 2017-05-18.
//  Copyright © 2017 Ali Barış Öztekin. All rights reserved.
//

import UIKit



class NetworkManager: NSObject {
    
    var listingOffset = 0

    func fetchNewData(closure:@escaping([Listing]) -> Void ) {
        listingOffset += 10
        fetchListings { newListings in
            OperationQueue.main.addOperation {
                closure(newListings)
            }
        }
    }
    
    
    fileprivate func fetchListings(closure:@escaping([Listing]) -> Void ){
        
        guard let url = URL(string:"https://openapi.etsy.com/v2/listings/trending?api_key=6ob8rkn0fs6jlxip9gmftm3t&limit=10&offset=\(listingOffset)") else {
            return
        }
       
       URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            var listings = [Listing]()
            if error != nil {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("data is empty")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options:
                []) as! Dictionary<String,Any> else { return }
            guard let results = json["results"] as! Array<Dictionary<String,Any>>? else {return}
            
            
            
            for listingJSON in results {
                
                
                guard let listingID = listingJSON["listing_id"] as! Int? else {
                    print("ID failed")
                    break}
                guard let listingTitle = listingJSON["title"] as! String? else {
                    print("title failed ")
                    break}
                guard let listingPrice = listingJSON["price"] as! String? else {
                    print("price failed")
                    break}
                guard let listingCurrency = currencyCode(rawValue: (listingJSON["currency_code"] as! String)) else {
                    print("curency failed")
                    break}
                let newListing = Listing(id: listingID, title: listingTitle, price: listingPrice, currency: listingCurrency)
                self.fetchImageURL(newListing)
                listings.append(newListing)
                print(listings.count)

            }
            closure(listings)
        }.resume()
        
    }
    
    func fetchImageURL(_ listing:Listing) {
        
        let baseURLString =  "https://openapi.etsy.com/v2/listings/"
        let endURLString = "/images?api_key=6ob8rkn0fs6jlxip9gmftm3t"
        

            let urlString = baseURLString.appending(String(listing.listingID)).appending(endURLString)
            guard let url = URL(string: urlString) else {return}
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                
                if error != nil {
                    print(error!)
                    return
                }
                
                guard let data = data else {
                    print("data is empty")
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options:
                    []) as! Dictionary<String,Any> else { return }
                
                guard let listingImages = json["results"] as! Array<Dictionary<String,Any>>? else {return}
                
                guard let imageURLString = listingImages.first?["url_75x75"] as! String? else {return}
                
                listing.imageURL = URL(string: imageURLString)
                
            }.resume()
            

        }
    
    func downloadImage(_ listing:Listing, closure:@escaping ()-> Void)  {
        
        guard let url = listing.imageURL else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            OperationQueue.main.addOperation {
                listing.image = image
                closure()
            }
            
        }.resume()
        
    }
    
    func getExchangeRates(_ closure:@escaping ([String:Double]) -> Void ){
        
        let url = URL(string: "http://apilayer.net/api/live?access_key=9651b48ab8bb2b256b4616b435c54501&currencies=USD,CAD,EUR,GBP&format=1")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            print("YSYSY")
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
                else { return }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else {return}
            
            guard let quotes = json["quotes"] as! [String:Double]? else {return}
           
            OperationQueue.main.addOperation {
                closure(quotes)
                print("WEWEWEW")
            }
        }.resume()
}

}


