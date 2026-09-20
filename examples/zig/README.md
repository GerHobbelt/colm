# Ragel examples for Zig

This directory contains examples of building Zig parsers with Ragel.

## Building

Ragel source files use the `*.rl` extension. Build examples with:

```bash
make
```

The `STYLE` variable selects the code generation style. It defaults to `-G2`, which is the fastest. Zig supports all seven code styles (`-T0 -T1 -F0 -F1 -G0 -G1 -G2`) because `ragel-zig` lowers Ragel's goto backends onto a labeled switch.

## Contributing

Please consider the following when adding examples:

1. One file — one example
2. Use `*.rl` extension for your examples
