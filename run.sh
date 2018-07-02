#!/bin/bash
#
argc=$#

if [ $argc -eq 0 ] ; then
    echo "No binary specified"
    exit -1
fi
#
binary=$1

if ! [ -e $binary ] ; then
    echo "binary \"$1\" not found"
    exit -1
fi

if echo $binary | grep -q -E '.*\.((64)|(html)|(json)|(bc)|(csv)|(txt))' ; then
    exit -1
fi

echo ""
echo "####################################################"
echo "$binary"
echo "####################################################"

binary64="$binary.64"

if ! [ -e $binary64 ] ; then
        echo "64-bit binary not found -> extract"
        rm $binary.* &> /dev/null
        lipo -thin arm64 $binary -o $binary64 &> /dev/null

        if ! [ $? -eq 0 ] ; then
            echo "ERROR: can't extract binary"
            exit
        fi
fi

grep -E "(CCCrypt)" $binary64 > /dev/null
hasCC=$?
if ! [ $hasCC -eq 0 ] ; then
    echo "Does not call CC"
    exit
fi

llvmir="$binary.bc"
llvmopt="$binary.opt.bc"

if ! [ -e $llvmopt ] ; then
    echo "Decompile"
    ./dagger/build/bin/llvm-dec $binary64 -O1 -bc -o $llvmir #&> /dev/null
    if ! [ $? -eq 0 ] ; then
        echo "ERROR: can not decompile $binary" >> errs.txt
        exit
    fi
    echo "Optimize"
    ./llvm-slicer/build/bin/opt -instcombine -sroa -simplifycfg -constprop $llvmir -o $llvmopt
    # opt -simplifycfg -constprop $llvmir -o $llvmopt
    # opt $llvmir -o $llvmopt
fi

rules="rules/rules.json"

if [ $# -gt 1 ] ; then
    rules=$2
fi

report="$binary.html"

if [ $# -gt 2 ] ; then
    report=$3
fi

if [ -e $report ] ; then
    echo "Report already exists"
    exit
fi

echo "Analyze"
# gtimeout 110m llvm-slicer $llvmopt -binary $binary64 -o /dev/null -r $report -rules $rules
# if math "$status != 0" > /dev/null
#     echo "ERROR: TIMEOUT"
# end
# llvm-slicer $llvmopt -binary $binary64 -o /dev/null -r $report -rules $rules
./llvm-slicer/build/bin/llvm-slicer $llvmopt -binary $binary64 -o /dev/null -r $report -rules $rules
# llvm-slicer $llvmopt -binary $binary64 -o /dev/null -r $report -rules $rules -print-same-usedef-only
# llvm-slicer $llvmopt -binary $binary64 -o /dev/null -r $report -rules $rules -same-usedef-only
