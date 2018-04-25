function attr_str = dicom_add_item(attr_str, group, element, varargin)
%DICOM_ADD_ITEM   Add an item/delimiter to a structure of attributes.
%   OUT = DICOM_ADD_ITEM(IN, GROUP, ELEMENT)
%   OUT = DICOM_ADD_ITEM(IN, GROUP, ELEMENT, DATA)
%   
%   This function is similar to DICOM_ADD_ATTR, but it doesn't allow
%   specifying VR values and can only be used for attributes of group
%   FFFE.
%
%   See also DICOM_ADD_ATTR, DICOM_ADD_PIXEL_DATA.

%   Copyright 1993-2010 The MathWorks, Inc.


% See PS-3.5 Sec. 7.5 for details on sequence and item encoding.


% Get group and element.
tmp.Group = get_group_or_element(group);
tmp.Element = get_group_or_element(element);

% Get data value.
if (nargin > 4)
    error(message('images:dicom_add_item:tooManyInputArgs'));
elseif (nargin == 3)
    tmp.Data = [];
else
    tmp.Data = varargin{1};
end

tmp.VR = 'UN';

% Check the group and element values.
if (tmp.Group ~= 65534)  % 0xFFFE == 65534
    error(message('images:dicom_add_item:groupNotAccepted', sprintf( '%X', tmp.Group )))
end

switch (tmp.Element)
case {57344}         % 0xE000 == 57344
    
    % Data is okay for (FFFE,E000).
    
case {57357, 57565}  % 0xE00D == 57357,  0XE0DD == 57565
    
    if (~isempty(tmp.Data))
        error(message('images:dicom_add_item:AttributeCannotHaveData', sprintf( '(%04X,%04X)', tmp.Group, tmp.Element )))
    end
    
otherwise
    error(message('images:dicom_add_item:attributeNotSupported', sprintf( '(%04X,%04X)', tmp.Group, tmp.Element )))
                  
end

% Pad the data to an even byte boundary.
if (rem(getSizeInBytes(tmp.Data), 2) == 1)
    tmp.Data(end + 1) = uint8(0);
end

% Store the data.
attr_str = cat(2, attr_str, tmp);


function numBytes = getSizeInBytes(data)

switch (class(data))
case {'uint8', 'int8'}
    multiplier = 1;
    
case {'uint16', 'int16'}
    multiplier = 2;
    
case {'uint32', 'int32', 'single'}
    multiplier = 4;
    
case {'double'}
    multiplier = 8;
    
end

numBytes = multiplier * numel(data);


function val = get_group_or_element(in)

if (isempty(in))
    
    error(message('images:dicom_add_item:groupElementNotHexOrInt'))
    
elseif (ischar(in))

    val = sscanf(in, '%x');
    
elseif (isnumeric(in))
    
    val = in;
    
else
    
    error(message('images:dicom_add_item:groupElementNotHexOrInt'))
    
end
