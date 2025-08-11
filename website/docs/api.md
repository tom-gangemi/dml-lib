# DML

Apex Classes: `DML.cls` and `DML_Test.cls`.

The lib main class for DML construction.

```apex
new DML()
    .toInsert(new Account(Name = 'Beyond The Cloud'))
    .commitWork();
```

## Methods

The following are methods for using `DML`:

[**Insert**](#insert)

[**Update**](#update)

[**Upsert**](#upsert)

[**Delete**](#delete)

## Insert

**Signature**

```apex
Commitable toInsert(SObject record);
Commitable toInsert(DML.Record record);
Commitable toInsert(List<SObject> records);
Commitable toInsert(DML.Records records);
```

**Example**

```sql
insert as user new Account(Name = 'My Account');
```
```apex
new DML()
    .toInsert(new Account(Name = 'My Account'))
    .commitWork();
```