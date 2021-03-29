// swift-tools-version:5.3
//  The swift-tools-version declares the minimum version of Swift required to build this package.
//
// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import PackageDescription

let package = Package(
    name: "AzureSDK",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(name: "AzureCore", targets: ["AzureCore"]),
        .library(name: "AzureCommunication", targets: ["AzureCommunication"]),
        .library(name: "AzureCommunicationChat", targets: ["AzureCommunicationChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0"),
        .package(url: "https://github.com/microsoft/trouter-client-ios.git", from: "v0.0.1-beta.4")
    ],
    targets: [
        // Build targets
        .target(
            name: "AzureCore",
            dependencies: [],
            path: "sdk/core/AzureCore",
            exclude: [
                "README.md",
                "Tests",
                "Source/Supporting Files"
            ],
            sources: ["Source"]
        ),
        .target(
            name: "AzureCommunication",
            dependencies: ["AzureCore"],
            path: "sdk/communication/AzureCommunication",
            exclude: [
                "README.md",
                "Tests",
                "Source/Supporting Files"
            ],
            sources: ["Source"]
        ),
        .target(
            name: "AzureCommunicationChat",
            dependencies: [
             "AzureCore",
             "AzureCommunication", 
             .product(name: "TrouterClientIos", package: "TrouterClientIos"),
             ],
            path: "sdk/communication/AzureCommunicationChat",
            exclude: [
                "README.md",
                "Tests",
                "Source/Supporting Files",
                "Package.swift"
            ],
            sources: ["Source"]
        ),
        // Test targets
        .testTarget(
            name: "AzureCoreTests",
            dependencies: ["AzureCore"],
            path: "sdk/core/AzureCore/Tests",
            exclude: [
                "Info.plist",
                "Data Files"
            ]
        ),
        .testTarget(
            name: "AzureCommunicationTests",
            dependencies: ["AzureCommunication"],
            path: "sdk/communication/AzureCommunication/Tests",
            exclude: [
                "Info.plist",
                "AzureCommunicationTests-Bridging-Header.h",
                "ObjCCommunicationTokenCredentialTests.m",
                "ObjCCommunicationTokenCredentialAsyncTests.m",
                "ObjCTokenParserTests.m"
            ]
        ),
        .testTarget(
            name: "AzureCommunicationChatTests",
            dependencies: [
                "AzureCommunication",
                "AzureCommunicationChat",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ],
            path: "sdk/communication/AzureCommunicationChat/Tests",
            exclude: [
                "Info.plist",
                "Util/Mocks",
                "Util/Recordings"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
