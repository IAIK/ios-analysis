#!/bin/bash

mkdir -p Bins

IPAs=$(find . -iname "*.ipa")

echo ${#IPAs[@]}

for ipaName in $IPAs
do
    echo "#########"
    echo "extract $ipaName"
    rm -rf tmp
    unzip -o -u $ipaName -d tmp &> /dev/null

    appFilename=$(find tmp -iname "*.app")
    appFilename=${appFilename[0]}
    echo $appFilename

    plist="$appFilename/Info.plist"
    echo "$plist"
    if ! [ -e $plist ] ; then
        echo "ERROR: No .plist file"
        continue
    fi

    bundleID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $plist)
    if [ $? -eq 1 ] ; then
        bundleID=$(/usr/libexec/PlistBuddy -c "Print CFBundleName" $plist)
    fi
    echo $bundleID

    displayName=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $plist)
    if [ $? -eq 1 ] ; then
        displayName=$(/usr/libexec/PlistBuddy -c "Print itemName" $plist)
    fi
    echo $displayName

    binaryName=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" $plist)
    echo $binaryName

    if [ -e "Bins/$binaryName" ] ; then
        i=0
        newBinaryName="$binaryName$i"
        while [ -e "Bins/$newBinaryName" ]
        do
            i=$(($i+1))
            newBinaryName="$binaryName$i"
        done
        cp $appFilename/$binaryName $appFilename/$newBinaryName
        binaryName="$newBinaryName"
        echo "ERROR: file exists $binaryName"

    fi
    echo "copy $binaryName"
    cp $appFilename/$binaryName Bins/$binaryName

    echo "$displayName;$bundleID;$binaryName" >> Bins/info.csv
    echo "$binaryName" >> Bins/binaries.txt

    rm -rf tmp
done
