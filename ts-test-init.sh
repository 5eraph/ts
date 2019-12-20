#!/bin/sh
BASEDIR=$(dirname "$0")
WALLET="$BASEDIR/wallets/stage2"
SEQNO=$1
GRAMS=$2

. "$BASEDIR/util/wrappers.sh"

run_func "ts/ts.fc" -o "ts/ts.fif" -P
NEW_OUTPUT=$(run_fift "$BASEDIR/ts/new.fif" 0 125000 10000000000 1577622063 1577022063 90 "$BASEDIR/wallets/ts" 0)

ADDR=$(printf "%s" "$NEW_OUTPUT" | grep "new event address" | sed 's/.*= //g')
NON_BOUNCABLE=$(printf "%s" "$NEW_OUTPUT" | grep "Non-bounceable address" | sed 's/.*: //g')
BOUNCABLE=$(printf "%s" "$NEW_OUTPUT" | grep "Bounceable address" | sed 's/.*: //g')

printf "ADDR=%s\nNON_BOUNCABLE=%s\nBOUNCABLE=%s\n" "$ADDR" "$NON_BOUNCABLE" "$BOUNCABLE" > .ts-info

run_fift "$BASEDIR/tools/send-grams.fif" "$WALLET" $NON_BOUNCABLE $SEQNO $GRAMS
run_lite_cmd "sendfile $BASEDIR/queries/send-grams.boc"

sleep 10 # wait 10 s to credit the account
run_lite_cmd "sendfile $BASEDIR/queries/create-event.boc"