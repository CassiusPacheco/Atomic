# Atomic
@Atomic Swift Property Wrapper

`@Atomic` uses `NSLock` by default since it turned out to be the best option, besides unfair lock, when [benchmarking against many other locks](https://github.com/CassiusPacheco/Atomic/tree/benchmark).
