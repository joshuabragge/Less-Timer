import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization()
}

class NotificationService: NotificationServiceProtocol {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notifications permission: \(error)")
            }
        }
    }
}
