# Pickup Day Notification System

## Overview
The BinSync app now features a comprehensive pickup day notification system that sends automatic reminders based on user-defined schedules.

## Features

### 1. **Manage Pickup Schedules**
- Users can add custom pickup schedules via the "Pickup Schedule" screen
- Access from: Home Screen → "Pickup Day Notifications" card → Manage button
- Can set:
  - Day of the week (Monday-Sunday)
  - Optional specific time (e.g., 10:00 AM)
  - Multiple schedules for different days

### 2. **Smart Notifications**
- **With Time Set**: Notification sent 1 hour before the scheduled pickup time
- **Without Time (All Day)**: Notification sent at 8:00 AM on pickup day
- **Push Notifications**: Appear in phone's notification panel using Firebase Cloud Messaging
- **In-App Notifications**: Also stored in Firestore and shown in the app's notification screen

### 3. **Automatic Scheduling**
- Background scheduler checks every 10 minutes for matching schedules
- Compares current time with user schedules
- Sends notifications when conditions match
- Works even when app is in background (via FCM)

## How It Works

### User Flow
1. **Add Schedule**: 
   - Open app → Home tab
   - Tap "Pickup Day Notifications" card
   - Tap "Add Schedule" (+ button)
   - Select day and optionally set time
   - Tap "Add"

2. **Receive Notification**:
   - On pickup day, at the scheduled time (or 1 hour before if time is set)
   - Notification appears in phone's notification panel
   - Also appears in app's notification screen (bell icon)

3. **Manage Schedules**:
   - View all schedules in "Pickup Schedule" screen
   - Delete schedules by tapping the trash icon
   - Edit by deleting and re-adding

### Technical Implementation

#### Components
- **FCMService** (`lib/services/fcm_service.dart`): Handles Firebase Cloud Messaging
- **PickupScheduleService** (`lib/services/pickup_schedule_service.dart`): Manages schedule CRUD operations
- **NotificationService** (`lib/services/notification_service.dart`): Sends notifications
- **NotificationScheduler** (`lib/services/notification_scheduler.dart`): Background checker

#### Data Structure

**Firestore Collection: `pickup_schedules`**
```json
{
  "userId": "user123",
  "day": "Monday",
  "time": "10:00 AM",  // Optional
  "isActive": true,
  "createdAt": Timestamp
}
```

**Firestore Collection: `notifications`**
```json
{
  "userId": "user123",
  "title": "Pickup Day Reminder",
  "message": "Garbage collection is scheduled at 10:00 AM. Please get your trash ready!",
  "type": "pickup_reminder",
  "read": false,
  "timestamp": Timestamp
}
```

#### Notification Logic
```dart
// If time is specified (e.g., 10:00 AM)
notificationTime = scheduledTime - 1 hour  // Sends at 9:00 AM

// If no time specified
notificationTime = 8:00 AM  // Default morning reminder
```

## Permissions Required

### Android
- `POST_NOTIFICATIONS`: For push notifications (Android 13+)
- Automatically requested when app starts

### iOS
- Notification permission requested via FCM initialization
- Alert, Badge, and Sound permissions

## Setup Notes

### Firebase Configuration
- Firebase Cloud Messaging must be enabled in Firebase Console
- `google-services.json` (Android) required in `android/app/`
- `GoogleService-Info.plist` (iOS) required in `ios/Runner/`

### Dependencies
```yaml
firebase_messaging: ^15.1.3
flutter_local_notifications: ^18.0.1
```

## Testing

### Test Notification System
1. Add a schedule for today with a time 1 hour from now
2. Wait for background scheduler to run (checks every 10 minutes)
3. Or trigger manually by restarting the app
4. Notification should appear in phone's notification panel

### Check Notification Schedule
- Logs print to console: "Checking pickup schedules..."
- Occurs every 10 minutes automatically

## Troubleshooting

### Notifications Not Appearing
1. **Check Permissions**: Ensure notification permissions are granted
2. **Check Schedule**: Verify schedule day matches today
3. **Check Time Window**: Scheduler has 10-minute window to catch notifications
4. **Check FCM Token**: Verify token is saved in Firestore `users` collection
5. **Check Logs**: Look for "Checking pickup schedules..." in console

### In-App Notifications Not Showing
1. Check Firestore `notifications` collection
2. Verify `userId` matches current user
3. Tap notification bell icon on home screen

## Future Enhancements
- iOS push notification support
- Notification history
- Custom notification messages
- Multiple notifications per day
- Snooze functionality
- Battery optimization handling
