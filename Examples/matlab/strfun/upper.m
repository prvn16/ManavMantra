%UPPER Convert to uppercase
%   NEWSTR = UPPER(STR) converts any lowercase characters in STR to the
%   corresponding uppercase character and leaves all other characters
%   unchanged. STR can be a string, character vector, or a cell array of
%   character vectors. NEWSTR is the same type and shape as STR.
%
%   Example:
%       STR = 'DATA.tar.gz';
%       upper(STR)          
%
%       returns  
%
%       DATA.TAR.GZ
%
%   Example:
%       STR = ["FUNDS.xlsx";"PAPER.docx"];
%       upper(STR)
%
%       returns
%
%           "FUNDS.XLSX"
%           "PAPER.DOCX"
%
%   See also LOWER, STRING, ISSTRPROP, REVERSE

%   Copyright 1984-2016 The MathWorks, Inc.