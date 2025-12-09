/// Generates a stable hash code for a string using FNV-1a 32-bit algorithm.
///
/// This is necessary because [String.hashCode] is not guaranteed to be stable
/// across different runs of the Dart VM.
int stableHash(String value) {
  const fnvOffsetBasis = 2166136261;
  const fnvPrime = 16777619;
  const mask32 = 0xFFFFFFFF;

  var hash = fnvOffsetBasis;
  for (var i = 0; i < value.length; i++) {
    hash ^= value.codeUnitAt(i);
    hash *= fnvPrime;
    // Force to 32-bit integer
    hash &= mask32;
  }
  return hash;
}
