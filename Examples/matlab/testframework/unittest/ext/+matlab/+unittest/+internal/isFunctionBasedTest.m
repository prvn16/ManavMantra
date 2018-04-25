function tf = isFunctionBasedTest(tree)

%  Copyright 2013-2017 The MathWorks, Inc.

tf = false;

if isnull(tree)
    return
end
    
root = tree.root;
if ~root.iskind('FUNCTION')
    return
end

mainOutput = root.Outs;
if mainOutput.isnull()
    return
end

outputExpressions = tree.mtfind('SameID', mainOutput);
indices = outputExpressions.indices;
% Work through the  array backwards, looking at the last expression with
% the variable and ignoring the first which is the variable listed in the
% main function output list.
for idx = fliplr(indices(2:end))
    thisOutput = tree.select(idx);
    parent = thisOutput.Parent;
    if ~parent.iskind('EQUALS')
        continue;
    end
    
    % Now that we have found the last assignment into the output variable,
    % this is our last loop iteration.
    expression = parent.Right;
    if ~expression.iskind('CALL')
        break;
    end
    
    functionCall = expression.Left;
    if ~functionCall.iskind('ID')
        break;
    end
    
    if strcmp(functionCall.string, 'functiontests')
        tf = true;
    end
    break;
end

% LocalWords:  isnull iskind mtfind
