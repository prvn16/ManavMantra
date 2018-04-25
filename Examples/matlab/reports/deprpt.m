function htmlOut = deprpt(name, option)
%DEPRPT  Audit a file or folder for dependencies
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   DEPRPT scans all MATLAB files in the current folder for dependencies.
%
%   DEPRPT(FILENAME) or DEPRPT(FILENAME,'file') scans the MATLAB file FILENAME
%   for dependencies.
%
%   DEPRPT(DIRNAME,'dir') scans the specified folder.
%
%   HTMLOUT = DEPRPT(...) returns the generated HTML text as a cell array.
%
%   See also PROFILE, MLINTRPT, HELPRPT, CONTENTSRPT, COVERAGERPT.

% Copyright 1984-2017 The MathWorks, Inc.

%#ok<*AGROW>

import com.mathworks.matlab.api.explorer.MatlabPlatformUtil;

%% Argument Checking
reportName = getString(message('MATLAB:codetools:reports:DependencyReportName'));

if nargout == 0
    internal.matlab.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    option = 'dir';
    name = cd;
end

if nargin == 1
    option = 'file';
end

if strcmp(option,'dir')
    dirname = name;
    fileList = internal.matlab.reports.matlabFiles(name, reportName); 
    %Tag on the directory path.
    if exist(name,'dir') == 7
        fileList = strcat(name,filesep,fileList);
    end
else
    fullname = which(name);
    if isempty(fullname)        
        internal.matlab.reports.webError(getString(message('MATLAB:codetools:reports:SpecificFileNotFound',name)), reportName);
        return
    end
    fileList = {fullname};   
end


%% Manage the preferences
localParentDisplayMode = getpref('dirtools', 'localParentDisplayMode', true);
allChildDisplayMode = getpref('dirtools', 'allChildDisplayMode', true);
depSubfunDisplayMode = getpref('dirtools', 'depSubfunDisplayMode', true);
tbMatlabDisplayMode = false;
builtinDisplayMode = false;
variableDisplayMode = false;

%% Collect all the calls info data
[childStrc, fcnHash] = internal.matlab.reports.parseDependencyInfo( fileList );


%% Make the Header
help = [getString(message('MATLAB:codetools:reports:DependencyReportDescription')) ' '];
docPage = 'matlab_env_dependency_rpt';
rerunAction = sprintf('deprpt(''%s'',''%s'')', name, option);
thisDirAction = 'deprpt';
% Now generate the HTML
s = internal.matlab.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

%% Make the form
% For now, show the checkbox form only in MATLAB desktop
% TODO: add the checkbox form back in MATLAB Online (g1564314) after the "Rerun This Report" and "Run Report on Current Folder" buttons are added back (g1564302)
if ~MatlabPlatformUtil.isMatlabOnline
    s{end+1} = '<form method="GET" action="matlab:internal.matlab.reports.handleForm">';
    s{end+1} = '<input type="hidden" name="reporttype" value="deprpt" />';
    checkOptions = {'','checked'};
    s{end+1} = sprintf(['<input type="checkbox" name="allChildDisplayMode" %s onChange="this.form.submit()" />', getString(message('MATLAB:codetools:reports:ShowChildFunctionsInReport'))], ...
        checkOptions{allChildDisplayMode+1});
    s{end+1} = sprintf(['<input type="checkbox" name="localParentDisplayMode" %s onChange="this.form.submit()" />', getString(message('MATLAB:codetools:reports:ShowParentFunctionsInReport')),'<br/>'], ...
        checkOptions{localParentDisplayMode+1});
    s{end+1} = sprintf(['<input type="checkbox" name="depSubfunDisplayMode" %s onChange="this.form.submit()" />', getString(message('MATLAB:codetools:reports:ShowSubFunctionsInReport'))], ...
        checkOptions{depSubfunDisplayMode+1});
    s{end+1} = '</form><p>';
end

s{end+1} = getString(message('MATLAB:codetools:reports:BuiltinFunctionsFilesNotShown'));

if strcmp(option,'dir')
    s{end+1} = [getString(message('MATLAB:codetools:reports:ReportForSpecificFolderStrong',dirname)) '<br/>'];
else
    s{end+1} = [getString(message('MATLAB:codetools:reports:ReportForSpecificFile',name)) '<br/>'];
    if localParentDisplayMode
        s{end+1} = ['<span style="color: #F00">', getString(message('MATLAB:codetools:reports:FunctionsCannotBeDisplayedInReport')), '</span><p>'];
        localParentDisplayMode = 0;
        setpref('dirtools','localParentDisplayMode',localParentDisplayMode);
    end
end

%% The Dependency Table
% The table has the following HTML structure:
% +----------------------------+----------+---------+
% | MATLAB files               | Children | Parents |
% +----------------------------+----------+---------+
% | filename:filename>fcnname  |
% 

%the table element
s{end+1} = '<table cellspacing="0" cellpadding="2" border="0" width="100%">';

%the table header
paddingRightStyle = 'style="padding-right:10px; border:none;"';
s{end+1} = ['<tr><td valign="bottom"', paddingRightStyle, '><strong>', getString(message('MATLAB:codetools:reports:MATLABFileList')) , '</strong></td>'];
if allChildDisplayMode
    s{end+1} = ['<td valign="bottom"', paddingRightStyle, '>', getString(message('MATLAB:codetools:reports:ChildrenCalledFunctions')), '</td>'];
end
if localParentDisplayMode
    s{end+1} = ['<td valign="bottom"', paddingRightStyle, '>', getString(message('MATLAB:codetools:reports:ParentsCallingFunctions')), '</td>'];
end
s{end+1} = '</tr>';

%Display all the results in the table rows
for fileIndex = 1:length(childStrc) %for each file
    thisFileStrc = childStrc{ fileIndex };
    filename = thisFileStrc.fullname;
    
    if depSubfunDisplayMode
        N = length(thisFileStrc.subs);
    else
        N = 1;
    end
    
    for subFunIndex = 1:N
        thisSubStrc = thisFileStrc.subs{subFunIndex};
        
        s{end+1} = '<tr>';  %make a new row
        
        %The file name column
        if (subFunIndex > 1)
            % This row represents a sub function within a top-level MATLAB file
            trClass = 'td-dashtop'; %gray background
        else
            % This row is for the script or top level function in the MATLAB file
            trClass = 'td-linetop';
        end
        % write out the | filename(> functionname) | + a link to open in the editor
        s{end+1} = sprintf('<td valign="top" class="%s">', trClass);
        s{end+1} = sprintf('<a class="mono" href="matlab: opentoline(''%s'',%d);">%s</a></td>', ...
            filename, thisSubStrc.line, thisSubStrc.fullname);
        
        %The Children column
        if allChildDisplayMode
            s = displaySubFunCalls( s, thisSubStrc, trClass, filename, ...
                tbMatlabDisplayMode, builtinDisplayMode, variableDisplayMode );
        end
        
        %The Parents column
        if localParentDisplayMode
            s = displayParentCalls( s, thisSubStrc, fcnHash, trClass);
        end
        
        s{end+1} = '</tr>'; %end row
    end
end

s{end+1} = '</table>';

%% End of the report
s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut], '-noaddressbox');
else
    htmlOut = s;
end

function s = displaySubFunCalls( s, subStrc, trClass, filename, tbMatlabDisplayMode, builtinDisplayMode, variableDisplayMode )
import codetools.reports.*;
%Display the called function information
s{end+1} = sprintf('<td valign="top" class="%sleft">', trClass);
currChildStrc = subStrc.calls;

if isempty(currChildStrc)
    s{end+1} = '&nbsp;</td>';
    return
end

import internal.matlab.reports.ReportConstants;
import com.mathworks.matlab.api.explorer.MatlabPlatformUtil;

for i = 1: length(currChildStrc)
    thisCallStrc = currChildStrc(i);
    callType = thisCallStrc.type;
    switch(callType)
        case ReportConstants.Unknown
            s{end+1} = typeColumn(callType, '#FFC0C0'); 
            s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d);">%s</a></span><br/>', ...
                filename, ...
                thisCallStrc.line, ...
                thisCallStrc.name);
        case ReportConstants.Error
            s{end+1} = typeColumn(callType, '#FFC0C0');
            s{end+1} = sprintf('%s<br/><span style="color: #F00">%s</span></span>', ...
                filename, ...
                thisCallStrc.name);
        otherwise %a toolbox or other that might have an overloaded method
            if (strcmp(callType, ReportConstants.MatlabToolbox) && ~tbMatlabDisplayMode) || ...
               (strcmp(callType, ReportConstants.Builtin) && ~builtinDisplayMode) || ...
               (strcmp(callType, ReportConstants.Variable) && ~variableDisplayMode)
                %skip certain types if they are not to be displayed.
                continue;
            end
            
            hasAlternatives = ~isempty(thisCallStrc.alternateMatches);
            s{end+1} = typeColumn(callType, '', ~hasAlternatives);
            
            %build a unique id for each called_fun
            [~, fname] = fileparts(thisCallStrc.name);
            span_id = strrep(strcat(subStrc.fullname, '_', fname),'\','_');
            
            if hasAlternatives
                % put an easy to scan for button in the gutter if there are
                % alternate possible methods
                s{end+1} = sprintf('<a href="javascript:void()" onclick="toggleexpander(''%s'');" class="expander">?</a> ',...
                    span_id);
                [~, justname] = fileparts(thisCallStrc.name);
                s{end+1} = sprintf([getString(message('MATLAB:codetools:reports:MultipleClassMethodsFound')), ' ', '<a href="matlab: opentoline(''%s'',%d);">%s.m</a>'], ...
                    filename, thisCallStrc.line, justname);
            else
                s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d);">%s</a>', ...
                    filename, ...
                    thisCallStrc.line, ...
                    thisCallStrc.name);
            end
            %if there are possible alternative matches for a function, let the user
            %know.
            if hasAlternatives
                spacer = repmat('&nbsp;',1,15);
                s{end+1} = sprintf('<div class="xtrainfo" style="display:none;background-color:#EEE;padding-top:1em;padding-bottom:1em;" id="%s">',span_id);
                % For now, only include the help link in MATLAB desktop
                % TODO: add help link in MATLAB Online (g1564303)
                if MatlabPlatformUtil.isMatlabOnline
                    s{end+1} = sprintf([spacer ...
                    '<u>' getString(message('MATLAB:codetools:reports:UnableToDetermineWhichFiles')) ' </u>']);
                else
                    s{end+1} = sprintf([spacer ...
                    '<u>' getString(message('MATLAB:codetools:reports:UnableToDetermineWhichFiles')) ' </u>: ' ...
                    '(<a href="matlab:helpview(%s,''%s'',''CSHelpWindow'')">Learn More</a>)' ],...
                    '[docroot ''/techdoc/env_csh/env_csh.map'']','desktop_dependency_report_classes');
                end
                s{end+1} = ['<br/>', spacer, thisCallStrc.name];
                for ow = 1:length(thisCallStrc.alternateMatches)
                    s{end+1} = ['<br/>',spacer, thisCallStrc.alternateMatches{ow}];
                end
                s{end+1 }= '</div>';
            end
            s{end+1} = '</span><br/>';
            
    end
    
end

s{end+1} = '&nbsp;</td>';

function s = typeColumn(type, color, showGutter)
if nargin < 3 || showGutter
    gutter = '&nbsp;&nbsp;'; %a 2-space gutter between the ":" and the filename
else
    gutter = '';
end
if ~isempty(color)
    style = sprintf('style="background: %s"',color); %color the row header
else
    style = '';
end
str = sprintf('%-20s', type);
str = strrep(str,' ','&nbsp;');
s =  sprintf('<span class="mono"><span %s>%s:</span>%s', style ,str, gutter);

function s = displayParentCalls(s, thisSubStrc, fcnHash, trClass)
% Displaying the parent callers
s{end+1} = sprintf('<td valign="top" class="%sleft">', trClass);

if any(ismember(fcnHash.keys, thisSubStrc.name))
    %function was called by another in the same dir
    x = fcnHash(thisSubStrc.name);
    s{end+1} = sprintf('<span class="mono">%s</span><br/>', ...
        x{:});
else
    s{end+1} = '&nbsp;';
end
s{end+1} = '</td>';
