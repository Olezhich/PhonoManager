fixture_music_lib(){
    mkdir -p "$1/music/album_1"
    mkdir -p "$1/music/album_2"
    mkdir -p "$1/music/album_empty"

    mkdir -p "$1/music/album_prohibited"

    touch "$1/music/album_1/album_1.cue"
    touch "$1/music/album_1/album_1.flac"

    touch "$1/music/album_2/track_1.flac"
    touch "$1/music/album_2/track_2.flac"

    touch "$1/music/album_prohibited/album_prohibited.cue"

    echo "music/album_prohibited/*" > "$1/.ignore"
}

setup(){
    export PROJECT_ROOT="${BATS_TEST_DIRNAME}/.."

    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

make_cache(){
  run make -C "$PROJECT_ROOT" -f "$PROJECT_ROOT/make_cache" INPUT_DIR="$TEST_DIR" Playlist.m3u8
  echo "$output"
}

teardown() {
    rm -rf "$TEST_DIR"
}

get_mtime() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f %m "$1"
  else
    stat -c %Y "$1"
  fi
}

@test "make_cache creates cache only where target files exist" {
    fixture_music_lib "$TEST_DIR"

    make_cache
    if [ "$status" -ne 0 ]; then 
      echo "$output"
    fi

    cat Playlist.m3u8
    
    [ "$status" -eq 0 ]

    [ -f music/album_1/.phono_manager.cache ]
    [ -f music/album_2/.phono_manager.cache ]
    [ ! -f music/album_empty/.phono_manager.cache ]

    run grep -q 'album_1.cue$' Playlist.m3u8
    [ "$status" -eq 0 ]
    run grep -q 'track_1.flac$' Playlist.m3u8
    [ "$status" -eq 0 ]
    run grep -q 'track_2.flac$' Playlist.m3u8
    [ "$status" -eq 0 ]
    run grep -q 'album_prohibited.cue' Playlist.m3u8
    [ "$status" -ne 0 ]
}


@test "cache mtime unchanged if files unchanged" {
  fixture_music_lib "$TEST_DIR"

  make_cache
  mtime1=$(get_mtime music/album_1/.phono_manager.cache)

  sleep 2
  make_cache
  mtime2=$(get_mtime music/album_1/.phono_manager.cache)

  [ "$mtime1" -eq "$mtime2" ]
}

@test "cache mtime updates when file changes" {
    fixture_music_lib "$TEST_DIR"

    make_cache

    mtime1=$(get_mtime Playlist.m3u8)

    sleep 2
    touch music/album_1/album.flac

    make_cache
    mtime2=$(get_mtime Playlist.m3u8)

  [ "$mtime2" -gt "$mtime1" ]
}