List<String> salesOrganisations = new List<String>();
salesOrganisations.add('S190'); // Germany
salesOrganisations.add('S450'); // USA
salesOrganisations.add('S440'); // Maxico
salesOrganisations.add('S430'); // Canada


List<Contact> relevantContacts = new List<Contact>([
    select Id, Name, HDM_contactrelevantfor__c 
    from contact
    where HDM_contactrelevantfor__c includes ('Service Survey')
    and Account.HDM_SalesOrganisation__c in :salesOrganisations
]);
System.debug('relevantContacts size = ' + relevantContacts.size());
for(Contact cnt : relevantContacts){
    List<String> itemsOri = new List<String>();
    List<String> items = new List<String>();
    itemsOri = cnt.HDM_contactrelevantfor__c.split(';');
    for(String str : itemsOri){
        if(str != 'Service Survey'){
            items.add(str);
        }
    }
    cnt.HDM_contactrelevantfor__c = String.join(items, ';');
    System.debug('Next record where Surve is removed = ' + cnt.Name + ', ori items = ' + itemsOri + ', new items = ' + cnt.HDM_contactrelevantfor__c);
}
update relevantContacts;