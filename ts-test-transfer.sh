#!/bin/sh

. "util/wrappers.sh"

WALLET_SEQNO=${1:-1}
CUSTOMER_SEQNO=${2:-1}
COUNT=${3:-1}
# load address
if ! grep "ADDR=" ".sw-info" > /dev/null; then 
    printf "%s\n" ".sw-info file not found, please run sw-test-init.sh first."
    exit 2
fi
ADDR=$(grep "ADDR=" ".ts-info" | sed "s/ADDR=//g")

run_fift ts/scripts/new-transfer-ticket-body.fif wallets/stage2 wallets/sw $COUNT $CUSTOMER_SEQNO
run_fift tools/send-grams.fif wallets/stage2 $ADDR $WALLET_SEQNO 1 -B bodies/transfer-tickets-body.boc
run_lite_cmd "sendfile queries/send-grams.boc"
