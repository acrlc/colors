#if canImport(SwiftUI)
import SwiftUI

extension Color: RGBAComponent {
 public init() { self = .clear }
 public var nativeColor: Color.Native {
  Color.Native(self)
 }

 public var components: [Double] {
  nativeColor.components
 }

 public var hsbComponents:
  (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
   nativeColor.hsbComponents
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
 #elseif canImport(TokamakCore)
 typealias Native = TokamakCore.Color
 #endif
 init(red: Double, green: Double, blue: Double, alpha: Double) {
  self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
 }

 init(native: Color.Native) {
  self.init(
   red: native.red,
   green: native.green,
   blue: native.blue,
   alpha: native.alpha
  )
 }

 #if os(macOS)
 @_transparent
 init(name: String? = nil, dynamicColor: @escaping (ColorScheme) -> Color) {
  self.init(
   native:
   Native(name: name) { appearance in
    let scheme: ColorScheme = switch appearance.name {
    case .darkAqua, .vibrantDark: .dark
    default: .light
    }
    return dynamicColor(scheme).nativeColor
   }
  )
 }
 #else
 @_transparent
 init(dynamicColor: @escaping (ColorScheme) -> Color) {
  self.init(
   native:
   Native { appearance in
    let scheme: ColorScheme =
     appearance.userInterfaceStyle == .dark ? .dark : .light
    return dynamicColor(scheme).nativeColor
   }
  )
 }
 #endif
}

public extension Color {
 #if os(iOS)
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
 static var tertiaryGroupedBackground: Self {
  Self(uiColor: .tertiarySystemGroupedBackground)
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

 #elseif os(macOS)
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
  (overlay + (background.isDark ? black : white)) / background
 }

 static func aligned(to background: Self)
  -> (isLightForeground: Bool, foreground: Self)
 {
  let isLight = background.isDark
  return (isLight, isLight ? Self.white : Self.black)
 }

 static var graphite: Self {
  Color { colorScheme in
   if colorScheme == .dark {
    Color(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078)
   } else {
    Color(red: 0.5960784314, green: 0.5960784314, blue: 0.5960784314)
   }
  }
 }

 static var flame: Self {
  Color {
   let orange =
    Color(red: 0.968627451, green: 0.5098039216, blue: 0.1058823529)
   let color = (orange * Color.red).saturation(2.75) as Color
   if $0 == .dark {
    return color.darkBlend(color, 0.05)
   } else {
    return color
   }
  }
 }

 static var sky: Self {
  Color {
   let color = Color(red: 0.1215686275, green: 0.7176470588, blue: 0.9803921569)
   if $0 == .dark {
    return color.darkBlend(color, 0.05)
   } else {
    return color
   }
  }
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
  let `self` = usingColorSpace(.sRGB)!
  #endif
  self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  return [
   Double(red),
   Double(green),
   Double(blue),
   Double(alpha)
  ]
 }

 var red: Double { components[0] }
 var green: Double { components[1] }
 var blue: Double { components[2] }
 var alpha: Double { components[3] }

 var hsbComponents:
  (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
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
   return (
    Double(hue),
    Double(saturation),
    Double(brightness),
    Double(alpha)
   )
  }
}
#endif

#if canImport(SwiftUI)
#Preview {
 ForEach([Color.sky, Color.flame], id: \.hashValue) { color in
  let hsl = color.hslComponents
  let hsb = color.hsbComponents

  // MARK: Colors Implementation
  Color(
   hue: hsl.hue,
   saturation: hsl.saturation,
   luminosity: hsl.luminosity,
   alpha: color.alpha
  )

  Color(
   hue: hsb.hue,
   saturation: hsb.saturation,
   brightness: hsb.brightness,
   alpha: color.alpha
  )

  // MARK: SwiftUICore Implementation
  Color(
   hue: hsb.hue,
   saturation: hsb.saturation,
   brightness: hsb.brightness,
   opacity: color.alpha
  )
 }
}
#endif
