#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OUTPUT_DIR="$HOME/Pictures/Протуберанцы/$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# You must add one empty line to the end of this file!
LINKS_FILE="$SCRIPT_DIR/links.txt"
echo "$(wc -l < "$LINKS_FILE") links in $LINKS_FILE"

COUNTER=1
while IFS= read -r LINK; do
    curl -so /tmp/t "$LINK"

    LAST_MODIFIED=$(curl -sI "$LINK" | sed -n "s/^last-modified: //ip")
    # Compute BLAKE3-hash and use it as suffix for prevent duplication.
    HASH_TAIL=$(b3sum /tmp/t | cut -c1-8)
    FILEPATH=$(date -d "$LAST_MODIFIED" +"${OUTPUT_DIR%/}/PHOTO_%Y%m%d_%H%M%S_$HASH_TAIL.jpg")

    mv /tmp/t "$FILEPATH"
    # Set real date and time.
    touch -d "$LAST_MODIFIED" "$FILEPATH"

    echo "$COUNTER. $FILEPATH has been downloaded"
    ((COUNTER++))
done < "$LINKS_FILE"

echo "Done."
exit 0