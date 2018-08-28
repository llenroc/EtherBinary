# Avoiding Common Attacks

## Avoiding tx.origin:
We avoided to use tx.origin in all cases because of the well known threats that it implies such as identity impersonation and others.

## Checks-Effects-Interactions:
Before doing any change on the storage or sending ether we validate that all conditions are met using modifiers, so in this way all checks needs to be passed before doing a certain action.