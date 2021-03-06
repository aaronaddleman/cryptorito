#!/usr/bin/env bats
# -*- mode: Shell-script;bash -*-
# happy path tests
load helper

setup() {
    gpg_fixture
}

@test "a happy path" {
    VAR="bla-blah-blah${RANDOM}"
    RECP="${GPGID}"
    run_cryptorito 0 encrypt "$RECP" <<< "$VAR"
    grep -v -E "^gpg:.+$" <<< "$output" > "${FIXTURE_DIR}/enc"
    # for some reason the output is prefixed by all this "gpg:" stuff in
    # test contexts. not when running otherwise :(
    run_cryptorito 0 decrypt < "${FIXTURE_DIR}/enc"
    scan_lines "$VAR" "${lines[@]}"
    run_cryptorito 0 has_key "$GPGID"
    run_cryptorito 1 has_key "nope"
}

@test "a happy path but with files" {
    FILE1="${FIXTURE_DIR}/ayyy${RANDOM}"
    FILE2="${FIXTURE_DIR}/ayyyenc${RANDOM}"
    FILE3="${FIXTURE_DIR}/ayyydec${RANDOM}"
    echo "$RANDOM" > "$FILE1"
    run_cryptorito 0 encrypt_file "$FILE1" "$FILE2" "$GPGID"
    gpg --list-secret-keys
    cat "$FILE2"
    run_cryptorito 0 decrypt_file "$FILE2" "$FILE3"
    [ "$(cat $FILE1)" == "$(cat $FILE3)" ]
}

@test "keybase minimal" {
    run_cryptorito 0 import_keybase otakup0pe
    run_cryptorito 2 import_keybase otakup0pe    
}
