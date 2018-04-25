function htmlOut = mlintrpt(name,option,config)
%MLINTRPT Run CHECKCODE for file or folder, reporting results in browser
%   MLINTRPT scans all MATLAB files in the current folder for messages.
%   MLINTRPT(FILENAME) scans the MATLAB file FILENAME for messages as does
%   the command MLINTRPT(FILENAME,'file').
%   MLINTRPT(DIRNAME,'dir') scans the specified folder.
%   MLINTRPT(...,CONFIG) uses the given configuration file.
%
%   See also CHECKCODE.

%   Copyright 1984-2017 The MathWorks, Inc.
if nargin > 0
    name = convertStringsToChars(name);
end

if nargin > 1
    option = convertStringsToChars(option);
end

if nargin > 2
    config = convertStringsToChars(config);
end

reportName = getString(message('MATLAB:codetools:reports:CodeAnalyzerReportName'));

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

configSpecified = (nargin > 2) && ~isempty(config);

mlintOptions = {'-struct'};
if configSpecified
    mlintOptions{end+1} = ['-config=' config];
end

if strcmp(option,'dir')
    mlintOptions{end+1} = '-fullpath';
    fileList = internal.matlab.reports.matlabFiles(name, reportName);
    localFilenames = strcat(name,filesep,fileList);
    mlintMsgs = mlint(localFilenames,mlintOptions{:});
else
    % Get the data
    [mlintMsgs,localFilenames] = mlint({name},mlintOptions{:});
    fullname = localFilenames{1};
    if isempty(fullname)
        internal.matlab.reports.webError(getString(message('MATLAB:codetools:reports:FileNotFoundPeriod',name)), title);
        return
    end
    fileList = {name};
end

% Gather all the data into a structure
strc = [];
for i = 1:length(mlintMsgs)
    
    strc(i).filename = fileList{i}; %#ok<AGROW>
    strc(i).fullfilename = localFilenames{i}; %#ok<AGROW>
    
    strc(i).linenumber = []; %#ok<AGROW>
    strc(i).linemessage = {}; %#ok<AGROW>
    
    mlmsg = mlintMsgs{i};
    for j = 1:length(mlmsg)
        ln = mlmsg(j).message;
        ln = code2html(ln);
        for k = 1:length(mlmsg(j).line)
            strc(i).linenumber(end+1) = mlmsg(j).line(k); %#ok<AGROW>
            strc(i).linemessage{end+1} = ln; %#ok<AGROW>
        end
    end
    
    % Now sort the list by line number
    if ~isempty(strc(i).linenumber)
        lnum = [strc(i).linenumber];
        lmsg = strc(i).linemessage;
        [~, ndx] = sort(lnum);
        lnum = lnum(ndx);
        lmsg = lmsg(ndx);
        strc(i).linenumber = lnum; %#ok<AGROW>
        strc(i).linemessage = lmsg; %#ok<AGROW>
    end
    
end

% Limit the number of messages displayed to keep from being overwhelmed by
% large pathological files.
displayLimit = 500;

% Now generate the HTML
help = [getString(message('MATLAB:codetools:reports:MLintReportDescription')) ' '];
doc = 'matlab_env_mlint';
if configSpecified
    configAction = [',''' config ''''];
else
    configAction = '';
end
rerunAction = sprintf('mlintrpt(''%s'',''%s''%s)',name, option, configAction);
runOnThisDirAction = 'mlintrpt';
s = internal.matlab.reports.makeReportHeader(reportName, help, doc, rerunAction, runOnThisDirAction);

s{end+1} = '<p>';
if strcmp(option,'file')
    s{end+1} = sprintf([getString(message('MATLAB:codetools:reports:ReportForFile')) ' <a href="matlab: edit(''%s'')">%s</a>'], ...
        urlencode(strc(1).fullfilename), strc(1).fullfilename);
else
    s{end+1} = getString(message('MATLAB:codetools:reports:ReportForSpecificFolder',name));
end
s{end+1} = '<p>';


s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
for n = 1:length(strc)
    
    encodedFileName = urlencode(strc(n).fullfilename);
    decodedFileName = urldecode(encodedFileName);
    
    s{end+1} = '<tr><td valign="top" class="td-linetop">'; %#ok<AGROW>
    if strcmp(option,'dir')
        openInEditor = sprintf('edit(''%s'')',decodedFileName);
        regExpRep = sprintf('%s', strc(n).filename);
        
        s{end+1} = ['<a class="mono" href="matlab:'  openInEditor '">'];
        s{end+1} = regExpRep;
        s{end+1} = sprintf('</a> </br>');
    end
    
    if isempty(strc(n).linenumber)
        msg = ['<span class="soft">' getString(message('MATLAB:codetools:reports:NoMessages')) '</span>'];
    elseif length(strc(n).linenumber)==1
        msg = ['<span class="warning">' getString(message('MATLAB:codetools:reports:OneMessage')) '</span>'];
    elseif length(strc(n).linenumber) < displayLimit
        msg = ['<span class="warning">' getString(message('MATLAB:codetools:reports:SpecifiedNumberOfMessages', length(strc(n).linenumber))) '</span>'];
    else
        % Truncate the list of messages if there are too many.
        msg = ['<span class="warning">' ...
            getString(message('MATLAB:codetools:reports:SpecifiedNumberOfMessages', length(strc(n).linenumber))) ...
            '\n<br/>'  ...
            getString(message('MATLAB:codetools:reports:ShowingOnlyFirstAmountOfMessages', displayLimit)) ...
            '</span>'];
    end
    s{end+1} = sprintf('%s</td><td valign="top" class="td-linetopleft">',msg); %#ok<AGROW>
    
    
    
    if ~isempty(strc(n).linenumber)
        for m = 1:min(length(strc(n).linenumber),displayLimit)
            
            openMessageLine = sprintf('opentoline(''%s'',%d)',decodedFileName, strc(n).linenumber(m));
            lineNumber = sprintf('%d', strc(n).linenumber(m));
            lineMessage =  sprintf('%s',strc(n).linemessage{m});
            
            s{end+1} = sprintf('<span class="mono">');
            s{end+1} = ['<a href="matlab:' openMessageLine '">'];
            s{end+1} = lineNumber;
            s{end+1} = sprintf('</a> ');
            s{end+1} = lineMessage;
            s{end+1} = sprintf('</span> <br/>');
        end
    end
    s{end+1} = '</td></tr>'; %#ok<AGROW>
    
end

s{end+1} = '</table>';
s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
