function data = makeStructure(names, values, areNamesUnique, areNamesValid)
% Create a structure from names and values cell arrays. Ensure the names
% are unique.
% Syntax
%
%     data = makeStructure(names, values, areNamesUnique, areNamesValid)
%
% Description
%
%     data = makeStructure(names, values, areNamesUnique, areNamesValid) creates a structure from names and values cell arrays 
%     
%
% Input Arguments
%
%     names          - cell array
%     values         - cell array 
%     areNamesUnique - logical (true/false)
%     areNamesValid  - logical (true/false)
%
% Output Arguments
%
%     data - output structure containing unique and valid field names
%
% Example
%
%     names = {'0', '_x'};
%     values = {'Hello', 24};
%     areNamesUnique = true;
%     areNamesValid = false;
%     matlab.internal.json.makeStructure(names, values, areNamesUnique, areNamesValid)
%
% This function is internal and is subject to change in the future.

% Copyright 2015-2016 The MathWorks, Inc.
% CONFIDENTIAL AND CONTAINING PROPRIETARY TRADE SECRETS
% The source code contained in this listing contains proprietary and
% confidential trade secrets of The MathWorks, Inc.   The use, modification,
% or development of derivative work based on the code or ideas obtained
% from the code is prohibited without the express written permission of The
% MathWorks, Inc.  The disclosure of this code to any party not authorized
% by The MathWorks, Inc. is strictly forbidden.

if ~(areNamesUnique && areNamesValid)

    names = matlab.lang.makeValidName(names);
    names = matlab.lang.makeUniqueStrings(names, 1:numel(names), namelengthmax);
    
end
data = cell2struct(values, names, 1);
if isempty(data)
    data = struct;
end
end
