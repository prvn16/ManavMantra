function functionInfo = getcallinfo(filename, varargin)
%GETCALLINFO  Returns called functions and their first and last lines
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%  STRUCT = GETCALLINFO(FILENAME, OPTION)
%
%  FILENAME must be the full path to the file. Partial path may result in
% an incorrect structure.

%   The output structure STRUCT takes the form
%      type:       [ MatlabType.Script | MatlabType.Function | MatlabType.Class ]
%                  or, [ subfunction | nested-function | class method ]
%      name:       name of the script, function, subfunction, class, or method
%      firstline:  first line of the script, function, subfunction, class, or method
%      lastline:   last line of the script, function, subfunction, class, or method
%      linemask:   contains the same number of lines as the file in flist.
%                  linemask is one on all lines where the function is in
%                  scope.
%      calls.fcnCalls.names:   calls made by the file to functions on the MATLAB path
%      calls.fcnCalls.lines:   lines from which the above calls were made
%      calls.innerCalls.names: calls made by a function or class to another function in the file
%      calls.innerCalls.lines: lines from which the above calls were made
%      calls.dotCalls.names:   items in the file accessed with a "." for instance object.method or
%                              struct.field. To resolve if this is a call to a static method or a
%                              field/property access use the which command
%      calls.dotCalls.lines:   lines from which the above calls were made
%      calls.atCalls.names:    items in the file accessed with a "@", i.e.
%                              function handles
%      calls.atCalls.lines:    lines from which the above calls were made
%
%
%   OPTION = [ 'normal' | 'flat'  | '-v7.8']
%   By default OPTION is set to 'normal'
%
%   OPTION = 'flat' returns one flattened structure for the entire file,
%   regardless of whether it is a script, a function with no subfunctions,
%   or a function with subfunctions. For a file with subfunctions, the
%   calls for the file includes all external calls made by subfunctions.
%
%   OPTION = 'normal' returns an array of structures. The first is for the
%   for the main function followed by all of the subfunctions. This option
%   returns the same result as 'flat' for scripts and one-function files.
%
%   OPTION = '-v7.8' backwards-compatibility mode; outputs the structure array as it used to in 
%   R14 through R2009a. This option is only for a multi-release conversion of the output is will 
%   be removed in a future version.
%
% See also which.

% Copyright 1984-2013 The MathWorks, Inc.

options = varargin;

%% Find all the lines of the file
flist = getmcode(filename);
fileCode = flist;
nonLines = false(length(fileCode),1);
%% new Get file structure
try
    tree = mtree(filename,'-file');
catch exception
    if strcmp(exception.identifier,'MATLAB:mtree:input');
        error('MATLAB:codetools:BadInput',exception.message);
    else
        exception.rethrow;
    end
end
if count(tree) == 1 && iskind(tree,'ERR')
    error(message('MATLAB:codetools:SyntaxError', string( tree )));
end

type = internal.matlab.codetools.reports.matlabType.findType(tree);
functions = mtfind(tree,'Kind','FUNCTION');
fileIsFunction = (type == internal.matlab.codetools.reports.matlabType.Function);
numberOfNonTopFunctions = count(functions) - 1 * fileIsFunction;

%% Parse the file structure
[~, fname] = fileparts(filename);

%functions

%The first thing we do is find the first root node. 
% This represents the top level function, or the script.
idx = functions.indices;
rootNode = root(tree); 
% We record some basic information about this top level node.
% Additional information will be recorded below, but first we need to know
% about other local functions.
functionInfo.type = type; 
functionInfo.name = fname; 
functionInfo.fullname = fname;
functionInfo.functionPrefix = [fname filemarker];

nonTopFunctionInfo = struct([]);

% For each nonTopLevel function (local function)
for i=1:numberOfNonTopFunctions
    % we get its mtree node
    functionNode = select(functions, idx(i - ~fileIsFunction+1));
    % and record some basic information about it.
    nonTopFunctionInfo = [nonTopFunctionInfo parseInfo(functionInfo, functionNode, nonLines)];
end

% If there any nodes at all in the mtree, i.e. it is not a blank file
if tree.count > 0
    % add the neccessary call information
    functionInfo = addCallInfo(functionInfo, rootNode, nonLines);
    
    %But if the file is a script...
    if isa(type, 'internal.matlab.codetools.reports.matlabType.Script')
        
        % ...that contains a local function
        if numberOfNonTopFunctions ~= 0
            % set the 'lastline' property to be the the line directly
            % before the start of the local functions.
            % Brackets are inserted to convert comma seperated list to
            % vector.
            firstLocalFunctionStart = min([nonTopFunctionInfo.firstline]);
            functionInfo.lastline = firstLocalFunctionStart - 1;
            % and set the line mask appropriately as well
            functionInfo.linemask(1:(firstLocalFunctionStart-1)) = 1;
            
            %This is valid because all local functions MUST come after the
            %last line of the script.
            
        % ...that does not contain a local function
        else
            % force a Script to take up the whole length of the file's code. The
            % root node is not necessarily all-encompassing. 
            functionInfo.lastline = getlastexecutableline(rootNode);
            functionInfo.linemask = functionInfo.linemask | 1;
        end
    end
else
    functionInfo = addNullCallInfo(functionInfo);
end

functionInfo = [functionInfo nonTopFunctionInfo];
%% old cleanup for output
if nargout==0
    displayStructure(convertToR2009a(functionInfo))
else    
    if any(strcmp(options,'flat'))
        functionInfo = flattenFileStructure(functionInfo);
    end
    if any(strcmp(options,'-v7.8'))
        functionInfo = convertToR2009a(functionInfo);
    end
end
end

function dashesStr = getDashesForString(str)
dashesStr = '';
numberOfDashes = length(str);
for idx = 1: numberOfDashes
    dashesStr = strcat(dashesStr, '-');
end
end

function displayStructure(strc)
% Display
name = getString(message('MATLAB:codetools:reports:RptName'));
type = getString(message('MATLAB:codetools:reports:RptType'));
starts = getString(message('MATLAB:codetools:reports:RptStarts'));
ends = getString(message('MATLAB:codetools:reports:RptEnds'));
reportLength = getString(message('MATLAB:codetools:reports:RptLength'));
fullName = getString(message('MATLAB:codetools:reports:RptFullName'));

fprintf('%-20s %-20s %-4s %-4s %-6s %-20s\n',name,type,starts,ends,reportLength,fullName);
fprintf('%-20s %-20s %-4s %-4s %-6s %-20s\n', ...
    getDashesForString(name), ...
    getDashesForString(type), ...
    getDashesForString(starts), ...
    getDashesForString(ends), ...
    getDashesForString(reportLength), ...
    getDashesForString(fullName));
for n = 1:numel(strc)
    fprintf('%-20s %-20s %4d  %4d %6d %-20s\n', ...
        strc(n).name, strc(n).type, strc(n).firstline, ...
        strc(n).lastline, sum(strc(n).linemask), ...
        strc(n).fullname);
end
end

function strc = flattenFileStructure(strc)
% Strip the structure from an array down to a scalar structure
% Remove any calls to local functions
if length(strc) > 1
    allCalls = [strc.calls];
    allFcnCalls = [allCalls.fcnCalls];
     allCalledFilenames = [allFcnCalls.names];
     allCallLines = [allFcnCalls.lines];
    
    % Remove local calls
    allInnerCalls.names=[];
    allInnerCalls.lines=[];
    
    % Remove dot calls
    % The flat structure is only used with -v7.8 calls which did not know about these anyway
    allDotCalls.names=[];
    allDotCalls.lines=[];
    
    % De-dupe
    [~, index] = unique(allCalledFilenames);
    allCalledFilenames = allCalledFilenames(index);
    allCallLines = allCallLines(index);
    % Sort by line number
    [~, index] = sort(allCallLines);
    allCalledFilenames = allCalledFilenames(index);
    allCallLines = allCallLines(index);

    strc(2:end) = [];
    strc(1).calls.fcnCalls.lines = allCallLines;
    strc(1).calls.fcnCalls.names = allCalledFilenames;
    strc(1).calls.innerCalls = allInnerCalls;
    strc(1).calls.dotCalls = allDotCalls;
end
end

function type = findSubFunType( node )
%FINDSUBFUNTYPE given a function node determine if the function is a
%method, nested function, or subfunction. Returns a translated string.

%sub functions appear at the same level (list) as the root node, while
%class methods and nested functions are under the root node. Class methods
%are like nested functions under a classdef

if isnull(list(root(node)) & node)
    
    if iskind(trueparent(node), 'METHODS')
        %method
        type = getString(message('MATLAB:codetools:reports:ClassMethod'));
    else
        %nested function
        type = getString(message('MATLAB:codetools:reports:NestedDashFunction'));
    end
else
    %subfunction
    type = getString(message('MATLAB:codetools:reports:Subfunction'));
end
end

function fullname = findFullName(rootStruct, node)    
baseName = rootStruct.functionPrefix;


%if nested functions the function name is
%  functionname>level1/level2/...
%if class the function name is class>class.method
nestedFname = '';
while (~isnull(node) && iskind(node, 'FUNCTION') && node ~= root(node))
    nestedFname = strcat(string(Fname(node)), '/', nestedFname);
    node = node.first.Parent;
end
fcnName = nestedFname(1:end-1);

% this is inside a class method
if iskind(node, 'METHODS');
    %methods and nested functions get
    classPrefix = [rootStruct.name '.'];
else
    classPrefix = '';
end

fcnName = [classPrefix fcnName];

fullname = [baseName fcnName];
end

function newStrc = convertToR2009a(strc)
%Converts the new output to the R2009a and earlier style, for backwards
%compatibility until all the profiler uses are converted, then this option
%will be deleted.

%remove the class information
if isa(strc(1).type, 'internal.matlab.codetools.reports.matlabType.Class')
    if length(strc) > 1
        strc = strc(2:end);
    else
        %an empty class file would probably have no calls?
    end
else
    %convert the enum to a string for functions and scripts
    strc(1).type = strc(1).type.char;
end

%treat empty cells as nulls
for i=1:length(strc)
    newThisStrc = strc(i);
   
    %convert new calls struct to old calls field
    calls = [newThisStrc.calls.fcnCalls.names newThisStrc.calls.innerCalls.names newThisStrc.calls.atCalls.names];
    calllines = [newThisStrc.calls.fcnCalls.lines newThisStrc.calls.innerCalls.lines newThisStrc.calls.atCalls.lines];
    if isempty(calls)
        calls = [];
        calllines = [];
    else
        [calllines, idx] = sort(calllines);
        calls = calls(idx);
    end
    newThisStrc.calls = calls;
    newThisStrc.calllines = calllines;
    newStrc(i) = newThisStrc;
end
end

function atdir = atDirPrefix(path)
%Parse the path to see if there is an @ dir at the top.
dirsep = strfind(path, filesep);
if ~isempty(dirsep)
    path = path(dirsep(end)+1:end);
end
if ~isempty(path) && path(1)=='@'
    atdir = [path(2:end) '.'];
else
    atdir = '';
end
end

function functionInfo = addCallInfo(functionInfo, functionNode, nonLines)
%call info
[callInfo, innerfcns] = parseCalls(functionNode);
functionInfo.calls = callInfo;

%line info
functionInfo.firstline = lineno(functionNode);
try 
    functionInfo.lastline = lastone(functionNode);
catch ex
    if strcmp(ex.identifier,'MATLAB:badsubscript')
        functionInfo.lastline = functionInfo.firstline;
    else
        ex.rethrow
    end
end
    
lineMask = nonLines;
lineMask(functionInfo.firstline:functionInfo.lastline)= true;
functionInfo.linemask = lineMask;

oidx = innerfcns.indices;
for i=1:length(oidx)
    otherNode = select(innerfcns, oidx(i));
    functionInfo.linemask(otherNode.lineno:otherNode.lastone)=false;
end

end

function functionInfo = addNullCallInfo(functionInfo)
%in cases where is no valid tree, create a "null" struct
    functionInfo.firstline = 0;
    functionInfo.lastline = 0;
    functionInfo.linemask = false;
    functionInfo.calls.fcnCalls.lines = [];
    functionInfo.calls.fcnCalls.names = [];
    functionInfo.calls.innerCalls.names = [];
    functionInfo.calls.innerCalls.lines = [];
    functionInfo.calls.dotCalls.names = [];
    functionInfo.calls.dotCalls.lines = [];
    functionInfo.calls.atCalls.names = [];
    functionInfo.calls.atCalls.lines = [];
    functionInfo.typeForTesting = functionInfo.type;
end

function [callInfo , otherfcns] = parseCalls(node) 
%parseCalls figures out what other functions (possibly variables) are called in the node's subtree
% the return value is a structure in three sub structs, one for the known calls outside of the file
% one for the known calls to functions within the files
% and one for the things in dot notation, which could be struct access or a class method. to parse
%  these out, additional work would have to be done
otherfcns = mtfind(subtree(node) - node, 'Kind','FUNCTION');
if iskind(node,'FUNCTION')    
    justthis = subtree(node) - subtree(otherfcns);
else
    justthis = subtree(list(node));
end
calls = mtfind(justthis,'Kind','CALL');

functionsInScope = Fname(list(node.Body));
parent = node.trueparent;
while ~isempty(parent)    
    functionsInScope = functionsInScope | Fname(list(parent.Body));
    parent = parent.trueparent;
end

calledInnerFunctions = mtfind(functionsInScope, 'SameID', calls.Left);
calledSubFunctions = mtfind(Fname(list(root(node))), 'SameID', calls.Left);
calledInners = calledInnerFunctions | calledSubFunctions;

innerCalls = mtfind(calls.Left, 'SameID', calledInners);
calls = calls.Left - innerCalls;

callInfo.fcnCalls.names = strings( calls );
callInfo.fcnCalls.lines = lineno( calls )';

callInfo.innerCalls.names = strings( innerCalls ); 
callInfo.innerCalls.lines = lineno( innerCalls )';

%parse the potential dot calls
dots = mtfind(justthis,'Kind','ID', 'Parent.Kind', 'DOT');
idx = dots.indices;
dotCalls = cell(1,length(idx));
for i=1:length(idx)
    top = justthis.select(idx(i));
    dotName = string( top );
    while (iskind( Parent(top), 'DOT'))
        top = Parent(top);
        dotName = [dotName '.' string( Right(top))];
    end
    dotCalls{i} = dotName; 
end
callInfo.dotCalls.names = dotCalls;
callInfo.dotCalls.lines = lineno( dots )';


%parse the potential dot calls
ats = justthis.mtfind('Kind','AT').subtree.mtfind('Kind','ID');
callInfo.atCalls.names = strings( ats ); 
callInfo.atCalls.lines = lineno( ats )';
end

function info = parseInfo(parentInfo, functionNode, nonLines)
%parse the info for an individual sub function
info.type = findSubFunType(functionNode);
info.name = char(strings(Fname(functionNode)));

info.fullname = findFullName(parentInfo, functionNode);
info.functionPrefix = info.fullname;

info = addCallInfo(info, functionNode, nonLines);
end

%#ok<*AGROW>
