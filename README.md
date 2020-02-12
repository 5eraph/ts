# TS - Ticket System TON Smart Contract

## Scenario

Ticket sales of big events are often affected by malicious actors counterfeiting tickets therefore stealing from customers and complicating the ticket verification process.
There are usually different measures taken to prevent such situations - starting with informing users about official resellers, ending with special forms of ticket printing and time stamping to limit counterfeiting.

Purpose of this PoC TON Smart Contract is to outline a way how we can leverage TON network to cryptographically secure ticket sales.

Of course, the nature of this smart contract can be reused or extended to additional types of sales, but the original motivation and the idea behind it is to improve event industry.

## Core Idea 

By leveraging the blockchain technology we provide to the customers a safe way to buy tickets from the organizer of the event through one or a set of smart contracts, while always being able to verify owned tickets. Also, we outline a way of verifying customer's ticket when entering the event.

## Implementation

TS is implemented as a single point of sale for single ticket/product. Naturally, events tend to provide a different kind of tickets (standard, VIP, backstage etc.). But providing SC with this kind of functionality would cause significant increase in complexity and storage costs and as such, we have decided to design it as 1 contract per ticket type.

Each contract holds its event info (which may contain information about the ticket type). It is expected and recommended for organizers to include list of authorized contracts and a signature of it as a proof of info originality as a contract owner does not have to be necessarily an event organizer.

Price cannot be changed during the contract lifetime to prevent potential issues with refunds.
End of sale can not be changed as well as we are expected to know thr end of sale from the contract deployment. (We know when and where an event takes place) 

End of refunds and refunds percentage are configurable because we may want to change it over time, e.g. 2 months before the event 90% refund, 1 month 75%, 2 weeks - no refunds. To disable refunds, we can set the end of the refunds to now or any other timestamp lower than now.

Code: `ts/ts.fc`

### Storage 

We store TS data in the following structure:
- 256 bit - public key of the contract owner
- 16 bit - seqno - as TS contracts are used temporarily - during the sales. It is not necessary to use higher capacity integers for seqno
- grams - price of ticket
- 32 bit - end of sale timestamp
- 32 bit - end of refunds timestamp
- 7 bit - refund percentage 
- store - dictionary containing user records - 256 bit keys representing user public keys.
    - user record:
        - 16 bit seqno (replay protection for refunds and transfers)
        - 8 bit ticket count (we don't expect that anyone would like to buy more and it is even not a good idea to let someone buy that many as it complicates verification)
    - key 0 holds 24 bit count of available tickets (max over 16M tickets. We expect that this is enough based on the biggest events in the history hosting around 3.5M people)
- event info reference

### Internal Messages

Internal messages provide core functionality of TS - buy, refund, transfer. Each message has to carry at least 1 GRAM as a processing fee. The remaining part of this 1 GRAM is returned to a message source address with a response signaling result of the operation. 

#### Internal Messages Body' Structure

TS expects internal message body structure as follows:
1 reference - message 
2 reference - message signature (required for a refund and transfer only)

1st reference structure:
3 bit - operation
64 bit - query id
... operation specific data:
- `op == 0` - pass through - for donations
- `op == 1` - buy (does not require signature - buy as a gift possible):
    - 256 bit public key which will hold paid tickets
    - 8 bit count of tickets to buy
- `op == 2` - refund (requires signature):
    - 16 bit customer seqno - replay protection
    - 256 bit public key of the owner of tickets
    - 8 bit count of tickets to buy
- `op == 3` - trasnfer (requires signature)
    - 16 bit customer seqno - replay protection
    - 256 bit public key of the owner of tickets
    - 256 bit public key of the new owner of tickets
    - 8 bit count of tickets to transfer
*Transfer provides a way to send tickets to someone else. E.g. if you cannot attend the event.*

- `op == 4` - buy with tip (considers anything above required price a tip for the contract owner)
    - 256 bit public key which will hold paid tickets
    - 8 bit count of tickets to buy

#### Structure Of Response Messages' Body
4 bit response code
64 bit query id - equals to query id used in received message

##### Return codes - 4 bit
*Only 0 return code is success (non error) code.*
0. success
1. didn't pay enough
2. not enough tickets for sale
3. the limit of tickets per account exceeded
4. not enough owned tickets
5. sale ended
6. invalid owner - means owner was equal to 0
7. not matching seqno
8. cannot buy 0 tickets
9.  refunds not accepted
10. signature check failed
11. unknown 

### External Messages

External messages allow the contract owner to control parts of the contract behavior. It is possible to set: the number of available tickets, refund percentage, end of refunds, event info.  

The contract owner is able to change available (not sold) tickets for cases of multiple points of sales or resellers.

#### External Messages Body' Structure

512 bit - contract owner signature
64 bit - query id - also provides replay protection - holds timeout timestamp
16 bit - seqno - replay protection within timeout window
3 bit - operation 
... operation specific data:
0 - init message - no additional data required
1 - add available tickets
    - 24 bit - ticket count (use negative to decrease)
    - **remember that users can buy in meantime so even when decreasing to 0, some tickets may be sold. Plan accordingly.**
2 - set end of refunds
    - 32 bit - timestamp
3 - set refund percentage
    - 7 bit - percentage
4 - send message to provide a way to withdraw grams (based on wallet2.fif)
    - 8 bit - send message mode
    - reference - raw message
5 - set event info
    - reference - containing event info

### Public Methods

- `int proof_ownership(int owner, cell data, cell signatureC)` - Provides a way to verify the owner of tickets. The verifier gives a one-time code to the owner which has to sign it. One-time code is passed as a data along with owner and cell holding the signature to the method. `proof_ownership` returns -1 if signature matches or 0 otherwise. *This method may be executed locally in VM as well. It is included in contract for cases when we would like to run without additional dependencies.*

**:warning:Remember to specify transparent and easily verifiable specification of data and to educate your customers.:warning:**

*NOTE: DATA should be simple one time code easily verifiable by the user and potential wallet software to avoid potential abuse of consumer by misleading them to sign queries or any data which could cause any harm*
*Possible data specification: Random number in range 1-1000 + current date and time in format ddMMyyHHmm. E.g. random number 355 and date 120220 and time 1725 together: 3551202201725. This fits into 44 bits of data and is easily verifiable by software and consumer visually.*                                                                                                                                                    

- `int owned_tickets(int owner)` - Takes public key and returns the number of tickets belonging to this public key.
- `int available_tickets()` - Returns the number of tickets available for sale.
- `int refunds_accepted()` - If refunds are accepted returns -1, otherwise 0.
- `int refunds_ends()` - Returns end of refunds timestamp.
- `int sale_ends()` - Returns end of sale timestamp.
- `int refund_percentage()` - Returns refund percentage.
- `int get_owner()` - Returns owner of the contract.
- `int get_price()` - Returns price of tickets.
- `int seqno()` - Returns seqno.
- `int customer_seqno(int owner)` returns customer specific seqno.

## Testing 

### Local 
Tests core functions of TS.
Requirements:
- comment out recv_internal and recv_external.
- uncomment main

Execute: `func stdlib.fc ts/ts.fc -o ts/ts.fif && fift -I fift-lib ts/test_local.fif`
Exit code 0 means that tests passed successfully. Other exit codes means failures in specific tests.

#### Local testing of recv_internal and recv_external
Requirements:
- comment out recv_internal or recv_external, so only one you want to test is available
- rename method you want to test to main
- adjust parameters in `ts/test_recv_internal.fif` or `ts/test_recv_external.fif`

Execute:
- `func stdlib.fc ts/ts.fc -o ts/ts.fif && fift -I fift-lib ts/test_recv_external.fif`
- `func stdlib.fc ts/ts.fc -o ts/ts.fif && fift -I fift-lib ts/test_recv_internal.fif`

### On Chain 

Use shell scripts provided.
Requirements:
- `stage2.addr` and `stage2.pk` - stage2 named wallet holding some grams for testing
  - use `create-wallet.sh` and then `sendfile queries/create-wallet-query.boc` through lite client 
- set correct values of `LITE_CLIENT_BIN`, `LITE_SERVER_ADDR`, `LITE_SERVER_PUB`, `FIFT` and `FUNC` in `util/wrappers.sh`
- remove `wallets/ts.addr` and `wallets/ts.pk` (optional - do it if you want to test deployment)

`ts-test-init.sh` <source wallet seqno> <grams to send> - deploys contract (generated contract wallet is stored in `wallets/ts.*` and wallet info in `.ts-info`)
`ts-test.sh` <ts seqno> - tests external messages (after deployment seqno is 1)
`ts-test-buy.sh` <source wallet seqno> <number of tickets> <grams> - sends buy message
`ts-test-refund.sh` <source wallet seqno> <number of tickets> <grams> - sends refund message
`ts-test-transfer.sh` <source wallet seqno> <number of tickets> <grams> - sends transfer message
`ts-test-withdraw.sh` <destination address> <ts seqno> <grams> - sends funds from contract to specified address

*Test transfer uses sw wallet as the destination.*

### Test & Operation Notes 

To use smart contract in a custom way you use `fif` scripts in `ts/scripts`. 

#### Creation

For manual TS creation use `ts/new.fif`.

#### Internal Messages

To send internal messages you need wallet with grams (*I used `wallet-v2.fif` and `new-wallet-v2.fif` from [ton-blockchain/ton](https://github.com/ton-blockchain/ton/blob/master/crypto/smartcont/new-wallet-v2.fif).*) and right message body generator.

- `ts/scripts/new-buy-ticket-body.fif` <wallet file base> <count> - generates buy message body
- `ts/scripts/new-refund-ticket-body.fif` <wallet file base> <count> - generates buy message body
- `ts/scripts/new-transfer-ticket-body.fif` <wallet file base> <dst file base> <count> - generates transfer message body (from 2 existing wallets)
- `ts/scripts/new-transfer-ticket-body2.fif` <wallet file base> <dst addr> <count> - generates transfer message body

*Generated bodies are stored in `bodies` directory.*

After generating message body you use it as body parameter for `tools/send-grams.fif`. 
Example: `fift -I fift-lib -s tools/send-grams.fif wallets/stage2 $ADDR $WALLET_SEQNO $GRAMS -B bodies/buy-tickets-body.boc`
*For more examples check ts-test\* test scripts.*

After generating send-grams message with included body send it with `sendfile` command through lite client. Generated send-grams query is stored in  `queries/send-grams.boc`

#### External Messages

Use scripts in `ts/scripts` to generate external messages.

`ts/scripts/send-grams.fif` <contract control wallet> <dest addr> <ts seqno> <grams> - customized `tools/send-grams.fif` script to work with TS.
`ts/scripts/set-available-tickets.fif`  <contract owner wallet> <contract addr> <count> <seq> - sets number of available tickets
`ts/scripts/set-event-info.fif` <contract owner wallet> <contract addr> <count> <file to event info represented by boc from> <seq> - sets event info
`ts/scripts/set-refunds-percentage.fif` <contract owner wallet> <contract addr> <percentage> <seq> - sets refunds percentage
`ts/scripts/set-refunds-timeout.fif` <contract owner wallet> <contract addr> <end of refunds> <seq> - sets end of refunds timestamp

*For more examples check ts-test\* test scripts.*

After generating external message send it with `sendfile` command through lite client. 

## Potential Issues
Customer has to make sure on its own, that contract he is trading with is authorized for selling tickets for this specific event. Such contract should hold signed event information with a list of authorized contract sellers - signed with the event organizer key. For customer knowing the organizer public key is a must. 

## Notes
- all stored integers are stored as unsigned integers
- if you are looking for how should be specific commands executed - check commands.md or specific test shell scripts
- **All scripts and commands are expected to be run from root directory of this project.**
