@testable import Colors
import struct SwiftUI.Color
import XCTest

final class ColorsTests: XCTestCase {
 func testPerception() {
  let black = RGBAColor.black
  XCTAssert(black.isDark)

  let white = RGBAColor.white
  XCTAssert(white.isLight)
 }

 func testMapping() throws {
  XCTAssert(RGBAColor.black.inverted == .white)
  // combination of red and green
  let yellow = try XCTUnwrap(Color(hex: "FFFF00"))
  XCTAssert(RGBAColor.blue.inverted == yellow)
  // combination of blue and red
  let magenta = try XCTUnwrap(Color(hex: "FF00FF"))
  XCTAssert(RGBAColor.green.inverted == magenta)
  // combination of green and blue
  let cyan = try XCTUnwrap(Color(hex: "00FFFF"))
  XCTAssert(RGBAColor.red.inverted == cyan)
 }

 func testConversion() {
  XCTAssert(RGBAColor.black.hex == "000000")
  XCTAssert(RGBAColor.white.hex == "FFFFFF")
  XCTAssert(RGBAColor.red.hex == "FF0000")
  XCTAssert(RGBAColor.green.hex == "00FF00")
  XCTAssert(RGBAColor.blue.hex == "0000FF")
 }

 func testCodable() throws {
  let color = Color.white + Color.mint
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let data = try encoder.encode(color)

  // FIXME: some native colors lose precision when encoding or decoding
  // so using the type `RGBAColor` to decode works but
  // this could be due to what process occurs when retrieving components
  let decoded = try decoder.decode(Color.self, from: data)
  XCTAssert(color == decoded)
 }
}
