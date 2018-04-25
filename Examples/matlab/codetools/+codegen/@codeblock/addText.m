function addText(hThis,varargin)

% Copyright 2005 The MathWorks, Inc.

if ~iscell(varargin)
    varargin = {varargin};
end

hTextLine = codegen.codetext;
set(hTextLine,'Text',varargin);

hThis.addPreConstructorFunction(hTextLine);
