#!/bin/bash
# Check and install all required overlays for the airway-salmon pipeline.
# Run from project root: bash src/setup.sh

set -euo pipefail

# Build any missing bundle overlays from src/overlay/*.yml
echo "=== Bundle overlays ==="
for yml in src/overlay/*.yml; do
    name=$(basename "$yml" .yml)
    sqf="src/overlay/${name}.sqf"
    if [ -f "$sqf" ]; then
        echo "  [ok]      $sqf"
    else
        echo "  [missing] $sqf — building from $yml..."
        condatainer create -p "src/overlay/${name}" -f "$yml"
    fi
done

# Auto-install missing module overlays declared in each script's #DEP: tags
echo ""
echo "=== Module overlays ==="
condatainer check -a src/*.sh || [ $? -eq 3 ]  # Check all scripts, ignore exit code 3 (missing overlays)
