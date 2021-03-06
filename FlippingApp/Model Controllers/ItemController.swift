//
//  ItemController.swift
//  FlippingApp
//
//  Created by Bronson Mullens on 2/12/21.
//

import UIKit

protocol ItemControllerDelegate {
    func saleWasMade()
    func itemWasEdited()
}

class ItemController {
    
    // MARK: - Properties
    
    var inventory: [Item] = []
    var soldItems: [Item] = []
    var tags: [String] = []
    
    var sales = 0
    var inventoryValue: Double = 0
    var profit: Double = 0
    
    var delegate: ItemControllerDelegate?
    
    // MARK: - CRUD Methods
    
    func addListedItem(with item: Item) {
        inventory.append(item)
        save()
    }
    
    func addTag(with tag: String) -> Bool {
        if tags.contains(tag) {
            return false
        } else {
            tags.append(tag)
            save()
            return true
        }
    }
    
    func editItem(with item: Item, replacing oldItem: Item, at index: Int) {
        if inventory[index] == oldItem {
            inventory[index] = item
        }
        delegate?.itemWasEdited()
        save()
    }
    
    func deleteItem(with item: Item) {
        if inventory.contains(item) {
            inventory.removeAll(where: { $0 == item })
        } else if soldItems.contains(item) {
            soldItems.removeAll(where: { $0 == item })
        } else {
            NSLog("Error: Could not remove nonexistent item")
        }
        save()
    }
    
    func deleteTag(with tag: String) {
        if tags.contains(tag) {
            tags.removeAll(where: { $0 == tag })
            save()
        }
    }
    
    func eraseAllInventory() {
        inventory.removeAll()
        save()
    }
    
    func eraseAllSoldItems() {
        soldItems.removeAll()
        save()
    }
    
    func eraseAllTags() {
        tags.removeAll()
        for item in inventory {
            item.tag = nil
        }
        for item in soldItems {
            item.tag = nil
        }
        save()
    }
    
    func eraseAllData() {
        soldItems.removeAll()
        inventory.removeAll()
        tags.removeAll()
        save()
    }
    
    func processSale(sold item: Item, listed oldItem: Item) {
        soldItems.append(item)
        if oldItem.quantity == 1 {
            if inventory.contains(oldItem) {
                inventory.removeAll(where: { $0 == oldItem })
            }
        } else {
            oldItem.quantity -= item.quantity
        }
        if oldItem.quantity == 0 {
            inventory.removeAll(where: { $0 == oldItem })
        }
        delegate?.saleWasMade()
        save()
    }
    
    // MARK: - Calculations
    
    func calculateInventoryValue() -> Double {
        inventoryValue = 0
        
        for item in inventory {
            if item.quantity > 1 {
                var count = item.quantity
                while count > 0 {
                    inventoryValue += item.listingPrice
                    count -= 1
                }
            } else if item.quantity == 1 {
                inventoryValue += item.listingPrice
            } else {
                continue
            }
        }
        
        return inventoryValue
    }
    
    func calculateInventoryQuantity() -> Int {
        var quantity = 0
        
        for item in inventory {
            if item.quantity > 1 {
                var count = item.quantity
                while count > 0 {
                    quantity += 1
                    count -= 1
                }
            } else {
                quantity += 1
            }
        }
        
        return quantity
    }
    
    func calculateProfit() -> Double {
        profit = 0
        
        for item in soldItems {
            if item.quantity > 1 {
                var count = item.quantity
                while count > 0 {
                    if let soldPrice = item.soldPrice {
                        profit += (soldPrice) - item.purchasePrice
                        count -= 1
                    }
                }
            } else if item.quantity == 1 {
                if let soldPrice = item.soldPrice {
                    profit += (soldPrice) - item.purchasePrice
                }
            } else {
                continue
            }
        }
        
        return profit
    }
    
    func calculateSales() -> Int {
        sales = 0
        sales += soldItems.count
        return sales
    }
    
    func calculateRecentlyListedPrice() -> Double? {
        guard let recentItem = inventory.last else { return nil }
        var recentlyListedPrice: Double = 0.0
        if recentItem.quantity > 1 {
            for _ in 1...recentItem.quantity {
                recentlyListedPrice += recentItem.listingPrice
            }
        } else {
            recentlyListedPrice = recentItem.listingPrice
        }
        return recentlyListedPrice
    }
    
    // MARK: - Searches
    
    func findOldestItem() -> Item? {
        var count = 0
        var oldestItem = inventory.first
        for item in inventory {
            count += 1
            if let itemDate = item.listedDate, let oldestDate = oldestItem?.listedDate {
                if itemDate < oldestDate {
                    oldestItem = item
                }
            }
        }
        return oldestItem
    }
    
    // MARK: - Persistence
    
    var inventoryURL: URL? {
        let fm = FileManager.default
        guard let directory = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return directory.appendingPathComponent("Inventory.plist")
    }
    
    var soldItemsURL: URL? {
        let fm = FileManager.default
        guard let directory = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return directory.appendingPathComponent("SoldItems.plist")
    }
    
    var tagsURL: URL? {
        let fm = FileManager.default
        guard let directory = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return directory.appendingPathComponent("Tags.plist")
    }
    
    // Saving data
    func save() {
        let encoder = PropertyListEncoder()
        
        do {
            let inventoryData = try encoder.encode(inventory)
            let soldItemData = try encoder.encode(soldItems)
            let tagsData = try encoder.encode(tags)
            
            if let inventoryURL = inventoryURL,
               let soldItemsURL = soldItemsURL,
               let tagsURL = tagsURL {
                try inventoryData.write(to: inventoryURL)
                try soldItemData.write(to: soldItemsURL)
                try tagsData.write(to: tagsURL)
            }
            
        } catch {
            NSLog("Error encoding items: \(error.localizedDescription)")
        }
    }
    
    // Loading data
    func load() -> Bool {
        let decoder = PropertyListDecoder()
        let fm = FileManager.default
        
        guard let inventoryURL = inventoryURL,
              fm.fileExists(atPath: inventoryURL.path) else { return false }
        
        guard let soldItemsURL = soldItemsURL, fm.fileExists(atPath: soldItemsURL.path) else { return false }
        
        guard let tagsURL = tagsURL, fm.fileExists(atPath: tagsURL.path) else { return false }
        
        do {
            let inventoryData = try Data(contentsOf: inventoryURL)
            let soldItemsData = try Data(contentsOf: soldItemsURL)
            let tagsData = try Data(contentsOf: tagsURL)
            
            let decodedInventory = try decoder.decode([Item].self, from: inventoryData)
            let decodedSoldItems = try decoder.decode([Item].self, from: soldItemsData)
            let decodedTags = try decoder.decode([String].self, from: tagsData)
            inventory = decodedInventory
            soldItems = decodedSoldItems
            tags = decodedTags
        } catch {
            NSLog("Error decoding items: \(error.localizedDescription)")
        }
        return true
    }
    
}
