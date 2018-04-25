%ENDSWITH True if text ends with pattern.
%   TF = endsWith(STR,PATTERN) returns 1 (true) if STR ends with PATTERN,
%   and returns 0 (false) otherwise.
%
%   STR can be a string array, a character vector, or a cell array of
%   character vectors. So can PATTERN. PATTERN and STR need not be the same
%   size. If PATTERN is a string array or cell array, then endsWith returns
%   true if STR ends with any element of PATTERN. If STR is a string array
%   or cell array, then TF is a logical array that is the same size.
%
%   TF = endsWith(STR,PATTERN,'IgnoreCase',IGNORE) ignores case when searching 
%   for PATTERN at the end of STR if IGNORE is true. The default value of IGNORE 
%   is false.
%
%   Examples
%       STR = "data.tar.gz";
%       P = "gz";
%       endsWith(STR,P)                   returns  1
%
%       STR = ["abstracts.docx","data.tar.gz"];
%       P = 'docx';         
%       endsWith(STR,P)                   returns  [1 0]
%
%       STR = "abstracts.docx";
%       P = {'docx','tar.gz'};
%       endsWith(STR,P)                   returns  1
%
%       STR = {'DATA.TAR.GZ','SUMMARY.PPT'};
%       P = "ppt";
%       endsWith(STR,P,'IgnoreCase',true) returns  [0 1]
%
%   See also startsWith, contains.

%   Copyright 2015-2017 The MathWorks, Inc.
