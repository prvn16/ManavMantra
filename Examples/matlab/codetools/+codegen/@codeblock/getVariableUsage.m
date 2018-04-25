function [hRequire, hProvide] = getVariableUsage(hCode)
%getVariableUsage Return the required and provided variables
%
%  [hRequired, hProvided] = getVariableUsage(hFunc) returns the set of
%  inputs that are required and the set of outputs that this code block
%  will provide.

% Copyright 2012-2015 The MathWorks, Inc.

% The required and provided variables for a codeblock are the union of the
% required and provided for all the code that the block creates, minus
% requirements that are satisfied by earlier code lines.

hPreFuncList = get(hCode,'PreConstructorFunctions');
hConstructor = get(hCode,'Constructor');
hPostFuncList = get(hCode,'PostConstructorFunctions');
hPostChildList = get(hCode,'PostChildFunctions');

% Recurse down to this node's children as well
kids = findobj(hCode,'-depth',1);
kids = kids(2:end);
if numel(kids)>1 && ~isempty(hCode.MomentoRef.ObjectRef) && ishghandle(hCode.MomentoRef.ObjectRef)
    % Reorder child blocks to fix dependencies where possible
    idx = getChildOrder(kids);
    kids = kids(idx);
end

AllFuncs = [hPreFuncList, hConstructor, hPostFuncList, kids(:).', hPostChildList];

hRequire = zeros(1,0);
hProvide = zeros(1,0);
for n = 1:length(AllFuncs)
    [hNextRequire, hNextProvide] = getVariableUsage(AllFuncs(n)); 
    
    hNextRequire = localConvertToActive(hNextRequire);
    hNextProvide = localConvertToActive(hNextProvide);
    
    % Required inputs for this function are only those that previous
    % functions have not provided
    if ~isempty(hNextRequire)
        hNextRequire = setdiff(hNextRequire, hProvide);

        hRequire = [hRequire, hNextRequire]; %#ok<*AGROW>
    end
    
    if ~isempty(hNextProvide)
        hProvide = [hProvide, hNextProvide];
    end
end

hRequire = unique(hRequire, 'R2012a');
hProvide = unique(hProvide, 'R2012a');


function hArgs = localConvertToActive(hArgs)
if ~isempty(hArgs)
    % Convert arguments to their "Active" handle
    ActiveVar = get(hArgs, {'ActiveVariable'});
    HasActiveVar = ~cellfun('isempty', ActiveVar);
    ActiveVar = [ActiveVar{:}];
    hArgs(HasActiveVar) = ActiveVar;
end