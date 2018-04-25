function [ childStrc, fcnHash ] = parseDependencyInfo(fileList, ~)
%PARSEDEPENDENCYINFO Parse a list of files, building up a structure of their dependencies
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

% Copyright 2009-2016 The MathWorks, Inc.

    %{
    The structure looks like:
    
    file.name
    file.fullname 
    file.subs
    ...
        thisSubFunStrc.name
        thisSubFunStrc.fullname
        thisSubFunStrc.line 
        thisSubFunStrc.calls
        ...
            callInfo.name
            callInfo.line
            callInfo.alternateMatches
            callInfo.type
    
    %}

%#ok<*AGROW>
import internal.matlab.reports.ReportConstants;

%% Process the data into a table
toolboxMatlab =  fullfile(matlabroot,'toolbox','matlab');
toolbox =  fullfile(matlabroot,'toolbox');
childStrc = [];

% Create a hash for keeping track of function names The hash will let me find the index for a file
% given its name maps a functionname to an index
fcnHash = containers.Map;

if ~isempty(fileList) 
    % If we have files in the folder, go through all the children for each file and determine who
    % is being called. Also build up calling adjacency matrix callGrid for working out parent
    % functions later on.
    for n = 1:length(fileList)
        %for each file
        currentFile = fileList{n};
        [dirname, filename] = fileparts(currentFile);
        file.name = filename;
        file.fullname = currentFile;
        
        %get the call structure for the file
        try
            strc = [];
            fileError = false;
            strc = getcallinfo(currentFile);
        catch exception
            fileError = true;
            errorMessage = exception.message;
        end
        
        if length(strc) == 1 && strc.type == internal.matlab.codetools.reports.matlabType.Unknown
            errorMessage = getString(message('MATLAB:codetools:reports:UnknownError'));
            fileError = true;
        end
        
        if fileError
            %we had an error trying to get info about the file
            errorStrc = [];
            errorStrc.fullname = currentFile;
            errorStrc.name = filename;
            
            errorFcn.name = filename;
            errorFcn.fullname = filename;
            errorFcn.line = 1;
            
            errorCallInfo.type = ReportConstants.Error;
            errorCallInfo.name = errorMessage;
            errorCallInfo.line = 1;            
            errorCallInfo.alternateMatches = '';
            
            errorFcn.calls =  errorCallInfo;
            errorStrc.subs =  {errorFcn};
            childStrc{n} = errorStrc;
            continue % go to the next file
        end
        
        allSubFunStrc = struct([]);
        
        for c = 1:length(strc)
            allChildStrc = struct([]);
            thisStrc = strc(c);
            thisSubFunStrc.name = thisStrc.name;
            thisSubFunStrc.fullname = thisStrc.fullname;
            thisSubFunStrc.line = thisStrc.firstline;
            
            outerCalls = [thisStrc.calls.fcnCalls.names thisStrc.calls.dotCalls.names thisStrc.calls.atCalls.names];
            innerCalls = thisStrc.calls.innerCalls.names;
            outerCallLines = [thisStrc.calls.fcnCalls.lines thisStrc.calls.dotCalls.lines thisStrc.calls.atCalls.lines];
            innerCallLines = thisStrc.calls.innerCalls.lines;
            
            for i=1:length(outerCalls)
                callInfo.name = outerCalls{i};
                
                try
                    [fullCallName,possibleAlternatives] = whichCaller(outerCalls{i}, currentFile);
                catch exception
                    % --- ERROR ---
                    callInfo.type = ReportConstants.Error;
                    callInfo.name = exception.message;
                    callInfo.line = [];
                    callInfo.alternateMatches = '';
                    continue;
                end
                callDir = fileparts(fullCallName);
                
                callInfo.line = outerCallLines(i);
                callInfo.alternateMatches = possibleAlternatives;
                
                if isempty(fullCallName)
                    %assume a dotcall is a variable access 
                    if ismember(outerCalls{i}, thisStrc.calls.dotCalls.names)
                        callInfo.type = ReportConstants.Variable;
                    %all other calls are unknown
                    else        
                        callInfo.type = ReportConstants.Unknown;
                    end
                elseif strfind(fullCallName, 'built-in')
                    % ---- BUILT-IN ----
                    callInfo.type = ReportConstants.Builtin;
                elseif strfind(fullCallName, toolboxMatlab)
                    % --- TOOLBOX / MATLAB ----
                    callInfo.type = ReportConstants.MatlabToolbox;
                elseif strcmp(callDir, fullfile(dirname, 'private'))
                    callInfo.type = ReportConstants.Private;
                elseif strcmp(callDir, dirname) && ~isempty(callDir)
                    %There is no string returned from which indicating
                    %subfunction so we must resort to checking if the path
                    %returned from which is the same as what was passed to
                    %which, all other cases where this is true will return
                    %a tag in the comment.
                    if ~isempty(fullCallName) && strcmp(fullCallName, currentFile)
                        callInfo.type = ReportConstants.SubFunction;
                    else
                        callInfo.type = ReportConstants.CurrentDirectory;
                        %add to list of parent functions
                        addToHash(callInfo.name, thisStrc.fullname);
                    end
                elseif strfind(fullCallName, toolbox)
                    callInfo.type = ReportConstants.Toolbox;
                    callInfo.name = strrep(fullCallName,toolbox,'');
                elseif strfind(fullCallName,' is a Java method')
                    callInfo.type = ReportConstants.JavaMethod;                
                else
                    % Need to do some deeper investigating
                    call = outerCalls{i};
                    info = evalc(sprintf('which(''%s'')',call));
                    
                    if strfind(info,' static method or package function')
                        seps = find(callDir==filesep);
                        if ~isempty(seps)
                            dirtype = callDir(seps(end)+1);
                            switch dirtype
                                case '+' %is a package dir
                                    callInfo.type = ReportConstants.PackageFunction;
                                otherwise %is an '@' dir or a class file
                                    callInfo.type = ReportConstants.StaticMethod;
                            end
                        end
                    else
                        %everything else - i.e. normal files on the path
                        callInfo.type = ReportConstants.Other;
                    end
                end
                allChildStrc = [allChildStrc callInfo];
            end
            for i=1:length(innerCalls)
                callInfo = [];
                callInfo.type = ReportConstants.Unknown;                    
                callName = innerCalls{i};
                subnames = {strc.name};
                matches = strcmp(subnames, callName);
                if ~isempty(matches)
                    if sum(matches) == 1
                        % just one sub-function of that name -- no need to further parse
                        callInfo.type = convertTypeToChar(strc(matches).type);
                    else
                        %search the calls that match the sub-function name with the fullname that matches
                        %the current caller function
                        matchedStrc = strc(matches);
                        matches = ~cellfun(@isempty, strfind({matchedStrc.fullname}, thisStrc.name));
                        if sum(matches) == 0 % may be one subfunction calling another 
                            parts = regexp(thisStrc.fullname, '>', 'split');
                            callingFunction = parts(1); % If no '>', will just be fullname
                            matches = ~cellfun(@isempty, strfind({matchedStrc.fullname}, callingFunction{:}));
                        end
                        if sum(matches) >= 1
                            % If more than one match, use the first match (preferring nested
                            % functions). Since this is an inner call, it doesn't really effect the
                            % dependency matrix if it gets it wrong.
                            allTypes = {matchedStrc(matches).type};
                            nestedFunctionMatches = strcmp(getString(message('MATLAB:codetools:reports:NestedDashFunction')), allTypes);
                            if (sum(nestedFunctionMatches) >= 1)
                                % Use first nested-function match (they will all be the same).
                                type = matchedStrc(nestedFunctionMatches).type;
                            else
                                % No nested-function matches, just use the first.
                                type = matchedStrc(matches).type;
                            end
                            callInfo.type = convertTypeToChar(type);
                        end
                    end
                    callInfo.name = callName;
                    callInfo.line = innerCallLines(i);
                    callInfo.alternateMatches = '';
                    
                    allChildStrc = [allChildStrc callInfo];
                    %add to list of parent functions
                    addToHash(callInfo.name, thisStrc.fullname);
                end
            end
            
            if ~isempty(allChildStrc)
                %sort
                [~, idx] = sort({allChildStrc.type});
                allChildStrc = allChildStrc(idx);
                %eliminate duplicates;
                [~, idx] = unique({allChildStrc.name},'first');
                thisSubFunStrc.calls = allChildStrc(idx);
            else
                thisSubFunStrc.calls = [];
            end
            allSubFunStrc{c} = thisSubFunStrc;
        end
        
        file.subs = allSubFunStrc;
        
        childStrc{n} = file;
    end
    
end

    function addToHash(functionCalled, callingFunction)
        if fcnHash.isKey(functionCalled)
            fcnHash(functionCalled) = ...
                unique([fcnHash(functionCalled) callingFunction]);
        else
            fcnHash(functionCalled) = {callingFunction};
        end
    end

end

function [outputFullPathFunction,possibleAlternates] = whichCaller(inputTargetFunction, inputContextFunction)
% This exists as a separate subfunction because the WHICH FOO IN BAR
% functionality is masked by variables in the calling function's scope.

possibleAlternates = [];
outputFullPathFunction = which([inputContextFunction,'>',inputTargetFunction], '-all');
if ~isempty(outputFullPathFunction)
    if size(outputFullPathFunction, 1) > 1
        %If there exists a class file that is p-coded, both the m and p
        %files show up in a WHICH -all, but the dependency report does need
        %to list those.
        p = cell(length(outputFullPathFunction),1);
        n = cell(length(outputFullPathFunction),1);
        e = cell(length(outputFullPathFunction),1);
        for i=1:length(outputFullPathFunction)
            [p{i},n{i},e{i}]=fileparts(outputFullPathFunction{i});
        end
        pfiles = find(strcmp(e,'.p'));
        todelete = false(size(outputFullPathFunction));
        for i=1:length(pfiles)
            pi=strcmp(p,p{pfiles(i)});
            ni=strcmp(n,n{pfiles(i)});
            x = pi & ni; %and(pi,ni);
            if sum(x) > 1
                x = find(x);
                todelete(x(2:end)) = true;
            end
        end
        outputFullPathFunction(todelete) = [];
        if length(outputFullPathFunction) > 1
            %of the remaining other code files, get just the class methods
            possibleAlternates = ...
                outputFullPathFunction(~cellfun('isempty',strfind(outputFullPathFunction,'@')));
        end
    end
    outputFullPathFunction = outputFullPathFunction{1};
else
    outputFullPathFunction = '';
end
end

function type = convertTypeToChar(inputType)
if isa(inputType,'internal.matlab.codetools.reports.matlabType.MatlabFileType')
    type = char(inputType);
else
    type = inputType;
end
end
