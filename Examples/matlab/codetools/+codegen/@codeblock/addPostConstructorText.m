function addPostConstructorText(hThis,varargin)

% Copyright 2006 The MathWorks, Inc.

if ~iscell(varargin)
    varargin = {varargin};
end

hTextLine = codegen.codetext;
set(hTextLine,'Text',varargin);

hThis.addPostConstructorFunction(hTextLine);
