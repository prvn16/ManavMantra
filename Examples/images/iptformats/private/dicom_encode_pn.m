function PN_chars = dicom_encode_pn(PN_struct, specificCharacterSet)
%DICOM_ENCODE_PN  Turn a structure of name info into a formatted string.

%   Copyright 1993-2016 The MathWorks, Inc.

% How this function works:
% * Data that will become encoded as PN can either be stored as a struct of
%   person name parts, or it can be a string of the actual values.
% * When it's a struct (or array of structs for multiple person names), put
%   each part of the struct into a 3-by-5 cell array. The rows are for the
%   alphabetic, phonetic, and ideographic parts of the name (which might
%   not all be present). The columns are for the part of the person name
%   (which also might not be present).
% * Once the data is separated, convert it to a correctly localized string
%   and put the pieces together into a string with appropriate separators.
% * Along the way and at the end of encoding, remove excess separators.

% Empty values and PN values stored as strings should be unchanged.
if ((~isstruct(PN_struct)) || (isempty(PN_struct)))
    PN_chars = PN_struct;
    return
else
    PN_chars = [];
end

PN_struct_fields = {'FamilyName', 'GivenName', 'MiddleName', 'NamePrefix', 'NameSuffix'};

% Encode a decorated PN struct.
for p = 1:numel(PN_struct)

    % Put each part of the persons name into an array whose rows are the
    % alphabetic, phonetic, and ideographic components.
    cellOfParts = cell(3,5);
    for idx = 1:numel(PN_struct_fields)
        theField = PN_struct_fields{idx};
        if (isfield(PN_struct, theField))
            parsedField = images.internal.dicom.tokenize(PN_struct(p).(theField), '=');
            numComponents = numel(parsedField);
            cellOfParts(1:numComponents, idx) = parsedField;
        end
    end

    % Build string for each component from the parts, separating parts with
    % '^' and components with '='.
    for idx = 1:numel(PN_struct_fields)
        PN_chars = [PN_chars, getLocalizedString(cellOfParts{1, idx}, specificCharacterSet{1}), uint8('^')]; %#ok<AGROW>
    end
    
    PN_chars = stripTrailingCharacters(PN_chars, '^');
    
    PN_chars = [PN_chars, uint8('=')]; %#ok<AGROW>
    
    for row = 2:3
        for idx = 1:numel(PN_struct_fields)
            PN_chars = [PN_chars, getLocalizedString(cellOfParts{row, idx}, specificCharacterSet{end}), uint8('^')]; %#ok<AGROW>
        end
        
        PN_chars = stripTrailingCharacters(PN_chars, uint8('^'));
        
        PN_chars = [PN_chars, uint8('=')]; %#ok<AGROW>
    end

    PN_chars = stripTrailingCharacters(PN_chars, uint8('='));

    % Separate multiple values.
    PN_chars = [PN_chars, uint8('\')]; %#ok<AGROW>
    
end

% Remove extra value delimiter '\'.
PN_chars(end) = [];

end


function out = stripTrailingCharacters(in, symbolToRemove)

out = in;

while ((~isempty(out)) && (out(end) == symbolToRemove))
    out(end) = [];
end

end



function out = getLocalizedString(in, specificCharacterSet)

if (isempty(in))
    out = [];
    return
end

icuCharacterSet = dicom_getConverterString(specificCharacterSet);
out = unicode2native(in, icuCharacterSet);

end