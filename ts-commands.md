# General

## Lite Client
`lite-client -a <address> -p  liteserver.pub`

### Commands 
`runmethod <contract addr> seqno` - returns seqno method
`sendfile queries/send-grams.boc` - sends file queries/send-grams.boc
`getaccount <contract address>` - gets contract account details

# TS

`func stdlib.fc ts/ts.fc -o ts/ts.fif -P`
`fift -I fift-lib -s ts/new.fif <workchain id> <tickets in total> <price in nanograms> <end of sale> <end of refunds> <refund percentage> wallets/ts`

Example: `fift -I fift-lib -s ts/new.fif 0 100000 10000000000 1577622063 1576722063 90 wallets/ts`

# Methods

`runmethod <contract address> seqno` 
`runmethod <contract address> available_tickets`
`runmethod <contract address> refunds_accepted`
`runmethod <contract address> refunds_ends`
`runmethod <contract address> refund_percentage`
`runmethod <contract address> get_owner`
`runmethod <contract address> event_info`
`runmethod <contract address> owned_tickets <owner>`
Example: `runmethod <contract address> owned_tickets 64640357283059775845136824454988057331072478345587548681446968416916405185894`
`runmethod <contract address> get_price`
`runmethod <contract address> customer_seqno <owner>`

*Sample contract address: `0:97344bd09ee1b3b84c2baee9f1c11df108928f2dc864937f88c50dcb015c66b9 `.*

# External messages

## Set Available Tickets
`fift -I fift-lib -s ts/scripts/set-available-tickets.fif wallets/ts <> 12000 0`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/ts-set-available-tickets.boc"`

## Set End Of Refunds
`fift -I fift-lib -s ts/scripts/set-refunds-timeout.fif wallets/ts <contract address> 1576722062 1`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/ts-set-refunds-timeout.boc"`

## Set Refunds Percentage
`fift -I fift-lib -s ts/scripts/set-refunds-percentage.fif wallets/ts <contract address>   75 2`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/ts-set-refunds-percentage.boc"`

## Set Event Info
`fift -I fift-lib -s ts/scripts/set-event-info.fif wallets/ts <contract address> ts/scripts/event-info.txt 1`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/ts-set-event-info.boc"`

## Withdraw funds
`fift -I fift-lib -s ts/scripts/send-grams.fif wallets/ts <contract address> 4 10`
``lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/ts-send-grams.boc"`

# Internal messages
## Buy Tickets
`fift -I fift-lib -s ts/scripts/new-buy-ticket-body.fif wallets/stage2 5`
`fift -I fift-lib -s tools/send-grams.fif wallets/stage2 <contract address> 101 53 -B bodies/buy-tickets-body.boc`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/send-grams.boc"`

## Refund Tickets
`fift -I fift-lib -s ts/scripts/new-refund-ticket-body.fif wallets/stage2 3 0`
`fift -I fift-lib -s tools/send-grams.fif wallets/stage2 <contract address> 99 2 -B bodies/refund-tickets-body.boc`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/send-grams.boc"`

## Transfer Tickets
`fift -I fift-lib -s ts/scripts/new-transfer-ticket-body.fif wallets/stage2 wallets/sw 1 0`
`fift -I fift-lib -s tools/send-grams.fif wallets/stage2 <contract address> 94 1 -B bodies/transfer-tickets-body.boc`
`lite-client -a <address> -p  liteserver.pub --cmd "sendfile queries/send-grams.boc"`

# Scripts
`./ts-test-buy.sh 102 6 62`
`./ts-test-refund.sh 103 2 3`
`./ts-test-transfer.sh 105 3 3`
`./ts-test-init.sh 97 10`