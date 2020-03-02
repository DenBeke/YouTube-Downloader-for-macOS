#!/bin/bash

DIR="build"

rm -rf $DIR/*

xcodebuild -project Youtube\ Downloader.xcodeproj -scheme "Youtube Downloader" -config Release -archivePath ./$DIR/Youtube\ Downloader.xcarchive archive

xcodebuild -archivePath ./$DIR/Youtube\ Downloader.xcarchive -exportArchive -exportPath ./$DIR/ -exportOptionsPlist exportOptions.plist