//
//  ViewController.swift
//  Wiivv Assignment-1
//
//  Created by Ali Barış Öztekin on 2017-05-18.
//  Copyright © 2017 Ali Barış Öztekin. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {

    @IBOutlet fileprivate weak var currencyLabel: UILabel!
    @IBOutlet fileprivate weak var currencySelector: UIButton!

    @IBOutlet fileprivate weak var navHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var navBarView: UIView!
    @IBOutlet fileprivate weak var listingTableView: UITableView!
   
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    var selectorState:Bool!
    var isLoading = false
    
    let headerDefaultHeight = 60
    let headerExpandedHeight = 100

    var listingDataSource = [Listing]()
    let networkManager = NetworkManager()
    var stackView:UIStackView!
    var selectedCurrency: currencyCode!
    var quoteData:[String:Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        selectorState = false
        isLoading = true
        activityIndicator.startAnimating()
        setupCurrencies()
        networkManager.fetchNewData { listings in
            self.listingDataSource.append(contentsOf: listings)
            self.listingTableView.reloadData()
            self.isLoading = false
            self.activityIndicator.stopAnimating()
        }
        networkManager.getExchangeRates { quotes in
            self.quoteData = quotes
        }
        listingTableView.rowHeight = listingTableView.frame.height/10
    }


    @IBAction func currencySelectorTapped(_ sender: Any) {
        updateCurrencyMenu()
    }

}

extension ViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return listingDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! EtsyTableViewCell
        let listing = listingDataSource[indexPath.row]
        
        if listing.image == nil {
            networkManager.downloadImage(listing, closure: { 
                cell.configureWith(listing)
                
            })
            tableView.reloadData()
        }else {
            cell.configureWith(listingDataSource[indexPath.row])
        }
        return cell
    }
    


}

extension ViewController: UIScrollViewDelegate{
    
    
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
            
            isLoading = true
            activityIndicator.startAnimating()
            networkManager.fetchNewData { newListings in
                self.listingDataSource.append(contentsOf: newListings)
                self.listingTableView.reloadData()
                self.isLoading = false
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
}


extension ViewController {
    
    func updateCurrencyMenu() {
        
        let currentStateRadians: CGFloat
        
        let openStateRadians = CGFloat.pi/2
        let closedStateRadians = CGFloat(0)
        
        let openStateConstraint = CGFloat(headerExpandedHeight)
        let closedStateConstraint = CGFloat(headerDefaultHeight)
        
        if selectorState == false {
            navHeightConstraint.constant = openStateConstraint
            currentStateRadians = openStateRadians
        }else{
            navHeightConstraint.constant = closedStateConstraint
            currentStateRadians = closedStateRadians
        }
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10 , options:[] , animations: {
            
            self.view.layoutIfNeeded()
            self.currencySelector.transform = CGAffineTransform(rotationAngle: currentStateRadians)
            self.updateStackView()
        }, completion: { finished in
            
            self.updateSelector()
            
        })
    }
    
    func setupCurrencies() {
        
        selectedCurrency = .USD
        currencyLabel.text = selectedCurrency.rawValue
        
        let buttonLength = navBarView.frame.width/5
        let cadButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonLength, height: buttonLength))
        let usdButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonLength, height: buttonLength))
        let eurButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonLength, height: buttonLength))
        let gbpButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonLength, height: buttonLength))
        
        let buttons = [cadButton, usdButton, eurButton, gbpButton]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .white
            button.alpha = 1
            button.layer.cornerRadius = 10
            button.setTitleColor(.black , for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    
        
        cadButton.setTitle(currencyCode.CAD.rawValue, for: .normal)
        usdButton.setTitle(currencyCode.USD.rawValue, for: .normal)
        eurButton.setTitle(currencyCode.EUR.rawValue, for: .normal)
        gbpButton.setTitle(currencyCode.GBP.rawValue, for: .normal)
        
        stackView = UIStackView(arrangedSubviews: [cadButton,usdButton,eurButton,gbpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = 16.0

        navBarView.addSubview(stackView)
        stackView.isHidden = true

        let margins = navBarView.layoutMarginsGuide
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
    
    }
    
    func buttonTapped(_ sender: UIButton) {
        let tempCurrency = selectedCurrency
        selectedCurrency = currencyCode(rawValue: (sender.titleLabel?.text)!)
        for listing in listingDataSource{
            convertPrice(listing, from: tempCurrency!, to: selectedCurrency!)
        }
        listingTableView.reloadData()
        currencyLabel.text = selectedCurrency.rawValue
        updateCurrencyMenu()
        
        
    }

    func convertPrice(_ listing:Listing, from:currencyCode, to:currencyCode) {
        
        let tuple : (currencyCode,currencyCode)
        if listing.currency == from {
        tuple = (from,to)
        }else {
        tuple = (listing.currency, to)
        }
        var multiplier = Double()
        guard let price = Double(listing.price) else {return}
        
        switch tuple {
        case (.USD,.USD):
            multiplier = quoteData["USDUSD"]!
        case (.USD,.CAD):
            multiplier = quoteData["USDCAD"]!
        case (.USD,.EUR):
            multiplier = quoteData["USDEUR"]!
        case (.USD,.GBP):
            multiplier = quoteData["USDGBP"]!
        case (.CAD, .USD):
            multiplier = 1.00 / quoteData["USDCAD"]!
        case (.CAD, .EUR):
            multiplier = quoteData["USDEUR"]! * (1.00 / quoteData["USDCAD"]!)
        case (.CAD, .GBP):
            multiplier = quoteData["USDGBP"]! * (1.00 / quoteData["USDCAD"]!)
        case (.EUR, .USD):
            multiplier = 1.00 / quoteData["USDEUR"]!
        case (.EUR, .CAD):
            multiplier = quoteData["USDCAD"]! * (1.00 / quoteData["USDEUR"]!)
        case (.EUR, .GBP):
            multiplier = quoteData["USDGBP"]! * (1.00 / quoteData["USDEUR"]!)
        case (.GBP, .USD):
            multiplier = 1.00 / quoteData["USDGBP"]!
        case (.GBP, .CAD):
            multiplier = quoteData["USDCAD"]! * (1.00 / quoteData["USDGBP"]!)
        case (.GBP, .EUR):
            multiplier = quoteData["USDEUR"]! * (1.00 / quoteData["USDGBP"]!)
        default:
            break
        }
        listing.price = String(format: "%.2f", price * multiplier)
        listing.currency = to

    }
    
    func updateSelector() {
        selectorState = !selectorState
    }
    
    func updateStackView() {
        stackView.isHidden = !stackView.isHidden
    }
}






