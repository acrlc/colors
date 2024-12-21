import Foundation

public protocol RGBComponent {
 var red: Double { get }
 var green: Double { get }
 var blue: Double { get }
 var components: [Double] { get }
 init()
 init(red: Double, green: Double, blue: Double)
// func unsafeMap(transform: @escaping (Double) -> Double) -> Self
// func unsafeReduction(
//  _ other: some RGBComponent,
//  _ result:
//  @escaping (_ lhs: Double, _ rhs: Double) -> Double
// ) -> Self
}

public extension RGBComponent {
 @_disfavoredOverload
 var components: [Double] { [red, green, blue] }
 @_disfavoredOverload
 var red: Double { components[0] }
 @_disfavoredOverload
 var green: Double { components[1] }
 @_disfavoredOverload
 var blue: Double { components[2] }

 @_disfavoredOverload
 static func == (lhs: Self, rhs: some RGBComponent) -> Bool {
  lhs.red == rhs.red
   && lhs.blue == rhs.blue
   && lhs.green == rhs.green
 }
}

public protocol RGBAComponent:
 RGBComponent,
 Codable,
 Hashable,
 Equatable
{
 var red: Double { get }
 var green: Double { get }
 var blue: Double { get }
 var alpha: Double { get }
 init()
 init(red: Double, green: Double, blue: Double, alpha: Double)
}

enum ColorCodingKeys: CodingKey {
 case red, blue, green, alpha
}

public extension RGBAComponent {
 @_disfavoredOverload
 init(red: Double, green: Double, blue: Double) {
  self.init(red: red, green: green, blue: blue, alpha: 1)
 }

 @_disfavoredOverload
 init(components: [Double]) {
  self.init(
   red: components[0],
   green: components[1],
   blue: components[2],
   alpha: components.count > 3 ? components[3] : 1
  )
 }

 func unsafeMap(
  transform: @escaping (Double) -> Double
 ) -> Self {
  let comp = components.map { transform($0) }
  return Self(red: comp[0], green: comp[1], blue: comp[2], alpha: alpha)
 }

 func unsafeReduction(
  _ other: some RGBAComponent,
  _ result:
  @escaping (_ lhs: Double, _ rhs: Double) -> Double
 ) -> Self {
  let comp = components.map { lhs -> Double in
   var comp: Double!
   other.components.forEach { rhs in comp = result(lhs, rhs) }
   return comp
  }
  return Self(red: comp[0], green: comp[1], blue: comp[2], alpha: alpha)
 }

 @_disfavoredOverload
 @inlinable
 static var clear: Self { Self() }

 var alpha: Double { components[3] }
// var hue: Double { hslComponents[0] }
// var saturation: Double { hslComponents[1] }
// var luminosity: Double { hslComponents[2] }
 var hex: String { hexComponents.joined() }

 var rgbComponents: [Double] { [red, green, blue] }

 static func == (lhs: Self, rhs: some RGBAComponent) -> Bool {
  lhs.red == rhs.red
   && lhs.blue == rhs.blue
   && lhs.green == rhs.green
   && lhs.alpha == rhs.alpha
 }

 init(from decoder: Decoder) throws {
  let container = try decoder.container(keyedBy: ColorCodingKeys.self)
  let red = try container.decode(Double.self, forKey: .red)
  let green = try container.decode(Double.self, forKey: .green)
  let blue = try container.decode(Double.self, forKey: .blue)
  let alpha = try container.decode(Double.self, forKey: .alpha)
  self.init(red: red, green: green, blue: blue, alpha: alpha)
 }

 func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: ColorCodingKeys.self)
  try container.encode(red, forKey: .red)
  try container.encode(green, forKey: .green)
  try container.encode(blue, forKey: .blue)
  try container.encode(alpha, forKey: .alpha)
 }

 func compare(
  _ new: some RGBAComponent,
  _ comparison:
  @escaping (_ lhs: Double, _ rhs: Double) -> Double
 ) -> [Double] {
  components.map { lhs -> Double in
   var comp: Double!
   new.components.forEach { rhs in comp = comparison(lhs, rhs) }
   return comp
  }
 }

 /// An opaque blend with another color composite
 func blended(
  _ other: some RGBAComponent,
  _ midpoint: Double = 0.5
 ) -> Self {
  unsafeReduction(other) { lhs, rhs -> Double in
   ((1 - midpoint) * pow(lhs, 2) + (midpoint * pow(rhs, 2))).squeezed
  }
 }

 var inverted: Self { unsafeMap { (1 - $0).squeezed } }

 func blendColor(
  _ color: some RGBAComponent,
  _ midpoint: Double = 0.5
 ) -> Self {
  Self(
   components:
   compare(color) { lhs, rhs -> Double in (1 - midpoint) *
    pow(lhs, 2) + (midpoint * pow(rhs, 2))
   } + [(1 - midpoint) * alpha + (midpoint * color.alpha)]
  )
 }

 static func + (lhs: Self, rhs: some RGBAComponent) -> Self {
  Self(
   components:
   lhs.compare(rhs) { lhs, rhs -> Double in
    (lhs + rhs) / 2
   } + [(lhs.alpha + rhs.alpha) / 2]
  )
 }

 static func - (lhs: Self, rhs: some RGBAComponent) -> Self {
  Self(
   components:
   lhs.compare(rhs) { lhs, rhs -> Double in min(lhs + rhs, 1) } +
    [min(lhs.alpha + rhs.alpha, 1)]
  )
 }

 static func * (lhs: Self, rhs: some RGBAComponent) -> Self {
  lhs.blendColor(rhs)
 }

 static func / (lhs: Self, rhs: some RGBAComponent) -> Self {
  lhs.blendColor(rhs.inverted)
 }

 init(white: Double, alpha: Double = 1) {
  self.init(red: white, green: white, blue: white, alpha: alpha)
 }

 @_disfavoredOverload
 init(
  red: Double = 0,
  green: Double = 0,
  blue: Double = 0,
  alpha: Double = 0
 ) {
  self.init(red: red, green: green, blue: blue, alpha: alpha)
 }

 init(red: Int, green: Int, blue: Int, alpha: Double = 1) {
  self.init(
   red: red.fromWeb,
   green: green.fromWeb,
   blue: blue.fromWeb,
   alpha: alpha
  )
 }

 init(
  hue: Double = 0,
  saturation: Double = 0,
  brightness: Double,
  alpha: Double = 1
 ) {
  var r = brightness.squeezed,
      g = brightness.squeezed,
      b = brightness.squeezed,
      h = hue.squeezed,
      s = saturation.squeezed,
      v = brightness.squeezed,
      i = floor(h * 6),
      f = h * 6 - i,
      p = v * (1 - s),
      q = v * (1 - f * s),
      t = v * (1 - (1 - f) * s)
  switch i.truncatingRemainder(dividingBy: 6) {
  case 0: r = v
   g = t
   b = p
  case 1: r = q
   g = v
   b = p
  case 2: r = p
   g = v
   b = t
  case 3: r = p
   g = q
   b = v
  case 4: r = t
   g = p
   b = v
  case 5: r = v
   g = p
   b = q
  default: break
  }
  self.init(red: r, green: g, blue: b, alpha: alpha)
 }

 // https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
 init(
  hue: Double = 0,
  saturation: Double = 0,
  luminosity: Double,
  alpha: Double = 1
 ) {
  let h = hue,
      s = saturation,
      l = luminosity
  var r: Double = 0,
      g: Double = 0,
      b: Double = 0
  if s == 0 {
   r = l
   g = l
   b = l
  } else {
   func hue2rgb(
    _ p: Double,
    _ q: Double,
    _ t: Double
   ) -> Double {
    let t = t.squeezed
    switch t {
    case 0 ... (1 / 6): return p + (q - p) * 6 * t
    case 0 ... (1 / 2): return q
    case 0 ... (2 / 3): return p + (q - p) * (2 / 3 - t) * 6
    default: return p
    }
   }
   let q = l < 0.5 ? l * (1 + s) : l + s - l * s
   let p = 2 * l - q
   r = hue2rgb(p, q, h + 1 / 3 - 0.0000000000000003).squeezed
   g = (hue2rgb(p, q, h) + 0.0000000000000003).squeezed
   b = hue2rgb(p, q, h - 1 / 3 + 0.0000000000000003).squeezed
  }
  self.init(
   red: r.rounded,
   green: g.rounded,
   blue: b.rounded,
   alpha: alpha.rounded
  )
 }

 @_disfavoredOverload
 static func white(
  _ value: Double,
  alpha: Double = 1
 ) -> Self {
  Self(red: value, green: value, blue: value, alpha: alpha)
 }

 init?(hex: String, alpha: Double = 1) {
  var hexValue = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
  if hexValue.count == 3 {
   for (index, char) in hexValue.enumerated() {
    hexValue.insert(
     char,
     at: hexValue.index(hexValue.startIndex, offsetBy: index * 2)
    )
   }
  }
  guard
   hexValue.count == 6,
   let intCode = Int(hexValue, radix: 16)
  else {
   return nil
  }
  self.init(
   red: (intCode >> 16) & 0xFF,
   green: (intCode >> 8) & 0xFF,
   blue: intCode & 0xFF,
   alpha: alpha
  )
 }

 var hslComponents: (hue: Double, saturation: Double, luminosity: Double) {
  let r = red, g = green, b = blue
  let maximum = max(r, g, b),
      minimum = min(r, g, b),
      avg = (maximum + minimum) / 2
  var h: Double = avg,
      s: Double = avg,
      l: Double = avg

  if minimum != maximum {
   let d = maximum - minimum
   s = l > 0.5
    ? d / (2 - maximum - minimum)
    : d / (maximum + minimum)
   switch maximum {
   case r:
    h = (g - b) / d + (g < b ? 6 : 0)
   case g:
    h = (b - r) / d + 2
   case b:
    h = (r - g) / d + 4
   default: break
   }
   h /= 6
  } else {
   h = 0
   s = 0
  }
  return (h, s, l)
 }

 var webComponents: [Int] {
  rgbComponents.map(\.toWeb)
 }

 var hexComponents: [String] {
  webComponents.map {
   String(format: "%2X", $0).replacingOccurrences(of: " ", with: "0")
  }
 }

 @_disfavoredOverload
 var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
  let red: Double = red / 255
  let green: Double = green / 255
  let blue: Double = blue / 255

  let max: Double = fmax(red, fmax(green, blue))
  let min: Double = fmin(red, fmin(green, blue))

  var h: Double = 0
  if max == red, green >= blue {
   h = 60 * (green - blue) / (max - min)
  } else if max == red, green < blue {
   h = 60 * (green - blue) / (max - min) + 360
  } else if max == green {
   h = 60 * (blue - red) / (max - min) + 120
  } else if max == blue {
   h = 60 * (red - green) / (max - min) + 240
  }
  let s = (max == 0) ? 0.0 : (1.0 - (min / max))
  return (h, s, max)
 }

 func alpha(_ value: Double) -> Self {
  Self(
   red: red,
   green: green,
   blue: blue,
   alpha: alpha * value
  )
 }

 func transform(_ value: @escaping (Double) -> Double) -> Self {
  Self(
   red: value(red).squeezed,
   green: value(green).squeezed,
   blue: value(blue).squeezed,
   alpha: alpha
  )
 }

 func hue(_ value: Double) -> Self {
  let (_, s, l) = hslComponents
  return Self(
   hue: value,
   saturation: s,
   luminosity: l,
   alpha: alpha
  )
 }

 func saturation(_ value: Double) -> Self {
  let (h, _, l) = hslComponents
  return Self(
   hue: h,
   saturation: value,
   luminosity: l,
   alpha: alpha
  )
 }

 func brightness(_ value: Double) -> Self {
  let (h, s, _) = hsbComponents
  return Self(
   hue: h,
   saturation: s,
   brightness: value,
   alpha: alpha
  )
 }

 func withInversion(_ value: Double) -> Self {
  transform { 1 - $0 * value }
 }

 func luminosity(_ value: Double) -> Self {
  let (h, s, _) = hslComponents
  return Self(
   hue: h, saturation: s,
   luminosity: value, alpha: alpha
  )
 }

 /// (0-1)
 func brighten(_ value: Double) -> Self {
  luminosity(
   (hslComponents.luminosity + value).clamp(0, 1)
  )
  .alpha(alpha)
 }

 /// (0-1)
 func darken(_ value: Double) -> Self {
  luminosity(
   (hslComponents.luminosity - value).clamp(0, 1)
  )
  .alpha(alpha)
 }

 var lightenedToAlpha: Self {
  guard alpha < 1 else {
   return self
  }
  return brighten(alpha)
 }

 var darkenedToAlpha: Self {
  guard alpha < 1 else {
   return self
  }
  return darken(alpha)
 }

 var computedBrightness: Double {
  (red + green + blue + alpha) / 4
 }

 var isDark: Bool { hslComponents.luminosity < 0.55 }
 var isLight: Bool { !isDark }

 func isVisible(with background: some RGBAComponent) -> Bool {
  guard isTransparent else {
   let luminosity = hslComponents.luminosity
   let ratio = luminosity / background.hslComponents.luminosity
   return ratio > 2
  }
  return (
   (red + green + blue - alpha) + (
    background.red + background.green + background.blue
   )
  ) / 2 > 1
 }

 var isOpaque: Bool { alpha == 1 }

 var isTransparent: Bool { !isOpaque }

 var opaque: Self {
  guard isTransparent else {
   return self
  }
  return alpha(1)
 }

 func darkBlend(_ color: some RGBAComponent, _ amount: Double) -> Self {
  (darken(amount) * color).saturation(1.75)
 }

 func brightBlend(_ color: some RGBAComponent, _ amount: Double) -> Self {
  (brighten(amount) * color).saturation(1.75)
 }

 var shadow: Self { luminosity(0.35) }
 var overlay: Self { alpha(0.8).saturation(0.75) }
 var highlight: Self { luminosity(0.9) }

 static func ?? <A: RGBAComponent>(lhs: A?, rhs: Self) -> A { A(lhs ?? A(rhs)) }

 @inlinable @_disfavoredOverload
 static var black: Self { Self(alpha: 1) }
 @inlinable @_disfavoredOverload
 static var white: Self { Self(white: 1, alpha: 1) }
 @inlinable @_disfavoredOverload
 static var red: Self { Self(red: 1, alpha: 1) }
 @inlinable @_disfavoredOverload
 static var green: Self { Self(green: 1, alpha: 1) }
 @inlinable @_disfavoredOverload
 static var blue: Self { Self(blue: 1, alpha: 1) }
 @inlinable @_disfavoredOverload
 static var orange: Self {
  Self(red: 1.0, green: 0.6235294117647059, blue: 0.0392156862745098)
 }

 @inlinable @_disfavoredOverload
 static var graphite: Self {
  Self(red: 0.5960784314, green: 0.5960784314, blue: 0.5960784314)
 }
 @inlinable @_disfavoredOverload
 static var sky: Self {
  Self(red: 0.1215686275, green: 0.7176470588, blue: 0.9803921569)
 }
 @inlinable @_disfavoredOverload
 static var flame: Self {
  let orange = Self(red: 0.968627451, green: 0.5098039216, blue: 0.1058823529)
  return (orange * Self.red).saturation(2.75) as Self
 }
}

// MARK: - Extensions
public extension RGBAComponent {
 var intValue: Int32 {
  let r = Int32(red * 255) << 16
  let g = Int32(green * 255) << 8
  let b = Int32(blue * 255)
  let a = Int32(alpha * 255) << 24
  return r + g + b + a
 }

 static func random() -> Self {
  func random() -> Double {
   Double(arc4random_uniform(255)) / 255
  }
  return
   Self(components: (0 ..< 3).map { _ in random() } + [1])
 }
}

public extension RGBAComponent {
 /// Initialize from a value that conforms to `RGAComponent`
 init(_ color: some RGBAComponent) {
  self.init(
   red: color.red, green: color.green, blue: color.blue, alpha: color.alpha
  )
 }

 @inlinable
 var secondary: Self { alpha(0.88) }
 @inlinable
 var tertiary: Self { alpha(0.77) }
 @inlinable
 var quaternary: Self { alpha(0.66) }
 @inlinable
 var quinary: Self { alpha(0.55) }
 @inlinable
 static var shadow: Self { Self(white: 0, alpha: 0.33) }
 @inlinable
 static var highlight: Self { Self(white: 1, alpha: 0.33) }
}
