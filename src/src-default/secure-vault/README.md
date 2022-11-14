# #12 - Secure Vault

A very sturdy vault is guarding 10,000,000 DefiCtf tokens. It follows the UUPS upgradeable pattern.

The owner of the vault can only withdraw a limited amount of tokens every 15 days. The owner is currently a timelock contract.

The vault however, has a role with the power to withdraw all funds in case of emergency.

In the timelock contract, you can schedule actions which can be executed after 1 hour passes. You need the **Proposer** role for this functionality though.

Can you empty this vault?