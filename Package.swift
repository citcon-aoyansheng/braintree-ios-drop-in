// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BraintreeDropIn",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "BraintreeDropIn",
            targets: ["BraintreeDropIn"]
        ),
        .library(
            name: "BraintreeUIKit",
            targets: ["BraintreeUIKit"]
        )
    ],
    dependencies: [
        .package(name: "Braintree", url: "https://github.com/braintree/braintree_ios", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BraintreeDropIn",
            dependencies: [
                .product(name: "BraintreeApplePay", package: "Braintree"),
                .product(name: "BraintreeCard", package: "Braintree"),
                .product(name: "BraintreeCore", package: "Braintree"),
                .product(name: "BraintreePaymentFlow", package: "Braintree"),
                .product(name: "BraintreePayPal", package: "Braintree"),
                .product(name: "BraintreeThreeDSecure", package: "Braintree"),
                .product(name: "BraintreeUnionPay", package: "Braintree"),
                .product(name: "BraintreeVenmo", package: "Braintree"),
                .target(name: "BraintreeUIKit")
            ],
            exclude: ["Info.plist"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Custom Views"),
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "BraintreeUIKit",
            exclude: ["Info.plist"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Components"),
                .headerSearchPath("Vector Art"),
                .headerSearchPath("Vector Art/Large")
            ]
        )
    ]
)