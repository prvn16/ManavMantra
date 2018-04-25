function ret = getArgInfoFromDoc(name)

ret = struct('name',{},'kind', {}, 'url',{},'purpose',{},'values',{});
 
try
    refRetriever = com.mathworks.mlwidgets.help.DocCenterReferenceRetrievalStrategy.createDataRetriever;
    oc = onCleanup(@() refRetriever.close);

    entityTypes = java.util.Collections.singletonList(com.mathworks.helpsearch.reference.RefEntityType.FUNCTION);
    refRequest = com.mathworks.helpsearch.reference.ReferenceEntityRequest(name, entityTypes);
    refItems = refRetriever.getReferenceData(refRequest);
    iRefItems = refItems.iterator;
    docRootObj = com.mathworks.mlwidgets.help.DocCenterDocConfig.getInstance.getDocRoot;
    
    while iRefItems.hasNext
        item = iRefItems.next;
        iArgument = item.getInputArguments.iterator;

        while iArgument.hasNext
            arg = iArgument.next;

            values = {};
            iValues = arg.getValues.iterator;
            while iValues.hasNext
                value = iValues.next;
                values{end+1} = regexprep(char(value.getValue), '\n', ' '); %#ok<AGROW>
                if (value.isDefault)
                    values{end} = [values{end} ' (' getString(message('MATLAB:TabCompletion:ArgumentDefaultValue')) ')'];
                end
            end

            name = char(arg.getName());
            kind = char(arg.getType());
            url = char(docRootObj.buildDocSetItemUrl(arg.getDocSetItem, arg.getRelativePath));
            purpose = regexprep(char(arg.getPurposeLine), '\n', ' ');
            values = strjoin(values, ' | ');

            ret(end+1) = struct('name', name,'kind', kind, 'url', url, 'purpose', purpose, 'values', values); %#ok<AGROW>
        end
    end
catch
    ret = struct('name',{},'kind', {}, 'url',{},'purpose',{},'values',{});
end

end
