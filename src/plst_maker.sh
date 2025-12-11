#!/bin/bash

set -euo pipefail


INPUT_DIR="."
OUTPUT_FILE="playlist.m3u8"
IGNORE_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            INPUT_DIR="$2"; shift 2 ;;
        -o|--output)
            OUTPUT_FILE="$2"; shift 2 ;;
        -g|--ignore)
            IGNORE_FILE="$2"; shift 2;;
        -d|--dry-run)
            DRY_RUN=true; shift ;;
        -h|--help)
            echo "Usage: $0 [-i DIR] [-o FILE] [--ignore-file FILE] [--dry-run]"
            exit 0 ;;
        *)
            echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Error: input directory does not exist: $INPUT_DIR" >&2
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "[DRY RUN] Would generate playlist from '$INPUT_DIR' to '$OUTPUT_FILE'"
else
  touch "$OUTPUT_FILE"
  echo "Playlist placeholder created: $OUTPUT_FILE"
fi

exit 0