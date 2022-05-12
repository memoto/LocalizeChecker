import ArgumentParser

#if swift(>=5.6)
/// Workaround  for swift 5.5 bug with macos 12 requirenment on concurrency
///  ignoring package min macos verion
protocol AsyncParsableCommandProtocol: AsyncParsableCommand {}
#else
/// Workaround  for swift 5.5 bug with macos 12 requirenment on concurrency
///  ignoring package min macos verion
protocol AsyncParsableCommandProtocol: ParsableCommand {}
#endif
