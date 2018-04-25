function d = buildCoverageInfo( dirname, reportName )
%BUILDCOVERAGEINFO parses a directory and the profiler info to build
%information about the coverage of the files in that directory
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

% Copyright 2009-2016 The MathWorks, Inc.

import com.mathworks.jmi.MLFileUtils;

%% Massage the directory name
fs = filesep;
if ~isempty(regexp(dirname,'\Wprivate$','once'))
    % Strip the front off the directory name, so we're left with something
    % like signal/private/ (Unix) or signal\private\ (Windows)
    
    fsIndex = find(dirname==fs);
    privateDirname = [dirname((fsIndex(end-1)+1):end) fs];
    classNamePrefix = '';
else
    privateDirname = '';
    classNamePrefix = '';
    % If we have been asked to collect coverage from a class directory we
    % need to prefix the function names with 'className.' or 'pkgName.className.'
    tokens = regexp( dirname, '@(\w+)', 'tokens' );
    if ~isempty( tokens )
        tokens = [tokens{:}];
        classNamePrefix = sprintf( '%s.', tokens{:} );
    end
end

%% Gather the data
profInfo = profile('info');

profiledFileList = {profInfo.FunctionTable.FileName};
profiledFcnList = {profInfo.FunctionTable.FunctionName};

dirFileList =  internal.matlab.reports.matlabFiles(dirname, reportName); 
d = struct('name',dirFileList);
d(1).profInfoIndex = [];

% Determine the overlap between the list of profiled files and the list of
% files in this directory. How many files in the current directory have
% been profiled?

for n = 1:length(profiledFileList)
    [pth, name, ext] = fileparts(profiledFileList{n});
    if (strcmp(pth, dirname) && (internal.matlab.reports.isMatlabCodeFile(profiledFileList{n}) || MLFileUtils.isMlappFile(profiledFileList{n})));
        % The file in question lives in the current directory
        ndx = strmatch([name ext],{d.name});
        % profInfoIndex is the index into the profiler's FunctionTable
        d(ndx).profInfoIndex = [d(ndx).profInfoIndex n];
        % Remove the directory from the front of the profile function list.
        % This is necessary for proper operation inside private/
        % directories.
        if ~isempty(privateDirname)
            profiledFcnList{n} = strrep(profiledFcnList{n},privateDirname,'');
        end
    end
end

% Take a second pass through to find the coverage stats by subfunction
for n = 1:length(d)
    % Use a negative coverage so that sorting will work out automatically 
    % If a file has coverage, it will be set later in this loop
    d(n).coverage = -1*n;
    d(n).funlist = [];
    
    if ~isempty(d(n).profInfoIndex)
        % We're in a function that was called
        
        % Get the names of all the subfunctions from this file
        callStrc = getcallinfo([dirname fs d(n).name]);
        
        linelist = (1:length(callStrc(1).linemask))';
        
        runnableLineIndex = callstats('file_lines',[dirname fs d(n).name]);
        
        if callStrc(1).type == internal.matlab.codetools.reports.matlabType.Class
            %if the file is a class, and there are no methods, then there
            %are no runnable lines in the class. Otherwise, remove the
            %classdef from the structure since there are no runnable lines
            %in the class;
            if length(callStrc) == 1
                continue;
            end
            callStrc = callStrc(2:end);
            runnableLineIndex(runnableLineIndex==1)=[];
        end
        
        runnableLines = linelist.*0;
        runnableLines(runnableLineIndex) = runnableLineIndex;

        for m = 1:length(callStrc)
            % Loop through the callStrc and see if any of the
            % functions/subfunctions match the profiled functions.
            profiledFcnName = callStrc(m).fullname;

            d(n).funlist(m).firstline = callStrc(m).firstline;
            d(n).funlist(m).name = profiledFcnName;
            % When the file is a private function, profiledFcnList
            % returns the complete path, not just the file name, and the
            % next line's strmatch fails.
            functionNameAsConstructor = [callStrc(m).name '.' callStrc(m).name '>' callStrc(m).name '.' callStrc(m).name];
            if strcmp(callStrc(m).fullname, functionNameAsConstructor)
                functionName = profiledFcnName;
            else
                functionName = [classNamePrefix,profiledFcnName];
            end
            ndx = strmatch(functionName, profiledFcnList(d(n).profInfoIndex), 'exact');
            
            startLine = callStrc(m).firstline;
            endLine = callStrc(m).lastline;

            % The linemask variable masks out all lines that are out of
            % the function's scope, i.e. nested functions.
            runnableLinesTemp = runnableLines .* callStrc(m).linemask;
            canRunList = find(linelist(startLine:endLine)==runnableLinesTemp(startLine:endLine));
            d(n).funlist(m).runnablelines = length(canRunList);

            if isempty(ndx)
                % We're in an uncalled subfunction of a called function
                d(n).funlist(m).coverage = 0;
                d(n).funlist(m).totaltime = 0;
                d(n).funlist(m).profindex = [];
            else
                % We're in a called subfunction of a called function
                % Now work out the coverage statistics for the
                % function/subfunction

                didRunList = profInfo.FunctionTable(d(n).profInfoIndex(ndx)).ExecutedLines(:,1);

                d(n).funlist(m).coverage = 100*length(didRunList)/length(canRunList);
                d(n).funlist(m).totaltime = profInfo.FunctionTable(d(n).profInfoIndex(ndx)).TotalTime;
                d(n).funlist(m).profindex = d(n).profInfoIndex(ndx);
            end
        end
        
        d(n).coverage = sum([d(n).funlist.coverage].*[d(n).funlist.runnablelines])/sum([d(n).funlist.runnablelines]);
        
    end
end
end

