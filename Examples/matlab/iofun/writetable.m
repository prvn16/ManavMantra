function writetable(a,filename,varargin)
%WRITETABLE Write a table to a file.
%   WRITETABLE(T) writes the table T to a comma-delimited text file. The file name is
%   the workspace name of the table T, appended with '.txt'. If WRITETABLE cannot
%   construct the file name from the table input, it writes to the file 'table.txt'.
%   WRITETABLE overwrites any existing file.
%
%   WRITETABLE(T,FILENAME) writes the table T to the file FILENAME as column-oriented
%   data. WRITETABLE determines the file format from its extension. The extension
%   must be one of those listed below.
%
%   WRITETABLE(T,FILENAME,'FileType',FILETYPE) specifies the file type, where
%   FILETYPE is one of 'text' or 'spreadsheet'.
%
%   WRITETABLE writes data to different file types as follows:
%
%   .txt, .dat, .csv:  Delimited text file (comma-delimited by default).
%
%          WRITETABLE creates a column-oriented text file, i.e., each column of each
%          variable in T is written out as a column in the file. T's variable names
%          are written out as column headings in the first line of the file.
%
%          Use the following optional parameter name/value pairs to control how data
%          are written to a delimited text file:
%
%          'Delimiter'      The delimiter used in the file. Can be any of ' ',
%                           '\t', ',', ';', '|' or their corresponding names 'space',
%                           'tab', 'comma', 'semi', or 'bar'. Default is ','.
%
%          'WriteVariableNames'  A logical value that specifies whether or not
%                           T's variable names are written out as column headings.
%                           Default is true.
%
%          'WriteRowNames'  A logical value that specifies whether or not T's
%                           row names are written out as first column of the file.
%                           Default is false. If the 'WriteVariableNames' and
%                           'WriteRowNames' parameter values are both true, T's first
%                           dimension name is written out as the column heading for
%                           the first column of the file.
%
%          'QuoteStrings'   A logical value that specifies whether to write
%                           text out enclosed in double quotes ("..."). If
%                           'QuoteStrings' is true, any double quote characters that
%                           appear as part of a text variable are replaced by two
%                           double quote characters.
%
%          'DateLocale'     The locale that writetable uses to create month and 
%                           day names when writing datetimes to the file. LOCALE must
%                           be a character vector or scalar string in the form xx_YY.
%                           See the documentation forDATETIME for more information.
%
%          'Encoding'       The encoding to use when creating the file.
%                           Default is 'system' which means use the system's default
%                           file encoding.
%
%   .xls, .xlsx, .xlsb, .xlsm, .xltx, .xltm:  Spreadsheet file.
%
%          WRITETABLE creates a column-oriented spreadsheet file, i.e., each column
%          of each variable in T is written out as a column in the file. T's variable
%          names are written out as column headings in the first row of the file.
%
%          Use the following optional parameter name/value pairs to control how data
%          are written to a spreadsheet file:
%
%          'WriteVariableNames'  A logical value that specifies whether or not
%                           T's variable names are written out as column headings.
%                           Default is true.
%
%          'WriteRowNames'  A logical value that specifies whether or not T's row
%                           names are written out as first column of the specified
%                           region of the file. Default is false. If the
%                           'WriteVariableNames' and 'WriteRowNames' parameter values
%                           are both true, T's first dimension name is written out as
%                           the column heading for the first column.
%
%          'DateLocale'     The locale that writetable uses to create month and day
%                           names when writing datetimes to the file. LOCALE must be
%                           a character vector or scalar string in the form xx_YY.
%                           Note: The 'DateLocale' parameter value is ignored
%                           whenever dates can be written as Excel-formatted dates.
%
%          'Sheet'          The sheet to write, specified the worksheet name, or a
%                           positive integer indicating the worksheet index.
%
%          'Range'          A character vector or scalar string that specifies a
%                           rectangular portion of the worksheet to write, using the
%                           Excel A1 reference style.
%
%   In some cases, WRITETABLE creates a file that does not represent T exactly, as
%   described below. If you use TABLE(FILENAME) to read that file back in and create
%   a new table, the result may not have exactly the same format or contents as the
%   original table.
%
%   *  WRITETABLE writes out numeric variables using long g format, and
%      categorical or character variables as unquoted text.
%   *  For non-character variables that have more than one column, WRITETABLE
%      writes out multiple delimiter-separated fields on each line, and constructs
%      suitable column headings for the first line of the file.
%   *  WRITETABLE writes out variables that have more than two dimensions as two
%      dimensional variables, with trailing dimensions collapsed.
%   *  For cell-valued variables, WRITE writes out the contents of each cell
%      as a single row, in multiple delimiter-separated fields, when the contents are
%      numeric, logical, character, or categorical, and writes out a single empty
%      field otherwise.
%
%   Save T as a mat file if you need to import it again as a table.
%      
%   See also TABLE, READTABLE.

%   Copyright 2012-2016 The MathWorks, Inc.

if isa(a,'timetable')
    error(message('MATLAB:table:write:TimetableNotSupported'));
end

if nargin < 2
    tablename = inputname(1);
    if isempty(tablename)
        tablename = 'table';
    end
    filename = [tablename '.txt'];
end
[a, filename, varargin{:}] = matlab.io.internal.utility.convertStringsToChars(a,filename,varargin{:});
write(a,filename,varargin{:})
