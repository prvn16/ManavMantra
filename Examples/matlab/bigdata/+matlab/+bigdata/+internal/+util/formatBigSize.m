function str = formatBigSize(sz)
%FORMATBIGSIZE  convert a dimension vector into a formatted string
%
%   STR = FORMATBIGSIZE(SZ) converts the dimension vector SZ into a
%   formatted string with thousands separated by commas or periods
%   according to the current locale.
%

%   Copyright 2015-2016 The MathWorks, Inc.

% Must be a row vector of non-negative integers
assert( isrow(sz) && all(sz >= 0) && all(floor(sz) == sz) );
strs = arrayfun( @iFormatOneDim, sz, 'UniformOutput', false );

str = strjoin(strs, getTimesCharacter());

end


function str = iFormatOneDim(sz)
% Convert one size number into a formatted string

if usejava('jvm')
    % Java is available, so use its built-in formatting
    loc = java.util.Locale.getDefault();
    % Java formatter replaces ',' with a localized separator
    str = char(java.lang.String.format(loc, '%,d', int64(sz)));

else
    % TODO: Without Java, how do we get the separator for the locale?
    sep = ',';

    % Work backwards, inserting a separator every 3 digits
    str = sprintf('%d',sz);
    N = length(str);
    for idx=N-3:-3:1
        str = [str(1:idx), sep, str(idx+1:end)];
    end
    
end

end
