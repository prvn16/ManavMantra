function len = strlength(s)
%STRLENGTH Lengths of text elements.
%   L = STRLENGTH(STR) returns the number of characters in STR.
%
%   STR can be a string array, a character vector, or a cell array of
%   character vectors. If STR is a string array or cell array, then L is a
%   numeric array, where each element is the number of characters in the
%   corresponding element of STR.
% 
%   Example:
%       STR = "data.xlsx";
%       strlength(STR)      
%
%       returns  
%
%            9
% 
%   Example:
%       STR = 'annualReport.docx';
%       strlength(STR)      
%
%       returns  
%
%           17
% 
%   Example:
%       STR = ["funds.xlsx";"demo.ppt"];
%       strlength(STR)      
%
%       returns  
%
%           10
%            8
%
%   See also LENGTH.

%   Copyright 2014-2017 The MathWorks, Inc.

    narginchk(1, 1);

    if ischar(s) && (isempty(s) || isrow(s))
        len = numel(s);
    elseif iscell(s)
        len = zeros(size(s));
        for idx = 1:numel(s)
            element = s{idx};
            if ischar(element) && (isempty(element) || isrow(element))
                len(idx) = numel(element);
            else
                error(firstInputErrorMessage);
            end
        end
    else
        error(firstInputErrorMessage);
    end
end

function msg = firstInputErrorMessage()
    firstInput = getString(message('MATLAB:string:FirstInput'));
    msg = message('MATLAB:string:MustBeCharCellArrayOrString', firstInput);
end