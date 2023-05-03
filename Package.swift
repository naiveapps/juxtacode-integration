// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "JuxtaCodeIntegration",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "JuxtaCodeIntegration",
      targets: ["JuxtaCodeIntegration"]),
  ],
  targets: [
    .target(
      name: "JuxtaCodeIntegration",
      dependencies: [])
  ]
)
