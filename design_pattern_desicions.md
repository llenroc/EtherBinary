# Design Patterns Desicions

## Emergency Stop or Circuit Breaker:
* **Desctiption:** Circuit breakers stop execution if certain conditions are met, and can be useful when new errors are discovered.

* **Reason:** This can help in case a bug is found cause we can pause the smart contract functionality till we track down the issue.

## Factory Pattern:
* **Desctiption:** Uses factory methods to deal with the problem of creating objects without having to specify the exact class of the object that will be created. 

* **Reason:** Since the amount of games that we can have can be very big and we can keep adding games, this is an easy way to deploy new games.

## Registry Pattern:
* **Desctiption:** Registry contract store the latest version of a contract, this is one of the best ways to write upgradeable smart contracts.

* **Reason:** This come in handy because since we can have a big amount of games deployed, through the registry we can always track which is the latest and valid contract to call.

## Withdrawal Pattern: 
* **Desctiption:** The recommended method of sending funds after an effect is using the withdrawal pattern. Although the most intuitive method of sending Ether, as a result of an effect, is a direct send call, this is not recommended as it introduces a potential security risk. 

* **Reason:** This help us to reduce security risks and also allow us to have more profits since the player doing the withdrawal is the one that has to pay the gas for the transaction.