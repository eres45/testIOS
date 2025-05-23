import ProjectDescription

let project = Project(
    name: "SingleScreenApp",
    organizationName: "YourOrg",
    targets: [
        Target(
            name: "SingleScreenApp",
            platform: .iOS,
            product: .app,
            bundleId: "com.yourorg.singlescreenapp",
            deploymentTarget: .iOS(targetVersion: "15.0", devices: .iphone),
            infoPlist: "Info.plist",
            sources: ["**/*.swift"],
            resources: ["Assets.xcassets"]
        )
    ]
) 