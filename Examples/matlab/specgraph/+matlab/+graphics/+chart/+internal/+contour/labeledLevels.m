function tf = labeledLevels(levelList, textList)
%   Given a contour level list and a "text list," return a logical vector
%   containing true for contour levels that should be labeled and false
%   otherwise.
%
%   Inputs
%   ------
%   levelList - Numerical vector listing contour levels in ascending order
%   textList  - Numerical vector listing contour levels to be labeled
%
%   Output
%   ------
%   tf - Logical vector having the same length as the levelList input.
%
%   In the output, an element is true if and only if the corresponding
%   level should be labeled. This, in turn, is determined by checking to
%   see which elements in levelList match an element in textList. A
%   tolerance of about 10 percent is used, except when both inputs have
%   integer class types.

% Copyright 2014 The MathWorks, Inc.

    tf = false(size(levelList));
    if ~isempty(levelList) && ~isempty(textList)
        textList = unique(textList);
        if isinteger(levelList) && isinteger(levelList)
            % Both lists use integer types; require exact equality.
            for k = 1:numel(levelList)
                tf(k) = any(levelList(k) == textList);
            end
        else
            % Cast both lists to double.
            textList = double(textList);
            levelList = double(levelList);

            % In order to return true for a given element of levelList,
            % require that there be an element of textList that matches it
            % to within 10 percent of the local spacing of elements in
            % levelList. (If there's only one element in levelList, require
            % a match to within 10 percent of its absolute value, or eps(1)
            % if that value is zero.)
            tol = tolerances(levelList);
            for k = 1:numel(levelList)
                tf(k) = (min(abs(levelList(k) - textList)) < tol(k));
            end
        end
    end
end

function tol = tolerances(levelList)
    if isscalar(levelList)
        if levelList == 0
            tol = eps(1);
        else
            tol = abs(levelList)/10;
        end
    else
        tol = zeros(size(levelList));
        d = abs(diff(levelList))/10;
        tol(1) = d(1);
        tol(2:end-1) = min(d(1:end-1),d(2:end));
        tol(end) = d(end);
    end
end
