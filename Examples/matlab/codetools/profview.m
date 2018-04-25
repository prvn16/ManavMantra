function htmlOut = profview(functionName, profInfo)
%PROFVIEW   Display HTML profiler interface
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   PROFVIEW(FUNCTIONNAME, PROFILEINFO)
%   FUNCTIONNAME can be either a name or an index number into the profile.
%   PROFILEINFO is the profile stats structure as returned by
%   PROFILEINFO = PROFILE('INFO').
%   If the FUNCTIONNAME argument passed in is zero, then profview displays
%   the profile summary page.
%
%   The output for PROFVIEW is an HTML file in the Profiler window. The
%   file listing at the bottom of the function profile page shows four
%   columns to the left of each line of code.
%   * Column 1 (red) is total time spent on the line in seconds.
%   * Column 2 (blue) is number of calls to that line.
%   * Column 3 is the line number
%
%   See also PROFILE.

%   Copyright 1984-2017 The MathWorks, Inc.


persistent profileInfo
% Three possibilities:
% 1) profile info wasn't passed and hasn't been created yet
% 2) profile info wasn't passed in but is persistent
% 3) profile info was passed in

import com.mathworks.mde.profiler.Profiler;

if (nargin < 2) || isempty(profInfo),
    if isempty(profileInfo),
        % 1) profile info wasn't passed and hasn't been created yet
        profile('viewer');
        return
    else
        % 2) profile info wasn't passed in but is persistent
        % No action. profileInfo was created in a previous call to this function
    end
else
    % 3) profile info was passed in
    profileInfo = profInfo;
    Profiler.stop;
end

if nargin < 1,
    % If there's no input argument, just provide the summary
    functionName = 0;
end

% Find the function in the supplied data structure
% functionName can be either a name or an index number
if ischar(functionName),
    functionNameList = {profileInfo.FunctionTable.FunctionName};
    idx = find(strcmp(functionNameList,functionName)==1);
    if isempty(idx)
        error(message('MATLAB:profiler:FunctionNotFound', functionName))
    end
else
    idx = functionName;
end

% Create all the HTML for the page
if idx==0
    s = makesummarypage(profileInfo);
else
    busyLineSortKey = getpref('profiler','busyLineSortKey','time');
    s = makefilepage(profileInfo,idx, busyLineSortKeyStr2Num(busyLineSortKey));
end

sOut = [s{:}];

if nargout==0
    setProfilerHtmlText(sOut);
else
    htmlOut = sOut;
end


function s = makesummarypage(profileInfo)
% --------------------------------------------------
% Show the main summary page
% --------------------------------------------------

% pixel gif location
pixelPath = makePixelPath();
cyanPixelGif = [pixelPath 'one-pixel-cyan.gif'];
bluePixelGif = [pixelPath 'one-pixel.gif'];

% Read in preferences
sortMode = getpref('profiler','sortMode','totaltime');

allTimes = [profileInfo.FunctionTable.TotalTime];
maxTime = max(allTimes);

% check if there is any memory data in the profile info
hasMem = hasMemoryData(profileInfo);

% Calculate self time and optionally self memory and self performance counter list
allSelfTimes = zeros(size(allTimes));
if hasMem
    allSelfMem = zeros(size(allTimes));
end
for i = 1:length(profileInfo.FunctionTable)
    allSelfTimes(i) = profileInfo.FunctionTable(i).TotalTime - ...
        sum([profileInfo.FunctionTable(i).Children.TotalTime]);
    if hasMem
        netMem = (profileInfo.FunctionTable(i).TotalMemAllocated - ...
            profileInfo.FunctionTable(i).TotalMemFreed);
        childNetMem = (sum([profileInfo.FunctionTable(i).Children.TotalMemAllocated]) - ...
            sum([profileInfo.FunctionTable(i).Children.TotalMemFreed]));
        allSelfMem(i) = netMem - childNetMem;
    end    
end

totalTimeFontWeight = 'normal';
selfTimeFontWeight = 'normal';
alphaFontWeight = 'normal';
numCallsFontWeight = 'normal';
allocMemFontWeight = 'normal';
freeMemFontWeight = 'normal';
peakMemFontWeight = 'normal';
selfMemFontWeight = 'normal';

% if the sort mode is set to a memory field but we don't have
% any memory data, we need to switch back to time.
if ~hasMem && (strcmp(sortMode, 'allocmem') || ...
        strcmp(sortMode, 'freedmem') || ...
        strcmp(sortMode, 'peakmem')  || ...
        strcmp(sortMode, 'selfmem'))
    sortMode = 'totaltime';
end

if strcmp(sortMode,'totaltime')
    totalTimeFontWeight = 'bold';
    [~,sortIndex] = sort(allTimes,'descend');
elseif strcmp(sortMode,'selftime')
    selfTimeFontWeight = 'bold';
    [~,sortIndex] = sort(allSelfTimes,'descend');
elseif strcmp(sortMode,'alpha')
    alphaFontWeight = 'bold';
    allFunctionNames = {profileInfo.FunctionTable.FunctionName};
    [~,sortIndex] = sort(allFunctionNames);
elseif strcmp(sortMode,'numcalls')
    numCallsFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.NumCalls],'descend');
elseif strcmp(sortMode,'allocmem')
    allocMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemAllocated],'descend');
elseif strcmp(sortMode,'freedmem')
    freeMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemFreed],'descend');
elseif strcmp(sortMode,'peakmem')
    peakMemFontWeight = 'bold';
    [~,sortIndex] = sort([profileInfo.FunctionTable.PeakMem],'descend');
elseif strcmp(sortMode,'selfmem')
    selfMemFontWeight = 'bold';
    [~,sortIndex] = sort(allSelfMem,'descend');
else
    error(message('MATLAB:profiler:BadSortMode', sortMode));
end

s = {}; %#ok<*AGROW>
%Make the text of profiler header
s{end+1} = makeprofilerheader();

% Summary info
status = profile('status');
s{end+1} = ['<span style="font-size: 14pt; background: #FFE4B0">', getString(message('MATLAB:profiler:ProfileSummaryName')), '</span><br/>'];
s{end+1} = ['<i>', getString(message('MATLAB:profiler:GeneratedUsing', datestr(now), status.Timer)), '</i><br/>'];

if isempty(profileInfo.FunctionTable)
    s{end+1} = ['<p><span style="color:#F00">', getString(message('MATLAB:profiler:NoProfileInfo')), '</span><br/>'];
    s{end+1} = [getString(message('MATLAB:profiler:NoteAboutBuiltins')), '<p>'];
end

s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
s{end+1} = '<tr>';
s{end+1} = generateTableElementLink('alpha', alphaFontWeight, 'MATLAB:profiler:FunctionNameTableElement');
s{end+1} = '</td>';
s{end+1} = generateTableElementLink('numcalls', numCallsFontWeight, 'MATLAB:profiler:CallsTableElement');
s{end+1} = '</td>';
s{end+1} = generateTableElementLink('totaltime', totalTimeFontWeight, 'MATLAB:profiler:TotalTimeTableElement');
s{end+1} = '</td>';
s{end+1} = generateTableElementLink('selftime', selfTimeFontWeight, 'MATLAB:profiler:SelfTimeTableElement');
s{end+1} = '*</td>';

% Add column headings for memory data.
if hasMem
    s{end+1} = generateTableElementLink('allocmem', allocMemFontWeight, 'MATLAB:profiler:AllocatedMemoryTableElement');
    s{end+1} = '</td>';
    
    s{end+1} = generateTableElementLink('freedmem', freeMemFontWeight, 'MATLAB:profiler:FreedMemoryTableElement');
    s{end+1} = '</td>';
    
    s{end+1} = generateTableElementLink('selfmem', selfMemFontWeight, 'MATLAB:profiler:SelfMemoryTableElement');
    s{end+1} = '</td>';

    s{end+1} = generateTableElementLink('peakmem', peakMemFontWeight, 'MATLAB:profiler:PeakMemoryTableElement');
    s{end+1} = '</td>';
    
end

s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0" valign="top">', getString(message('MATLAB:profiler:TotalTimePlotTableElement')), '<br/>'];
s{end+1} = [getString(message('MATLAB:profiler:DarkBandSelfTime')), '</td>'];
s{end+1} = '</tr>';

for i = 1:length(profileInfo.FunctionTable),
    n = sortIndex(i);
    
    name = profileInfo.FunctionTable(n).FunctionName;
    
    s{end+1} = '<tr>';
    
    % Truncate the name if it gets too long
    displayFunctionName = truncateDisplayName(name, 40);
    s{end+1} = '<td class="td-linebottomrt">';
    s{end+1} = printfProfilerLink('profview(%d);', '%s', n, displayFunctionName);
    
    if isempty(regexp(profileInfo.FunctionTable(n).Type,'^M-','once'))
        s{end+1} = sprintf(' (%s)</td>', ...
            typeToDisplayValue(profileInfo.FunctionTable(n).Type));
    else
        s{end+1} = '</td>';
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
        profileInfo.FunctionTable(n).NumCalls);
    
    
    % Don't display the time if it's zero
    if profileInfo.FunctionTable(n).TotalTime > 0,
        s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>', ...
            profileInfo.FunctionTable(n).TotalTime);
    else
        s{end+1} = '<td class="td-linebottomrt">0 s</td>';
    end
    
    if maxTime > 0,
        timeRatio = profileInfo.FunctionTable(n).TotalTime/maxTime;
        selfTime = profileInfo.FunctionTable(n).TotalTime - sum([profileInfo.FunctionTable(n).Children.TotalTime]);
        selfTimeRatio = selfTime/maxTime;
    else
        timeRatio = 0;
        selfTime = 0;
        selfTimeRatio = 0;
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',selfTime);
    
    % Add column data for memory
    if hasMem
        % display alloc, freed, self and peak mem on summary page
        totalAlloc = profileInfo.FunctionTable(n).TotalMemAllocated;
        totalFreed = profileInfo.FunctionTable(n).TotalMemFreed;
        netMem = totalAlloc - totalFreed;
        childAlloc = sum([profileInfo.FunctionTable(n).Children.TotalMemAllocated]);
        childFreed = sum([profileInfo.FunctionTable(n).Children.TotalMemFreed]);
        childMem = childAlloc - childFreed;
        selfMem = netMem - childMem;
        peakMem = profileInfo.FunctionTable(n).PeakMem;
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalAlloc));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalFreed));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,selfMem));
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,peakMem));
    end
    
    s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10><img src="%s" width=%d height=10></td>', ...
        bluePixelGif, round(100*selfTimeRatio), ...
        cyanPixelGif, round(100*(timeRatio-selfTimeRatio)));
    
    s{end+1} = '</tr>';
end
s{end+1} = '</table>';

if profileInfo.Overhead==0
    s{end+1} = sprintf(['<p><a name="selftimedef"></a>', getString(message('MATLAB:profiler:SelfTime1st')) ' ']);
else
    s{end+1} = sprintf(['<p><a name="selftimedef"></a>', getString(message('MATLAB:profiler:SelfTime2nd', profileInfo.Overhead))]);
end
%Make the footer text of profiler
s{end+1} = makeprofilerfooter;



% --------------------------------------------------
% Show the function details page
% --------------------------------------------------
function s = makefilepage(profileInfo,idx,key_data_field)
% profileInfo - the profiling data structure from callstats
% idx - index of the function to generate details for
% key_data_field - an integer representing which type of
%                  collected data to sort the details by.
%                  this controls what lines are displayed
%                  as the top 5 busy lines.
%   1 - sort by time
%   2 - sort by allocated memory
%   3 - sort by freed memory
%   4 - sort by peak memory

ftItem = profileInfo.FunctionTable(idx);
hasMem = hasMemoryData(ftItem);

% Select the column order and unit strings depending on the
% sort type.
%
% The field_order controls how the columns of time and memory
% are laid out left to right.  Each entry in the field order
% vector corresponds to the key_data_field for that item.
% The first entry in the field order is always the item we are
% currently sorting on.
%
% The key_unit and key_unit_up variables are used to parameterize
% the values of some strings depending on what we a
%
if ~hasMem 
    % if we have no memory, default to time
    key_data_field = 1;
    field_order = 1;
    key_unit = 'time';
    key_unit_up = getString(message('MATLAB:profiler:Time1'));
else
    num_fields = 1;
    if hasMem
        num_fields = num_fields + 3;
    end
    field_order = 1:num_fields;
    if key_data_field == 1
        key_unit = 'time';
        key_unit_up = getString(message('MATLAB:profiler:Time1'));
    elseif hasMem && key_data_field <= 4
        % if we have memory data, reorder the first 4 fields
        % keeping the memory data grouped together.
        switch(key_data_field)
            case 2
                field_order(1:4) = [2 3 4 1];
                key_unit = 'allocated memory';
                key_unit_up = getString(message('MATLAB:profiler:AllocatedMemoryTableElement'));
            case 3
                field_order(1:4) = [3 4 2 1];
                key_unit = 'freed memory';
                key_unit_up = getString(message('MATLAB:profiler:FreedMemoryTableElement'));
            case 4
                field_order(1:4) = [4 2 3 1];
                key_unit = 'peak memory';
                key_unit_up = getString(message('MATLAB:profiler:PeakMemoryTableElement'));
        end
    else
        error(message('MATLAB:profiler:BadSortKey', key_data_field));
    end
end

pixelPath= makePixelPath();
bluePixelGif = [pixelPath 'one-pixel.gif'];

% totalData holds all the totals for each type of data (time & memory)
% for the current function.  It is indexed by key_data_field or entries
% in field_order.
totalData(1) = ftItem.TotalTime;
if hasMem
    totalData(2) = ftItem.TotalMemAllocated;
    totalData(3) = ftItem.TotalMemFreed;
    totalData(4) = ftItem.PeakMem;
end

% Build up function name target list from the children table
targetHash = [];
for n = 1:length(ftItem.Children)
    targetName = profileInfo.FunctionTable(ftItem.Children(n).Index).FunctionName;
    % Don't link to Opaque-functions with dots in the name
    if ~any(targetName=='.') && ~any(targetName=='@')
        % Build a hashtable for the target strings
        % Ensure that targetName is a legal MATLAB identifier.
        targetName = regexprep(targetName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
        if ~isempty(targetName) && targetName(1) ~= '_'
            targetHash.(targetName) = ftItem.Children(n).Index;
        end
    end
end

% MATLAB code files are the only files we can list.
mFileFlag = 1;
pFileFlag = 0;
filteredFileFlag = false;
if (isempty(regexp(ftItem.Type,'^(M-|Coder|generated)','once')) || ...
        strcmp(ftItem.Type,'M-anonymous-function') || ...
        isempty(ftItem.FileName))
    mFileFlag = 0;
else
    % Make sure it's not a P-file
    if ~isempty(regexp(ftItem.FileName,'\.p$','once'))
        pFileFlag = 1;
        pFullName = ftItem.FileName;
        
        % Replace ".p" string with ".m" string.
        fullName = regexprep(ftItem.FileName,'\.p$','.m');
        
        %g1004325 - if the m file is newer than the p file we know it is
        %out of sync, treat it as if the m file isn't there.
        mTimeDir = dir(fullName);
        pTimeDir = dir(pFullName);
        
        % Check if mfile doesn't exist or mfile is newer than the pfile 
        % (out of sync), then treat it as if the m file isn't there.
        if isempty(mTimeDir) || mTimeDir.datenum > pTimeDir.datenum
            mFileFlag = 0;
        end
    else
        fullName = ftItem.FileName;
    end
    % g894021 - Make sure the MATLAB code file still exists
    if ~exist(fullName, 'file')
        mFileFlag = 0;
    end
end

badListingDisplayMode = false;
if mFileFlag
    f = getmcode(fullName);
    
    if isempty(ftItem.ExecutedLines) && ftItem.NumCalls > 0
        % If the executed lines array is empty but the number of calls
        % is not 0 then the body of this function must have been filtered
        % for some reason.  We do not want to display the MATLAB code in this
        % case.
        f = [];
        filteredFileFlag = true;
    elseif length(f) < ftItem.ExecutedLines(end,1)
        % This is a simple (non-comprehensive) test to see if the file has been
        % altered since it was profiled. The variable f contains every line of
        % the file, and ExecutedLines points to those line numbers. If
        % ExecutedLines points to lines outside that range, something is wrong.
        badListingDisplayMode = true;
    end
elseif ~pFileFlag   
    %g1229814 Having a pfile is not a badListingDisplayMode scenario 
    %because we do have code we can run.  We only want 
    %badListingDisplayMode to be true here if there was no code to 
    %actually run.
    %g894021 - If the mFileFlag is false than the file does not exist, set the
    %badListing flag.
    badListingDisplayMode = true;
end

s = {};
s{1} = makeprofilerheader();
s{end+1} = ['<title>' getString(message('MATLAB:profiler:FunctionDetailsFor', escapeHtml(ftItem.FunctionName))) '</title>'];
cssfile = which('matlab-report-styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';
s{end+1} = '<body>';

% Summary info
displayName = escapeHtml(ftItem.FunctionName);
s{end+1} = sprintf('<span style="font-size:14pt; background:#FFE4B0">%s', ...
    displayName);

callStr = getString(message('MATLAB:profiler:CallsTimeTitle', ...
                                sprintf('%d', ftItem.NumCalls), ...
                                sprintf('%4.3f s', totalData(1))));
status = profile('status');

% set up column data for the summary
str = sprintf(' (%s', callStr);

if hasMem
    str = [str sprintf(', %s, %s, %s', formatData(2,totalData(2)), ...
        formatData(2,totalData(3)), ...
        formatData(2,totalData(4)))];
end

str = [str ')</span><br/>'];
s{end+1} = str;
s{end+1} = ['<i>', getString(message('MATLAB:profiler:GeneratedUsing', datestr(now), status.Timer)), '</i><br/>'];

if mFileFlag
    s{end+1} = [getString(message('MATLAB:profiler:InFile', typeToDisplayValue(ftItem.Type))) ' ' printfProfilerLink('edit(urldecode(''%s''))', '%s', urlencode(fullName), fullName)];
    s{end+1} ='<br/>';
elseif isequal(ftItem.Type,'M-subfunction')
    s{end+1} =  [getString(message('MATLAB:profiler:AnonymousFunction')), '<br/>'];
else
    s{end+1} = [getString(message('MATLAB:profiler:InFile1', typeToDisplayValue(ftItem.Type), ftItem.FileName)) '<br/>'];
end

s{end+1} = printfProfilerLink('stripanchors', getString(message('MATLAB:profiler:CopyToNewWindow')));

if pFileFlag && ~mFileFlag
    s{end+1} =['<p><span class="warning">', getString(message('MATLAB:profiler:PFileWithNoMATLABCode')), '</span></p>'];
end

didChange = callstats('has_changed',ftItem.CompleteName);
if didChange
    s{end+1} = ['<p><span class="warning">', getString(message('MATLAB:profiler:FileChangedDuringProfiling1')), '</span></p>'];
end

s{end+1} = '<div class="grayline"/>';


% --------------------------------------------------
% Manage all the checkboxes
% Read in preferences
parentDisplayMode = getpref('profiler','parentDisplayMode',1);
busylineDisplayMode = getpref('profiler','busylineDisplayMode',1);
childrenDisplayMode = getpref('profiler','childrenDisplayMode',1);
mlintDisplayMode = getpref('profiler','mlintDisplayMode',1);
coverageDisplayMode = getpref('profiler','coverageDisplayMode',1);
listingDisplayMode = getpref('profiler','listingDisplayMode',1);

% disable the source listing if the file has changed in a major way
oldListingDisplayMode = listingDisplayMode;
if badListingDisplayMode
    listingDisplayMode = false;
end

s{end+1} = '<form method="GET" action="matlab:profviewgateway">';
s{end+1} = printProfilerRefreshButton();
s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);

s{end+1} = '<table>';
s{end+1} = '<tr><td>';


checkOptions = {'','checked'};

s{end+1} = sprintf('<input type="checkbox" name="parentDisplayMode" %s />', ...
    checkOptions{parentDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowParentFunctions')), '</td><td>'];

s{end+1} = sprintf('<input type="checkbox" name="busylineDisplayMode" %s />', ...
    checkOptions{busylineDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowBusyLines')), '</td><td>'];

s{end+1} = sprintf('<input type="checkbox" name="childrenDisplayMode" %s />', ...
    checkOptions{childrenDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowChildFunctions')), '</td></tr><tr><td>'];

s{end+1} = sprintf('<input type="checkbox" name="mlintDisplayMode" %s />', ...
    checkOptions{mlintDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowCodeAnalyzerResults')), '</td><td>'];

s{end+1} = sprintf('<input type="checkbox" name="coverageDisplayMode" %s />', ...
    checkOptions{coverageDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowFileCoverage')), '</td><td>'];

s{end+1} = sprintf('<input type="checkbox" name="listingDisplayMode" %s />', ...
    checkOptions{listingDisplayMode+1});
s{end+1} = [getString(message('MATLAB:profiler:ShowFunctionListing')), '</td>'];

s{end+1} = '</tr></table>';

s{end+1} = '</form>';

if hasMem
    %
    % if we have more than just time data, insert a callback tied to a pulldown
    % menu which allows the user to select between data sorting methods
    % todo this menu needs to be moved somewhere nicer

    s{end+1} = '<form method="GET" action="matlab:profviewgateway">';
    s{end+1} = [getString(message('MATLAB:profiler:SortBusyLines')) ' '];
    s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
    s{end+1} = '<select name="busyLineSortKey" onChange="this.form.submit()">';
    optionsList = { };
    optionsList{end+1} = 'time';
    if hasMem
        optionsList{end+1} = 'allocated memory';
        optionsList{end+1} = 'freed memory';
        optionsList{end+1} = 'peak memory';
    end
    for n = 1:length(optionsList)
        if strcmp(busyLineSortKeyNum2Str(key_data_field), optionsList{n})
            selectStr = 'selected'; %g1269807 Do not translate, as this is a non-visible HTML attribute
        else
            selectStr = '';
        end
        s{end+1} = sprintf('<option %s>%s</option>', selectStr, optionsList{n});
    end
    s{end+1} = '</select>';
    s{end+1} = '</form>';
end

s{end+1} = '<div class="grayline"/>';
% --------------------------------------------------


% --------------------------------------------------
% Parent list
% --------------------------------------------------
if parentDisplayMode
    parents = ftItem.Parents;
    
    s{end+1} = [getString(message('MATLAB:profiler:Parents')), '<br/>'];
    if isempty(parents)
        s{end+1} = [' ' getString(message('MATLAB:profiler:NoParent')) ' '];
    else
        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:FunctionNameTableElement')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:FunctionType')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CallsTableElement')), '</td>'];
        s{end+1} = '</tr>';
        
        for n = 1:length(parents),
            s{end+1} = '<tr>';
            
            displayName = truncateDisplayName(profileInfo.FunctionTable(parents(n).Index).FunctionName,40);
            s{end+1} = '<td class="td-linebottomrt">';
            s{end+1} = printfProfilerLink('profview(%d);', '%s',  parents(n).Index, displayName);
            s{end+1} = '</td>';
            
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                typeToDisplayValue(profileInfo.FunctionTable(parents(n).Index).Type));
            
            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                parents(n).NumCalls);
            
            s{end+1} = '</tr>';
        end
        s{end+1} = '</table>';
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End parent list section
% --------------------------------------------------

% --------------------------------------------------
% Busy line list section
% --------------------------------------------------

% the index into ExecutedLines is always key_data_field + 2
% (i.e. 3 is time, 4 is allocated memory, 5 is freed memory, 6 is peak)
ln_index = key_data_field + 2;

% sort the data by the selected data kind.
[sortedDataList(:,key_data_field), sortedDataIndex] = sort(ftItem.ExecutedLines(:,ln_index));
sortedDataList = flipud(sortedDataList);

maxDataLineList = flipud(ftItem.ExecutedLines(sortedDataIndex,1));
maxDataLineList = maxDataLineList(1:min(5,length(maxDataLineList)));
maxNumCalls = max(ftItem.ExecutedLines(:,2));
dataSortedNumCallsList = flipud(ftItem.ExecutedLines(sortedDataIndex,2));

% sort all the rest of the line data based on the indices of the original
% sort.
for i=1:length(field_order)
    fi = field_order(i);
    if fi == key_data_field, continue; end
    sortedDataList(:,fi) = flipud(ftItem.ExecutedLines(sortedDataIndex,fi+2));
end

% Link directly to the busiest lines
% ----------------------------------------------

% set formats for each column (format is 1 for time, 2 for mem and 3 for other)
fmt = ones(1,length(field_order));

% The column names
data_fields = {getString(message('MATLAB:profiler:TotalTimeTableElement'))};

% memory column names
if hasMem
    fmt(2:4) = 2;
    data_fields = [ data_fields getString(message('MATLAB:profiler:AllocatedMemoryTableElement')) getString(message('MATLAB:profiler:FreedMemoryTableElement')) getString(message('MATLAB:profiler:PeakMemoryTableElement')) ];
end

if busylineDisplayMode
    s{end+1} = ['<strong>', getString(message('MATLAB:profiler:LinesSpent', lower(key_unit_up))), '</strong><br/> '];
    
    if ~mFileFlag || filteredFileFlag
        s{end+1} = getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
    else
        if totalData(key_data_field) == 0
            s{end+1} = getString(message('MATLAB:profiler:NoMeasurableSpentInThisFunction', lower(key_unit_up)));
        end
        
        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';
        
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">',  getString(message('MATLAB:profiler:LineNumber')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:Code')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CallsTableElement')), '</td>'];
        
        % output the column names in the right order
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">' data_fields{fidx} '</td>'];
        end
        
        % the percentage and histogram bar always come last.
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">% ' key_unit_up '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">' key_unit_up ' ' getString(message('MATLAB:profiler:Plot')), '</td>'];
        s{end+1} = '</tr>';
        
        for n = 1:length(maxDataLineList),
            s{end+1} = '<tr>';
            if listingDisplayMode
                s{end+1} = sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>', ...
                    maxDataLineList(n),maxDataLineList(n));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                    maxDataLineList(n));
            end
            
            if maxDataLineList(n) > length(f)   % insurance
                codeLine = '';                    % file must have changed
            else
                codeLine = f{maxDataLineList(n)};
            end
            
            % Squeeze out the leading spaces
            codeLine(cumsum(1-isspace(codeLine))==0)=[];
            % Replace angle brackets
            codeLine = code2html(codeLine);
            
            maxLineLen = 30;
            if length(codeLine) > maxLineLen
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s...</pre></td>',codeLine(1:maxLineLen));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s</pre></td>',codeLine);
            end
            
            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>',dataSortedNumCallsList(n));
            
            % output each column of data in the proper order
            for fi=1:length(field_order)
                fidx = field_order(fi);
                t = sortedDataList(n,fidx);
                s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', formatData(fmt(fidx),t));
            end
            
            % output the percentage based on the key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt" class="td-linebottomrt">%s</td>',...
                formatNicePercent(sortedDataList(n,key_data_field), totalData(key_data_field)));
            
            if totalData(key_data_field) > 0
                dataRatio = sortedDataList(n,key_data_field)/totalData(key_data_field);
            else
                dataRatio = 0;
            end
            
            % generate histogram bar based on the key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
                bluePixelGif, round(100*dataRatio));
            s{end+1} = '</tr>';
            
        end
        
        % Now add a row for everything else
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt">', getString(message('MATLAB:profiler:AllOtherLines')), '</td>'];
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        
        % compute totals for remaining time & memory
        for fi=1:length(field_order)
            fidx = field_order(fi);
            if ~hasMem || fidx ~= 4
                % this doesn't work for peaks
                allOtherLineData(fidx) = totalData(fidx) - sum(sortedDataList(1:length(maxDataLineList), fidx));
            else
                % peak memory needs max.
                allOtherLineData(fidx) = max(sortedDataList(1:length(maxDataLineList), fidx));
            end
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx), allOtherLineData(fidx)));
        end
        
        % output percentage of "all other lines" by key sort type.
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(allOtherLineData(key_data_field),totalData(key_data_field)));
        
        if totalData(key_data_field) > 0,
            dataRatio = allOtherLineData(key_data_field)/totalData(key_data_field);
        else
            dataRatio= 0;
        end
        
        % generate histogram bar for "all other lines" by key sort type.
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*dataRatio));
        s{end+1} = '</tr>';
        
        % Totals line
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:Totals')), '</td>'];
        s{end+1} = '<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';
        
        % output totals for each column
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = sprintf('<td class="td-linebottomrt" style="background-color:#F0F0F0">%s</td>',formatData(fmt(fidx),totalData(fidx)));
        end
        if totalData(key_data_field) > 0,
            s{end+1} = '<td class="td-linebottomrt" style="background-color:#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" style="background-color:#F0F0F0">0%</td>';
        end
        
        % no histogram bar here
        s{end+1} = '<td class="td-linebottomrt" style="background-color:#F0F0F0">&nbsp;</td>';
        
        s{end+1} = '</tr>';
        
        s{end+1} = '</table>';
    end
    s{end+1} = '<div class="grayline"/>';
    
end
% --------------------------------------------------
% End line list section
% --------------------------------------------------


% --------------------------------------------------
% Children list
% --------------------------------------------------
if childrenDisplayMode
    % Sort children by key data field (i.e. time, allocated mem, freed mem or peak mem)
    
    children = ftItem.Children;
    s{end+1} = [getString(message('MATLAB:profiler:Children')), '<br/>'];
    
    if isempty(children)
        s{end+1} = getString(message('MATLAB:profiler:NoChildren'));
    else
        % Children are sorted by the current key
        childrenData(:,1)   = [ftItem.Children.TotalTime];
        if hasMem
            childrenData(:,2) = [ftItem.Children.TotalMemAllocated];
            childrenData(:,3) = [ftItem.Children.TotalMemFreed];
            childrenData(:,4) = [ftItem.Children.PeakMem];
        end
        [~, dataSortIndex] = sort(childrenData(:,key_data_field));
        
        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">', getString(message('MATLAB:profiler:FunctionNameTableElement')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">', getString(message('MATLAB:profiler:FunctionType')), '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">', getString(message('MATLAB:profiler:CallsTableElement')), '</td>'];
        
        % output column headers for children
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' data_fields{fidx} '</td>'];
        end
        
        % percentage and histogram always go last
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">% ' key_unit_up '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' key_unit_up ' ' getString(message('MATLAB:profiler:Plot')) '</td>'];
        s{end+1} = '</tr>';
        
        for i = length(children):-1:1,
            n = dataSortIndex(i);
            s{end+1} = '<tr>';
            
            % Truncate the name if it gets too long
            displayFunctionName = truncateDisplayName(profileInfo.FunctionTable(children(n).Index).FunctionName,40);
            
            s{end+1} = '<td class="td-linebottomrt">';
            s{end+1} = printfProfilerLink('profview(%d);', '%s', children(n).Index, displayFunctionName);
            s{end+1} = '</td>';
            
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                typeToDisplayValue(profileInfo.FunctionTable(children(n).Index).Type));
            
            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                children(n).NumCalls);
            
            % output data for each column in the correct order
            for fi=1:length(field_order)
                fidx = field_order(fi);
                t = childrenData(n,fidx);
                s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', formatData(fmt(fidx),t));
            end
            
            % output percentage based on key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                formatNicePercent(childrenData(n,key_data_field), totalData(key_data_field)));
            
            if totalData(key_data_field) > 0,
                dataRatio = childrenData(n,key_data_field)/totalData(key_data_field);
            else
                dataRatio= 0;
            end
            
            % generate histogram based on key sort type
            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
                bluePixelGif, round(100*dataRatio));
            s{end+1} = '</tr>';
        end
        
        % Now add a row with self-timing information
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt">', getString(message('MATLAB:profiler:SelfBuiltIns', lower(key_unit_up))), '</td>'];
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        
        % output self information for each type of data (time, memory)
        for fi=1:length(field_order)
            fidx = field_order(fi);
            if fidx ~= 4
                % not for peak
                selfData(fidx) = totalData(fidx) - sum(childrenData(:,fidx));
            else
                % peaks need something different.  (is this meaningless?)
                selfData(fidx) = totalData(fidx);
            end
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(fmt(fidx),selfData(fidx)));
        end
        
        % output percentage
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(selfData(key_data_field),totalData(key_data_field)));
        
        if totalData(key_data_field) > 0,
            dataRatio = selfData(key_data_field)/totalData(key_data_field);
        else
            dataRatio= 0;
        end
        
        % generate histogram
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*dataRatio));
        s{end+1} = '</tr>';
        
        % Totals row
        s{end+1} = '<tr>';
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' getString(message('MATLAB:profiler:Totals')) '</td>'];
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        
        % output totals for each kind of data
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%s</td>',formatData(fmt(fidx),totalData(fidx)));
        end
        
        % percentage is always 100% or 0%
        if totalData(key_data_field) > 0,
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
        end
        
        % no histogram for totals
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        
        s{end+1} = '</tr>';
        
        s{end+1} = '</table>';
    end
    
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End children list section
% --------------------------------------------------


if mFileFlag && ~filteredFileFlag
    % Calculate beginning and ending lines for the current function
    
    % In the expression ftok = xmtok(f), ftok returns information
    % about line continuations.
    
    ftok = xmtok(f);
    try
        runnableLineIndex = callstats('file_lines',ftItem.FileName);
    catch e
        warning(message('MATLAB:profiler:NoCoverageInfo', ftItem.FileName, e.message));
        runnableLineIndex= [];
    end
    runnableLines = zeros(size(f));
    runnableLines(runnableLineIndex) = runnableLineIndex;
    
    % getmcode and callstats don't necessarily agree on line counting
    % (particularly when analyzing a p-coded file).  Force consistency
    % of the array dimensions to prevent error (g462077).
    if length(runnableLines) > length(f)
        runnableLines = runnableLines(1:length(f));
    end
    
    % FunctionName takes one of several forms:
    % 1. foo
    % 2. foo>bar
    % 3. foo1\private\foo2
    % 4. foo1/private/foo2>bar
    %
    % We need to strip off everything except for the very last \w+ string
    %
    % Except in the case of set.foo and get.foo when it is a property
    % accessor method (g1310129). In these cases we need to match the whole
    % set.foo and get.foo 
    %
    % The regex below matches the very last \w+ string in the second
    % capture group and any directly preceding 'get.' or 'set.' in the first
    % group.
    % Example of regex matches:
    % Input: 'foo1\private\foo2'
    % Output: {'','foo2'}
    %
    % Input: 'foo1\private\set.Foo2'
    % Output: {'set.','foo2'}
    
    fNameMatches = regexp(ftItem.FunctionName,'((set|get)\.)?(\w+)$','tokens','once');
    fname = fNameMatches{2};
    
    strc = getcallinfo(fullName,'-v7.8');
    fcnList = {strc.name};
    fcnIdx = find(strcmp(fcnList,fname)==1);
    
    % If no match was found for the current function name, BUT the function
    % was preceded by a 'set.' or 'get.' then we append those and try
    % again.
    if isempty(fcnIdx) && ~isempty(fNameMatches{1})
   
        % Class property setters and getters are named set.Prop and
        % get.Prop. We need to check for this as well.
        possibleFullName = [fNameMatches{1} fNameMatches{2}];
        fcnIdx = find(strcmp(fcnList,possibleFullName)==1);
        
        %If we find a match, then set that as the new function name.
        %Otherwise, the fcnIndex will be empty and we will assume it is an
        %anonymous function below.
        if ~isempty(fcnIdx)
            fname = possibleFullName;
        end
    end
      
    if length(fcnIdx) > 1
        % In rare situations, two nested functions can have exactly the
        % same name twice in the same file. In these situations, I will
        % default to the first occurrence.
        fcnIdx = fcnIdx(1);
        warning(message('MATLAB:profiler:FunctionAppearsMoreThanOnce', fname));
    end
    
    if isempty(fcnIdx)
        % ANONYMOUS FUNCTIONS
        % If we can't find the function name on the list of functions
        % and subfunctions, assume this is an anonymous
        % function. Just display the entire file in this case.
        startLine = 1;
        endLine = length(f);
        lineMask = ones(length(f),1);
    else
        startLine = strc(fcnIdx).firstline;
        endLine = strc(fcnIdx).lastline;
        lineMask = strc(fcnIdx).linemask;
    end
    
    runnableLines = runnableLines .* lineMask;
    
    moreSubfunctionsInFileFlag = 0;
    if endLine < length(f)
        moreSubfunctionsInFileFlag = 1;
    end
    
    % hiliteOption = [ time | numcalls | coverage | noncoverage | allocmem | freedmem | peakmem | none ]
    
    % getpref doesn't like spaces in the option names. is there a way around this?
    hiliteOption = getpref('profiler','hiliteOption',key_unit);
    
    % if we have no memory data but the current hiliteOption is
    % memory related, we must default back to the current type
    % we are sorting by (i.e. memory).
    if ~hasMem && (strcmp(hiliteOption, 'allocated memory') || ...
            strcmp(hiliteOption, 'freed memory') || ...
            strcmp(hiliteOption, 'peak memory'))
        hiliteOption = key_unit;
    end
    
    mlintstrc = [];
    if strcmp(hiliteOption,'mlint') || mlintDisplayMode
        mlintstrc = mlint(fullName,'-struct');
        
        % Sometimes the number of lines reported for a single mlint message
        % is greater than one. When this is true, we will split the single
        % message into two similar messages, each with its own line number.
        sortFlag = false;
        for i = 1:length(mlintstrc)
            if length(mlintstrc(i).line)>1
                mlintLineList = mlintstrc(i).line;
                % The original mlint message gets one of the line numbers.
                % Deal the rest of the messages out to new messages at the
                % end of the structure.
                sortFlag = true;
                mlintstrc(i).line = mlintLineList(1);
                for j = 2:length(mlintLineList)
                    mlintstrc(end+1) = mlintstrc(i);
                    mlintstrc(end).line = mlintLineList(j);
                end
            end
        end
        
        % Only sort the mlint structure if multiple lines per message were
        % encountered.
        if sortFlag
            % Sort the result so they go in order of line number
            mlintLines = [mlintstrc.line];
            [~,sortIndex] = sort(mlintLines);
            mlintstrc = mlintstrc(sortIndex);
        end
        
    end
end

% --------------------------------------------------
% Code Analyzer list section
% --------------------------------------------------
if mlintDisplayMode
    s{end+1} = ['<strong>', getString(message('MATLAB:profiler:CodeAnalyzerResults')), '</strong><br/>'];
    
    if ~mFileFlag || filteredFileFlag
        s{end+1} = getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
    else
        if isempty(mlintstrc)
            s{end+1} = getString(message('MATLAB:profiler:NoCodeAnalyzerMessages'));
        else
            % Remove mlint messages outside the function region
            mlintLines = [mlintstrc.line];
            mlintstrc([find(mlintLines < startLine) find(mlintLines > endLine)]) = [];
            s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
            s{end+1} = '<tr>';
            s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">', getString(message('MATLAB:profiler:LineNumberSoft')), '</td>'];
            s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">', getString(message('MATLAB:profiler:Message')), '</td>'];
            s{end+1} = '</tr>';
            
            for n = 1:length(mlintstrc)
                if (mlintstrc(n).line <= endLine) && (mlintstrc(n).line >= startLine)
                    s{end+1} = '<tr>';
                    if listingDisplayMode
                        s{end+1} = sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>', mlintstrc(n).line, mlintstrc(n).line);
                    else
                        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', mlintstrc(n).line);
                    end
                    s{end+1} = sprintf('<td class="td-linebottomrt"><span class="mono">%s</span></td>', mlintstrc(n).message);
                    s{end+1} = '</tr>';
                end
            end
            s{end+1} = '</table>';
        end
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End Code Analyzer list section
% --------------------------------------------------


% --------------------------------------------------
% Coverage section
% --------------------------------------------------
if coverageDisplayMode
    s{end+1} = ['<strong>', getString(message('MATLAB:profiler:CoverageResults')), '</strong><br/>'];
    
    if ~mFileFlag || filteredFileFlag
        s{end+1} = getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
    else
        s{end+1} = printfProfilerLink('coveragerpt(fileparts(urldecode(''%s'')))', getString(message('MATLAB:profiler:ShowCoverageForParentDir')),  urlencode(fullName));
        s{end+1} = '<br/>';
        
        linelist = (1:length(f))';
        canRunList = find(linelist(startLine:endLine)==runnableLines(startLine:endLine)) + startLine - 1;
        didRunList = ftItem.ExecutedLines(:,1);
        notRunList = setdiff(canRunList,didRunList);
        neverRunList = find(runnableLines(startLine:endLine)==0);
        
        s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:TotalLinesInFunction')), '</td>'];
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', endLine-startLine+1);
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:NoncodeLines')), '</td>'];
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(neverRunList));
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CodeLines')), '</td>'];
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(canRunList));
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CodeLinesThatDidRun')), '</td>'];
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(didRunList));
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CodeLinesThatDidNotRun')), '</td>'];
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(notRunList));
        s{end+1} = ['<tr><td class="td-linebottomrt" style="background-color:#F0F0F0">', getString(message('MATLAB:profiler:CoverageDidCanRun')), '</td>'];
        if ~isempty(canRunList)
            s{end+1} = sprintf('<td class="td-linebottomrt">%4.2f %%</td></tr>', 100*length(didRunList)/length(canRunList));
        else
            s{end+1} = sprintf('<td class="td-linebottomrt">N/A</td></tr>');
        end
        s{end+1} = '</table>';
        
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End Coverage section
% --------------------------------------------------


% --------------------------------------------------
% File listing
% --------------------------------------------------
% Make a lookup table to speed index identification
% The executedLines table is as long as the file and stores the index
% value for every executed line.
 
if oldListingDisplayMode && badListingDisplayMode
    s{end+1} = ['<p><span class="warning">', getString(message('MATLAB:profiler:FileModifiedDuringProfiling')), '</span></p>'];
end

if listingDisplayMode
    s{end+1} = ['<b>',  getString(message('MATLAB:profiler:FunctionListing')), '</b><br/>'];
    
    if ~mFileFlag || filteredFileFlag
        s{end+1} = getString(message('MATLAB:profiler:NoMATLABCodeToDisplay'));
    else
        
        executedLines = zeros(length(f),1);
        executedLines(ftItem.ExecutedLines(:,1)) = 1:size(ftItem.ExecutedLines,1);
        
        % Enumerate all alphanumeric values for later use in linking code
        alphanumericList = ['a':'z' 'A':'Z' '0':'9' '_'];
        alphanumericArray = zeros(1,128);
        alphanumericArray(alphanumericList) = 1;
        
        %g1164317 - Roll up timing data to the start of any line 
        %continuations.
        ftItem = adjustExecutionTimeForLineContinuations(startLine, endLine, ftItem, executedLines, ftok);
        
        [bgColorCode,bgColorTable,textColorCode,textColorTable] = makeColorTables( ...
            f,hiliteOption, ftItem, ftok, startLine, endLine, executedLines, runnableLines,...
            mlintstrc, maxNumCalls);
        s{end+1} = '<form method="GET" action="matlab:profviewgateway">';
        s{end+1} = [getString(message('MATLAB:profiler:ColorHighlightCodeAccordingTo')) ' '];
        s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
        s{end+1} = generateProfilerSelect();
        optionsList = { };
        shownString = { };
        %the optionsList is the string value used by the report to select
        %what is highlighted in the profile report. shownString is the
        %user-visible string in the html
        optionsList{end+1} = 'time';
        shownString{end+1} = getString(message('MATLAB:profiler:Time'));
        optionsList{end+1} = 'numcalls';
        shownString{end+1} = getString(message('MATLAB:profiler:Numcalls'));
        optionsList{end+1} = 'coverage';
        shownString{end+1} = getString(message('MATLAB:profiler:Coverage'));
        optionsList{end+1} = 'noncoverage';
        shownString{end+1} = getString(message('MATLAB:profiler:Noncoverage'));
        optionsList{end+1} = 'mlint';
        shownString{end+1} = getString(message('MATLAB:profiler:CodeAnalyzer'));
        if hasMem
            % add more highlight options when memory data is available
            optionsList{end+1} = 'allocated memory';
            shownString{end+1} = getString(message('MATLAB:profiler:AllocatedMemory'));
            optionsList{end+1} = 'freed memory';
            shownString{end+1} = getString(message('MATLAB:profiler:FreedMemory'));
            optionsList{end+1} = 'peak memory';
            shownString{end+1} = getString(message('MATLAB:profiler:PeakMemory'));
        end
        optionsList{end+1} = 'none';
        shownString{end+1} = getString(message('MATLAB:profiler:None'));
        for n = 1:length(optionsList)
            if strcmp(hiliteOption, optionsList{n})
                selectStr = 'selected'; %g1269807 Do not translate, as this is a non-visible HTML attribute
            else
                selectStr = '';
            end
            s{end+1} = sprintf('<option %s value="%s">%s</option>', selectStr, optionsList{n}, shownString{n});
        end
        s{end+1} = '</select>';
        s{end+1} = '</form>';
        
        
        % --------------------------------------------------
        %         Table creation
        s{end+1} = '<table id="FunctionListingTable">';
        
        s{end+1} = '<tr style="height:20px;">';
        s{end+1} = '<th>';
        s{end+1} = '<pre>';
        s{end+1} = ['<span style="color:#FF0000;">' getString(message('MATLAB:profiler:Time')) '</span> '];
        s{end+1} = '</pre>';
        s{end+1} = '</th>';
        s{end+1} = '<th>';
        s{end+1} = '<pre>';
        s{end+1} = ['<span style="color:#0000FF;">' getString(message('MATLAB:profiler:CallsTableElement')) '</span> '];
        s{end+1} = '</pre>';
        s{end+1} = '</th>';
        
        if hasMem
            s{end+1} = '<th>';
            s{end+1} = '<pre>';
            s{end+1} = '<span style="color:#20AF20;">mem</span> ';
            s{end+1} = '</pre>';
            s{end+1} = '</th>';
        end
         
        s{end+1} = '<th class="leftAligned" COLSPAN=2>';
        s{end+1} = '<pre>';
        s{end+1} = ['<span> ' getString(message('MATLAB:profiler:Line')) '</span>'];
        s{end+1} = '</pre>';
        s{end+1} = '</th>';
        
        %Only add a column for mlint messages when the "Code Analyzer"
        %highlight option is selected and when there actually exist any
        %messages to show.
        if strcmp(hiliteOption,'mlint') && length(mlintstrc) > 0
            s{end+1} = '<th>';
            s{end+1} = '<pre>';
            s{end+1} = ['<span style="color:#000;">' getString(message('MATLAB:profiler:CodeAnalyzerMessage')) '</span>'];
            s{end+1} = '</pre>';
            s{end+1} = '</th>';
        end
        
        s{end+1} = '</tr>';
        
        % Cycle through all the lines
        for n = startLine:endLine
            
            s{end+1} = '<tr>';
            
            lineIdx = executedLines(n);
            if lineIdx>0,
                callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                timePerLine = ftItem.ExecutedLines(lineIdx,3);
                if hasMem
                    memAlloc = ftItem.ExecutedLines(lineIdx,4);
                    memFreed = ftItem.ExecutedLines(lineIdx,5);
                    peakMem = ftItem.ExecutedLines(lineIdx,6);
                end 
            else
                timePerLine = 0;
                callsPerLine = 0;
                memAlloc = 0;
                memFreed = 0;
                peakMem = 0;
            end
            
            % Display the mlint message if necessary
            color = bgColorTable{bgColorCode(n)};
            textColor = textColorTable{textColorCode(n)};
            
            if mlintDisplayMode
                if any([mlintstrc.line]==n)
                    s{end+1} = sprintf('<a name="Line%d"></a>',n);
                end
            end
                      
            % Modify text so that < and > don't cause problems
            if n > length(f)    % insurance
                codeLine = '';    % file must have changed
            else
                codeLine = code2html(f{n});
            end
            
            % Display the time
            s{end+1} = '<td>';
            s{end+1} = '<pre>';
            if timePerLine > 0.001
                s{end+1} = sprintf('<span style="color: #FF0000"> %6.3f </span>', ...
                    timePerLine);
            elseif timePerLine > 0
                s{end+1} = '<span style="color: #FF0000">&lt; 0.001 </span>';
            end
            s{end+1} = '</pre>';
            s{end+1} = '</td>';
            
            % Display the number of calls
            s{end+1} = '<td>';
            s{end+1} = '<pre>';
            if callsPerLine > 0,
                s{end+1} = sprintf('<span style="color: #0000FF">%7d </span>', ...
                    callsPerLine);
            end
            s{end+1} = '</pre>';
            s{end+1} = '</td>';
            
            % Display memory data
            if hasMem
                s{end+1} = '<td>';
                s{end+1} = '<pre>';
                if memAlloc > 0 || memFreed > 0 || peakMem > 0
                    
                    str = sprintf('%s/%s/%s', ...
                        toKb(memAlloc,'%0.3g',true), ...
                        toKb(memFreed,'%0.3g',true), ...
                        toKb(peakMem,'%0.3g',true));
                    % 3 5-digit numbers, 2 slashes, 2 spaces = 19 spaces
                    str = sprintf('<span style="color: #20AF20">%19s </span>', str);
                end
                s{end+1} = str;
                s{end+1} = '</pre>';
                s{end+1} = '</td>';
            end            
           
            % Display the line number
            s{end+1} = '<td>';
            s{end+1} = '<pre>';
            if callsPerLine > 0
                s{end+1} = '<span style="color: #000000; font-weight: bold; margin:0; ">';
                s{end+1} = printfProfilerLink('opentoline(urldecode(''%s''),%d)', '%4d', urlencode(fullName), n, n);
                s{end+1} = '</span>';
            else
                s{end+1} = sprintf('<span style="color: #A0A0A0; margin:0;">%4d</span> ', n);
            end
            
            if ~isempty(find(n==maxDataLineList, 1)),
                % Mark the busy lines in the file with an anchor
                s{end+1} = sprintf('<a name="Line%d"></a>',n);
            end
            s{end+1} = '</pre>';
            s{end+1} = '</td>';
            
            if callsPerLine > 0
                % Need to add a space to the end to make sure the last
                % character is an identifier.
                codeLine = [codeLine ' '];
                % Use state machine to substitute in linking code
                codeLineOut = '';
                
                state = 'between';
                
                substr = [];
                for m = 1:length(codeLine),
                    ch = codeLine(m);
                    % Deal with the line with identifiers and Japanese comments .
                    % 128 characters are from 0 to 127 in ASCII
                    if ch >= 0 && ch <= 127
                        alphanumeric = alphanumericArray(ch);
                    else
                        alphanumeric = 0;
                    end
                    
                    switch state
                        case 'identifier'
                            if alphanumeric,
                                substr = [substr ch];
                            else
                                state = 'between';
                                if isfield(targetHash,substr)
                                    substr = printfProfilerLink('profview(%d);', '%s', targetHash.(substr), substr);
                                end
                                codeLineOut = [codeLineOut substr ch];
                            end
                        case 'between'
                            if alphanumeric,
                                substr = ch;
                                state = 'identifier';
                            else
                                codeLineOut = [codeLineOut ch];
                            end
                        otherwise
                            
                            error(message('MATLAB:profiler:UnexpectedState', state));
                            
                    end
                end
                codeLine = codeLineOut;
            end
            
            % Display the line
            s{end+1} = '<td class="leftAligned">';
            s{end+1} = '<pre>';
            s{end+1} = sprintf('<span style="color: %s; background: %s; padding:1px;">%s</span><br/>', ...
                textColor, color, codeLine);
            s{end+1} = '</pre>';
            s{end+1} = '</td>';
            
            if strcmp(hiliteOption,'mlint') && length(mlintstrc) > 0
                % Use the color as the indicator that an mlint message
                % occurred on this line
                % Mark this line for in-document linking from the mlint
                % list
                mlintIdx = find([mlintstrc.line]==n);
                s{end+1} = '<td>';
                for nMsg = 1:length(mlintIdx)
                    s{end+1} = sprintf('<span style="color: #F00">%s</span><br/>', ...
                        mlintstrc(mlintIdx(nMsg)).message);
                end
                s{end+1} = '</td>';
            end
            
            s{end+1} = '</tr>';
            
        end
        
        s{end+1} = '</table>';
        if moreSubfunctionsInFileFlag
            s{end+1} = ['<p><p>', getString(message('MATLAB:profiler:SubfunctionsNotIncluded'))];
        end
    end
end

% --------------------------------------------------
% End file list section
% --------------------------------------------------

s{end+1} = makeprofilerfooter();


function adjustedFtItem = adjustExecutionTimeForLineContinuations(startLine, endLine, ftItem, executedLines, ftok)
%g1164317 - This is a workaround to account for some new behaviors in
%the LXE.  
%The LXE now provides finer grained line continuation execution time data.  
%The issue is that this can often be misleading.  
%For example take this case:
%
% function repro
% foo( ...
%     f, ... 
%     g, ... %Execution time is that of g AND the total time to execute 
%            % foo since this is the last executable line in the 
%            % continuation.
%     1 ... %Marked non-executable
%     ); %Marked non-executable
% g;
% end
% 
% function foo(varargin)
% pause(2)
% end
% 
% function out = f
% out = 1;
% end
% 
% function out = g
% out = 2;
% pause(1);
% end
%
%Currently the final two lines of foo are marked non-executable, 
%and the total time it takes to run foo is summed with the last 
%executable line g.  This causes the user to lose the nuance that
%g takes 1 second and foo takes 2, making it appear like g takes 3 
%seconds.
%Until the LXE provides statement level timing data (sub-line) we are 
%going to implement this workaround to sum the timing data up to the 
%start line of the continuation..
continuationStartLineIdx = -1;

%Preprocess lines to adjust execution data for line continuations 
%(sum up execution time to first line of continuation)
for n = startLine:endLine    
    executableLineIdx = executedLines(n);
    %The token array represents line continuations by having the 
    %token be the index of the start of the continuation.
    tokenLineNumber = ftok(n);
    if isequal(tokenLineNumber, 0) || isequal(tokenLineNumber, n)
        continuationStartLineIdx = -1;
        continue;
    end
    %If we get here we know we are somewhere beyond the first 
    %line of a continuation.   
    
    %If we arn't on an executable line (meaning it has a value of 0), 
    %continue it won't have any timing data to sum up.
    if  isequal(executableLineIdx, 0)
        continue;
    end    
    
    %g1297810 - the timing data rolls up to the first executable 
    %line in the continuation, which is not always the start 
    %of the continuation.
    if isequal(continuationStartLineIdx, -1)
        if ~isequal(executedLines(tokenLineNumber), 0)
            continuationStartLineIdx = executedLines(tokenLineNumber);
        else
            continuationStartLineIdx = executableLineIdx;
        end
    end    
    
    %This is the timing data for a sub line in the continuation
    %NOTE: "3" is the index of the timing data, this data structure
    %also contains numcalls, and coverage data.
    continuationTimingData = ...
        ftItem.ExecutedLines(executableLineIdx,3);

    %We maintain a running sum of each line in the continuations 
    %timing data
    continuationSumData = ...
        ftItem.ExecutedLines(continuationStartLineIdx,3);
    %Add the current lines data to the sum data (the start 
    %line of the continuation)
    ftItem.ExecutedLines(continuationStartLineIdx,3) = ...
        continuationSumData + continuationTimingData;
    %Zero out the current lines data now that it has 
    %been moved to the start line.
    ftItem.ExecutedLines(executableLineIdx,3) = 0;    
end
adjustedFtItem = ftItem;

function escapedString = escapeHtml(originalString)
%ESCAPEHTML Escapes the characters in a String using HTML entities
 
escapedString = char(org.apache.commons.lang.StringEscapeUtils.escapeHtml(originalString));

% --------------------------------------------------
function shortFileName = truncateDisplayName(longFileName,maxNameLen)
%TRUNCATEDISPLAYNAME  Truncate the name if it gets too long

shortFileName = escapeHtml(longFileName);
if length(longFileName) > maxNameLen,
    shortFileName = char(com.mathworks.util.FileUtils.truncatePathname( ...
        shortFileName, maxNameLen));
end


% --------------------------------------------------
function b = hasMemoryData(s)
% Does this profiler data structure have memory profiling information in it?
b = (isfield(s, 'PeakMem') || ...
    (isfield(s, 'FunctionTable') && isfield(s.FunctionTable, 'PeakMem')));
% --------------------------------------------------
function s = formatData(key_data_field, num)
% Format a number as seconds or bytes depending on the
% value of key_data_field (1 = time, 2 = memory, 3 = other)
switch(key_data_field)
    case 1
        if num > 0
            s = sprintf('%4.3f s', num);
        else
            s = '0 s';
        end
    case 2
        num = num ./ 1024;
        s = sprintf('%4.2f Kb', num);
    case 3
        s = num2str(num);
end

% --------------------------------------------------
function s = formatNicePercent(a, b)
% Format the ratio of two numbers as a percentage.
% Use 0% when either number is zero.
if b > 0 && a > 0
    s = sprintf('%3.1f%%', 100*a/b);
else
    s = '0%';
end

% --------------------------------------------------
function x = toKb(y,fmt,terse)
% convert number of bytes into a nice printable string

values   = { 1 1024 1024 1024 1024 };
if nargin == 3 && terse
    suffixes = {'b' 'k' 'm' 'g' 't'};
else
    suffixes = { ' bytes' ' Kb' ' Mb' ' Gb' ' Tb' };
end

suff = suffixes{1};

for i = 1:length(values)
    if abs(y) >= values{i}
        suff = suffixes{i};
        y = y ./ values{i};
    else
        break;
    end
end

if nargin == 1
    if strcmp(suff, suffixes{1})
        fmt = '%4.0f';
    else
        fmt = '%4.2f';
    end
end

x = sprintf([fmt suff], y);

% --------------------------------------------------
function n = busyLineSortKeyStr2Num(str)
% Convert between string names and profile data sort types
% (see key_data_field)
if strcmp(str, 'time')
    n = 1;
    return;
elseif strcmp(str, 'allocated memory')
    n = 2;
    return;
elseif strcmp(str, 'freed memory')
    n = 3;
    return;
elseif strcmp(str, 'peak memory')
    n = 4;
    return;
end

error(message('MATLAB:profiler:UnknownSortKind', str));

% --------------------------------------------------
function str = busyLineSortKeyNum2Str(n)
% Convert from data sort types to string name.
% (see key_data_field)
strs = { 'time' };

% Cheat a bit here.  Only add the memory fields if the profiler
% is recording memory information.
if (callstats('memory') > 1)
    strs = [strs 'allocated memory' 'freed memory' 'peak memory' ];
end

str = strs{n};

% --------------------------------------------------
function [bgColorCode,bgColorTable,textColorCode,textColorTable] = makeColorTables( ...
    f, hiliteOption, ftItem, ftok, startLine, endLine, executedLines, ...
    runnableLines, mlintstrc, maxNumCalls)


% Take a first pass through the lines to figure out the line color
bgColorCode = ones(length(f),1);
textColorCode = ones(length(f),1);
textColorTable = {'#228B22','#000000','#A0A0A0'};

% Ten shades of green
memColorTable = { '#FFFFFF' '#00FF00' '#00EE00' '#00DD00' '#00CC00' ...
    '#00BB00' '#00AA00' '#009900' '#008800' '#007700'};

switch hiliteOption
    case 'time'
        % Ten shades of red
        bgColorTable = {'#FFFFFF','#FFF0F0','#FFE2E2','#FFD4D4', '#FFC6C6', ...
            '#FFB8B8','#FFAAAA','#FF9C9C','#FF8E8E','#FF8080'};
        key_data_field = 1;
    case 'numcalls'
        % Ten shades of blue
        bgColorTable = {'#FFFFFF','#F5F5FF','#ECECFF','#E2E2FF', '#D9D9FF', ...
            '#D0D0FF','#C6C6FF','#BDBDFF','#B4B4FF','#AAAAFF'};
    case 'coverage'
        bgColorTable = {'#FFFFFF','#E0E0FF'};
    case 'noncoverage'
        bgColorTable = {'#FFFFFF','#E0E0E0'};
    case 'mlint'
        bgColorTable = {'#FFFFFF','#FFE0A0'};
        
    case 'allocated memory'
        bgColorTable = memColorTable;
        key_data_field = 2;
        
    case 'freed memory'
        bgColorTable = memColorTable;
        key_data_field = 3;
        
    case 'peak memory'
        bgColorTable = memColorTable;
        key_data_field = 4;
        
    case 'none'
        bgColorTable = {'#FFFFFF'};
          
    otherwise 
        error(message('MATLAB:profiler:UnknownHiliteOption', hiliteOption));
end

maxData(1) = max(ftItem.ExecutedLines(:,3));

if hasMemoryData(ftItem)
    maxData(2) = max(ftItem.ExecutedLines(:,4));
    maxData(3) = max(ftItem.ExecutedLines(:,5));
    maxData(4) = max(ftItem.ExecutedLines(:,6));
end

for n = startLine:endLine
    
    if ftok(n) == 0
        % Non-code line, comment or empty. Color is green
        textColorCode(n) = 1;    
    elseif ftok(n) < n
        % This is a continuation line. Make it the same color
        % as the originating line
        bgColorCode(n) = bgColorCode(ftok(n));
        textColorCode(n) = textColorCode(ftok(n));
    else
        % This is a new executable line
        lineIdx = executedLines(n);
        
        if (strcmp(hiliteOption,'time') || ...
                strcmp(hiliteOption,'allocated memory') || ...
                strcmp(hiliteOption,'freed memory') || ...
                strcmp(hiliteOption,'peak memory'))
            
            if lineIdx > 0
                textColorCode(n) = 2;
                if ftItem.ExecutedLines(lineIdx,key_data_field+2) > 0
                    dataPerLine = ftItem.ExecutedLines(lineIdx,key_data_field+2);
                    ratioData = dataPerLine/maxData(key_data_field);
                    bgColorCode(n) = ceil(10*ratioData);
                else
                    % The amount of time (or memory) spent on the line was negligible
                    bgColorCode(n) = 1;
                end
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end
            
        elseif strcmp(hiliteOption,'numcalls')
            
            if lineIdx > 0
                textColorCode(n) = 2;
                if ftItem.ExecutedLines(lineIdx,2)>0;
                    callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                    ratioNumCalls = callsPerLine/maxNumCalls;
                    bgColorCode(n) = ceil(10*ratioNumCalls);
                else
                    % This line was not called
                    bgColorCode(n) = 1;
                end
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end
            
        elseif strcmp(hiliteOption,'coverage')
            
            if lineIdx > 0
                textColorCode(n) = 2;
                bgColorCode(n) = 2;
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end
            
        elseif strcmp(hiliteOption,'noncoverage')
            
            % If the line did execute or it is a
            % non-breakpointable line, then it should not be
            % flagged
            if (lineIdx > 0) || (runnableLines(n) == 0)
                textColorCode(n) = 2;
                bgColorCode(n) = 1;
            else
                % The line was not executed
                textColorCode(n) = 2;
                bgColorCode(n) = 2;
            end
            
        elseif strcmp(hiliteOption,'mlint')
            
            if any([mlintstrc.line]==n)
                bgColorCode(n) = 2;
                textColorCode(n) = 2;
            else
                bgColorCode(n) = 1;
                if lineIdx > 0
                    textColorCode(n) = 2;
                else
                    % The line was not executed
                    textColorCode(n) = 3;
                end
            end
            
        elseif strcmp(hiliteOption,'none')
            
            if lineIdx > 0
                textColorCode(n) = 2;
            else
                % The line was not executed
                textColorCode(n) = 3;
            end
            
        end
    end
end

function str = typeToDisplayValue(type)
%convert function info table TYPE strings to display strings
switch type
    case 'M-function'
        str = getString(message('MATLAB:profiler:Function'));
    case 'M-subfunction'
        str = getString(message('MATLAB:profiler:Subfunction'));
    case 'M-anonymous-function'
        str = getString(message('MATLAB:profiler:AnonymousFunctionShort'));
    case 'M-nested-function'
        str = getString(message('MATLAB:profiler:NestedFunction'));
    case 'M-method'
        str = getString(message('MATLAB:profiler:Method'));
    case 'M-script'
        str = getString(message('MATLAB:profiler:Script'));
    case 'MEX-function'
        str = getString(message('MATLAB:profiler:MEXfile'));
    case 'Builtin-function'
        str = getString(message('MATLAB:profiler:BuiltinFunction'));
    case 'Java-method'
        str = getString(message('MATLAB:profiler:JavaMethod'));
    case 'constructor-overhead'
        str = getString(message('MATLAB:profiler:ConstructorOverhead'));
    case 'MDL-function'
        str = getString(message('MATLAB:profiler:SimulinkModelFunction'));
    case 'Root'
        str = getString(message('MATLAB:profiler:Root'));
    otherwise
        str = type;
end

function str = generateTableElementLink(pref, fontWeight, msgID)
%Generate the link of table elements at the top of  profiler function table
str = [ '<td class="td-linebottomrt" style="background-color:#F0F0F0" valign="top">' ...
    printfProfilerLink(['setpref(''profiler'',''sortMode'',''' pref ''');profview(0);'], '<span style="font-weight:%s">%s</span>', fontWeight, getString(message(msgID)))];