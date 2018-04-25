function procedureName = getTestProcedureNameAtCursor(fileName, cursorPosition)
% This function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.

import matlab.unittest.internal.fileResolver;
import matlab.internal.getCode;

fileName = fileResolver(fileName);

try
    builtin('_mcheck',fileName);
catch exception
    throwAsCaller(exception);
end

% Since com.mathworks.mde.editor.MatlabEditor's getCaretPosition value
% doesn't include sprintf('\r') characters but mtree's leftposition and
% rightposition values do, we need to strip out the '\r' characters before
% applying mtree.
code = getCode(fileName);
code = regexprep(code, '\r', '');
parseTree = mtree(code,'-comments');

root = parseTree.root;
if root.FileType == mtree.Type.ClassDefinitionFile
    subTree = getFunctionsFromTestMethodBlocksSubTree(parseTree);
    procedureName = getProcedureNameFromSubtree(subTree, cursorPosition);
elseif root.FileType == mtree.Type.FunctionFile
    subTree = getTestSubFunctionsSubTree(parseTree);
    procedureName = getProcedureNameFromSubtree(subTree, cursorPosition);
    if ~isempty(procedureName) && isempty(testsuite(fileName,'ProcedureName',procedureName))
        procedureName = '';
    end
else
    % To address edge case where file is updated to script and button is
    % clicked before save occurs, we force empty procedureName.
    procedureName = '';
end
end


function functionsFromTestMethodBlocks = getFunctionsFromTestMethodBlocksSubTree(parseTree)
testMethodsTree = parseTree.mtfind('Kind', 'METHODS', 'Attr.Arg.List.Any.Left.String', 'Test' );
functionsFromTestMethodBlocks = testMethodsTree.Body.List.mtfind('Kind','FUNCTION');
end


function subTree = getTestSubFunctionsSubTree(parseTree)
subTree = parseTree.root.Next.List.mtfind('Kind','FUNCTION');
end


function procedureName = getProcedureNameFromSubtree(subTree, cursorPosition)
procedureName = '';
for k=subTree.indices
    fcnNode = subTree.select(k);
    if fcnNode.leftposition-1 <= cursorPosition && cursorPosition <= fcnNode.rightposition
        procedureName = fcnNode.Fname.string;
        return;
    end
end
end