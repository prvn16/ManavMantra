function htmlOut = helprpt(name, option)
%HELPRPT  Audit a file or folder for help
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   HELPRPT scans all MATLAB files in the current folder for problems in the
%   help lines. This includes missing examples, "see also" lines,
%   and copyright.
%
%   HELPRPT(FILENAME) or HELPRPT(FILENAME,'file') scans the file
%   FILENAME.
%
%   HELPRPT(DIRNAME,'dir') scans the specified folder.
%
%   HTMLOUT = HELPRPT(...) returns the generated HTML text as a cell array
%
%   See also PROFILE, MLINTRPT, DEPRPT, CONTENTSRPT, COVERAGERPT.

% Copyright 1984-2016 The MathWorks, Inc.

import com.mathworks.matlab.api.explorer.MatlabPlatformUtil;

reportName = getString(message('MATLAB:codetools:reports:HelpReportName'));
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
    fileList = internal.matlab.reports.matlabFiles(dirname, reportName);
    %Tag on the directory path.
    fileList = strcat(name,filesep,fileList);
else
    fullname = which(name);
    if isempty(fullname)
        internal.matlab.reports.webError(getString(message('MATLAB:codetools:reports:SpecificFileNotFound', name)), reportName);
        return
    end
    [dirname, realname] = fileparts(fullname);
    % add a '.m' if there is not already one
    fileList = {[dirname filesep realname '.m']};
end


%% Manage the preferences
h1DisplayMode = getpref('dirtools','h1DisplayMode',1);
helpDisplayMode = getpref('dirtools','helpDisplayMode',1);
options.displayCopyright = getpref('dirtools','copyrightDisplayMode',1);
options.displayHelpForMethods = getpref('dirtools','helpSubfunsDisplayMode',1);
options.displayExamples = getpref('dirtools','exampleDisplayMode',1);
options.displaySeeAlso = getpref('dirtools','seeAlsoDisplayMode',1);

%% First gather all the data
strc = internal.matlab.reports.parseHelpInfo(fileList, options);

%% Make the Header
help = [getString(message('MATLAB:codetools:reports:HelpReportDescription')) ' '];
docPage = 'matlab_env_help_rpt';
thisDirAction = 'helprpt';
rerunAction = sprintf('helprpt(''%s'',''%s'')', name, option);

% Now generate the HTML
s = internal.matlab.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

% For now, show the checkbox form only in MATLAB desktop
% TODO: add the checkbox form back in MATLAB Online (g1564319) after the "Rerun This Report" and "Run Report on Current Folder" buttons are added back (g1564302)
%% Make the form
if ~MatlabPlatformUtil.isMatlabOnline
    s{end+1} = '<form method="GET" action="matlab:internal.matlab.reports.handleForm">';
    s{end+1} = '<input type="hidden" name="reporttype" value="helprpt" />';
    s{end+1} = '<table cellspacing="8">';
    s{end+1} = '<tr>';

    checkOptions = {'','checked'};

    s{end+1} = sprintf('<td><input type="checkbox" name="helpSubfunsDisplayMode" %s onChange="this.form.submit()" />%s</td>',...
        checkOptions{options.displayHelpForMethods + 1}, getString(message('MATLAB:codetools:reports:ShowClassMethodsOption')));
    s{end+1} = sprintf('<td><input type="checkbox" name="h1DisplayMode" %s onChange="this.form.submit()" />%s</td>',...
        checkOptions{h1DisplayMode+1}, getString(message('MATLAB:codetools:reports:DescriptionOption')));
    s{end+1} = sprintf('<td><input type="checkbox" name="exampleDisplayMode" %s onChange="this.form.submit()" />%s</td>',...
        checkOptions{options.displayExamples + 1}, getString(message('MATLAB:codetools:reports:ExamplesOption')));
    s{end+1} = '</tr><tr>';
    s{end+1} = sprintf('<td><input type="checkbox" name="helpDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
        checkOptions{helpDisplayMode+1}, getString(message('MATLAB:codetools:reports:ShowAllHelpOption')));
    s{end+1} = sprintf('<td><input type="checkbox" name="seeAlsoDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
        checkOptions{options.displaySeeAlso + 1}, getString(message('MATLAB:codetools:reports:SeeAlsoOption')));
    s{end+1} = sprintf('<td><input type="checkbox" name="copyrightDisplayMode" %s onChange="this.form.submit()" />%s</td>', ...
        checkOptions{options.displayCopyright + 1}, getString(message('MATLAB:codetools:reports:CopyrightOption')));

    s{end+1} = '</tr>';
    s{end+1} = '</table>';

    s{end+1} = '</form>';
end

s{end+1} = [getString(message('MATLAB:codetools:reports:ReportForSpecificFolder', dirname)) '<p>'];

s{end+1} = ['<strong>' getString(message('MATLAB:codetools:reports:MATLABFileList')) '</strong><br/>'];
s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';

for n = 1:length(strc)
    
    lineNumberWhereHelpSectionStartsInActualFile = getLineNumberWhereHelpSectionStarts(strc(n).filename, strc(n).description) - 1;
    
    encoded = urlencode(strc(n).filename);
    decoded = urldecode(encoded);
    shortFileName = sprintf('%s', strc(n).shortfilename);
    fullFileName = sprintf('%s', strc(n).fullname);
    openFunction = sprintf('matlab.desktop.editor.openAndGoToFunction(''%s'',''%s'')', decoded, shortFileName);
    openInEditor = sprintf('edit(''%s'')', decoded);
    
    s{end+1} = '<tr>';
    isSubFun = strcmp(strc(n).type, getString(message('MATLAB:codetools:reports:Subfunction'))) || strcmp(strc(n).type, getString(message('MATLAB:codetools:reports:ClassMethod')));
    
    % Display all the results
    if isSubFun
        s{end+1} = sprintf('<td valign="top" class="td-dashtop">');
        s{end+1} = ['<a class= "mono" href="matlab: ' openFunction '"> '];
        s{end+1} = fullFileName;
        s{end+1} = sprintf('</a></td>');
        s{end+1} = sprintf('<td class="td-dashtopleft">');
    else
        s{end+1} = sprintf('<td valign="top" class="td-dashtop">');
        s{end+1} = ['<a class= "mono" href="matlab: ' openInEditor '"> '];
        s{end+1} = shortFileName;
        s{end+1} = sprintf('</a></td>');
        s{end+1} = sprintf('<td class="td-linetopleft">');
    end
    
    if h1DisplayMode
        if isempty(strc(n).description)
            s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:NoDescriptionLineHelp')));
        else
            s{end+1} = sprintf('<pre>%s</pre>',strc(n).description);
        end
    end
    
    if helpDisplayMode
        if isempty(strc(n).help)
            s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:NoHelpHelp')));
        else
            s{end+1} = '<pre>';
            s{end+1} = sprintf('%s<br/>',regexprep(strc(n).help,'^ %',' '));
            s{end+1} = '</pre>';
        end
    end
    
    if options.displayExamples
        if isempty(strc(n).example)
            s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:NoExamplesHelp')));
        else
            strc(n).exampleLine = strc(n).exampleLine + lineNumberWhereHelpSectionStartsInActualFile;
            lineLabelForExamples = sprintf('%2d:',strc(n).exampleLine);
            lineLabelForExamples = strrep(lineLabelForExamples,' ','&nbsp;');
            openToLineForExamples = sprintf('opentoline(''%s'',%d)',decoded, strc(n).exampleLine);
            s{end+1} = sprintf('<pre>');
            s{end+1} = ['<a href="matlab:' openToLineForExamples '">'];
            s{end+1} = sprintf('%s', lineLabelForExamples);
            s{end+1} = sprintf('</a>');
            s{end+1} = sprintf('%s', strc(n).example);
            s{end+1} = sprintf('</pre>');
        end
    end
    
    if options.displaySeeAlso
        if isempty(strc(n).seeAlso)
            s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:NoSeeAlsoLineHelp')));
        else
            strc(n).seeAlsoLine = strc(n).seeAlsoLine + lineNumberWhereHelpSectionStartsInActualFile;
            lineLabelForSeeAlso = sprintf('%2d:',strc(n).seeAlsoLine);
            lineLabelForSeeAlso = strrep(lineLabelForSeeAlso,' ','&nbsp;');
            openToLineForSeeAlso = sprintf('opentoline(''%s'',%d)', decoded, strc(n).seeAlsoLine);
            s{end+1} = sprintf('<pre>');
            s{end+1} = ['<a href="matlab:' openToLineForSeeAlso '">'];
            s{end+1} = sprintf('%s', lineLabelForSeeAlso);
            s{end+1} = sprintf('</a>');
            s{end+1} = sprintf('%s', strc(n).seeAlso);
            s{end+1} = sprintf('</pre>');
            
            checkSeeAlsoFcn = 1;
            if checkSeeAlsoFcn
                for m = 1:length(strc(n).seeAlsoFcnList)
                    
                    % Throw a warning if the file can't be found.
                    % Since MATLAB convention UPPERCASES function names
                    % in SEE ALSO lines, we test for both the literal and
                    % lowercase version of this filename.
                    testNameLiteral = strc(n).seeAlsoFcnList{m}{1};
                    testNameLowerCase = lower(strc(n).seeAlsoFcnList{m}{1});
                    
                    if isempty(which(testNameLiteral)) && isempty(which(testNameLowerCase))
                        s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:FunctionDoesNotAppearOnThePathHelp', ...
                            strc(n).seeAlsoFcnList{m}{1})));
                    end
                    
                end
            end
            
        end
    end
    
    if ~isSubFun && options.displayCopyright
        if isempty(strc(n).copyright)
            s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:NoCopyrightLineHelp')));
        else
            s{end+1} = sprintf('<pre><span style="font-size: 11">%s</span></pre>', ...
                strc(n).copyright);
            dv = datevec(now);
            if strc(n).copyrightEndYear ~= dv(1)
                s{end+1} = missingHelpMessage(getString(message('MATLAB:codetools:reports:CopyrightYearIsNotCurrentHelp')));
            end
        end
    end
    
    s{end+1} = '</td></tr>';
    
end
s{end+1} = '</table>';
s{end+1} = '</body></html>';

sOut = [s{:}];
if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end
end
function str = missingHelpMessage(currentMessage)
str = ['<span style="background: #FFC0C0">' currentMessage '</span><br/>'];
end

function lineNumberWhereHelpSectionStarts = getLineNumberWhereHelpSectionStarts(filename, description)
lineNumberWhereHelpSectionStarts = 0;
matlabCodeAsCellArray = getmcode(filename);
for i=1:length(matlabCodeAsCellArray)
    firstLineOfHelpSection = strfind(matlabCodeAsCellArray{i}, strtrim(description));
    if (~isempty(firstLineOfHelpSection))
        lineNumberWhereHelpSectionStarts = i;
        break;
    end
end
end

%#ok<*AGROW>
