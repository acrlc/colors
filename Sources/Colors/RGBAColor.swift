/// A simple RGB color component with alpha
public struct RGBAColor: RGBAComponent {
 public
 var red: Double = 0, green: Double = 0, blue: Double = 0, alpha: Double = 0

 public init(
  red: Double = 0,
  green: Double = 0,
  blue: Double = 0,
  alpha: Double = 0
 ) {
  self.red = red.squeezed
  self.green = green.squeezed
  self.blue = blue.squeezed
  self.alpha = alpha.squeezed
 }
}

public extension RGBAColor {
 init() {}

 var components: [Double] { [red, green, blue, alpha] }
 var hsbComponents: [Double] {
  let r = red, g = green, b = blue
  let maximum = max(r, g, b), minimum = min(r, g, b)
  var h: Double = 0,
      s: Double = 0,
      v: Double = maximum
  if minimum != maximum {
   let d = maximum - minimum
   s = maximum == 0 ? 0 : d / maximum
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
  }
  return [h, s, v, alpha]
 }
}

public struct RGBColor: RGBComponent {
 public
 var red: Double = 0, green: Double = 0, blue: Double = 0

 public init(
  red: Double = 0,
  green: Double = 0,
  blue: Double = 0
 ) {
  self.red = red.squeezed
  self.green = green.squeezed
  self.blue = blue.squeezed
 }
}

public extension RGBColor {
 init() {}

 var components: [Double] { [red, green, blue] }
 var hsbComponents: [Double] {
  let r = red, g = green, b = blue
  let maximum = max(r, g, b), minimum = min(r, g, b)
  var h: Double = 0,
      s: Double = 0,
      v: Double = maximum
  if minimum != maximum {
   let d = maximum - minimum
   s = maximum == 0 ? 0 : d / maximum
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
  }
  return [h, s, v]
 }
}
