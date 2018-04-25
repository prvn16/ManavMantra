function ret = getDocumentedNamesFromDoc(c)
ret = struct;
retSize = length(ret);

refTypes = javaArray('com.mathworks.helpsearch.reference.RefEntityType',1); 
refTypes(1) = com.mathworks.helpsearch.reference.RefEntityType.FUNCTION;
refTypes(2) = com.mathworks.helpsearch.reference.RefEntityType.OBJECT;
refTypes(3) = com.mathworks.helpsearch.reference.RefEntityType.CLASS;

if nargin>0
    refPrecision = javaMethod('valueOf','com.mathworks.helpsearch.reference.ReferenceEntityRequest$Precision','PREFIX_MATCH');
    refRequest = com.mathworks.helpsearch.reference.ReferenceEntityRequest(c, refPrecision, refTypes); 
else
    refRequest = com.mathworks.helpsearch.reference.ReferenceRequest; 
end

refRequest.setDuplicateEntityResolver(com.mathworks.helpsearch.reference.TypePrecedenceDuplicateEntityResolver(true));
refRequest.addReferenceTypes(refTypes); 
refRetriever = com.mathworks.mlwidgets.help.DocCenterReferenceRetrievalStrategy.createDataRetriever;
refData = refRetriever.getReferenceData(refRequest); 
refDataIterator = refData.iterator; 
while refDataIterator.hasNext 
    item = refDataIterator.next; 
    ret(retSize, 1).topic = char(item.getTopic); %#ok<AGROW>
    ret(retSize, 1).purpose = char(item.getPurposeLine);
    retSize = retSize + 1;
    % 'product', char(item.getDocSetItem.getDisplayName); 
end
refRetriever.close;
