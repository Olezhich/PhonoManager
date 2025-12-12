#!/bin/bash

set -euo pipefail


INPUT_DIR="."
OUTPUT_FILE="playlist.m3u8"
IGNORE_FILE=""

AGREGATOR_FILES=(-name '*.cue')
AUDIO_FILES=(-name '*.flac' -o -name '*.ape' -o -name '*.wav' -o -name '*.mp3' -o -name '*.m4a')
TARGET_FILES=(${AGREGATOR_FILES[@]} -o ${AUDIO_FILES[@]})

EXCLUDE_PATTERNS=(.DS_Store)

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            INPUT_DIR="$2"; shift 2 ;;
        -o|--output)
            OUTPUT_FILE="$2"; shift 2 ;;
        -g|--ignore)
            IGNORE_FILE="$2"; shift 2;;
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



load_ignore_patterns() {
  local ignore_path="$1"
  if [[ -f "$ignore_path" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      EXCLUDE_PATTERNS+=("$line")
    done < "$ignore_path"
  fi
}

should_exclude() {
  local filepath="$1"
  local rel_path="${filepath#$INPUT_DIR/}"

  for pat in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$pat" == */*"/" ]]; then
      local dir_pat="${pat%/}"
      if [[ "$rel_path" == $dir_pat/* ]]; then
        return 0
      fi
    else
      if [[ "$rel_path" == $pat ]]; then
        return 0
      fi
    fi
  done
  return 1
}

load_ignore_patterns "$IGNORE_FILE"

# Main Logic

# Set of all target files (.cue && .flac etc.)

all_files=()

while IFS= read -rd '' file; do
    all_files+=("$file")
done < <(find "$INPUT_DIR" -type f \( ${TARGET_FILES[@]} \) -print0)

declare -a unique_dirs
for file in "${all_files[@]}"; do
  [[ -z "$file" ]] && continue
  dir="${file%/*}"
  unique_dirs+=("$dir")
done

unique_dirs=($(printf '%s\n' "${unique_dirs[@]}" | sort -u))



# List only of files that goes to playlist

declare -a playlist_entries

for dir in "${unique_dirs[@]}"; do
    cue_files=()
    while IFS= read -rd '' file; do
        cue_files+=("$file")
    done < <(find "$dir" -maxdepth 1 -type f \( ${AGREGATOR_FILES[@]} \) -print0)

    if [[ ${#cue_files[@]} -gt 0 ]]; then
        # if .cue exists
        for f in "${cue_files[@]}"; do
            [[ -z "$f" ]] && continue
            if ! should_exclude "$f"; then 
                playlist_entries+=("$f")
            fi
        done
    else
        # No .cue 
        audio_files=()
        while IFS= read -rd '' file; do
            audio_files+=("$file")
        done < <(find "$dir" -maxdepth 1 -type f \( ${AUDIO_FILES[@]} \) -print0)

        for f in "${audio_files[@]}"; do
            [[ -z "$f" ]] && continue
            if ! should_exclude "$f"; then 
                playlist_entries+=("$f")
            fi
        done
    fi
done

printf '%s\n' "${playlist_entries[@]}" > "$OUTPUT_FILE"

exit 0