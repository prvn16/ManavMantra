function generateDefaultPropValueSyntax(hThis)

% Copyright 2003-2004 The MathWorks, Inc.

% Create input arguments
generateDefaultPropValueSyntaxNoOutput(hThis);

% Get handles
hFunc = getConstructor(hThis);
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');

% Add Output argument
hArg = codegen.codeargument('Value',hObj,...
                            'Name',get(hFunc,'Name'));
addArgout(hFunc,hArg);

