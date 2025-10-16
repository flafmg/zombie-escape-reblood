#!/bin/bash
# my bad attempt into converting the bat into a bash script, but it works
name="ZGL_ZombieEscape" # change name?
version="2.5.1" # increment version or start over?

delump=0
verbose=1
e=0
root="$(cd "$(dirname "$0")" && pwd)"

pk3="${name}-v${version}.pk3"

if [ $verbose -eq 1 ]; then
    echo "Current directory: \"$root\""
    echo "pk3 location: \"$root/bin/$pk3\""
    echo "/src directory: \"$root/src/\""
    echo "/tools directory: \"$root/tools/\""
fi

if [ $delump -eq 1 ]; then
    cd "$root/src/"
    echo "Removing .lmp extension from files in \"$(pwd)\"..."
    find . -name "*.lmp" -type f | while read -r file; do
        mv "$file" "${file%.lmp}"
    done
fi

echo "Testing for 7zip..."
cd "$root/tools/"
if [ $verbose -eq 1 ]; then
    echo "Working directory: \"$(pwd)\""
fi
if ! command -v ./7za >/dev/null 2>&1 && ! command -v 7za >/dev/null 2>&1; then
    echo "7za doesn't exist in $(pwd) or PATH"
    e=1
fi
if [ $e -eq 1 ]; then
    exit 1
fi

echo "Packing \"$root/src/\" into \"$root/bin/$pk3\" ..."
./7za u -tzip "$root/bin/$pk3" -r "$root/src/*" -mx5 -up0q0r2x1y2z1 || 7za u -tzip "$root/bin/$pk3" -r "$root/src/*" -mx5 -up0q0r2x1y2z1

echo "Reordering TEXTURES files..."
if [ $verbose -eq 1 ]; then
    echo "Working directory: \"$(pwd)\""
fi

if [ -f textures.txt ]; then
    rm textures.txt
fi

(./7za x "$root/bin/$pk3" TEXTURES.* -y || 7za x "$root/bin/$pk3" TEXTURES.* -y) 2>/dev/null
(./7za d "$root/bin/$pk3" TEXTURES.* || 7za d "$root/bin/$pk3" TEXTURES.*) 2>/dev/null

for file in TEXTURES.*; do
    if [ -f "$file" ]; then
        mv "$file" "abc$file"
    fi
done

(./7za a "$root/bin/$pk3" abcTEXTURES.* || 7za a "$root/bin/$pk3" abcTEXTURES.*) 2>/dev/null
rm -f abcTEXTURES.*

cd "$root/src/"
if [ $verbose -eq 1 ]; then
    echo "Working directory: \"$(pwd)\""
fi

for file in TEXTURES.*; do
    if [ -f "$file" ]; then
        echo "abc$file" >> "$root/tools/textures.txt"
        echo "$file" >> "$root/tools/textures.txt"
    fi
done

cd "$root/tools/"
if [ $verbose -eq 1 ]; then
    echo "Working directory: \"$(pwd)\""
fi

(./7za rn "$root/bin/$pk3" @textures.txt || 7za rn "$root/bin/$pk3" @textures.txt) 2>/dev/null
rm -f textures.txt
echo "Done!"