function specificCharacterSet = dicom_get_SpecificCharacterSet(metadata, dictionary)
%dicom_get_SpecificCharacterSet   Get SpecificCharacterSet attribute.

% Copyright 2015 The MathWorks, Inc.

persistent specificCharacterSetFieldName
if isempty(specificCharacterSetFieldName)
    specificCharacterSetFieldName = images.internal.dicom.lookupActions('0008', '0005', dictionary);
end

if (isfield(metadata, specificCharacterSetFieldName))
    rawFieldValue = metadata.(specificCharacterSetFieldName);
    if isempty(rawFieldValue)
        specificCharacterSet = {'ISO_IR 6'};
    else
        specificCharacterSet = multiValueString2cell(rawFieldValue);
    end
else
    specificCharacterSet = {'ISO_IR 6'};
end

if (isempty(specificCharacterSet{1}))
    specificCharacterSet{1} = 'ISO_IR 6';
end

end



function cellOfValues = multiValueString2cell(rawString)

if (isempty(rawString))
    cellOfValues = {};
else
    cellOfValues = images.internal.dicom.tokenize(rawString, '\');
end

end