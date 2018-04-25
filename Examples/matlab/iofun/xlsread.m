function [numericData, textData, rawData, customOutput] = xlsread(file, sheet, range, mode, customFun)
% XLSREAD Read Microsoft Excel spreadsheet file.
%   [NUM,TXT,RAW]=XLSREAD(FILE) reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the numeric data in array NUM.
%   Optionally, returns the text fields in cell array TXT, and the unprocessed data
%   (numbers and text) in cell array RAW.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET) reads the specified worksheet.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE) reads from the specified SHEET and RANGE.
%   Specify RANGE using the syntax 'C1:C2', where C1 and C2 are opposing corners of
%   the region. Not supported for XLS files in BASIC mode.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'basic') reads from the spreadsheet in
%   BASIC mode, the default on systems without Excel for Windows. RANGE is supported
%   for XLSX files only.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,RANGE) reads data from the specified RANGE of the
%   first worksheet in the file. Not supported for XLS files in BASIC mode.
%
%   The following syntaxes are supported only on Windows systems with Excel software:
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,-1) opens an Excel window to select data
%   interactively.
%
%   [NUM,TXT,RAW,CUSTOM]=XLSREAD(FILE,SHEET,RANGE,'',FUNCTIONHANDLE) reads from the
%   spreadsheet, executes the function associated with FUNCTIONHANDLE on the data,
%   and returns the final results. Optionally, returns additional CUSTOM output,
%   which is the second output from the function. XLSREAD does not change the data
%   stored in the spreadsheet.
%
%   Input Arguments:
%
%   FILE    Name of the file to read. SHEET   Worksheet to read. One of the
%           following:
%           * The worksheet name.
%           * Positive, integer-valued scalar indicating the worksheet
%             index.
%
%   RANGE   Character vector or string that specifies a rectangular portion of the
%           worksheet to read. Not case sensitive. Use Excel A1 reference style. If 
%           you do not specify a SHEET, RANGE must include both corners and a colon 
%           character (:), even for a single cell (such as 'D2:D2').
%
%   'basic' Flag to request reading in BASIC mode, which is the default for
%           systems without Excel for Windows. In BASIC mode, XLSREAD:
%           * Reads XLS, XLSX, XLSM, XLTX, and XLTM files only.
%           * Does not support an xlRange input when reading XLS files.
%             In this case, use '' in place of xlRange.
%           * For XLS files, requires a name to specify the SHEET,
%             and the name is case sensitive.
%           * Does not support function handle inputs.
%           * Imports all dates as Excel serial date numbers. Excel
%             serial date numbers use a different reference date than MATLAB date
%             numbers.
%
%   -1      Flag to open an interactive Excel window for selecting data.
%           Select the worksheet, drag and drop the mouse over the range you want,
%           and click OK. Supported only on Windows systems with Excel software.
%
%   FUNCTIONHANDLE
%           Handle to your custom function. When XLSREAD calls your function, it
%           passes a range interface from Excel to provide access to the data. Your
%           function must include this interface (of type
%           'Interface.Microsoft_Excel_5.0_Object_Library.Range', for example) both
%           as an input and output argument.
%
%   Notes:
%
%   * On Windows systems with Excel software, XLSREAD reads any file
%     format recognized by your version of Excel, including XLS, XLSX, XLSB, XLSM,
%     and HTML-based formats.
%
%   * If your system does not have Excel for Windows, XLSREAD operates in
%     BASIC mode (see Input Arguments).
%
%   * XLSREAD imports formatted dates as character vectors (such as '10/31/96'),
%     except in BASIC mode. In BASIC mode, XLSREAD imports all dates as serial date
%     numbers. Serial date numbers in Excel use different reference dates than date
%     numbers in MATLAB. For information on converting dates, see the documentation
%     on importing spreadsheets.
%
%   Examples:
%
%   % Create data for use in the examples that follow:
%   values = {1, 2, 3 ; 4, 5, 'x' ; 7, 8, 9};
%   headers = {'First', 'Second', 'Third'};
%   xlswrite('myExample.xls', [headers; values]);
%   moreValues = rand(5);
%   xlswrite('myExample.xls', moreValues, 'MySheet');
%
%   % Read data from the first worksheet into a numeric array:
%   A = xlsread('myExample.xls')
%
%   % Read a specific range of data:
%   subsetA = xlsread('myExample.xls', 1, 'B2:C3')
%
%   % Read from a named worksheet:
%   B = xlsread('myExample.xls', 'MySheet')
%
%   % Request the numeric data, text, and a copy of the unprocessed (raw)
%   % data from the first worksheet:
%   [ndata, text, alldata] = xlsread('myExample.xls')
%
%   See also XLSWRITE, XLSFINFO, DLMREAD, IMPORTDATA, TEXTSCAN.

%   Copyright 1984-2016 The MathWorks, Inc.
%=============================================================================

%Find all arguments containing strings or string arrays and convert
%them to char vectors or cellstrs.

import matlab.io.internal.utility.convertStringsToChars


rawData = {};
Sheet1 = 1;
if nargin < 2
    sheet = Sheet1;
    range = '';
elseif nargin < 3
    range = '';
end
% handle input values
if nargin < 1 || isempty(file)
    error(message('MATLAB:xlsread:FileName'));
end

[file, sheet, range] = convertStringsToChars(file, sheet, range);

if ~ischar(file)
    error(message('MATLAB:xlsread:InvalidFileName'));
end

% Resolve filename
try
    file = validpath(file);
catch exception
    error(message('MATLAB:xlsread:FileNotFound', file, exception.message));
end
[~,~,ext] = fileparts(file);
openXMLmode = any(strcmp(ext, matlab.io.internal.xlsreadSupportedExtensions('SupportedOfficeOpenXMLOnly')));

if nargin > 1
    % Verify class of sheet parameter
    if ~ischar(sheet) && ...
            ~(isnumeric(sheet) && length(sheet)==1 && ...
            floor(sheet)==sheet && sheet >= -1)
        error(message('MATLAB:xlsread:InvalidSheet'));
    end
    
    if isequal(sheet,-1)
        range = ''; % user requests interactive range selection.
    elseif ischar(sheet)
        if ~isempty(sheet)
            % Parse sheet and range strings
            if contains(sheet,':')
                % Range was specified in the 2nd input argument named sheet
                % Swap them and ignore the third argument.
                if nargin == 3 || ~isempty(range)
                    warning(message('MATLAB:xlsread:thirdArgument'));
                end
                range = sheet;
                sheet = Sheet1;% Use default sheet.
            end
        else
            sheet = Sheet1; % set sheet to default sheet.
        end
    end
end
if nargin > 2
    % verify class of range parameter
    if ~ischar(range)
        error(message('MATLAB:xlsread:InvalidRange'));
    end
end
if nargin >= 4
    % verify class of mode parameter
    if ~isempty(mode) && ~(strcmpi(mode,'basic'))
        warning(message('MATLAB:xlsread:InvalidMode'));
        mode = '';
    end
else
    mode = '';
end

mode = convertStringsToChars(mode);

%Decide mode
basicMode = ~ispc;
if strcmpi(mode, 'basic')
    basicMode = true;
end
if ispc && ~basicMode
    try
        Excel = matlab.io.internal.getExcelInstance;
    catch exc   %#ok<NASGU>
        warning(message('MATLAB:xlsread:ActiveX'));
        basicMode = true;
    end
end

if basicMode
    if openXMLmode
        if isequal(sheet, -1)
            sheet = 1;
            warning(message('MATLAB:xlsread:InteractiveIncompatible'));
        end
    else
        if ~isempty(range)
            warning(message('MATLAB:xlsread:RangeIncompatible'));
        end
        if isequal(sheet,1)
            sheet = '';
        elseif isequal(sheet, -1)
            sheet = '';
            warning(message('MATLAB:xlsread:InteractiveIncompatible'));
        elseif ~ischar(sheet)
            error(message('MATLAB:xlsread:InvalidSheetBasicMode'));
        end
    end
end

if nargin >= 5
    if basicMode
        warning(message('MATLAB:xlsread:Incompatible'))
    elseif ~isa(customFun,'function_handle')
        warning(message('MATLAB:xlsread:NotHandle'));
        customFun = {};
    end
else
    customFun = {};
    if nargout > 3
        error(message('MATLAB:xlsread:NoHandleForCustom' ) )
    end
end

customFun = convertStringsToChars(customFun);

% Read the spreadsheet with the appropriate mode reader.
customOutput = {};
try
    if ~basicMode
        [numericData, textData, rawData, customOutput] = xlsreadCOM(file, sheet, range, Excel, customFun);
    else
        if openXMLmode
            [numericData, textData, rawData] = xlsreadXLSX(file, sheet, range);
        else
            if nargout > 2
                [numericData, textData, rawData] = xlsreadBasic(file,sheet);
            else
                [numericData, textData] = xlsreadBasic(file,sheet);
            end
        end
    end
catch exception
    if isempty(exception.identifier)
        exception = MException('MATLAB:xlsreadold:FormatError','%s', exception.message);
    end
    throw(exception);
end

end
