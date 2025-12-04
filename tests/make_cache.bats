MAKEFILE_PATH="${BATS_TEST_DIRNAME}/../make_cache"


setup(){
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"

    cp "${MAKEFILE_PATH}" ./Makefile
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "make_cache creates cache only where target files exist" {
    mkdir -p music/album_1
    mkdir -p music/album_2
    mkdir -p music/album_empty

    touch music/album_1/album_1.cue
    touch music/album_1/album_1.flac

    touch music/album_2/track_1.flac
    touch music/album_2/track_2.flac

    run make Playlist.m3u8
    [ "$status" -eq 0 ]

    [ -f music/album_1/.phono_manager.cache ]
    [ -f music/album_2/.phono_manager.cache ]
    [ ! -f music/album_empty/.phono_manager.cache ]
}