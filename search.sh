#!/usr/bin/env bash
# Find and show a Setup question (or search) in an exported NVRAM file.
#
# Usage:
#   ./search.sh "<setting name>" [export-file]
#   ./search.sh -list [export-file]
#
# Default export file: nvram.txt
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIR="$SCRIPT_DIR"

FILE="${2:-nvram.txt}"
if [[ ! -f "$FILE" ]]; then
    echo "error: $FILE not found. Run ./export.sh first."
    exit 1
fi

case "${1:-}" in
    -list|-l)
        grep "^Setup Question	= " "$FILE" | sed 's/^Setup Question	= //'
        ;;
    "")
        echo "Usage:"
        echo "  ./search.sh \"<setting name>\"   # show one setting's block"
        echo "  ./search.sh -list                # list all setting names"
        exit 0
        ;;
    *)
        awk -v q="^Setup Question	= ${1}$" \
            '$0 ~ q {f=1} f {print} f && /^$/ {exit}' "$FILE"
        ;;
esac
