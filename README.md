# Colors
A library built for the everyday purpose of encoding, decoding, and transforming colors 
```swift
// combine the colors white and mint
let lightMint = Color.white + Color.mint

// encode and decode
let encoder = JSONEncoder()
let decoder = JSONDecoder()
let data = try encoder.encode(color)

// the decoded combination of white and mint aka lightMint
let decoded = try decoder.decode(RGBAColor.self, from: data)
```
## Note
This library is still under development and bug fixes are needed for some initializers.
For the time being, you can create an issue or pull request to fix these or use built-in initializers.
