function bdata = subtractFromDateFields(adata,amounts,fieldIDs,timeZone)

%   Copyright 2014-2015 The MathWorks, Inc.

bdata = adata;
for field = 1:length(amounts)
    amount = amounts{field};
    if ~isequal(amount,0)
        bdata = matlab.internal.datetime.addToDateField(bdata,-amount,fieldIDs(field),timeZone);
    end
end
