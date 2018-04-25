function codeStruct = parseUserCode( content )
%parseUserCode parses code from an App and converts it to struct of data

% Copyright 2015 The MathWorks, Inc.

import appdesigner.internal.codegeneration.MTreeCodeParser;
% extrenal function used to parse code
parser = MTreeCodeParser();
% returns a struct containing sub-structs with information on
% each class component block
codeStruct = parser.parse(content);
end
