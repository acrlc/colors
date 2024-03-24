// swift-tools-version:5.5
import PackageDescription

let package = Package(
 name: "Colors",
 platforms: [.macOS(.v11), .iOS(.v15)],
 products: [
  .library(
   name: "Colors", targets: ["Colors"]
  )
 ],
 targets: [
  .target(
   name: "Colors",
   dependencies: []
  ),
  .testTarget(
   name: "ColorsTests",
   dependencies: ["Colors"]
  )
 ]
)
