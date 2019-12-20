#!/bin/sh

. "util/wrappers.sh"

DEST_ADDR=$1
SEQNO=${2:-1}
AMOUNT=${3:-1}
# load address
if ! grep "ADDR=" ".sw-info" > /dev/null; then 
    printf "%s\n" ".sw-info file not found, please run sw-test-init.sh first."
    exit 2
fi
ADDR=$(grep "ADDR=" ".ts-info" | sed "s/ADDR=//g")

# buy ticket
run_fift ts/scripts/new-buy-ticket-body.fif wallets/stage2 5
run_fift tools/send-grams.fif wallets/stage2 $ADDR $SEQNO 53 -B bodies/buy-tickets-body.boc
run_lite_cmd "sendfile queries/send-grams.boc"

run_fift ts/scripts/send-grams.fif wallets/ts $DEST_ADDR $SEQNO $AMOUNT
run_lite_cmd "sendfile queries/ts-send-grams.boc"