function [theMessage, description, format] = xlsfinfo(filename)
%XLSFINFO Determine if file contains Microsoft Excel spreadsheet.
%   STATUS = XLSFINFO(FILENAME) returns 'Microsoft Excel Spreadsheet' if the
%   specified file is in a format that XLSREAD can read.  Otherwise, STATUS is an
%   empty character vector, ''.
%
%   [STATUS,SHEETS] = XLSFINFO(FILENAME) returns a cell array of character vectors
%   containing the names of each spreadsheet in the file. If XLSREAD cannot read a
%   particular worksheet, the corresponding cell contains an error message. If
%   XLSFINFO cannot read the file, SHEETS is a character vector containing an error
%   message.
%
%   [STATUS,SHEETS,FORMAT] = XLSFINFO(FILENAME) returns the format description that
%   Excel returns for the file.  On systems without Excel for Windows, FORMAT is an
%   empty character vector, ''.
%
%   Specific Excel formats include, but are not limited to:
%      'xlWorkbookNormal', 'xlHtml', 'xlXMLSpreadsheet', 'xlCSV'
%
%   NOTE: On Windows systems with Excel software, XLSFINFO obtains information using
%   the COM server, which is part of the typical Excel installation.  If the COM
%   server is unavailable, XLSFINFO warns that it cannot start an ActiveX server. In
%   this case, consider reinstalling your Excel software.
%
%   See also XLSREAD, XLSWRITE, DLMREAD, DLMWRITE.

%   Copyright 1984-2016 The MathWorks, Inc.
    %==============================================================================
    
    % Validate filename data type
    if nargin < 1
        error(message('MATLAB:xlsfinfo:Nargin'));
    end
    
    % accept string filenames
    filename = matlab.io.internal.utility.convertStringsToChars(filename);
    
    if ~ischar(filename)
        error(message('MATLAB:xlsfinfo:InputClass'));
    end
    
    % Validate filename is not empty
    if isempty(filename)
        error(message('MATLAB:xlsfinfo:FileName'));
    end
    
    % handle requested Excel workbook filename
    filename = validpath(filename);
    
    try
        % Don't even attempt to open an excel server if it isn't pc.
        if ~ispc
            format = '';
            [theMessage, description] = callNonComXLSFINFO(filename);
        else
            % Attempt to start Excel as ActiveX server process on local host
            % try to start ActiveX server
            try
                Excel = matlab.io.internal.getExcelInstance;
            catch exception                                                        %#ok<NASGU>
                warning(message('MATLAB:xlsfinfo:ActiveX'))
                format = '';
                [theMessage, description] = callNonComXLSFINFO(filename);
                return;
            end
            [theMessage, description, format] = xlsfinfoCOM(Excel, filename);
        end
    catch exception
        theMessage = '';
        description =  [getString(message('MATLAB:xlsfinfo:UnreadableExcelFile')),' ', exception.message];
        if strcmp(exception.identifier, 'MATLAB:xlsread:FileFormat')
            format = 'xlCurrentPlatformText';
        end
    end
end
%==============================================================================
function [m, descr] = xlsfinfoBinary(filename)
    
    biffvector = biffread(filename);
    m = 'Microsoft Excel Spreadsheet';
    [~,descr] = matlab.iofun.internal.excel.biffparse(biffvector);
    descr = descr';
end

%==============================================================================
function [theMessage, description] = xlsfinfoXLSX(filename)
    
    % Requires java to unzip xlsx files
    if ~usejava('jvm')
        error(message('MATLAB:xlsfinfo:noJVM'))
    end;
    
    % Unzip the XLSX file (a ZIP file) to a temporary location
    baseDir = tempname;
    mkdir(baseDir);
    cleanupBaseDir = onCleanup(@()rmdir(baseDir,'s'));
    unzip(filename, baseDir);
    
    docProps = fileread(fullfile(baseDir,'docProps','app.xml'));
    theMessage = '';
    matchMessage = regexp(docProps,'<Application>(?<message>Microsoft\s+(\w+\s+)?Excel)</Application>','names');
    if ~isempty(matchMessage);
        theMessage = [matchMessage.message ' Spreadsheet'];
    end
    
    workbook_xml_rels  = fileread(fullfile(baseDir, 'xl', '_rels', 'workbook.xml.rels')); 
    workbook_xml  = fileread(fullfile(baseDir, 'xl', 'workbook.xml')); 
    description = getSheetNames(workbook_xml_rels, workbook_xml);
end

%==============================================================================
function [theMessage, description] = callNonComXLSFINFO(filename)
    [~, ~, ext] = fileparts(filename);
    if any(strcmp(ext, matlab.io.internal.xlsreadSupportedExtensions('SupportedOfficeOpenXMLOnly')))
        [theMessage, description] = xlsfinfoXLSX(filename);
    else
        [theMessage, description] = xlsfinfoBinary(filename);
    end
end