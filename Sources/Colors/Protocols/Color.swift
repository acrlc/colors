#if canImport(SwiftUI)
import SwiftUI

extension Color: RGBAComponent {
 public init() { self = .clear }
 public var nativeColor: Color.Native {
  Color.Native(self)
 }

 public var components: [Double] {
  self.nativeColor.components
 }

 public var hsbComponents: [Double] {
  self.nativeColor.hsbComponents
 }
}

#elseif canImport(TokamakCore)
@testable import TokamakCore

extension Color: RGBAComponent {
 public init() { self = .clear }
 public var components: [Double] {
  let provider = provider as! _ConcreteColorBox
  return [
   provider.rgba.red,
   provider.rgba.blue,
   provider.rgba.green,
   provider.rgba.opacity
  ]
 }
}
#endif

public extension Color {
 #if os(macOS)
 typealias Native = NSColor
 #elseif os(iOS)
 typealias Native = UIColor
 #elseif os(WASI)
 typealias Native = Color
 #endif
 init(red: Double, green: Double, blue: Double, alpha: Double) {
  self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
 }
}

public extension Color {
 init(native: Color.Native) {
  self.init(
   red: native.red,
   green: native.green,
   blue: native.blue,
   alpha: native.alpha
  )
 }

 #if os(iOS)
 @inlinable
 static var accent: Self {
  guard let color =
   Color.Native(named: "AccentColor") else {
   return Self(uiColor: Color.accentColor)
  }
  return Self(uiColor: color)
 }

 @inlinable
 static var background: Self { Self(uiColor: .systemBackground) }
 @inlinable
 static var groupedBackground: Self {
  Self(uiColor: .systemGroupedBackground)
 }

 @inlinable
 static var secondaryBackground: Self {
  Self(uiColor: .secondarySystemBackground)
 }

 @inlinable
 static var tertiaryBackground: Self {
  Self(uiColor: .tertiarySystemBackground)
 }

 @inlinable
 static var tertiaryFill: Self { Self(uiColor: .tertiarySystemFill) }
 @inlinable
 static var secondaryGroupedBackground: Self {
  Self(uiColor: .secondarySystemGroupedBackground)
 }

 @inlinable
 static var fill: Self { Self(uiColor: .systemFill) }
 @inlinable
 static var secondaryFill: Self { Self(uiColor: .secondarySystemFill) }
 @inlinable
 static var label: Self { Self(uiColor: .label) }
 @inlinable
 static var secondaryLabel: Self { Self(uiColor: .secondaryLabel) }
 @inlinable
 static var tertiaryLabel: Self { Self(uiColor: .tertiaryLabel) }
 @inlinable
 static var placeholder: Self { Self(uiColor: .placeholderText) }
 @inlinable
 static var separator: Self { Self(uiColor: .separator) }
 @inlinable
 static var outline: Self { label.light }

 #elseif os(macOS)
 @available(macOS 12.0, *)
 @inlinable
 static var accent: Self {
  guard let color =
         Color.Native(named: "AccentColor") else {
   return Self(nsColor: .controlAccentColor)
  }
  return Self(nsColor: color)
 }
 @available(macOS 12.0, *)
 @inlinable
 static var background: Self { Self(nsColor: .windowBackgroundColor) }
 @available(macOS 14.0, *)
 @inlinable
 static var fill: Self { Self(nsColor: .systemFill) }
 @available(macOS 14.0, *)
 @inlinable
 static var secondaryFill: Self { Self(nsColor: .secondarySystemFill) }
 @available(macOS 14.0, *)
 @inlinable
 static var tertiaryFill: Self { Self(nsColor: .tertiarySystemFill) }
 @available(macOS 14.0, *)
 @inlinable
 static var quaternaryFill: Self { Self(nsColor: .quaternarySystemFill) }

 @available(macOS 12.0, *)
 @inlinable
 static var tertiary: Self { Self(nsColor: .tertiaryLabelColor) }
 @available(macOS 12.0, *)
 @inlinable
 static var quaternary: Self { Self(nsColor: .quaternaryLabelColor) }
 @available(macOS 12.0, *)
 @inlinable
 static var quinary: Self { Self(nsColor: .quinaryLabel) }
 #endif

 /// Adjusts to overlay the background color.
 static func aligned(to background: Self, with overlay: Self) -> Self {
  (overlay + (background.isDark ? Self.black : Self.white)) / background
 }

 static func aligned(to background: Self) -> (isLightForeground: Bool, foreground: Self) {
  let isLight = background.isDark
  return (isLight, isLight ? Self.white : Self.black)
 }

 static var orangeRed: Self {
  .red.darkBlend(Color.orange)
 }
}

#if os(iOS) || os(macOS)
public extension Color.Native {
 convenience init(
  red: Double, green: Double, blue: Double, alpha: Double
 ) {
  self.init(
   red: CGFloat(red),
   green: CGFloat(green),
   blue: CGFloat(blue),
   alpha: CGFloat(alpha)
  )
 }

 var components: [Double] {
  var red: CGFloat = 0,
      green: CGFloat = 0,
      blue: CGFloat = 0,
      alpha: CGFloat = 0

  #if os(macOS)
  let `self` = self.usingColorSpace(.sRGB)!
  #endif
  self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  return [
   Double(red),
   Double(green),
   Double(blue),
   Double(alpha)
  ]
 }

 var red: Double { self.components[0] }
 var green: Double { self.components[1] }
 var blue: Double { self.components[2] }
 var alpha: Double { self.components[3] }

 var hsbComponents: [Double] {
  var hue: CGFloat = 0,
      saturation: CGFloat = 0,
      brightness: CGFloat = 0,
      alpha: CGFloat = 0

  #if os(macOS)
  usingColorSpace(.sRGB)?
   .getHue(
    &hue,
    saturation: &saturation,
    brightness: &brightness,
    alpha: &alpha
   )
  #elseif os(iOS)
  getHue(
   &hue,
   saturation: &saturation,
   brightness: &brightness,
   alpha: &alpha
  )
  #endif
  return [
   Double(hue),
   Double(saturation),
   Double(brightness),
   Double(alpha)
  ]
 }
}
#endif
