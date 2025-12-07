MAKEFILE_PATH="${BATS_TEST_DIRNAME}/../make_cache"

fixture_music_lib(){
    mkdir -p "$1/music/album_1"
    mkdir -p "$1/music/album_2"
    mkdir -p "$1/music/album_empty"

    touch "$1/music/album_1/album_1.cue"
    touch "$1/music/album_1/album_1.flac"

    touch "$1/music/album_2/track_1.flac"
    touch "$1/music/album_2/track_2.flac"
}

setup(){
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"

    cp "${MAKEFILE_PATH}" ./Makefile

    make() {
        command make "$@"
    }
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "make_cache creates cache only where target files exist" {
    fixture_music_lib "$TEST_DIR"

    run make Playlist.m3u8
    [ "$status" -eq 0 ]

    [ -f music/album_1/.phono_manager.cache ]
    [ -f music/album_2/.phono_manager.cache ]
    [ ! -f music/album_empty/.phono_manager.cache ]
}


@test "cache mtime unchanged if files unchanged" {
  fixture_music_lib "$TEST_DIR"

  make Playlist.m3u8
  mtime1=$(stat -f %m music/album_1/.phono_manager.cache)

  sleep 1
  make Playlist.m3u8
  mtime2=$(stat -f %m music/album_1/.phono_manager.cache)

  [ "$mtime1" -eq "$mtime2" ]
}

@test "cache mtime updates when file changes" {
    fixture_music_lib "$TEST_DIR"

    make Playlist.m3u8

    mtime1=$(stat -f %m Playlist.m3u8)

    sleep 2
    touch music/album_1/album.flac

    make Playlist.m3u8
    mtime2=$(stat -f %m Playlist.m3u8)

  [ "$mtime2" -gt "$mtime1" ]
}