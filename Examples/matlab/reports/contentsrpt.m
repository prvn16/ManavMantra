function htmlOut = contentsrpt(dirname)
%CONTENTSRPT  Audit the Contents.m for the given directory
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   CONTENTSRPT checks for the existence and correctness of the
%   Contents.m file in the current directory.
%
%   CONTENTSRPT(DIRNAME) scans the specified directory.
%
%   HTMLOUT = CONTENTSRPT(...) returns the generated HTML text as a cell
%   array.
%
%   See also PROFILE, MLINTRPT, DEPRPT, HELPRPT, COVERAGERPT.

%   Copyright 1984-2016 The MathWorks, Inc.

reportName = getString(message('MATLAB:codetools:reports:ContentsReportName'));

if nargout == 0
    internal.matlab.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    dirname = cd;
end

contentsFile = fullfile(dirname,'Contents.m');

% Is there a Contents.m file?
noContentsFlag = 0;
if isempty(dir([dirname filesep 'Contents.m']))
    noContentsFlag = 1;
else
    [contents, excluded] = auditcontents(dirname);
end


%% Make the Header
help = [getString(message('MATLAB:codetools:reports:ContentsReportDescription')) ' '];
docPage = 'matlab_env_contents_rpt';
rerunAction = sprintf('contentsrpt(''%s'')', dirname);
thisDirAction = 'contentsrpt';

% Now generate the HTML
s = internal.matlab.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);
s{end+1} = '<p>';

dirNameEncoded = urlencode(dirname);
dirNameDecoded = urldecode(dirNameEncoded);
makeContentsMFile = sprintf('makecontentsfile(''%s'');', dirNameDecoded);
showContentsReport = sprintf('contentsrpt(''%s'');', dirNameDecoded);
hyperlinkToMakeContentsFile = [makeContentsMFile,  showContentsReport];

if noContentsFlag
    s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:NoContentsM')));
    s{end+1} = [' [ <a href="matlab:' hyperlinkToMakeContentsFile '">'];
    s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:Yes')));
    s{end+1} = sprintf('</a> ]');
else
    contentsFileEncoded = urlencode(contentsFile);
    contentsFileDecoded = urldecode(contentsFileEncoded);
    editContentsFile = sprintf('edit(''%s'');', contentsFileDecoded);
    fixContentsReportSpacing = sprintf('fixcontents(''%s'',''prettyprint'');', contentsFileDecoded);
    fixContentsReportAll = sprintf('fixcontents(''%s'',''all'');', contentsFileDecoded);
    hyperlinkToFixSpacing = [fixContentsReportSpacing, showContentsReport];
    hyperlinkToFixAll = [fixContentsReportAll, showContentsReport];
    
    s{end+1} = ['[ <a href="matlab:' editContentsFile '">'];
    s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:EditContentsM')));
    s{end+1} = sprintf('</a> | ');
    
    s{end+1} = ['<a href="matlab:' hyperlinkToFixSpacing  '">'];
    s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:FixSpacing')));
    s{end+1} = sprintf('</a> | ');
    
    s{end+1} = ['<a href="matlab:' hyperlinkToFixAll  '">'];
    s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:FixAll')));
    s{end+1} = sprintf('</a> ]');
    s{end+1} = sprintf('</p>');
    
    s{end+1} = ['<p>' getString(message('MATLAB:codetools:reports:ReportForFolder', dirname)) '</p>'];
    
    s{end+1} = '<pre>';
    
    for n = 1:length(contents)
        fileline = regexprep(contents(n).text,'^%','');
        fileline = code2html(fileline);
        if contents(n).ismfile
            
            fullFileNameEncoded = urlencode([dirname filesep contents(n).mfilename]);
            fullFileNameDecoded = urldecode(fullFileNameEncoded);
            hyperlinkToEditMFile = sprintf('edit(''%s'');', fullFileNameDecoded);
            fileName = sprintf('%s', contents(n).mfilename);                
                            
            % Make the first mention of the file name a clickable link to
            % bring up the file in the editor. The exception to this case
            % is when the file doesn't appear to exist (i.e. auditcontents
            % suggests the "remove" action
            
            if strcmp(contents(n).action,'remove')
                fileline2 = fileline;
            else
                linkStr = ['<a href="matlab:' hyperlinkToEditMFile '">' fileName '</a>'];
                
                % Escape out any backslashes or they will mess up the regular
                % expression replacement below.
                linkStr = strrep(linkStr,'\','\\');
                fileline2 = regexprep(fileline, ...
                    contents(n).mfilename, ...
                    linkStr, ...
                    'once');
            end
            
            s{end+1} = sprintf('%s\n',fileline2); %#ok<*AGROW>
            
            if strcmp(contents(n).action,'update')
                s{end+1} = '</pre><div style="background:#FEE">';
                fileNameUrl = ['<a href="matlab:' hyperlinkToEditMFile '">' fileName '</a>'];
                
                s{end+1} = [getString(message('MATLAB:codetools:reports:DescriptionLinesDoNotMatch', fileNameUrl)) '<br/>'];
                useDescriptionFromFile = sprintf('fixcontents(''%s'',''update'',''%s'');', contentsFileDecoded, fullFileNameDecoded);
                hyperlinkToUseDescriptionFromFile = [useDescriptionFromFile, showContentsReport];
                s{end+1} = sprintf(getString(message('MATLAB:codetools:reports:DescriptionFromFile')));
                s{end+1} = [' [ <a href="matlab:' hyperlinkToUseDescriptionFromFile '"> '];
                s{end+1} = [ getString(message('MATLAB:codetools:reports:Yes')) '</a>  ] '];
                
                filelineFile = fileline;
                idx = strfind(filelineFile,' - ');
                filelineFile(idx:end) = [];
                filelineFile = [filelineFile ' - ' contents(n).filedescription];
                filelineFile = code2html(filelineFile);
                s{end+1} = sprintf('<pre>%s</pre>\n',filelineFile);
                
                useDescriptionFromContentsMFile = sprintf('fixcontents(''%s'',''updatefromcontents'',''%s'');', contentsFileDecoded, fullFileNameDecoded);
                hyperlinkToUseDescriptionFromContentsMFile = [useDescriptionFromContentsMFile, showContentsReport];
                s{end+1} = [getString(message('MATLAB:codetools:reports:DescriptionFromContents')) ' '];
                s{end+1} = [' [ <a href="matlab:' hyperlinkToUseDescriptionFromContentsMFile '"> '];
                s{end+1} = [getString(message('MATLAB:codetools:reports:Yes')) '</a>  ] '];
                s{end+1} = sprintf('<pre>%s</pre>\n',fileline);
                s{end+1} = '</div><pre>';
                
            elseif strcmp(contents(n).action,'remove')
                s{end+1} = '</pre><div style="background:#FEE">';
                
                s{end+1} = [getString(message('MATLAB:codetools:reports:FileNotInFolder', contents(n).mfilename)) '<br/>'];
                removeFromContentsMFile = sprintf('fixcontents(''%s'',''remove'',''%s'');', contentsFileDecoded, contents(n).mfilename);
                hyperlinkToRemoveFromContentsMFile = [removeFromContentsMFile, showContentsReport];
                s{end+1} = [getString(message('MATLAB:codetools:reports:RemoveFromContents')) ' '];
                s{end+1} = [' [ <a href="matlab:' hyperlinkToRemoveFromContentsMFile '"> '];
                s{end+1} = [getString(message('MATLAB:codetools:reports:Yes')) '</a>  ] '];
                s{end+1} = '</div><pre>';
            end
        else
            s{end+1} = sprintf('%s\n',fileline);
        end
    end
    
    for n = 1:length(excluded)
        excludedFileNameEncoded = urlencode(excluded(n).mfilename);
        excludedFileNameDecoded = urldecode(excludedFileNameEncoded);
        editExcludedFile = sprintf('edit(''%s'')', excludedFileNameDecoded);
        excludedFileName = sprintf('%s', excluded(n).mfilename);
        
        fileUrl = ['<a href="matlab:' editExcludedFile '">'  excludedFileName '</a>'];
        s{end+1} = ['</pre><div style="background:#EEE">' getString(message('MATLAB:codetools:reports:InFolderButNotContents', fileUrl)) '<pre>'];
        s{end+1} = code2html(excluded(n).contentsline);
        fileStr = regexprep(excluded(n).contentsline,'-.*$','');
        
        s{end+1} = ['</pre>' getString(message('MATLAB:codetools:reports:AddTheLineShownAbove')) ' '];
        fileStrEncoded = urlencode(fileStr);
        fileStrDecoded = urldecode(fileStrEncoded);
        addToContentsMFile = sprintf('fixcontents(''%s'',''append'',''%s'');', contentsFileDecoded, fileStrDecoded);
        hyperlinkToContentsMFile = [addToContentsMFile, showContentsReport];
        s{end+1} = [' [ <a href="matlab:' hyperlinkToContentsMFile '">'];
        s{end+1} = [getString(message('MATLAB:codetools:reports:Yes')) '</a>  ] </div><pre>'];
    end
    
    s{end+1} = '</pre>';
    
end

s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
