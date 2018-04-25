function newName = cleanName(hCode,name, defaultName)
% Given a potential name, determine if the name can be used as a variable
% name and return the new name. Otherwise, return the default name.

% Copyright 2006 The MathWorks, Inc.

if ~localIsValidName(name)
    newName = defaultName;
else
    newName = localCleanName(name, defaultName);
end

%----------------------------------------------------------%
function name = localCleanName(name,defaultName)
% Clean up a name by removing numeric suffixes and parentheses in the case
% of matrix input

% First, check for invalid characters:
pInd = regexp(name,'(');
if ~isempty(pInd)
    name = name(1:pInd(1)-1);
end

% Check for other invalid characters:
while ~isempty(name) && ~isvarname(name)
    name(end) = [];
end
% If the name ends up being empty, use the default:
if isempty(name)
    name = defaultName;
end

% Check for numeric suffixes:
while (name(end) >= '0') && (name(end) <= '9')
    name(end) = [];
end

%-----------------------------------------------------------%
function res = localIsValidName(objName)
% Check to see if a *SourceName property will translate to a valid variable
% name:
res = true;
if isempty(objName) %Empty
    res = false;
    return;
elseif objName(1)>='0' && objName(1)<='9' %Numeric start
    res = false;
    return;
elseif objName(1) == '(' || objName(1) == '[' %Symbolic start
    res = false;
    return;
end