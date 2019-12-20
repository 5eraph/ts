#!/bin/sh

. "util/wrappers.sh"

SEQNO_SHIFT=${1:-1}
SLEEP=60
# load address
if ! grep "ADDR=" ".sw-info" > /dev/null; then 
    printf "%s\n" ".sw-info file not found, please run sw-test-init.sh first."
    exit 2
fi
ADDR=$(grep "ADDR=" ".ts-info" | sed "s/ADDR=//g")

TIMESTAMP=$(date +'%s')
END_OF_REFUNDS=$(sum $TIMESTAMP 10000000)

run_fift ts/scripts/set-available-tickets.fif wallets/ts $ADDR 12000 $(sum $SEQNO_SHIFT 0)
run_lite_cmd "sendfile queries/ts-set-available-tickets.boc"
sleep $SLEEP
run_fift ts/scripts/set-refunds-timeout.fif wallets/ts $ADDR $END_OF_REFUNDS $(sum $SEQNO_SHIFT 1)
run_lite_cmd "sendfile queries/ts-set-refunds-timeout.boc"
sleep $SLEEP
run_fift ts/scripts/set-refunds-percentage.fif wallets/ts $ADDR 75 $(sum $SEQNO_SHIFT 2)
run_lite_cmd "sendfile queries/ts-set-refunds-percentage.boc"
sleep $SLEEP
run_fift ts/scripts/set-event-info.fif wallets/ts $ADDR ts/scripts/event-info.txt $(sum $SEQNO_SHIFT 3)
run_lite_cmd "sendfile queries/ts-set-event-info.boc"