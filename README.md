# Automated Binary Analysis on iOS

> This is the implementation of our framework to automatically analyze iOS applications, as presented at WiSec 2018.
> See the [paper](https://pure.tugraz.at/ws/portalfiles/portal/17749575) by Feichtner, Missmann, and Spreitzer for more details.

In this repository you will *soon* (end of June 2018) find our solution to:

- Decompile 64-bit ARM binaries to LLVM intermediate representation (IR),
- Perform static program slicing with pointer analysis on IR code, and
- Security rules to highlight improper usage of cryptographic APIs.
