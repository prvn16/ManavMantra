function subFunctionsToMCode(hCode,hText,varargin)
% Generates code based on input codeblock object

% Copyright 2006 The MathWorks, Inc.

% Iterate through the subfunctions and generate code for each:
hSubFunc = hCode.SubFunctionList;
for i = 1:length(hSubFunc)
    hSubFunc(i).toMCode(hText,varargin{:});
end

% Recursively go through the children
% Recurse down to this node's children
kids = findobj(hCode,'-depth',1);
n_kids = length(kids);
for n = n_kids:-1:2
   kids(n).subFunctionsToMCode(hText,varargin{:});
end
