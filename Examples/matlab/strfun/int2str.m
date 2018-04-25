function s = int2str(x)
%INT2STR Represent integers as character array
%   S = INT2STR(X) rounds the elements of numeric matrix X to integers and 
%   converts the result into a character array that represents the numbers.
%
%   INT2STR returns NaN and Inf elements as 'NaN' and 'Inf', respectively.
%
%   See also NUM2STR, SPRINTF, FPRINTF, MAT2STR.

%   Copyright 1984-2016 The MathWorks, Inc.

% only work with real portion of x
x = real(x);

% create a copy of x to use to calculate maximum width in digits
widthCopy = x;
if isfloat(x)
    x = 0+round(x); %remove negative zero
    % replace Inf and NaN with a number of equivalent length for width
    % calcultion
    widthCopy(~isfinite(widthCopy)) = 314;
    formatConversion = '.0f';
elseif isa(x, 'uint64')
    formatConversion = 'lu';
else
    formatConversion = 'ld';
end

if isempty(x)
    s = '';
elseif isscalar(x)
    s = sprintf(['%', formatConversion], x);
else
    % determine the variable text field width quantity
    widthMax = double(max(abs(widthCopy(:))));
    if widthMax == 0
        width = 3;
    else
        width = floor(log10(widthMax)) + 3;
    end

    format = sprintf('%%%d%s', width, formatConversion);

    [rows, cols] = size(x);
    s = char(zeros(rows, width*cols));
    for row = 1:rows
        % use vectorized version of sprintf for each row
        s(row,:) = sprintf(format, x(row,:));
    end

    % trim leading spaces from string array within constraints of rectangularity.
    s = strtrim(s);
end

