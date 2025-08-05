//
//  NotificationManager.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import UserNotifications

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(for product: ProductObject) {
        let center = UNUserNotificationCenter.current()
        
        let productName = product.name
        let productID = product._id.stringValue
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        // 1. Уведомление "Скоро испортится" (за неделю)
        if let aboutToSpoilDate = Calendar.current.date(byAdding: .day, value: -7, to: product.expirationDate), aboutToSpoilDate > Date() {
            content.title = "Shelf Life Alert: About to Spoil!"
            content.body = "Your \(productName) is expiring in one week. Don't forget to use it!"
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: aboutToSpoilDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(productID)_about_to_spoil", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling 'about to spoil' notification: \(error.localizedDescription)")
                }
            }
        }
        
        // 2. Уведомление "Испортился" (в день истечения срока)
        if product.expirationDate > Date() {
            let spoiledContent = UNMutableNotificationContent()
            spoiledContent.sound = UNNotificationSound.default
            spoiledContent.title = "Shelf Life Alert: Product Expired"
            spoiledContent.body = "Your \(productName) has expired today. Check it before use."

            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: product.expirationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(productID)_spoiled", content: spoiledContent, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling 'spoiled' notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelNotifications(for productID: String) {
        let center = UNUserNotificationCenter.current()
        let identifiers = ["\(productID)_about_to_spoil", "\(productID)_spoiled"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
