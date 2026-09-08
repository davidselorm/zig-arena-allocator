# zig-arena-allocator

A high-performance page-aligned region arena allocator for Zig with sub-nanosecond bump allocation.

## Architecture
- **Chunk Linked-List**: Dynamic allocation across amortized fixed-size blocks (default 64KB).
- **Instant Reset**: O(1) bulk memory recycle without operating system kernel deallocation syscalls.
- **Strict Alignment**: Compile-time alignment checks matching target type requirements.
