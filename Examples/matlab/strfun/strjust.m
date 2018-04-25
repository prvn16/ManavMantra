function t = strjust(s,justify)
%STRJUST Justify character array.
%   T = STRJUST(S) or T = STRJUST(S,'right') returns a right justified 
%   version of S.  S can be a character array, string array, or cell array
%   of character arrays.
%
%   T = STRJUST(S,'left') returns a left justified version of S.
%
%   T = STRJUST(S,'center') returns a center justified version of S.
%
%   See also DEBLANK, STRTRIM.

%   Copyright 1984-2016 The MathWorks, Inc.

    if nargin<2
        justify = 'right'; 
    else
        justify = lower(justify);
    end

    if ischar(s) || isnumeric(s)
        t = strjustOnChar(s, justify);
    elseif iscellstr(s) || isstring(s)
        t = s;
        num = numel(s);
        for i = 1:num
            textArray = s{i};
            if ~ischar(textArray)
                error(message('MATLAB:strjust:InputMustBeText'));
            end
            t{i} = strjustOnChar(textArray, justify);
        end
    else
        error(message('MATLAB:strjust:InputMustBeText'));
    end
end

function t = strjustOnChar(s,justify)

    if isempty(s)
        t = s; 
        return;
    end

    [m,n] = size(s);

    spaceCol = 0;
    switch justify
    case 'right'
        spaceCol = n;
    case 'left'
        spaceCol = 1;
    end

    if spaceCol
        if ~any(isspace(s(:,spaceCol)))
            t = char(s);
            return;
        end        
    end

    % Find non-pad characters
    ch = (s ~= ' ' & s ~= 0);
    [r,c] = find(ch);

    % Determine offset
    switch justify
    case 'right'
        [dum,offset] = max(fliplr(ch),[],2);
        offset =  offset - 1;
    case 'left'
        [dum,offset] = max(ch,[],2);
        offset = 1 - offset;
    case 'center'
        [dum,offsetR] = max(fliplr(ch),[],2);
        [dum,offsetL] = max(ch,[],2);
        offset = floor((offsetR - offsetL)/2);
    otherwise
        error(message('MATLAB:strjust:UnknownParameter'));
    end

    % Apply offset to justify character array
    newc = c + offset(r);
    t = repmat(' ',m,n);
    t(r + (newc-1)*m) = s(r + (c-1)*m);
end
