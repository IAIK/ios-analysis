# Automated Binary Analysis on iOS

> This is the implementation of our framework to automatically analyze iOS applications, as presented at WiSec 2018.
> See the [paper](https://pure.tugraz.at/ws/portalfiles/portal/17749575) by Feichtner, Missmann, and Spreitzer for more details.

In this repository you find our solution to:

- Decompile 64-bit ARM binaries to LLVM intermediate representation (IR),
- Perform static program slicing with pointer analysis on IR code, and
- Security rules to highlight improper usage of cryptographic APIs.

**Note:** *This code is provided as-is. You are responsible for protecting yourself, your property and data, and others from any risks caused by this code. It may or may not detect vulnerabilities in your application/OS or device. It is intended only for educational purposes.*

## Setup

**Important::** You might need macOS to get the whole thing running...

 ```bash
git clone https://github.com/IAIK/ios-analysis
cd ios-analysis
git submodule update --init --recursive
```

### dagger

```bash
cd dagger
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="AArch64;X86" ..
make -j4 llvm-dec
```

### llvm-slicer

```bash
cd llvm-slicer
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="AArch64;X86" -DLLVM_ENABLE_EH=YES -DLLVM_ENABLE_RTTI=ON ..
make -j4 opt
make -j4 llvm-slicer  # requires that 'opt' is already built
```

## Analysis Workflow

The basic steps are as follows:


1. **Get the .ipa file:** E.g. using the tool [Clutch](https://github.com/KJCracks/Clutch) or [r2Clutch](https://github.com/as0ler/r2clutch) to decrypt the application you would like to inspect.
2. **Extract the ARM binary:** Unzip an application package and extract the ARM binary.
  *extract.sh* can be run in a folder with .ipa files. It extracts the individual app binaries and stores them in a new folder named `Bins`.
3. **Start the analysis:**
  See *run.sh* for the steps needed to process a particular binary. The script first gets the ARMv8 64-bit file using `lipo`, decompiles it using dagger, applies some LLVM optimization passes, and finally feeds it to llvm-slicer in order to evaluate the rules specified in *rules.json*. The script takes the following arguments:  
   `./run.sh {64-bit binary name} {optional: JSON rule file (default: $RULES/rules.json)} {optional: report output filename (default: $binary.html)}`

### dagger

*llvm-dec* should be called like this:  
`llvm-dec {64-bit binary input filename} -O1 -bc -o {IR Output}`

* bc: sets the output format to bitcode. The default format is LLVM assembler code, but this increases the file size.
* O1: Optimizations to prepare the file for the usage in LLVMSlicer

#### llvm-slicer

Additionally to the optimizations already performed in `llvm-dec`, the bitcode has to be prepared for LLVMSlicer using:  
`opt -instcombine -sroa -simplifycfg -constprop {input} -o {output}`

The LLVMSlicer is then executed by calling:  
`llvm-slicer {IR Code} -binary {64-bit binary} -o /dev/null -r {report filename} -rules {Rules JSON file}`
