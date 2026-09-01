#!/usr/bin/env bash
# Export current BIOS NVRAM settings to a script file.
#
# Usage:
#   sudo ./export.sh [output-file]
#
# Default output: nvram.txt
# Run as root. Creates a plain-text script listing every Setup question
# with the currently active value marked by '*'.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCE="$SCRIPT_DIR/sceelnx64"
OUT="${1:-nvram.txt}"
LOG="log-file.txt"

if [[ $EUID -ne 0 ]]; then
    echo "error: run as root (sudo)"
    exit 1
fi
if [[ ! -x "$SCE" ]]; then
    echo "error: sceelnx64 not found in $SCRIPT_DIR"
    exit 1
fi

echo "Exporting NVRAM settings to '$OUT' ..."
"$SCE" /o /s "$OUT" /d 2> "$LOG" || true

if [[ -f "$OUT" && -s "$OUT" ]]; then
    echo "Exported $(wc -l < "$OUT") lines -> $OUT"
    echo "Edit this file (move the '*'), then run: sudo ./import.sh $OUT"
else
    echo "error: export failed. See $LOG"
    cat "$LOG"
    exit 1
fi
