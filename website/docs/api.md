# DML

Apex Classes: `DML.cls` and `DML_Test.cls`.

The lib main class for DML construction.

```apex title="Basic Usage Example"
new DML()
    .toInsert(new Account(Name = 'Beyond The Cloud'))
    .commitWork();
```

## Methods

The following are methods for using `DML`:

[**INSERT**](#insert)

- [`toInsert(SObject record)`](#toinsert)
- [`toInsert(DML.Record record)`](#toinsert)
- [`toInsert(Iterable<SObject> records)`](#toinsert)
- [`toInsert(DML.Records records)`](#toinsert)

[**INSERT IMMEDIATELY**](#insert-immediately)

- [`insertImmediately(SObject record)`](#insertimmediately)
- [`insertImmediately(DML.Record record)`](#insertimmediately)
- [`insertImmediately(List<SObject> records)`](#insertimmediately)
- [`insertImmediately(DML.Records records)`](#insertimmediately)

[**UPDATE**](#update)

- [`toUpdate(SObject record)`](#toupdate)
- [`toUpdate(DML.Record record)`](#toupdate)
- [`toUpdate(Iterable<SObject> records)`](#toupdate)
- [`toUpdate(DML.Records records)`](#toupdate)

[**UPDATE IMMEDIATELY**](#update-immediately)

- [`updateImmediately(SObject record)`](#updateimmediately)
- [`updateImmediately(DML.Record record)`](#updateimmediately)
- [`updateImmediately(List<SObject> records)`](#updateimmediately)
- [`updateImmediately(DML.Records records)`](#updateimmediately)

[**UPSERT**](#upsert)

- [`toUpsert(SObject record)`](#toupsert)
- [`toUpsert(DML.Record record)`](#toupsert)
- [`toUpsert(Iterable<SObject> records)`](#toupsert)
- [`toUpsert(DML.Records records)`](#toupsert)

[**UPSERT IMMEDIATELY**](#upsert-immediately)

- [`upsertImmediately(SObject record)`](#upsertimmediately)
- [`upsertImmediately(DML.Record record)`](#upsertimmediately)
- [`upsertImmediately(List<SObject> records)`](#upsertimmediately)
- [`upsertImmediately(DML.Records records)`](#upsertimmediately)

[**DELETE**](#delete)

- [`toDelete(Id recordId)`](#todelete)
- [`toDelete(SObject record)`](#todelete)
- [`toDelete(Iterable<Id> recordIds)`](#todelete)
- [`toDelete(List<SObject> records)`](#todelete)

[**DELETE IMMEDIATELY**](#delete-immediately)

- [`deleteImmediately(Id recordId)`](#deleteimmediately)
- [`deleteImmediately(SObject record)`](#deleteimmediately)
- [`deleteImmediately(Iterable<Id> recordIds)`](#deleteimmediately)
- [`deleteImmediately(List<SObject> records)`](#deleteimmediately)

[**UNDELETE**](#undelete)

- [`toUndelete(Id recordId)`](#toundelete)
- [`toUndelete(SObject record)`](#toundelete)
- [`toUndelete(Iterable<Id> recordIds)`](#toundelete)
- [`toUndelete(List<SObject> records)`](#toundelete)

[**UNDELETE IMMEDIATELY**](#undelete-immediately)

- [`undeleteImmediately(Id recordId)`](#undeleteimmediately)
- [`undeleteImmediately(SObject record)`](#undeleteimmediately)
- [`undeleteImmediately(Iterable<Id> recordIds)`](#undeleteimmediately)
- [`undeleteImmediately(List<SObject> records)`](#undeleteimmediately)

[**PLATFORM EVENTS**](#platform-events)

- [`toPublish(SObject record)`](#topublish)
- [`toPublish(Iterable<SObject> records)`](#topublish)

[**PUBLISH IMMEDIATELY**](#publish-immediately)

- [`publishImmediately(SObject record)`](#publishimmediately)
- [`publishImmediately(List<SObject> records)`](#publishimmediately)

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`userMode()`](#usermode)
- [`systemMode()`](#systemmode)

[**SHARING MODE**](#sharing-mode)

- [`withSharing()`](#withsharing)
- [`withoutSharing()`](#withoutsharing)

[**CONFIGURATION**](#configuration)

- [`allowPartialSuccess()`](#allowpartialsuccess)
- [`options(Database.DmlOptions options)`](#options)
- [`commitHook(DML.Hook callback)`](#commithook)

[**MOCKING**](#mocking)

- [`identifier(String dmlIdentifier)`](#identifier)

[**DEBUGGING**](#debugging)

- [`preview()`](#preview)

[**EXECUTION**](#execution)

- [`commitWork()`](#commitwork)
- [`dryRun()`](#dryrun)
- [`hardCommitWork()`](#hardcommitwork)

## INSERT

### toInsert

Insert new records into the database.

**Signature**

```apex title="Method Signatures"
Commitable toInsert(SObject record);
Commitable toInsert(DML.Record record);
Commitable toInsert(Iterable<SObject> records);
Commitable toInsert(DML.Records records);
```

**Example**

```sql title="Traditional DML"
insert new Account(Name = 'My Account');
```
```apex title="DML Lib Implementation"
new DML()
    .toInsert(new Account(Name = 'My Account'))
    .commitWork();
```

```apex title="With Relationships"
Account account = new Account(Name = 'Parent Account');
Contact contact = new Contact(FirstName = 'John', LastName = 'Doe');

new DML()
    .toInsert(account)
    .toInsert(DML.Record(contact).withRelationship(Contact.AccountId, account))
    .commitWork();
```

```apex title="Multiple Records"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Account 1'),
    new Account(Name = 'Account 2')
};
new DML()
    .toInsert(accounts)
    .commitWork();
```

## INSERT IMMEDIATELY

### insertImmediately

Insert records immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult insertImmediately(SObject record);
OperationResult insertImmediately(DML.Record record);
OperationResult insertImmediately(List<SObject> records);
OperationResult insertImmediately(DML.Records records);
```

**Example**

```apex title="Insert Immediately"
Account account = new Account(Name = 'My Account');

DML.OperationResult result = new DML().insertImmediately(account);

Assert.isNotNull(account.Id);
Assert.areEqual(1, result.succeededCount());
Assert.isFalse(result.hasFailures());
```

## UPDATE

### toUpdate

Update existing records in the database.

**Signature**

```apex title="Method Signatures"
Commitable toUpdate(SObject record);
Commitable toUpdate(DML.Record record);
Commitable toUpdate(Iterable<SObject> records);
Commitable toUpdate(DML.Records records);
```

**Example**

```sql title="Traditional DML"
update account;
```
```apex title="DML Lib Implementation"
Account account = [SELECT Id, Name FROM Account LIMIT 1];
account.Name = 'Updated Name';

new DML()
    .toUpdate(account)
    .commitWork();
```

```apex title="Bulk Update with Field Modification"
List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = null];

new DML()
    .toUpdate(DML.Records(contacts).with(Contact.AccountId, accountId))
    .commitWork();
```

## UPDATE IMMEDIATELY

### updateImmediately

Update records immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult updateImmediately(SObject record);
OperationResult updateImmediately(DML.Record record);
OperationResult updateImmediately(List<SObject> records);
OperationResult updateImmediately(DML.Records records);
```

**Example**

```apex title="Update Immediately"
Account account = [SELECT Id, Name FROM Account LIMIT 1];
account.Name = 'Updated Name';

DML.OperationResult result = new DML().updateImmediately(account);

Assert.areEqual(1, result.succeededCount());
Assert.isFalse(result.hasFailures());
```

## UPSERT

### toUpsert

Insert new records or update existing ones based on record ID.

**Signature**

```apex title="Method Signatures"
Commitable toUpsert(SObject record);
Commitable toUpsert(DML.Record record);
Commitable toUpsert(Iterable<SObject> records);
Commitable toUpsert(DML.Records records);
```

**Example**

```sql title="Traditional DML"
upsert accounts;
```
```apex title="DML Lib Implementation"
List<Account> accounts = new List<Account>{
    new Account(Name = 'New Account'),           // Will be inserted
    new Account(Id = existingId, Name = 'Updated') // Will be updated
};

new DML()
    .toUpsert(accounts)
    .commitWork();
```

## UPSERT IMMEDIATELY

### upsertImmediately

Upsert records immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult upsertImmediately(SObject record);
OperationResult upsertImmediately(DML.Record record);
OperationResult upsertImmediately(List<SObject> records);
OperationResult upsertImmediately(DML.Records records);
```

**Example**

```apex title="Upsert Immediately"
Account account = new Account(Name = 'New or Existing Account');

DML.OperationResult result = new DML().upsertImmediately(account);

Assert.isNotNull(account.Id);
Assert.areEqual(1, result.succeededCount());
```

## DELETE

### toDelete

Delete records from the database.

**Signature**

```apex title="Method Signatures"
Commitable toDelete(Id recordId);
Commitable toDelete(SObject record);
Commitable toDelete(Iterable<Id> recordIds);
Commitable toDelete(List<SObject> records);
```

**Example**

```sql title="Traditional DML"
delete account;
```
```apex title="DML Lib Implementation"
new DML()
    .toDelete(accountId)
    .commitWork();
```

```apex title="Delete Multiple Records"
List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name LIKE 'Test%'];
new DML()
    .toDelete(accountsToDelete)
    .commitWork();
```

## DELETE IMMEDIATELY

### deleteImmediately

Delete records immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult deleteImmediately(Id recordId);
OperationResult deleteImmediately(SObject record);
OperationResult deleteImmediately(Iterable<Id> recordIds);
OperationResult deleteImmediately(List<SObject> records);
```

**Example**

```apex title="Delete Immediately"
Account account = [SELECT Id FROM Account LIMIT 1];

DML.OperationResult result = new DML().deleteImmediately(account);

Assert.areEqual(1, result.succeededCount());
Assert.isFalse(result.hasFailures());
```

## UNDELETE

### toUndelete

Restore deleted records from the recycle bin.

**Signature**

```apex title="Method Signatures"
Commitable toUndelete(Id recordId);
Commitable toUndelete(SObject record);
Commitable toUndelete(Iterable<Id> recordIds);
Commitable toUndelete(List<SObject> records);
```

**Example**

```sql title="Traditional DML"
undelete account;
```
```apex title="DML Lib Implementation"
new DML()
    .toUndelete(deletedAccountId)
    .commitWork();
```

## UNDELETE IMMEDIATELY

### undeleteImmediately

Undelete records immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult undeleteImmediately(Id recordId);
OperationResult undeleteImmediately(SObject record);
OperationResult undeleteImmediately(Iterable<Id> recordIds);
OperationResult undeleteImmediately(List<SObject> records);
```

**Example**

```apex title="Undelete Immediately"
Account deletedAccount = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS LIMIT 1];

DML.OperationResult result = new DML().undeleteImmediately(deletedAccount);

Assert.areEqual(1, result.succeededCount());
Assert.isFalse(result.hasFailures());
```

## PLATFORM EVENTS

### toPublish

Publish platform events.

**Signature**

```apex title="Method Signatures"
Commitable toPublish(SObject record);
Commitable toPublish(Iterable<SObject> records);
```

**Example**

```sql title="Traditional DML"
EventBus.publish(events);
```
```apex title="DML Lib Implementation"
MyEvent__e event = new MyEvent__e(Message__c = 'Hello World');
new DML()
    .toPublish(event)
    .commitWork();
```

## PUBLISH IMMEDIATELY

### publishImmediately

Publish platform events immediately and return the operation result without calling `commitWork()`.

**Signature**

```apex title="Method Signatures"
OperationResult publishImmediately(SObject record);
OperationResult publishImmediately(List<SObject> records);
```

**Example**

```apex title="Publish Immediately"
MyEvent__e event = new MyEvent__e(Message__c = 'Hello World');

DML.OperationResult result = new DML().publishImmediately(event);

Assert.areEqual(1, result.requestedCount());
```

## FIELD-LEVEL SECURITY

### userMode

Execute DML operations respecting user permissions (default behavior).

**Signature**

```apex title="Method Signature"
Commitable userMode();
```

**Example**

```apex title="DML Lib User Mode"
new DML()
    .toInsert(new Case(Subject = 'User Mode Case'))
    .userMode()
    .commitWork();
```

### systemMode

Execute DML operations bypassing user permissions.

**Signature**

```apex title="Method Signature"
Commitable systemMode();
```

**Example**

```apex title="DML Lib System Mode"
new DML()
    .toInsert(new Case(Subject = 'System Mode Case'))
    .systemMode()
    .commitWork();
```

## SHARING MODE

### withSharing

Execute DML operations enforcing sharing rules.

**Signature**

```apex title="Method Signature"
Commitable withSharing();
```

**Example**

```apex title="With Sharing"
new DML()
    .toInsert(accounts)
    .withSharing()
    .commitWork();
```

### withoutSharing

Execute DML operations bypassing sharing rules.

**Signature**

```apex title="Method Signature"
Commitable withoutSharing();
```

**Example**

```apex title="Without Sharing"
new DML()
    .toInsert(accounts)
    .withoutSharing()
    .commitWork();
```

## CONFIGURATION

### allowPartialSuccess

Allow some records to fail without rolling back successful operations.

**Signature**

```apex title="Method Signature"
Commitable allowPartialSuccess();
```

**Example**

```apex title="Partial Success"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Valid Account'),
    new Account(), // Missing required Name field
    new Account(Name = 'Another Valid Account')
};

new DML()
    .toInsert(accounts)
    .allowPartialSuccess()
    .commitWork();
```

### options

Provide custom Database.DmlOptions for DML operations.

**Signature**

```apex title="Method Signature"
Commitable options(Database.DmlOptions options);
```

**Example**

```apex title="Custom DML Options"
Database.DmlOptions options = new Database.DmlOptions();
options.optAllOrNone = false;
options.duplicateRuleHeader.allowSave = true;

new DML()
    .toInsert(accounts)
    .options(options)
    .commitWork();
```

### commitHook

Register a hook to execute custom logic before and after commit.

**Signature**

```apex title="Method Signature"
Commitable commitHook(DML.Hook callback);
```

**Example**

```apex title="Commit Hook"
public class MyHook implements DML.Hook {
    public void before() {
        System.debug('Before commit');
    }
    
    public void after() {
        System.debug('After commit');
    }
}

new DML()
    .toInsert(accounts)
    .commitHook(new MyHook())
    .commitWork();
```

## MOCKING

### identifier

Associate a DML operation with an identifier for mocking and result tracking.

**Signature**

```apex title="Method Signature"
Commitable identifier(String dmlIdentifier);
```

**Example**

```apex title="Using Identifier"
new DML()
    .toInsert(accounts)
    .identifier('myTransaction')
    .commitWork();
```

::: tip
For complete mocking documentation, see the [Mocking Guide](/mocking).
:::

## DEBUGGING

### preview

Preview DML operations without executing them.

**Signature**

```apex title="Method Signature"
void preview();
```

**Example**

```apex title="Preview Operations"
new DML()
    .toInsert(account)
    .toUpdate(contact)
    .preview(); // Outputs debug information to logs
```

## EXECUTION

### commitWork

Execute all registered DML operations in a single transaction and return the results.

**Signature**

```apex title="Method Signature"
Result commitWork();
```

**Example**

```apex title="Commit Work"
DML.Result result = new DML()
    .toInsert(account)
    .toUpdate(contact)
    .toDelete(leadId)
    .commitWork();

// Check results
Assert.isFalse(result.inserted(Account.SObjectType).hasFailures());
```

### dryRun

Execute all registered DML operations but rollback the transaction. Useful for validation.

**Signature**

```apex title="Method Signature"
Result dryRun();
```

**Example**

```apex title="Dry Run"
DML.Result result = new DML()
    .toInsert(account)
    .dryRun();

// Operations were executed but rolled back
Assert.areEqual(0, [SELECT COUNT() FROM Account]);

// But we can still check what would have happened
Assert.areEqual(1, result.inserted().size());
```

### hardCommitWork

Execute all registered DML operations with automatic rollback on any exception.

**Signature**

```apex title="Method Signature"
Result hardCommitWork();
```

**Example**

```apex title="Hard Commit Work"
try {
    DML.Result result = new DML()
        .toInsert(account)
        .toUpdate(contact)
        .hardCommitWork();
} catch (Exception e) {
    // All operations are automatically rolled back
    System.debug('Transaction rolled back: ' + e.getMessage());
}
```

::: tip
For complete result documentation, see the [Result Guide](/result).
:::

## Record Manipulation

### Field Assignment

Assign field values to records using the `with` method.

```apex title="Field Assignment"
DML.Record(contact).with(Contact.Email, 'john@example.com')
```

### Relationship Handling

Handle parent-child relationships in DML operations.

```apex title="Direct Relationship"
DML.Record(contact).withRelationship(Contact.AccountId, account)
```

```apex title="External ID Relationship"
DML.Record(contact).withRelationship(
    Contact.AccountId, 
    Account.External_Id__c, 
    'EXT123'
)
```

## Factory Methods

### DML.Record

Create a Record wrapper for single SObject manipulation.

**Signature**

```apex title="Method Signatures"
Record Record(Id recordId);
Record Record(SObject record);
```

**Example**

```apex title="Record Factory"
DML.Record record = DML.Record(sobjectInstance);
DML.Record recordById = DML.Record(recordId);
```

### DML.Records

Create a Records wrapper for multiple SObject manipulation.

**Signature**

```apex title="Method Signatures"
Records Records(List<SObject> records);
Records Records(Iterable<Id> recordIds);
```

**Example**

```apex title="Records Factory"
DML.Records records = DML.Records(sobjectList);
DML.Records recordsByIds = DML.Records(recordIdSet);
```