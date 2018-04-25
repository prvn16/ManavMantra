function isTestFile = getClassFileInfoForToolstrip(file,parseTree,alreadyVisited)
% This function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.
import matlab.unittest.internal.ui.toolstrip.getClassFileInfoForToolstrip;
import matlab.unittest.internal.getFilenameFromParentName;
import matlab.unittest.internal.whichFile;
isTestFile = false;

if parseTree.isnull || parseTree.root.iskind('ERR')
    return;
end

superClassNames = getSuperClassNames(parseTree.root);

% Performance boost: first we try a direct check
if any(superClassNames == "matlab.unittest.TestCase")
    isTestFile = true;
    return;
end

if nargin < 3
    alreadyVisited = string.empty(1,0);
end

for superClassNameStr = superClassNames
    if any(superClassNameStr == alreadyVisited)
        continue;
    else
        alreadyVisited(end+1) = superClassNameStr;
    end
    
    superClassName = char(superClassNameStr);
    
    try
        superClassFile = whichFile(superClassName);
    catch
        % Prevent errors from the which command from appearing
        continue;
    end
    
    if isempty(superClassFile) || ~exist(superClassFile,'file')
        % If class file not found, then we try again looking into the original file's base folder
        baseFolder = regexprep(fileparts(file),['\' filesep '(+|@).*$'],'');
        superClassFile = fullfile(baseFolder,[getFilenameFromParentName(superClassName) '.m']);
        if ~exist(superClassFile,'file')
            continue;
        end
    end
    
    [~, ~, superExt] = fileparts(superClassFile);
    if strcmpi(superExt,'.p')
        isTestFile = isTestFileUsingMetaClass(superClassName);
    elseif strcmpi(superExt,'.m') || strcmpi(superExt,'.mlx')
        isTestFile = getClassFileInfoForToolstrip(superClassFile,mtree(superClassFile,'-file'),alreadyVisited);
    end
    
    if isTestFile
        return;
    end
end
end


function superClasses = getSuperClassNames(classdefNode)
superClasses = string.empty(1,0);

% Add superclasses corresponding to multiple inheritance
superClassNode = classdefNode.Cexpr.Right;
while ~isnull(superClassNode) && strcmp(kind(superClassNode), 'AND')
    superClasses = [string(superClassNode.Right),superClasses];  %#ok<*AGROW>
    superClassNode = superClassNode.Left;
end

% Add first superclass
if ~isnull(superClassNode)
    superClasses = [string(superClassNode),superClasses];
end
end


function isTestFile = isTestFileUsingMetaClass(className) %#ok<INUSD> - evalc
try
    % In the event that a class has static properties which might
    % invoke code, we need to hide any output from the screen.
    [~,mc] = evalc('meta.class.fromName(className);');
catch
    isTestFile = false;
    return;
end
isTestFile = ~isempty(mc) && mc <= ?matlab.unittest.TestCase;
end