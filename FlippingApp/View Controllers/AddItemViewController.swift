//
//  AddItemViewController.swift
//  FlippingApp
//
//  Created by Bronson Mullens on 2/12/21.
//

import UIKit

protocol AddItemViewControllerDelegate {
    func itemWasAdded()
}

class AddItemViewController: UIViewController {
    
    // MARK: - Properties
    
    var itemController: ItemController?
    var delegate: AddItemViewControllerDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var purchasePriceTextField: UITextField!
    @IBOutlet weak var listingPriceTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var tagTextView: UITextView!
    @IBOutlet weak var tagButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if titleTextField.text == "Gnomes!" {
            UserDefaults.standard.setValue(true, forKey: "gnomes")
        } else if titleTextField.text == "Gnomes Be Gone!" {
            UserDefaults.standard.setValue(false, forKey: "gnomes")
        }

        if let title = titleTextField.text,
           !title.isEmpty,
           let purchasePrice = purchasePriceTextField.text,
           !purchasePrice.isEmpty,
           let listingPrice = listingPriceTextField.text,
           !listingPrice.isEmpty,
           let quantity = quantityTextField.text,
           !quantity.isEmpty {
            let item = Item(title: title,
                            purchasePrice: Double(purchasePrice) ?? -1,
                            listingPrice: Double(listingPrice) ?? -1,
                            quantity: Int(quantity) ?? -1,
                            tag: tagTextView.text)
            itemController?.addListedItem(with: item)
            delegate?.itemWasAdded()
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Hold on there...", message: "Are you sure you gave each text field a valid input? Check and try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            UIView.animate(withDuration: 5) {
                if self.titleTextField.text == "" {
                    self.titleTextField.backgroundColor = .systemRed
                    self.titleTextField.backgroundColor = .none
                }
                if self.purchasePriceTextField.text == "" {
                    self.purchasePriceTextField.backgroundColor = .systemRed
                    self.purchasePriceTextField.backgroundColor = .none
                }
                if self.listingPriceTextField.text == "" {
                    self.listingPriceTextField.backgroundColor = .systemRed
                    self.listingPriceTextField.backgroundColor = .none
                }
                if self.quantityTextField.text == "" {
                    self.quantityTextField.backgroundColor = .systemRed
                    self.quantityTextField.backgroundColor = .none
                }
            }
            
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.becomeFirstResponder()
        configureViews()
    }
    
    func configureViews() {
        if self.traitCollection.userInterfaceStyle == .dark {
            navigationController?.navigationBar.barTintColor = .black
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x457b9d)]
        
        tagTextView.layer.borderWidth = 1
        tagTextView.layer.borderColor = UIColor.systemGray.cgColor
        tagTextView.layer.opacity = 0.25
        tagTextView.layer.cornerRadius = 4
        tagTextView.backgroundColor = .clear
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPopOver" {
            guard let popOverVC = segue.destination as? TagTableViewController else { return }
            popOverVC.itemController = itemController
            popOverVC.preferredContentSize = CGSize(width: 150, height: 150)
            popOverVC.modalPresentationStyle = .popover
            popOverVC.popoverPresentationController?.delegate = self
            popOverVC.popoverPresentationController?.sourceRect = CGRect(origin: tagTextView.center, size: .zero)
            popOverVC.popoverPresentationController?.sourceView = tagTextView
            popOverVC.delegate = self
        }
    }
    
}

extension AddItemViewController: TagDataDelegate {
    func passData(_ tag: String) {
        print(tag)
        tagTextView.text = tag
    }
}

extension AddItemViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
