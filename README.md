# Automated Binary Analysis on iOS

> This is the implementation of our framework to automatically analyze iOS applications, as presented at WiSec 2018.
> See the [paper](https://doi.org/10.1145/3212480.3212487) by Feichtner, Missmann, and Spreitzer for more details.

In this repository you will *soon* find our solution to:

- Decompile 64-bit ARM binaries to LLVM intermediate representation (IR),
- Perform static program slicing with pointer analysis on IR code, and
- Security rules to highlight improper usage of cryptographic APIs.
