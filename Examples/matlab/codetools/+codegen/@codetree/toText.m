function toText(hCodeTree,hFunctionTable,outputTopNode)
% Determines text representation

% Copyright 2006-2007 The MathWorks, Inc.

hCodeTree.CodeRoot.toText(hCodeTree.VariableTable,hFunctionTable);
% Create a new variable table and clean up the numbering.
% Not quite sure why, but the following line is necessary to prevent
% codefunction objects from disappearing.
hRoot = hCodeTree.CodeRoot;

% Need to ensure that if the top node has been specified as output, it must
% not be removed
if outputTopNode
    hConstructorOutput = hRoot.Constructor.Argout;
    setRemovalPermissions(hConstructorOutput(1),false,hRoot.Constructor);
end

hCodeTree.VariableTable.clearTable;
hCodeTree.CodeRoot.toText(hCodeTree.VariableTable,hFunctionTable);