// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "FocusApp",
    platforms: [
        .iOS(.v16) // מגדיר שהאפליקציה דורשת iOS 16 ומעלה
    ],
    products: [
        .iOSApplication(
            name: "FocusApp",
            targets: ["AppModule"],
            bundleIdentifier: "com.yourname.focusapp",
            teamIdentifier: "", // השאר ריק אם אין לך חשבון מפתח בתשלום
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeLeft,
                .landscapeRight,
                .portraitUpsideDown(.when(deviceFolders: [.pad]))
            ],
            capabilities: [
                .pushNotifications() // מאפשר את ההתראות שכתבת בקוד
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
