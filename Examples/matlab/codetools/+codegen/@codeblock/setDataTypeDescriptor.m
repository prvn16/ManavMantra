function setDataTypeDescriptor(hThis,prop_name,descriptor_name)
% Internal use

% Specify data type descriptor for input properties
% prop_name: cell string of propertynames
% descriptor_name: enumeration string specified in codeargument.schema

% Copyright 2005-2012 The MathWorks, Inc.

% Cast to cell array of string if just a string
if isstr(prop_name)
  prop_name = {prop_name};
end

% Only cell array of strings valid input
if ~iscellstr(prop_name)
  error(message('MATLAB:codetools:codegen:InvalidInputRequiresCellArrayOfStrings'));
end

% Get handles
hMomento = get(hThis,'MomentoRef');

% Loop through all properties and mark them to be ignored.
hPropList = get(hMomento,'PropertyObjects');
for n = 1:length(hPropList)
    hProp = hPropList(n);
    name = get(hProp,'Name');
    if any(strcmpi(name,prop_name))
       set(hProp,'DataTypeDescriptor',descriptor_name);  
    end
end

