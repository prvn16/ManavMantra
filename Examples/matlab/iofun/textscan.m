%function [varargout] = textscan(varargin) TEXTSCAN Read formatted data from text
%file, character vector, or scalar string.
%   C = TEXTSCAN(FID,'FORMAT') reads data from an open text file identified by FID
%   into cell array C. Use FOPEN to open the file and obtain FID. The FORMAT is a
%   character vector or scalar string of conversion specifiers. The number of
%   specifiers determines the number of cells in the cell array C. For more 
%   information, see "Format Options."
%   
%   C = TEXTSCAN(FID,'FORMAT',N) reads data from the file, using the FORMAT N times,
%   where N is a positive integer. To read additional data from the file after N
%   cycles, call TEXTSCAN again using the original FID.
%
%   C = TEXTSCAN(FID,'FORMAT','PARAM',VALUE) accepts one or more comma-separated
%   parameter name/value pairs. For a list of parameters and values, see "Parameter
%   Options."
%
%   C = TEXTSCAN(FID,'FORMAT',N,'PARAM',VALUE) reads data from the file, using the
%   FORMAT N times, and using settings specified by pairs of PARAM/VALUE arguments.
%
%   C = TEXTSCAN(TEXT,...) reads data from the character vector or scalar string
%   TEXT. You can use the FORMAT, N, and PARAM/VALUE arguments described above with
%   this syntax. Unlike with file identifiers, repeated calls to TEXTSCAN restart the
%   scan from the beginning of the text array each time. (To restart a scan from the
%   last position, request a POSITION output. See also Example 3.)
%
%   [C, POSITION] = TEXTSCAN(...) returns the position at the end of the scan as the
%   second output argument. For a file, this is the value that FTELL(FID) would
%   return after calling TEXTSCAN. For a text, POSITION indicates how many characters
%   TEXTSCAN read.
%
%   Notes:
%
%   When TEXTSCAN reads a specified file or text, it attempts to match the data to
%   the format specifier. If TEXTSCAN fails to convert a data field, it stops reading
%   and returns all fields read before the failure.
%
%   Format Options:
%
%   The FORMAT specifier is of the form:  %<WIDTH>.<PREC><TYPESPECIFIER>
%       <TYPESPECIFIER> is required; <WIDTH> and <PREC> are optional. <WIDTH> is the
%       number of characters or digits to read. <PREC> applies only to the family of
%       %f specifiers, and specifies the number of digits to read to the right of the
%       decimal point.
%
%   Supported values for TYPESPECIFIER:
%
%       Numeric Input Type   Specifier   Output Class
%       ------------------   ---------   ------------
%       Integer, signed        %d          int32
%                              %d8         int8
%                              %d16        int16
%                              %d32        int32
%                              %d64        int64
%       Integer, unsigned      %u          uint32
%                              %u8         uint8
%                              %u16        uint16
%                              %u32        uint32
%                              %u64        uint64
%       Floating-point number  %f          double
%                              %f32        single
%                              %f64        double
%                              %n          double
%
%       TEXTSCAN converts numeric fields to the specified output type according to
%       MATLAB rules regarding overflow, truncation, and the use of NaN, Inf, and
%       -Inf. For example, MATLAB represents an integer NaN as zero.
%
%       TEXTSCAN imports any complex number as a whole into a complex numeric field,
%       converting the real and imaginary parts to the specified type (such as %d or
%       %f). Do not include embedded white space in a complex number.
%
%       Text Arrays        Specifier  Details 
%       -----------------  ---------  ------------------------- 
%       Text                 %s       Returns text array containing the data up to
%                                     the next delimiter, or end-of-line character.
%                                     The type of the text array depends on the value
%                                     of TextType parameter.
%
%       Quoted Text          %q       Same as Text except leading and trailing
%                                     double-quote characters are removed.
%                                     Note: Use quoted text to capture delimiters,
%                                     whitespace or end-of-line characters enclosed
%                                     by pairs of double quotes.
%
%       Character Array      %c       Single character, including delimiters,
%                                     whitespace, or end of line characters. This
%                                     data is returned as a character array.
%
%       Pattern-matching     %[...]   Read only characters in the brackets, until the
%                                     first non-matching character. To include ] in
%                                     the set, specify it first: %[]...].
%
%                            %[^...]  Read only characters not in the brackets, until
%                                     the first matching character. To exclude ],
%                                     specify it first: %[^]...].
%
%       Other Types  Specifier  Details
%       -----------  ---------  ---------------------------------
%       Categorical      %C     CATEGORICAL array whose categories are defined by the
%                               text in the file. Note: the text "<undefined>" is
%                               always converted to an undefined value in the output
%                               categorical array.
%
%       Datetime         %D     DATETIME array from date or time data. TEXTSCAN
%                               reads text, and converts them into DATETIME values.
%
%       Datetime      %{fmt}D   DATETIME array with a format. Same as %D but uses the
%                               format supplied by fmt. (e.g. %{dd/MM/yyyy}D) text
%                               that does not match the format is converted to NaT
%                               (Not a Time) values.
%
%       Duration         %T     DURATION array from time data. TEXTSCAN
%                               reads text, and converts them into DURATION values.
%
%       Duration      %{fmt}T   DURATION array with a format. Same as %T but uses the
%                               format supplied by fmt. (e.g. %{hh:mm}T) text
%                               that does not match the format is converted
%                               to NaN.
%
%   Reading Numbers with Width and Precision:
%
%       Format specifiers for TEXTSCAN may include a width or precision sub-field. A
%       specifier may contain a width, (e.g. %6s) a precision (e.g. %.3f) or both
%       (e.g. %3.2f).
%
%       Specifier   Format          Action Taken
%       ---------   -------------   ------------
%        %w.p...    %f,%d,%u,%n     Reads at most w characters (including
%                                   sign, decimal and exponent characters) and
%                                   converts that to a number. If p is specified,
%                                   reads only up to p digits after the decimal
%                                   place, but not more than w total characters.
%
%                   %c              Exactly w characters are read into a char
%                                   array. Precision is ignored.
%
%                   %s,%q           Reads up to w characters or to the next
%                                   delimiter or end-of-line. Precision is ignored.
%
%                   %[...],%[^...]  Reads up to w characters or until the
%                                   pattern does not match. Precision is ignored.
%
%   Skipping fields or parts of fields:
%
%       Specifier  Action Taken
%       ---------  ------------
%         %*...    Skip the field. TEXTSCAN does not create an output cell.
%                  Although the field is skipped, TEXTSCAN may still error if the
%                  field cannot be read.
%
%       Alternatively, include literal text to ignore in the specifier. For example,
%       'Level%u8' reads 'Level1' as 1.
%
%       TEXTSCAN does not include leading white-space characters in the processing of
%       any data fields. When processing numeric data, TEXTSCAN also ignores trailing
%       white space.
%
%       If you use the default (white space) field delimiter, TEXTSCAN interprets
%       repeated white-space characters as a single delimiter. If you specify a
%       non-default delimiter, TEXTSCAN interprets repeated delimiter characters as
%       separate delimiters, and returns an empty value to the output cell.
%
%   Parameter Options:
%
%        Parameter      Value                               Default
%        ---------      -----                               -------
%        CollectOutput  If true, TEXTSCAN concatenates      0 (false)
%                       consecutive output cells with the
%                       same data type into a single array.
%
%        CommentStyle   Symbol(s) designating text to       None
%                       ignore. Specify a character vector 
%                        or scalar string
%                       (such as '%') to ignore characters
%                       following the matching text on the 
%                       same line. Specify a cell array of  
%                       two character vectors or a 
%                       two-element string array 
%                       (such as {'/*', '*/'})  to ignore 
%                       characters between the the two 
%                       text symbols. TEXTSCAN checks for
%                       comments only at the start of each
%                       field, not within a field.
%       
%        DateLocale     Locale to use with %D format        None
%                       specifiers when reading month
%                       names/abbreviations from a locale 
%                       different than the system locale.
%
%        Delimiter      Field delimiter character(s)        White space 
%                       Multiple character delimiters can
%                       be specified by cell arrays of 
%                       character vectors or string array.
%
%        EmptyValue     Value to return for empty numeric   NaN
%                       fields in delimited files
%
%        EndOfLine      End-of-line character. Can be any   Detected from 
%                       single character, or '\r\n'. If     file: \n, \r, 
%                       EndOfLine is '\r\n', TEXTSCAN       or \r\n
%                       treats any of the following as a 
%                       line ending:\n, \r, or \r\n. Can be
%                       specified as a character vector or
%                       scalar string.
%
%        ExpChars       Characters used to indicate an          'eEdD'
%                       exponent in numeric data. Can be 
%                       specified as a character vector or 
%                       scalar string.
%
%        Headerlines    Number of lines to skip. Includes   0
%                       the remainder of the current line.
%
%        MultipleDelimsAsOne                                0 (false)
%                       If true, TEXTSCAN treats 
%                       consecutive delimiters as a single 
%                       delimiter. Only valid if you 
%                       specify the 'Delimiter' option.
%
%        ReturnOnError  Determines behavior when TEXTSCAN   1 (true)
%                       fails to read or convert. If true,
%                       TEXTSCAN terminates without error
%                       and returns all fields read. If 
%                       false, TEXTSCAN terminates with an
%                       error and does not return an output
%                       cell array.
%
%        TreatAsEmpty   Text in the data file to            None
%                       treat as an empty value. Can be a
%                       character vector, cell array of 
%                       character vectors, or a string 
%                       array. Only applies to numeric 
%                       fields.
%
%        Whitespace     White-space characters              ' \b\t'
%
%        TextType       The output type of text variables. Text variables
%                       are those with %s, %q, or %[...] formats. It can
%                       have either of the following values:
%                             'char'   - Return text as a cell array of
%                                        character vectors. 
%                             'string' - Return text as
%                                        a string array.
%
%   Examples:
%
%   Example 1: Read each column of a text file.
%       Suppose the text file 'mydata.dat' contains the following:
%           Sally Level1 12.34 45 1.23e10 inf Nan Yes 5.1+3i
%           Joe   Level2 23.54 60 9e19 -inf  0.001 No 2.2-.5i
%           Bill  Level3 34.90 12 2e5   10  100   No 3.1+.1i
%
%       Read the file:
%           fid = fopen('mydata.dat');
%           C = textscan(fid, '%s%s%f32%d8%u%f%f%s%f');
%           fclose(fid);
%
%       TEXTSCAN returns a 1-by-9 cell array C with the following cells:
%           C{1} = {'Sally','Joe','Bill'}            %class cell
%           C{2} = {'Level1'; 'Level2'; 'Level3'}    %class cell
%           C{3} = [12.34;23.54;34.9]                %class single
%           C{4} = [45;60;12]                        %class int8
%           C{5} = [4294967295; 4294967295; 200000]  %class uint32
%           C{6} = [Inf;-Inf;10]                     %class double
%           C{7} = [NaN;0.001;100]                   %class double 
%           C{8} = {'Yes','No','No'}                 %class cell
%           C{9} = [5.1+3.0i; 2.2-0.5i; 3.1+0.1i]    %class double
%
%       The first two elements of C{5} are the maximum values for a 32-bit 
%       unsigned integer, or intmax('uint32').
%
%   Example 2: Read in memory text, truncating each value to one decimal digit.
%       str = '0.41 8.24 3.57 6.24 9.27';
%       C = textscan(str, '%3.1f %*1c');
%       
%       TEXTSCAN returns a 1-by-1 cell array C:
%           C{1} = [0.4; 8.2; 3.5; 6.2; 9.2]
%
%   Example 3: Resume a text scan of a scalar string.
%       lyric = "Blackbird singing in the dead of night";
%       [firstword, pos] = textscan(lyric,"%9c", 1);       %first word
%       lastpart = textscan(extractAfter(lyric,pos), "%s");%remaining text
%
%   For additional examples, type "doc textscan" at the command prompt.
%
%   See also FOPEN, FCLOSE, LOAD, IMPORTDATA, UIIMPORT, DLMREAD, XLSREAD, FSCANF, FREAD.

%   Copyright 1984-2017 The MathWorks, Inc.
