function s = num2str(x, f)
%NUM2STR Convert numbers to character representation
%   T = NUM2STR(X) converts the matrix X into its character representation T
%   with about 4 digits and an exponent if required.  This is useful for
%   labeling plots with the TITLE, XLABEL, YLABEL, and TEXT commands.
%
%   T = NUM2STR(X,N) converts the matrix X into a character representation
%   with a maximum N digits of precision.  The default number of digits is
%   based on the magnitude of the elements of X.
%
%   T = NUM2STR(X,FORMAT) uses the format specifier FORMAT (see SPRINTF for
%   details).
%
%   Example:
%       num2str(randn(2,2),3) produces a character representation such as
%
%        1.44    -0.755
%       0.325      1.37
%
%   Example:
%       num2str(rand(2,3) * 9999, '%10.5e\n') produces a character
%       representation such as
%
%       8.14642e+03
%       1.26974e+03
%       6.32296e+03
%       9.05701e+03
%       9.13285e+03
%       9.75307e+02
%
%   See also INT2STR, SPRINTF, FPRINTF, MAT2STR, STRING.

%   Copyright 1984-2017 The MathWorks, Inc.
%------------------------------------------------------------------------------
    if nargin > 0
        x = convertStringsToChars(x);
    end
    
    if nargin > 1
        f = convertStringsToChars(f);
    end
    
    narginchk(1,2);
    if ischar(x)
        s = x;
        return;
    end
    if isempty(x)
        s = '';
        return
    end
    if ~isnumeric(x) && ~islogical(x)
        error(message('MATLAB:num2str:nonNumericInput') );
    end
    if isfloat(x)
        x = 0+x;  % Remove negative zero
    end
    if issparse(x)
        x = full(x);
    end
    intFieldExtra = 1;
    maxFieldWidth = 12;
    floatWidthOffset = 4;
    forceWidth = 0;
    padColumnsWithSpace = true;
    % Compose sprintf format string of numeric array.
        
    if nargin < 2 || (isinteger(x) && isnumeric(f))
        
        % To get the width of the elements in the output string
        widthCopy = x;
        % replace Inf and NaN with a number of equivalent length (3 digits) for width
        % calcultion
        if isfloat(x)
            widthCopy(~isfinite(widthCopy)) = 314; %This could be any 3 digit number
        end
        xmax = double(max(abs(widthCopy(:))));
        if isequaln(x, fix(x)) && (isinteger(x) || eps(xmax) <= 1)
            if isreal(x)
                s = int2str(x); % Enhance the performance
                return;
            end         

            d = min(maxFieldWidth, floor(log10(xmax)) + 1);
            forceWidth = d+intFieldExtra;
            f = '%d';
        else
            % The precision is unspecified; the numeric array contains floating point
            % numbers.
            if xmax == 0
                d = 1;
            else
                d = min(maxFieldWidth, max(1, floor(log10(xmax))+1))+floatWidthOffset;
            end
            
            [s, forceWidth, f] = handleNumericPrecision(x, d);

            if ~isempty(s)
                return;
            end
        end
    elseif isnumeric(f)
        f = round(real(f));

        [s, forceWidth, f] = handleNumericPrecision(x, f);

        if ~isempty(s)
            return;
        end
    elseif ischar(f)
        % Precision is specified as an ANSI C print format string.
        
        % Explicit format strings should be explicitly padded
        padColumnsWithSpace = false;
        
        % Validate format string
        k = strfind(f,'%');
        if isempty(k)
            error(message('MATLAB:num2str:fmtInvalid', f));
        end
    else
        error(message('MATLAB:num2str:invalidSecondArgument'))        
    end

    %-------------------------------------------------------------------------------
    % Print numeric array as a string image of itself.

    if isreal(x)
        [raw, isLeft] = cellPrintf(f, x, false);
        [m,n] = size(raw);
        cols = cell(1,n);
        widths = zeros(1,n);
        for j = 1:n
            if isLeft
                cols{j} = char(raw(:,j));
            else
                cols{j} = strvrcat(raw(:,j));
            end
            widths(j) = size(cols{j}, 2);
        end
    else
        forceWidth = 2*forceWidth + 2;
        raw = cellPrintf(f, real(x), false);
        imagRaw = cellPrintf(f, imag(x), true);
        [m,n] = size(raw);
        cols = cell(1,n);
        widths = zeros(1,n);
        for j = 1:n
            cols{j} = [strvrcat(raw(:,j)) char(imagRaw(:,j))];
            widths(j) = size(cols{j}, 2);
        end
    end

    maxWidth = max([widths forceWidth]);
    padWidths = maxWidth - widths;
    padIndex = find(padWidths, 1);
    while ~isempty(padIndex)
        padWidth = padWidths(padIndex);
        padCols = (padWidths==padWidth);
        padWidths(padCols) = 0;
        spaceCols = char(ones(m,padWidth)*' ');
        cols(padCols) = strcat({spaceCols}, cols(padCols));
        padIndex = find(padWidths, 1);
    end

    if padColumnsWithSpace
        spaceCols = char(ones(m,1)*' ');
        cols = strcat(cols, {spaceCols});
    end

    s = strtrim([cols{:}]);
end

function s = strvrcat(c)
    s = strjust(char(c));
end

function [cells, isLeft] = cellPrintf(f, x, b)
    try
        [cells, err, isLeft] = sprintfc(f, x, b);
        if ~isempty(err)
            warning(message('MATLAB:num2str:badConversion', err));
        end
    catch e
        warning(e.identifier, e.message);
        cells = {''};
        isLeft = false;
    end
end

function [s, forceWidth, f] = handleNumericPrecision(x, precision)
    if isreal(x)
        s = convertUsingRecycledSprintf(x, precision);
        forceWidth = 0;
        f = '';
    else
        floatFieldExtra = 6;
        s = '';
        forceWidth = precision+floatFieldExtra;
        f = sprintf('%%.%dg', precision);
    end
end

function s = convertUsingRecycledSprintf(x, d)
    floatFieldExtra = 7;
    f = sprintf('%%%.0f.%.0fg', d+floatFieldExtra, d);
    
    [m, n] = size(x);
    scell = cell(1,m);
    pads = logical([]);
    for i = 1:m
        scell{i} =  sprintf(f,x(i,:));
        if n > 1 && (min(x(i,:)) < 0)
            pads(regexp(scell{i}, '([^\sEe])-')) = true;
        end
    end

    s = char(scell{:});

    pads = find(pads);
    if ~isempty(pads)
        pads = fliplr(pads);
        spacecol = char(ones(m,1)*' ');
        for pad = pads
            s = [s(:,1:pad) spacecol s(:,pad+1:end)];
        end
    end
    
    s = strtrim(s);
end