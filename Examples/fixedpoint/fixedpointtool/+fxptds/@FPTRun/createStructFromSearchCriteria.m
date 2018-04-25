function dStruct = createStructFromSearchCriteria(~, searchCriteria)
    % Copyright 2016-2017 The MathWorks, Inc.
	% NOTE: Method originally part of Application Data, see g1431153
    propNames = searchCriteria(1:2:end);
    propValues = searchCriteria(2:2:end);
    
    for i = 1:length(propNames)
        if strcmpi(propNames{i},'UniqueIdentifier')
            dStruct.Object = propValues{i}.getObject;
            dStruct.ElementName = propValues{i}.getElementName;
        elseif strcmpi(propNames{i},'Object')
            dStruct.Object = propValues{i};
        elseif strcmpi(propNames{i},'ElementName')
            dStruct.ElementName = propValues{i};
        else
            dStruct.(propNames{i}) = propValues{i};
        end
    end
    
end