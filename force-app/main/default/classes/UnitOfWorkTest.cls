@IsTest
private class UnitOfWorkTest {

    @IsTest
    static void registerNewSingleRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');

        // Test
        UnitOfWork uow = new UnitOfWork();
        uow.registerNew(account);
        uow.commitWork();

        // Verify
    }
}
