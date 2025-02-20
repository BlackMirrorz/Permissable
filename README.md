<img src="https://github.com/user-attachments/assets/872fd5ca-8027-4abd-aafa-f3cd9661c4a7" alt="Permissios Client For SwiftUI & UIKit" width="300" height="300" />

# Permissable
An Swift Package for handling basic Permissions such as Camera, Microphone, PhotoLibrary and Push Notifications.


- ****Supports****: Swift 5.9

- ****Platforms****: iOS 16+

## Installation

To install via SPM add the following to your `Package.swift`:

  

```swift

dependencies: [
.package(url: "https://github.com/BlackMirrorz/Permissable", from: "1.0.0")
]

```

Then, import `Permissable` anywhere you'd like to use it:

  
```swift

import Permissable

```

## Overview:

By Default Permissable includes Validators which perform validation for their specified service.

These Validators conform to the ```PermissionsValidatorProtcol``` and can easily be  added to the ```PermissionsClient``` to handle additional validation.

Current Validators are:
1. CameraPermissionsValidator
2. MicrophonePermissionsValidator
3. PhotLibraryPermissionsValidator
4. PushNotificationsValidator
   

## PermissionsClient:
The PermissionsClient is the core component responsible for managing and validating permissions. It acts as a central hub to which you can add various permission services along with their corresponding validators.

### Using The PermissionsClient:
The package contains and example SwiftUI app showing how to seamlessly integrate the client into your app.

#### Main Methods:
```getAuthorizationStatus(for:)```

Retrieves the current authorization status for a given permission service.
```swift
let status = client.getAuthorizationStatus(for: breakService)
switch status {
case .authorized:
    print("Permission authorized")
case .denied:
    print("Permission denied")
default:
    print("Permission not determined or restricted")
}
```

```requestAuthorization(for:)```

Initiates an asynchronous permission request for the specified service and returns a Bool indicating whether the permission was granted.
```swift
Task {
    let granted = await client.requestAuthorization(for: breakService)
    if granted {
        print("Permission granted")
    } else {
        print("Permission denied")
    }
}
```

```hasRequestedPermission(for:)```

Checks if a permission request has already been made for the given service. This helps avoid unnecessary prompts if the status is already determined.
```swift
if client.hasRequestedPermission(for: breakService) {
    print("Permission has already been requested.")
} else {
    print("Permission has not been requested yet.")
}
```
## Creating A New Service & Validator:
To extend the functionality of PermissionsClient by handling an additional permission type, you need to follow these steps:

#### (a) Create A Service:
A service encapsulates the permission you want to handle. For example, to create a service for a custom permission (e.g., “Break Time”):

```swift
  let askBossService = PermissionsService(
    identifier: "break",
    description: "slackingOff"
  )
```

#### (b) Create A Validator:
A validator is responsible for determining the current authorization status and handling permission requests for the associated service. To add an additional validator, create a new class that conforms to the PermissionsValidatorProtocol. For example:

```swift
public final class BreakTimeValidator: PermissionsValidatorProtocol {

  public func getAuthorizationStatus() -> PermissionsRequestResult {
    let status = evilBoss.authorizationStatus(for: .break)
    switch status {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorized:
      return .authorized
    @unknown default:
      fatalError("Unknownauthorization status.")
    }
  }

  public func requestAuthorization() async -> Bool {
    await  evilBoss.authorizationStatus(for: .break)
  }

  public func hasRequestedPermission() -> Bool {
    getAuthorizationStatus() != .notDetermined
  }
}
```

#### (c) Add As A Provider Of The PermissionsClient:
Once you have both the service and the validator set up, you can add them as a provider to the PermissionsClient:
```swift
let breakService = PermissionsService(
 identifier: "break",
 description: "SlackingOff"
)
    
let client = PermissionsClient(providers: [breakService: BreakTimeValidator()])
```
This setup allows the PermissionsClient to manage your custom permission seamlessly alongside the default ones.

Alternatively if you want to use the Default Services you can register additional ones at any time by:
```swift

let client = PermissionsClient(providers: [breakService: BreakTimeValidator()])

let breakService = PermissionsService(
 identifier: "break",
 description: "SlackingOff"
)

client.registerProviders([breakService: BreakTimeValidator()])

```

## Architecture:
<img width="1248" alt="uml" src="https://github.com/user-attachments/assets/0949d6a0-0907-4811-9d1f-ae5f23b99f73" />
