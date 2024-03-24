import Foundation

extension Double {
 var doubleRange: ClosedRange<Double> { 0 ... 1 }
 var roundValue: Int { 16 }
 public func roundTo(to decimals: Int) -> Self {
  let divisor = pow(10.0, Self(decimals))
  return (self * divisor).rounded() / divisor
 }

 var rounded: Self { self.roundTo(to: roundValue) }
 var squeezed: Self { doubleRange.squeeze(self) }
 var toWeb: Int { Int(self * 255) }
}

extension Int {
 var webRange: ClosedRange<Int> { 0 ... 255 }
 var squeezed: Int { webRange.squeeze(self) }
 var fromWeb: Double { (Double(self.squeezed) / 255).rounded }
}

public extension Comparable {
 func clamp(_ lhs: Self, _ rhs: Self) -> Self {
  min(max(self, lhs), rhs)
 }
}
