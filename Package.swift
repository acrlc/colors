// swift-tools-version:5.3
import PackageDescription

let package = Package(
 name: "Colors",
 platforms: [.macOS(.v11), .iOS(.v14)],
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
