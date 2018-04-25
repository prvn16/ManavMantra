%COUNT Returns the number of occurrences of a pattern in text.
%   C = COUNT(STR,PATTERN) returns the number of occurrences of PATTERN in
%   STR.
%
%   STR can be a string array, a character vector, or a cell array of
%   character vectors. So can PATTERN. PATTERN and STR need not be the same
%   size. If PATTERN is a string array or a cell array, then COUNT returns
%   the total number of occurrences of all elements of PATTERN in STR.
% 
%   C = COUNT(STR,PATTERN,'IgnoreCase',IGNORE) ignores case when searching 
%   for PATTERN in STR if IGNORE is true. The default value of IGNORE is false.
% 
%   Examples
%       STR = "data.tar.gz";
%       P = "tar";
%       COUNT(STR,P)                   returns  1
%
%       STR = ["abstracts.docx","data.tar.gz"];
%       P = 'tar';         
%       COUNT(STR,P)                   returns  [0 1]
%
%       STR = "data.tar.gz";
%       P = {'docx','tar'};
%       COUNT(STR,P)                   returns  1
%
%       STR = {'DATA.TAR.GZ','SUMMARY.PPT'};
%       P = "tar";
%       COUNT(STR,P,'IgnoreCase',true) returns  [1 0]
%
%   See also endsWith, startsWith, contains.

%   Copyright 2015-2017 The MathWorks, Inc.
