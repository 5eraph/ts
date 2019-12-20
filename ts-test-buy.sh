#!/bin/sh

. "util/wrappers.sh"

WALLET_SEQNO=${1:-1}
AMOUNT=${2:-5}
PAY=${3:-51}
# load address
if ! grep "ADDR=" ".sw-info" > /dev/null; then 
    printf "%s\n" ".sw-info file not found, please run sw-test-init.sh first."
    exit 2
fi
ADDR=$(grep "ADDR=" ".ts-info" | sed "s/ADDR=//g")

# buy ticket
run_fift ts/scripts/new-buy-ticket-body.fif wallets/stage2 $AMOUNT
run_fift tools/send-grams.fif wallets/stage2 $ADDR $WALLET_SEQNO $PAY -B bodies/buy-tickets-body.boc
run_lite_cmd "sendfile queries/send-grams.boc"