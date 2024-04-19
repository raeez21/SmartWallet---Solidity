# SmartWallet
This is an implementation of a SmartWallet in a Smart Contract to be deployed in Ethereum blockchain. 

The wallet has these properties:
1. Has one and only one owner at a time
2. The wallet should receive funds no matter what
3. The owner should be able to spend funds on any kind of address, be it Externally Owned Account (EOA - with private key) or a Contract address (another smart contract)
4. The wallet should allow certain people (only those authorised by owner) to spend certain amounts of funds based on their allowance quota.
5. The owner can set some accounts as guardians of his/her wallet. If the owner looses his account, it is possible to change the owner to a new address only if atleast 3 guardians vote for that new owner.

The entire code is in [SmartContractWallet.sol](SmartContractWallet.sol)

For additional details refer to this [site](https://ethereum-blockchain-developer.com/2022-04-smart-wallet/09-the-smart-contract-wallet/)
