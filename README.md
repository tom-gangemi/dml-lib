# DML Lib (Beta)

The DML Lib provides functional constructs for DML statements in Apex.

For more details, please refer to the [documentation](https://dml.beyondthecloud.dev).

**Insert DML**

```java
new DML()
    .toInsert(new Account(Name = 'My Account'))
    .commitWork();

// or

DML dml = new DML();

dml.toInsert(new Account(Name = 'My Account'));

dml.commitWork();
```

**Update DML** 

```java
Account account = [SELECT Id, Name FROM Account LIMIT 1];

account.Name = 'New Account Name';

new DML()
    .toUpdate(account)
    .commitWork();

//

DML dml = new DML();

dml.toUpdate(account);

dml.commitWork();
```



## License notes:
- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2025, Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
