function ret = isFunctionInput(hArg)
%isFunctionInput Test whether an argument needs to be an input to a function
%
%  isFunctionInput(hArg) returns true for arguments that have been marked
%  as parameters but not as anyone's output.  This means that they need to
%  be input arguments to the containing function.  hArg may be a vector of
%  codeargument objects, in which case the return will be a logical vector
%  of the same size as the input.

%  Copyright 2012 The MathWorks, Inc.

IsParam = get(hArg,{'IsParameter'});
IsParam = [IsParam{:}];
IsOutput = get(hArg,{'IsOutputArgument'});
IsOutput = [IsOutput{:}];

ret = IsParam & ~IsOutput;
