function hAllFuncs = createSetCall(hObjectArg, hPropList, CommentName)
%createSetCall Cosntruct a codegen.codefunction to call set.
%
%  codegen.codefunction.createSetCall(hObj, PropList, CommentName) creates
%  a set of calls that implement setting of the given properties on the
%  object hObj, using calls to "set". hObj must be a codegen.codeargument
%  object that refers to the object whose properties need to be set.
%  PropList should be a vector of momentoproperty objects.  CommentName is
%  a string that is used to generate argument comments and should refer to
%  the name of the object that the properties are for.
%
%  In the simple case, this will create a single call to set with
%  parameter-value pairs, however if the values contain a nested momento,
%  then that will require a call to get the object in that property
%  followed by another call to set the properties of that new object.  The
%  final result in that case is a sequence of get's followed by set's for
%  that object.
%
%  If there are no properties in the final set call, then no function will
%  be returned.

%  Copyright 2015 The MathWorks, Inc.

if nargin<3
    CommentName = '';
end

hFunc = codegen.codefunction;
hFunc.Name = 'set';
hFunc.addArgin(hObjectArg);
extraFuncs = hFunc.generatePropValueList(hPropList, CommentName, hObjectArg);

if numel(hFunc.Argin)==1
    % There were no prop-value pairs in this call.
    hAllFuncs = extraFuncs;
else
    hAllFuncs = [hFunc extraFuncs];
end
