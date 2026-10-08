# 📊 Padma — Data Models & Schemas

> Detailed schema specification for all data entities, serialization structures, and domain models used in **Padma**.

---

## 1. Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ MESSAGE : sends
    USER ||--o{ BLOOD_REQUEST : creates
    ROUTE ||--|{ STOP : contains
    BUS ||--|| ROUTE : assigned_to
    BUS ||--o{ MESSAGE : logs_telemetry
    CHANNEL ||--|{ MESSAGE : contains

    USER {
        string id PK
        string name
        string email
        string studentId
        string department
        string role
        string bloodGroup
        bool isDonorAvailable
    }

    BUS {
        string id PK
        string name
        string plateNumber
        string routeId FK
        string driverName
        string status
        float speed
        float lat
        float lng
    }

    ROUTE {
        string id PK
        string title
        string startPoint
        string endPoint
        int estimatedMinutes
    }

    STOP {
        string id PK
        string name
        string nameBn
        float lat
        float lng
        int order
    }

    CHANNEL {
        string id PK
        string name
        string type
        bool isReadOnly
    }

    MESSAGE {
        string id PK
        string channelId FK
        string senderId FK
        string senderName
        string senderRole
        string text
        timestamp timestamp
        list reactions
    }

    BLOOD_REQUEST {
        string id PK
        string patientName
        string bloodGroup
        int unitsRequired
        string hospital
        string location
        string contactPhone
        string urgencyLevel
        bool isFulfilled
    }
```

---

## 2. Model Specifications

### 1. `BusRoute` (`lib/data/models/bus_route.dart`)
Represents an active university transit route.

```dart
class BusRoute {
  final String id;
  final String title;
  final String busNumber;
  final String driverName;
  final String currentStop;
  final String nextStop;
  final int etaMinutes;
  final double distanceProgress;
  final List<String> checkpoints;
}
```

### 2. `BusLocation` (`lib/features/live_bus/domain/models/bus_location.dart`)
Real-time GPS coordinate telemetry payload streamed from the bus transponder.

```dart
class BusLocation {
  final double latitude;
  final double longitude;
  final double speed;        // In km/h
  final double heading;      // 0 - 360 degrees
  final DateTime timestamp;
  final double accuracy;     // In meters
}
```

### 3. `ChatMessage` (`lib/data/models/chat_message.dart`)
Discord-style channel message payload.

```dart
class ChatMessage {
  final String id;
  final String senderName;
  final String senderRole;   // 'Student', 'Admin', 'Driver'
  final String text;
  final String time;
  final bool isMe;
  final List<String> reactions;
}
```

### 4. `EmergencyRequest` (`lib/data/models/emergency_request.dart`)
Verified emergency blood request entity.

```dart
class EmergencyRequest {
  final String id;
  final String bloodGroup;   // 'A+', 'B+', 'O+', 'AB-', etc.
  final String patientName;
  final String hospital;
  final String location;
  final int unitsNeeded;
  final String contactPhone;
  final String timeNeeded;
  final bool isUrgent;
  final int donorCount;
}
```

### 5. `NotificationItem` (`lib/data/models/notification_item.dart`)
Transit broadcast or emergency notification alert.

```dart
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String type;         // 'alert', 'announcement', 'blood'
  final bool isRead;
}
```

### 6. `UserProfile` (`lib/data/models/user_profile.dart`)
Student authentication and profile information.

```dart
class UserProfile {
  final String name;
  final String studentId;
  final String department;
  final String email;
  final String preferredRoute;
  final String bloodGroup;
  final bool isBloodDonor;
}
```
