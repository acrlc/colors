extension ClosedRange {
 func squeeze(_ value: Bound) -> Bound {
  contains(value)
   ? value
   : value > upperBound
    ? upperBound
    : lowerBound
 }
}
