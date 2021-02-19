//
//  SettingsViewController.swift
//  FlippingApp
//
//  Created by Bronson Mullens on 2/12/21.
//

import UIKit
import StoreKit

struct IAP {
    var name: String
    var handler: (() -> Void)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    var itemController: ItemController?
    var delegate: AddItemViewControllerDelegate?
    var settings: [String] = [
        "🗞 What's New?",
        "🐦 Twitter",
        "💰 Tip Jar",
        "🆘 Helpful Tips",
        "🦻🏻 Feedback",
        "⭐️ Rate the App",
        "⚖️ Privacy Policy",
        "🗑 Erase All Data",
    ]
    var IAPs = [IAP]()
    var totalTipped: Double {
        return UserDefaults.standard.double(forKey: "tipped")
    }

    // MARK: - IBOutlets

    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        appendIAPs()
        configureNavBar()
    }

    func updateViews() {
        appVersionLabel.text = "App Version \(UIApplication.appVersion!)"
        appLogoImageView.layer.cornerRadius = 16
    }

    // MARK: - Methods

    func whatsNew() {
        let alert = UIAlertController(title: "\(UIApplication.appVersion!) Notes", message:
                """
                - Change: Overhauled the UI
                - Feature: Added settings page
                - Feature: Implemented tip jar
                - Bug fix: Filtering inventory in the pre-sale screen now works as expected.
                """
                                      , preferredStyle: .alert)
        let action = UIAlertAction(title: "Awesome!", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func twitter() {
        let screenName = "bronsonmullens"
        let appURL = URL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = URL(string: "https://twitter.com/\(screenName)")!

        let application = UIApplication.shared

           if application.canOpenURL(appURL as URL) {
                application.open(appURL)
           } else {
                application.open(webURL)
           }
    }

    func tipJar() {
        let alert = UIAlertController(title: "Tip Jar", message: "Thank you for your generosity. All tips go toward the continuous development of my apps.", preferredStyle: .actionSheet)
        let tier1TipAction = UIAlertAction(title: "Small tip ($0.99)", style: .default) { (_) in
            self.IAPs[0].handler()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(tier1TipAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func helpfulTips() {
        let helpMessage =
        """
        Begin by adding an item to your inventory. After saving, the item will be added and your inventory value will update. Tap on the report a sale button when one of your items sells. If you'd like to remove or edit your item prior to a sale, open your inventory and locate your item.
        """
        let alert = UIAlertController(title: "How to use this app",
                                      message: helpMessage,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }

    func feedback() {
        let email: String = "bronsonmullens@icloud.com"
        let alert = UIAlertController(title: "Submit Feedback", message: "Whether it's a bug report, feature request, or general feedback, I'd love to hear from you. Send me an email at \(email).", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func rateTheApp() {
        SKStoreReviewController.requestReview()
    }

    func privacyPolicy() {
        let privacyPolicyURL = URL(string: "https://github.com/bronsonmullens/FlippingApp/blob/main/PrivacyPolicy.MD")!
        let application = UIApplication.shared
        application.open(privacyPolicyURL)
    }

    func eraseData() {
        let alert = UIAlertController(title: "Warning!", message: "Proceeding will permanently delete all stored user data. This includes all sales, profit, inventory, and tags. This cannot be reversed.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "I Understand", style: .destructive) { (_) in
            UserDefaults.standard.setValue(false, forKey: "gnomes")
            self.itemController?.resetData()
            self.delegate?.itemWasAdded()
        }
        let cancel = UIAlertAction(title: "Nevermind", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func appendIAPs() {
        IAPs.append(IAP(name: "Small Tip", handler: {
            IAPManager.shared.purchase(product: .tier1Tip) { [weak self] tipped in
                DispatchQueue.main.async {
                    let currentTipped = self?.totalTipped ?? 0
                    let newTipped = currentTipped + tipped
                    UserDefaults.standard.setValue(newTipped, forKey: "tipped")
                }
            }
        }))
    }
    
    func configureNavBar() {
        if self.traitCollection.userInterfaceStyle == .dark {
            navigationController?.navigationBar.barTintColor = .black
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x457b9d)]
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsCell
        cell.settingTypeLabel.text = settings[indexPath.row]
        if cell.settingTypeLabel.text == "🗑 Erase All Data" {
            cell.settingTypeLabel.textColor = .systemRed
            cell.settingTypeLabel.font = .boldSystemFont(ofSize: 16)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch settings[indexPath.row] {
        case "🗞 What's New?":
            whatsNew()
        case "🐦 Twitter":
            twitter()
        case "💰 Tip Jar":
            tipJar()
        case "🆘 Helpful Tips":
            helpfulTips()
        case "🦻🏻 Feedback":
            feedback()
        case "⭐️ Rate the App":
            rateTheApp()
        case "⚖️ Privacy Policy":
            privacyPolicy()
        case "🗑 Erase All Data":
            eraseData()
        default:
            NSLog("Error occured when attempting to select a settings option.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
