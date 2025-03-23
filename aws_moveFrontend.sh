#!/bin/bash

# Check if the first argument (filename) is provided

cp -r "C:\Users\jack\source\repos\Web_Dev\02-Personal_Repos\trackerapp-frontend\build" .
cd build
7z a build.zip
mv build.zip ../
cd ..
./moveData.sh build.zip
rm -f build.zip