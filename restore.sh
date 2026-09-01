#!/usr/bin/env bash
# Restore BIOS NVRAM from a backup file.
#
# Usage:
#   sudo ./restore.sh [backup-file]
#
# If no file given, lists available backups in ./backups/.
# Restoring re-imports the backup values, then requires a power cycle.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIR="$SCRIPT_DIR/backups"

if [[ $# -lt 1 ]]; then
    echo "Usage: sudo ./restore.sh <backup-file>"
    echo
    echo "Available backups:"
    ls -1 "$DIR" 2>/dev/null || echo "  (none in $DIR)"
    exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
    echo "error: $FILE not found"
    exit 1
fi

"$SCRIPT_DIR/import.sh" "$FILE"
