function [value1, value2] = dicomlookup(varargin)
%DICOMLOOKUP   Find an attribute in the DICOM data dictionary.
%    NAME = DICOMLOOKUP(GROUP, ELEMENT) looks into the current DICOM
%    data dictionary for an attribute with the specified GROUP and
%    ELEMENT tag and returns a string containing the NAME of the
%    attribute.  GROUP and ELEMENT can contain either a decimal
%    value or hexadecimal string.
%
%    [GROUP, ELEMENT] = DICOMLOOKUP(NAME) finds the GROUP and
%    ELEMENT values for the attribute with a given NAME.
%
%    Example 1
%    ---------
%    Find the names of DICOM attributes using their tags.
%
%        name1 = dicomlookup('7FE0', '0010')
%        name2 = dicomlookup(40, 4)
%
%    Example 2
%    ---------
%    Look up a DICOM attribute's tag (GROUP and ELEMENT) using its
%    name.
%
%        [group, element] = dicomlookup('TransferSyntaxUID')
%
%    Example 3
%    ---------
%    Examine the metadata of a DICOM file.  This will return the
%    same value even if the data dictionary changes.
%
%        metadata = dicominfo('CT-MONO2-16-ankle.dcm');
%        metadata.(dicomlookup('0028', '0004'))
%
%    See also dicom-dict.txt, DICOMDICT, DICOMINFO.

%   Copyright 2006-2017 The MathWorks, Inc.

dictionary = dicomdict('get_current');

% Check input values and call the correct syntax.
narginchk(1,2)

varargin = matlab.images.internal.stringToChar(varargin);

% Lightweight input validation (part 1).
if (isempty(varargin{1}))
  
    error(message('images:dicomlookup:emptyArg1'))
    
end

% Look up the tag or the name.
if (nargin == 1)
  
    if (~ischar(varargin{1}))
      
        error(message('images:dicomlookup:oneInputMustBeChar'))
        
    end
    
    [value1, value2] = images.internal.dicom.lookupActions(varargin{1}, dictionary);
    
elseif (nargin == 2)
  
    % Lightweight input validation (part 2).
    if (isempty(varargin{2}))
      
        error(message('images:dicomlookup:emptyArg2'))
        
    end
  
    % Convert group and element to integers if necessary.
    group   = getValue(varargin{1});
    element = getValue(varargin{2});

    [value1, value2] = images.internal.dicom.lookupActions(group, element, dictionary);

end



function int = getValue(hexOrInt)

% Get a hex or numeric value.
if (isnumeric(hexOrInt))

    int = hexOrInt;

elseif (ischar(hexOrInt))

    if (isValidHex(hexOrInt))
        int = sscanf(hexOrInt, '%x');
    else
        error(message('images:dicomlookup:badHex', hexOrInt));
    end
    
else
  
    error(message('images:dicomlookup:notIntOrHex'))

end    

% Make sure it is a single, valid uint16.
if (numel(int) > 1)
      
    error(message('images:dicomlookup:tooManyElements'))
      
elseif ((int < 0) || (int > intmax('uint16')))
  
    error(message('images:dicomlookup:badValue'))

end



function tf = isValidHex(hexChars)

tf = all(((hexChars >= '0') & (hexChars <= '9')) | ...
         ((hexChars >= 'a') & (hexChars <= 'f')) | ...
         ((hexChars >= 'A') & (hexChars <= 'F')));
