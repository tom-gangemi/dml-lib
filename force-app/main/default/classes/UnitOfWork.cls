public inherited sharing class UnitOfWork implements DmlCommitable {
    public interface DmlCommitable {
        // Settings
        DmlCommitable systemMode();
        DmlCommitable withSharing();
        DmlCommitable withoutSharing();
        DmlCommitable allowPartialSuccess();
        // Insert
        DmlCommitable registerNew(SObject record);
        DmlCommitable registerNew(Iterable<SObject> records);
        DmlCommitable registerNew(SObject record, SObjectField targetField, SObject relatedRecord);
        // Update
        DmlCommitable registerDirty(SObject record);
        DmlCommitable registerDirty(Iterable<SObject> records);
        // Relationship
        // DmlCommitable registerRelationship(SObject targetRecord, SObjectField targetField, SObject relatedRecord);
        // DmlCommitable registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId);
        // Upsert
        DmlCommitable registerUpsert(SObject record);
        DmlCommitable registerUpsert(Iterable<SObject> records);
        // Delete
        DmlCommitable registerDelete(SObject record);
        DmlCommitable registerDelete(Iterable<SObject> recordssObjs);
        // Platform Event
        DmlCommitable registerPlatformEvent(SObject record);
        DmlCommitable registerPlatformEvent(List<SObject> records);
        // Debug
        void preview();
        // Save
        void commitWork();
        // commitWorkAsSystem();
        // commitWorkAsUser();
    }

    // Implementation

    private DmlExecutor insertUow = new InsertUow();
    private DmlExecutor updateUow = new UpdateUow();
    private DmlExecutor deleteUow = new DeleteUow();
    private DmlExecutor platformEventUow = new PlatformEventUow();

    public DmlCommitable systemMode() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
        return this;
    }

    public DmlCommitable withSharing() {
        this.insertUow.withSharing();
        this.updateUow.withSharing();
        this.deleteUow.withSharing();
        this.platformEventUow.withSharing();
        return this;
    }

    public DmlCommitable withoutSharing() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
        return this;
    }

    public DmlCommitable allowPartialSuccess() {
        this.insertUow.allowPartialSuccess();
        this.updateUow.allowPartialSuccess();
        this.deleteUow.allowPartialSuccess();
        this.platformEventUow.allowPartialSuccess();
        return this;
    }

    public DmlCommitable registerNew(SObject record) {
        if (String.isNotBlank(record.Id)) {
            throw new DmlException('Only new records can be registered as new.');
        }

        this.insertUow.register(new PlainSObjectUow(record));

        return this;
    }

    public DmlCommitable registerNew(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerNew(record);
        }
        
        return this;
    }

    public DmlCommitable registerDirty(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as dirty.');
        }

        this.updateUow.register(new PlainSObjectUow(record));

        return this;
    }

    public DmlCommitable registerDirty(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerDirty(record);
        }
        
        return this;
    }

    public DmlCommitable registerNew(SObject targetRecord, SObjectField targetField, SObject relatedRecord) {
        this.insertUow.register(new RelationshipSObjectUow(targetRecord, targetField, relatedRecord));
        return this;
    }

    public DmlCommitable registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId) {
        // TODO
        return this;
    }

    public DmlCommitable registerUpsert(SObject record) {
        if (String.isBlank(record.Id)) {
            return this.registerNew(record);
        }

        return this.registerDirty(record);
    }

    public DmlCommitable registerUpsert(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerUpsert(record);
        }

        return this;
    }

    public DmlCommitable registerDelete(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }

        this.deleteUow.register(new PlainSObjectUow(record));

        return this;
    }

    public DmlCommitable registerDelete(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerDelete(record);
        }
        
        return this;
    }

    public DmlCommitable registerPlatformEvent(SObject record) {
        this.platformEventUow.register(new PlainSObjectUow(record));
        return this;
    }

    public DmlCommitable registerPlatformEvent(List<SObject> records) {
        for (sObject record : records) {
            this.registerPlatformEvent(record);
        }

        return this;
    }

    public void preview() {
        this.insertUow.preview();
        this.updateUow.preview();
        this.deleteUow.preview();
        this.platformEventUow.preview();
    }

    public void commitWork() {
        Savepoint savePoint = Database.setSavepoint();

        try {
            this.insertUow.execute();
            this.updateUow.execute();
            this.deleteUow.execute();
            this.platformEventUow.execute();
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public abstract class DmlExecutor {
        protected Map<String, ObjectTypeContainer> recordsByType = new Map<String, ObjectTypeContainer>();
        protected AccessLevel accessMode = AccessLevel.USER_MODE;
        protected Boolean allOrNone = true;

        private DmlSharing sharingExecutor = new InheritedSharing();

        public DmlExecutor systemMode() {
            this.accessMode = AccessLevel.SYSTEM_MODE;
            return this;
        }

        public DmlExecutor allowPartialSuccess() {
            this.allOrNone = false;
            return this;
        }

        public DmlExecutor withSharing() {
            this.sharingExecutor = new WithSharing();
            return this;
        }

        public DmlExecutor withoutSharing() {
            this.sharingExecutor = new WithoutSharing();
            return this;
        }

        public void register(SObjectUow uow) {
            String sObjectType = uow.getRecord().getSObjectType().getDescribe().getName();

            ObjectTypeContainer recordsToProcess = this.recordsByType.containsKey(sObjectType) ? this.recordsByType.get(sObjectType) : new ObjectTypeContainer();

            recordsToProcess.add(uow);

            this.recordsByType.put(sObjectType, recordsToProcess);
        }

        public void preview() {
            System.debug(JSON.serializePretty(this.recordsByType));
        }

        public abstract void execute();
    }

    public inherited sharing class InsertUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                this.recordsByType.get(sObjectTypeName).resolve();
                Database.insert(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class UpdateUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                this.recordsByType.get(sObjectTypeName).resolve();
                Database.update(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class DeleteUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                Database.delete(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class PlatformEventUow extends DmlExecutor {
        public override void execute() {
        }
    }

    private interface DmlSharing {
        void execute(DmlExecutor executor);
    }

    private inherited sharing class InheritedSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private without sharing class WithoutSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private with sharing class WithSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private abstract class SObjectUow {
        public SObject currentRecord;

        public virtual void resolve() {}
        public abstract SObject getRecord();
    }

    private inherited sharing class PlainSObjectUow extends SObjectUow {
        public PlainSObjectUow(SObject currentRecord) {
            this.currentRecord = currentRecord;
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private inherited sharing class ExternalSObjectUow extends SObjectUow {
        public SObjectField relatedToField;
        public SObjectField externalIdField;
        public SObjectType relatedTo;
        public String relationshipName;
        public Object externalId;

        public ExternalSObjectUow(SObject record, SObjectField relatedToField, SObjectField externalIdField, Object externalId) {
            this.validateRelatedToField(relatedToField);
            this.validateExternalIdField(relatedToField, externalIdField);

            this.currentRecord = record;
            this.relatedToField = relatedToField;
            this.externalIdField = externalIdField;
            this.externalId = externalId;
        }

        public override void resolve() {
            SObject relationshipObject = this.relatedTo.newSObject();
            relationshipObject.put(externalIdField.getDescribe().getName(), this.externalId);

            this.currentRecord.putSObject(this.relationshipName, relationshipObject);
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }

        private void validateRelatedToField(SObjectField relatedToField) {
            if (relatedToField == null) {
                // throw new UnitOfWorkException('Invalid argument: relatedToField.');
            }
    
            String relationshipName = relatedToField.getDescribe().getRelationshipName();
    
            if (String.isBlank(relationshipName)) {
                // throw new UnitOfWorkException('Invalid argument: relatedToField. Field supplied is not a relationship field.');
            }
        }

        private void validateExternalIdField(SObjectField relatedToField, SObjectField externalIdField) {
            Boolean externalIdFieldIsValid = externalIdField.getDescribe().isExternalId();
    
            if (!externalIdFieldIsValid) {
                // throw new UnitOfWorkException('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.');
            }
    
            List<SObjectType> relatedObjects = relatedToField.getDescribe().getReferenceTo();
            SObjectType relatedObject = relatedObjects[0];
            String externalIdFieldName = externalIdField.getDescribe().getName();
    
            Boolean relatedHasExternalIdField = relatedObject.getDescribe().fields.getMap().keySet().contains(externalIdFieldName.toLowerCase());
    
            if (!relatedHasExternalIdField) {
                // throw new UnitOfWorkException('Invalid argument: externalIdField. Field supplied is not a known field on the target sObject.');
            }
        }
    }

    private inherited sharing class RelationshipSObjectUow extends SObjectUow {
        private SObject relatedToRecord;
        private SObjectField relationshipField;

        public RelationshipSObjectUow(SObject currentRecord, SObjectField relationshipField, SObject relatedToRecord) {
            this.currentRecord = currentRecord;
            this.relatedToRecord = relatedToRecord;
            this.relationshipField = relationshipField;
        }

        public override void resolve() {
            if (this.relationshipField == null || this.relatedToRecord == null) {
                return;
            }
            this.currentRecord.put(this.relationshipField, this.relatedToRecord.Id);
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private class ObjectTypeContainer {
        private List<SObjectUow> sObjectsWithRelationships;

        public ObjectTypeContainer() {
            this.sObjectsWithRelationships = new List<SObjectUow>();
        }

        public void add(SObjectUow sObjectWithRelationship) {
            this.sObjectsWithRelationships.add(sObjectWithRelationship);
        }

        public void resolve() {
            for (SObjectUow sObjectWithRelationship : this.sObjectsWithRelationships) {
                sObjectWithRelationship.resolve();
            }
        }

        public List<SObject> getRecords() {
            List<SObject> recordsToProcess = new List<SObject>();

            for (SObjectUow sObjectWithRelationship : this.sObjectsWithRelationships) {
                recordsToProcess.add(sObjectWithRelationship.getRecord());
            }

            return recordsToProcess;
        }
    }
}

    /*
     UnitOfWork uow = new UnitOfWork();
     uow.registerNew(new Account(Name='Test Account'));
     uow.registerNew(new Account(Name='Test Account 2'));
     uow.commitWork();

     uow.registerRelationship(new Account(Name='Test Account'))
        .withRelationshipField(...)
        .withExternalIdField(...)
        .withRelatedRecord(new Account(Name='Test Account 2'));

    uow.registerRelationship(new Account(Name='Test Account'), Account.RelationshipField__c, new Account(Name='Test Account 2'));

    uow.registerRelationship(
        UOW.Relationship.of(new Account(Name='Test Account'))
            .withRelationshipField(...)
            .withExternalIdField(...)
            .withRelatedRecord(new Account(Name='Test Account 2'))
    )

    */