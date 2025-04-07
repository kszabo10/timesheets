Id stanpacId = '0019Q00000UxuzUQAR';
//Id zxProductId = '01t2p00000C6BG0AAN';
Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Heidelberg Asset').getRecordTypeId();

/*Id zxProductId = [
    select Id, Name
    from Product2
    where Name = 'ZX.137EM'
    limit 1
].Id;*/

Product2 product = new Product2(
    Name = 'ZX.138EM'
);

insert product;
System.debug('Product created = ' + product);

