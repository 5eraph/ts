#!/bin/sh

LITE_CLIENT_BIN="$HOME/projects/ton/build/lite-client/lite-client"
LITE_SERVER_ADDR="88.99.85.139:2030"
LITE_SERVER_PUB="$HOME/projects/ton/build/lite-client/liteserver.pub"
FIFT="$HOME/projects/ton/build/crypto/fift"
FUNC="$HOME/projects/ton/build/crypto/func"

run_func() {
    "$FUNC" stdlib.fc $@
}

run_fift() {
    "$FIFT" -I fift-lib -s $@
}

run_lite_cmd() {
    "$LITE_CLIENT_BIN" -a "$LITE_SERVER_ADDR" -p "$LITE_SERVER_PUB" --cmd "$@"
}

sum() {
    printf "%d + %d\n" "$1" "$2" | bc
}