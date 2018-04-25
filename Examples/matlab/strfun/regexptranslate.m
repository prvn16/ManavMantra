%REGEXPTRANSLATE Regular expression related transformations
%   A = REGEXPTRANSLATE(OPERATION, B) Translates B using the
%   operation specified by OPERATION. OPERATION can be one of the
%   following options which will enable the corresponding translation.
%   
%     'escape'   -- Escape all special characters in B such that regexp with A
%                   will match or replace as B literally.
%     'wildcard' -- Convert the wildcard string B to a regular expression (A)
%                   that will match the same strings.
%
%   A = REGEXPTRANSLATE('flexible', B, C) Treats C as a regular expression
%   and replaces each matching pattern of C in B with the escaped regular 
%   expression of C. It is functionally equivalent to:
%   
%       A = regexprep(B, C, regexptranslate('escape', C)) 
%
%   B and C can be either character vectors or string scalars. A is returned as the 
%   same data type as B.
%
%   REGEXPTRANSLATE supports international character sets.
%
%   See also REGEXP, REGEXPI, REGEXPREP.
%

%
%   J. Breslau
%   Copyright 1984-2016 The MathWorks, Inc.
%

