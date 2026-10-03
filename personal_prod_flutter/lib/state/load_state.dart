/// Lifecycle of an async list, shared by every provider so pages can switch on
/// one type instead of each defining its own.
enum LoadState { idle, loading, ready, failed }