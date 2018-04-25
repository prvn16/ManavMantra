function specificCharacterSet = getSpecificCharacterSet(metadata, varargin)

% Copyright 2015-2017 The MathWorks, Inc.

persistent specificCharacterSetFieldName

switch nargin
case 1  % DICOMFile object
    rawFieldValue = metadata.getAttribute(8, 5);  % (0008,0005) - SpecificCharacterSet

case 2  % Metadata struct
    if isempty(specificCharacterSetFieldName)
        specificCharacterSetFieldName = images.internal.dicom.lookupActions('0008', '0005', varargin{1});
    end

    if (isfield(metadata, specificCharacterSetFieldName))
        rawFieldValue = metadata.(specificCharacterSetFieldName);
    else
        rawFieldValue = '';
    end

otherwise
    assert(false, 'Wrong number of arguments to getSpecificCharacterSet')

end

if isempty(rawFieldValue)
    specificCharacterSet = {'ISO_IR 6'};
else
    specificCharacterSet = multiValueString2cell(rawFieldValue);
end

if isempty(specificCharacterSet{1})
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
