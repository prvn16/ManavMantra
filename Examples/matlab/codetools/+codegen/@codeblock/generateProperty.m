function generateProperty(hThis, propnames, reverseTraverse)
% Tells code object to generate code for a property. The property will then
% be added as a series of post-constructor functions and a call to SET.

% Copyright 2007-2012 The MathWorks, Inc.

% Cast to cell array of string if just a string
if ischar(propnames)
  propnames = {propnames};
end

% Only cell array of strings valid input
if ~iscellstr(propnames)
  error(message('MATLAB:codetools:codegen:InvalidInputRequiresCellArrayOfStrings'));
end

hMomento = hThis.MomentoRef;
hObj = hMomento.ObjectRef;

% For each property, construct the momento reference for it:
hMomentos = [];
propnamesOut = {};
for i = 1:numel(propnames)
    currProp = get(hObj,propnames{i});
    % Skip properties that are not handles.
    if ~ishandle(currProp)
        continue;
    end
    propnamesOut{end+1} = propnames{i};
    currProp = handle(currProp);
    options.ReverseTraverse = reverseTraverse;
    hMomentos = [hMomentos codegen.momento(currProp,options)]; %#ok<AGROW>
end

% For each momento, generate a code block for it and add its construction
% to the main block:
for i = 1:numel(hMomentos)
    hBlock = codegen.codeblock;
    constructObj(hBlock,hMomentos(i));
    % Add each block as a series of post-constructor functions to the 
    % main code block:
    hFuns = hBlock.PreConstructorFunctions;
    for j=1:numel(hFuns)
        hThis.addPostConstructorFunction(hFuns(j));
    end
    hThis.addPostConstructorFunction(hBlock.Constructor);
    hFuns = hBlock.PostConstructorFunctions;
    for j=1:numel(hFuns)
        hThis.addPostConstructorFunction(hFuns(j));
    end
end

% Add a call to the SET function to link the object with the generated
% properties.
hFunc = codegen.codefunction('Name', 'set', 'CodeRef', hThis);
hArg = codegen.codeargument('Value',hObj,'IsParameter',true);
hFunc.addArgin(hArg);
for i = 1:numel(hMomentos)
    hProp = hMomentos(i).ObjectRef;
    hArg = codegen.codeargument('Value',propnamesOut{i});
    hFunc.addArgin(hArg);
    hArg = codegen.codeargument('Value',hProp,'IsParameter',true);
    hFunc.addArgin(hArg);
end
hThis.addPostConstructorFunction(hFunc);