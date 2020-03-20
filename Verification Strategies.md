## Simple Strategy

Customer signs data blob with private key used to pay for the tickets.

### Issues

- You have to educate your customers not to sign anything
- Data blob has to be easily verifiable by customers.
- Customers may be mislead to sign transaction and lost funds.

## Secure Strategy

Leveraging buy as gift - the customer wallet generates event specific private key which will hold the tickets and will be used to confirm customer identity.
User wallet allows only sign specific form of data blob with this private key or request refund/transfer operations.

### Issues

- You have to warn your users to backup wallet after key generation.

### Advantages

- Other customer funds are protected
- Customer main wallet accounts are inaccessible through alternative private key 
- Customer operations with account holding tickets are limited to necessary operations only.

### Disadvantages

- more complex client side implementation