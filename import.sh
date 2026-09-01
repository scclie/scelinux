#!/usr/bin/env bash
# Import (apply) a modified NVRAM script file.
#
# Usage:
#   sudo ./import.sh [input-file]
#
# Default input: nvram.txt
# Run as root. Writes the values marked with '*' back into BIOS NVRAM.
# A power cycle (full shutdown, not reboot) is required for some controls.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCE="$SCRIPT_DIR/sceelnx64"
IN="${1:-nvram.txt}"
LOG="log-file.txt"

if [[ $EUID -ne 0 ]]; then
    echo "error: run as root (sudo)"
    exit 1
fi
if [[ ! -x "$SCE" ]]; then
    echo "error: sceelnx64 not found in $SCRIPT_DIR"
    exit 1
fi
if [[ ! -f "$IN" ]]; then
    echo "error: $IN not found. Run ./export.sh first, then edit the file."
    exit 1
fi

echo "Importing NVRAM settings from '$IN' ..."
"$SCE" /i /s "$IN" /d 2> "$LOG" || true

echo
echo "See $LOG for warnings."
grep -iE "warning|error|imported|power cycle" "$LOG" || true
echo
echo "A POWER CYCLE (full shutdown, not reboot) is required for changes"
echo "to take effect on some controls."
