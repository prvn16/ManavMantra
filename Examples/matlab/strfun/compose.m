function s = compose(fmt, varargin)
%COMPOSE Converts data into formatted string arrays
%   STR = COMPOSE(TXT) translates the escape-character sequences in the
%   input text TXT and leaves all other characters unchanged.
%   Escape-character sequences represent nonprinting characters such as
%   newlines or tabs.
%
%   STR = COMPOSE(FORMAT, A1, ..., AN) formats values from  A1, ..., AN
%   using formatting operators specified by FORMAT and returns the
%   resulting text in STR. COMPOSE formats the values from  A1, ..., AN in
%   column order.
% 
%   FORMAT can be a string array, character vector, or cell array of
%   character vectors. If FORMAT is a string array then STR is a string 
%   array. Otherwise, STR is a cell array of character vectors.
%
%   * If  A1, ..., AN have multiple rows, COMPOSE repeats FORMAT in each
%     row of STR, with formatted values from the corresponding row of 
%     A1, ..., AN.
%   * If the number of columns in  A1, ..., AN exceed the number of
%     operators in FORMAT, COMPOSE repeats FORMAT as an additional column
%     of STR. The extra columns of A1, ..., AN contribute formatted values
%     to the new column of strings in STR.
%   * If the number of columns in  A1, ..., AN are less than the number of
%     operators in FORMAT, then COMPOSE does not format values using those
%     operators. Instead, COMPOSE leaves formatting operators in STR.
% 
%   Conversion operators with the processing-order identifier (n$ syntax)
%   and * field width are not supported.
% 
%   Example:
%       TXT = "The quick brown fox jumps";
%       TXT = TXT + '\n' + 'over the lazy dog.';
%       compose(TXT)
%
%       returns
%
%           "The quick brown fox jumps
%            over the lazy dog."
%   
%   Example:
%       F = "pi = %.5f";
%       compose(F, pi)
%
%       returns
% 
%           "pi = 3.14159"
%
%   Example:
%       F = "pi = %.2f, e = %.5f";
%       compose(F, [pi,exp(1)])         
%
%       returns  
%
%           "pi = 3.14, e = 2.71828"
%
%   Example:
%       F = "real = %3.2f, imag = %3.2f";
%       A = [4+6i;2.3+5.7i;6.1+2i;0.5+7i];
%       compose(F, [real(A),imag(A)])
%
%       returns  
%
%           "real = 4.00, imag = 6.00"
%           "real = 2.30, imag = 5.70"
%           "real = 6.10, imag = 2.00"
%           "real = 0.50, imag = 7.00"
%
%   Example:
%       F = 'The time is %d:%d';
%       A = [8,15,9,30;12,23,11,46];
%       compose(F,A)                 
%
%       returns  
%
%           'The time is 8:15'     'The time is 9:30' 
%           'The time is 12:23'    'The time is 11:46'
%
%   See also SPRINTF, NEWLINE, STRING, STRING/PLUS

%   Copyright 2015-2017 The MathWorks, Inc.

    narginchk(1, Inf);
    if ~isTextStrict(fmt)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(fmt);
        s = s.compose(varargin{:});
        
        if ~isstring(fmt)
            s = cellstr(s);
        end
        
    catch E
        throw(E);
    end
end
