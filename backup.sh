#!/usr/bin/env bash
# Back up current BIOS NVRAM settings to a timestamped file.
#
# Usage:
#   sudo ./backup.sh [label]
#
# Creates ./backups/nvram-YYYYmmdd-HHMMSS<label>.txt
# Always make a backup before modifying any BIOS settings.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="${1:-}"
TS="$(date +%Y%m%d-%H%M%S)"
DIR="$SCRIPT_DIR/backups"
mkdir -p "$DIR"
FILE="$DIR/nvram-$TS${LABEL:+-$LABEL}.txt"

"$SCRIPT_DIR/export.sh" "$FILE"
echo "Backup saved: $FILE"
