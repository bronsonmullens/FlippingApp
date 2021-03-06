//
//  InventoryViewController.swift
//  FlippingApp
//
//  Created by Bronson Mullens on 2/12/21.
//

import UIKit

protocol InventoryDelegate {
    func itemWasDeleted()
}

class InventoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: - Properties
    
    var itemController: ItemController?
    var filteredItems: [Item]!
    var searchType: String!
    var viewingSold: Bool?
    var filteringByTag: Bool = false
    var delegate: InventoryDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        filteringByTag.toggle()
        filteringByTag ? filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), for: .normal) : filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        filterButton.contentScaleFactor = 1
        changeSearchBarPlaceholder()
        searchBar.text?.removeAll()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        changeSearchBarPlaceholder()
        configureColors()
    }
    
    func configureColors() {
        view.backgroundColor = UIColor(named: "Background")
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.separatorColor = UIColor(named: "Background")
        filterButton.tintColor = UIColor(named: "Text")
        doneButton.tintColor = UIColor(named: "Text")
        doneButton.setTitleColor(UIColor(named: "Text"), for: .normal)
        searchBar.barTintColor = UIColor(named: "Background")
        searchBar.tintColor = UIColor(named: "Foreground")
    }
    
    // MARK: - Methods
    
    func changeSearchBarPlaceholder() {
        if let viewingSold = viewingSold {
            if viewingSold {
                searchBar.placeholder = "Search for a sold item"
            } else {
                searchBar.placeholder = "Search for an item's name"
            }
        }
        
        if filteringByTag {
            searchBar.placeholder = "Search for a tag"
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = NumberFormatter()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        
        formatter.numberStyle = .decimal
        cell.itemNameLabel.text = filteredItems[indexPath.row].title
        cell.itemQuantityLabel.text = "Quantity: \(formatter.string(from: (filteredItems[indexPath.row].quantity) as NSNumber) ?? "")"
        cell.backgroundColor = UIColor(named: "Foreground")
        
        formatter.numberStyle = .currency
        if let soldPrice = filteredItems[indexPath.row].soldPrice {
            let formattedNumber = formatter.string(from: soldPrice*Double(filteredItems[indexPath.row].quantity) as NSNumber)
            cell.valueLabel.text = "\(formattedNumber ?? "-1")"
        } else {
            let listingPrice = filteredItems[indexPath.row].listingPrice
            let formattedNumber = formatter.string(from: listingPrice*Double(filteredItems[indexPath.row].quantity) as NSNumber)
            cell.valueLabel.text = "\(formattedNumber ?? "-1")"
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if filteringByTag {
            if searchType == "inventory" {
                guard let data = itemController?.inventory else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.tag?.range(of: searchText, options: .caseInsensitive) != nil
                })
            } else if searchType == "soldItems" {
                guard let data = itemController?.soldItems else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.tag?.range(of: searchText, options: .caseInsensitive) != nil
                })
            } else if searchType == "selling" {
                guard let data = itemController?.inventory else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.tag?.range(of: searchText, options: .caseInsensitive) != nil
                })
            }
        } else {
            if searchType == "inventory" {
                guard let data = itemController?.inventory else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.title.range(of: searchText, options: .caseInsensitive) != nil
                })
            } else if searchType == "soldItems" {
                guard let data = itemController?.soldItems else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.title.range(of: searchText, options: .caseInsensitive) != nil
                })
            } else if searchType == "selling" {
                guard let data = itemController?.inventory else { return }
                filteredItems = searchText.isEmpty ? data : data.filter({(item: Item) -> Bool in
                    return item.title.range(of: searchText, options: .caseInsensitive) != nil
                })
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if let viewingSold = viewingSold {
                if !viewingSold {
                    itemController?.deleteItem(with: filteredItems[indexPath.row])
                    filteredItems.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    delegate?.itemWasDeleted()
                } else {
                    itemController?.deleteItem(with: filteredItems[indexPath.row])
                    filteredItems.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    delegate?.itemWasDeleted()
                }
            }
        
        if filteredItems.count == 0 { dismiss(animated: true, completion: nil) }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    // MARK: - Row selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if searchType == "selling" {
                guard let saleVC = storyboard?.instantiateViewController(identifier: "SaleVC") as? ItemSaleViewController else { return }
                saleVC.itemController = itemController
                saleVC.item = filteredItems[indexPath.row]
                saleVC.delegate = self
                present(saleVC, animated: true, completion: nil)
            } else if searchType == "inventory" {
                guard let editVC = storyboard?.instantiateViewController(identifier: "EditVC") as? EditItemViewController else { return }
                editVC.itemController = itemController
                editVC.item = filteredItems[indexPath.row]
                editVC.delegate = self
                editVC.index = indexPath.row
                present(editVC, animated: true, completion: nil)
            } else if searchType == "soldItems" {
                guard let popOverVC = storyboard?.instantiateViewController(identifier: "SoldItemInfoVC") as? SoldItemInfoViewController else { return }
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                popOverVC.item = filteredItems[indexPath.row]
                popOverVC.itemController = itemController
                popOverVC.modalPresentationStyle = .popover
                popOverVC.preferredContentSize = CGSize(width: 220, height: self.view.bounds.height/2)
                popOverVC.popoverPresentationController?.delegate = self
                popOverVC.popoverPresentationController?.sourceRect = CGRect(origin: cell.center, size: .zero)
                popOverVC.popoverPresentationController?.sourceView = tableView
                present(popOverVC, animated: true, completion: nil)
            }
    }
    
}

// MARK: - Protocol methods

extension InventoryViewController: ItemControllerDelegate {
    
    func saleWasMade() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension InventoryViewController: EditItemDelegate {
    
    func itemWasEdited() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension InventoryViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
