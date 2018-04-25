function attr = dicom_dict_lookup(group, element, dictionary)
%DICOM_DICT_LOOKUP  Lookup an attribute in the data dictionary.
%   ATTRIBUTE = DICOM_DICT_LOOKUP(GROUP, ELEMENT, DICTIONARY) searches for
%   the attribute (GROUP,ELEMENT) in the data dictionary, DICTIONARY.  A
%   structure containing the attribute's properties from the dictionary
%   is returned.  ATTRIBUTE is empty if (GROUP,ELEMENT) is not in
%   DICTIONARY.
%
%   Note: GROUP and ELEMENT can be either decimal values or hexadecimal
%   strings.

%   Copyright 1993-2010 The MathWorks, Inc.


% IMPORTANT NOTE:
%
% This function must be wrapped inside of a try-catch-end block in order
% to prevent the DICOM file from being left open after an error.


MAX_GROUP = 65535;   % 0xFFFF
MAX_ELEMENT = 65535;  % 0xFFFF

%
% Load the data dictionary.
%

persistent tags values prev_dictionary;
mlock;

% Load dictionary for the first time or if dictionary has changed.
if ((isempty(values)) || (~isequal(prev_dictionary, dictionary)))
    
    [tags, values] = images.internal.dicom.loadDictionary(dictionary);
    prev_dictionary = dictionary;
    
end

%
% Convert hex strings to decimals.
%

if (ischar(group))
    group = sscanf(group, '%x');
end

if (ischar(element))
    element = sscanf(element, '%x');
end

if (group > MAX_GROUP)
    error(message('images:dicom_dict_lookup:groupOutOfRange', sprintf( '%x', group ), sprintf( '(%x,%04x)', group, element )))
end


if (element > MAX_ELEMENT)
    error(message('images:dicom_dict_lookup:elementOutOfRange', sprintf( '%x', element ), sprintf( '(%04x,%x)', group, element )))
end

%
% Look up the attribute.
%

% Group and Element values in the published data dictionary are 0-based.
index = tags((group + 1), (element + 1));

if (index == 0)
    attr = struct([]);
else
    attr = values(index);
end
