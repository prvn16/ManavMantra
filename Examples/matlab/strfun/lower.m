%LOWER Convert to lowercase
%   NEWSTR = LOWER(STR) converts any uppercase characters in STR to the
%   corresponding lowercase character and leaves all other characters
%   unchanged. STR can be a string, character vector, or a cell array of
%   character vectors. NEWSTR is the same type and shape as STR.
%
%   Example:
%       STR = 'DATA.tar.gz';
%       lower(STR)          
%
%       returns  
%
%       data.tar.gz
%
%   Example:
%       STR = ["FUNDS.xlsx","PAPER.docx"];
%       lower(STR)
%
%       returns
%
%           "funds.xlsx"
%           "paper.docx"
%
%   See also UPPER, STRING, ISSTRPROP, REVERSE

%   Copyright 1984-2016 The MathWorks, Inc.