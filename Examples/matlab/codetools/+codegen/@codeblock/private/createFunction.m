function hFunc = createFunction(hFunc, varargin)
%createFunction  Create a codegen.codefunction 
%
%  createFunction constructs a codegen.codefunction from the input
%  arguments, ready for placing in the codeblock.
%
%  createFunction(hFunc) accepts a pre-built codefunction and simply
%  returns it without changes.
%
%  createFunction(FuncName) takes a function name as a string and generates
%  a function call to it with no inputs and no outputs.
%
%  createFunction(SubFunc) takes a subfunction codereoutine and generates
%  a function call to it with no inputs and no outputs.
%
%  createFunction(..., Inputs) takes a function and a list of inputs as a 
%  cell array.  Each input may be a codegen.codeargument or a bare value 
%  that will be converted to a string and inlined into the code.
%
%  createFunction(..., Inputs, Outputs) takes a function, a list of inputs
%  and a list of outputs as a cell array.  Each input may be a
%  codegen.codeargument or a bare value that will be converted to a string
%  and inlined into the code, but each output must be a
%  codegen.codeargument, because outputs have to be captured into named
%  variables.
%
%  createFunction(..., Comment) specifies a comment line that should be
%  printed before the function call.  The Comment may be a string or a
%  message object.

% Copyright 2015 The MathWorks, Inc.

if ischar(hFunc)
    hFunc = codegen.codefunction('Name', hFunc);
elseif isa(hFunc, 'codegen.coderoutine')
    hFunc = codegen.codefunction('SubFunction', hFunc);
end

 % Handle a trailing comment if there is one
if nargin>1
    comment = varargin{end};
    if ischar(comment)
        hFunc.Comment = comment;
        varargin(end) = [];
    elseif isa(comment, 'message')
        hFunc.Comment = getString(comment);
        varargin(end) = [];
    end
end

% Look for inputs
if ~isempty(varargin)
    hFunc.addArgin(varargin{1}{:});
end

% Look for outputs
if numel(varargin)>1
    hFunc.addArgout(varargin{2}{:});
end
