function x = hex2num(s)
%HEX2NUM Convert IEEE hexadecimal string to double precision number
%   HEX2NUM(S), where S contains a 16-character representation of
%   a hexadecimal number, returns the IEEE double precision
%   floating point number it represents. If S has fewer than 16 
%   characters, then HEX2NUM pads to the right with zeroes.
%
%   If S is a character array, then HEX2NUM interprets each row as a
%   double precision number. If S is a cell array of character vectors,
%   then HEX2NUM interprets each element as a double precision number.
%
%   HEX2NUM handles NaN, Inf, and denorm values correctly.
%
%   Example:
%       hex2num('400921fb54442d18') returns Pi. 
%       hex2num('bff') returns -1.
%
%   See also NUM2HEX, HEX2DEC, SPRINTF, FORMAT.

%   Copyright 1984-2016 The MathWorks, Inc.

    if ischar(s)
        x = hex2decImpl(s);
    elseif iscellstr(s)
        x = hex2decImpl(char(s));
    elseif isstring(s)
        x = zeros(size(s));
        for i = 1:numel(s)
            x(i) = hex2decImpl(char(s(i)));
        end
    else
        error(message('MATLAB:hex2num:InputMustBeString'))
    end
end


function num = hex2decImpl(dec)

    if isempty(dec)
        num = [];
        return;
    end

    blanks = find(dec==' '); % Find the blanks at the end
    if ~isempty(blanks)
        dec(blanks) = '0';
    end % Zero pad the shorter hex numbers.

    [row,col] = size(dec);
    d = zeros(row,16);
    % Convert '0':'9' to 0:9;
    d(:,1:col) = abs(lower(dec)) - '0';
    % Compensate for the above to convert 'a':'f' to 10:15.
    d = d - 39.*(d>9);

    if any(d(:) > 15) || any(d(:) < 0)
        error(message('MATLAB:hex2num:OutOfRange'))
    end

    % More than 16 characters are truncated.
    if col > 16
        d(:, col:end) = [];
    end

    num = uint8(d);
    % We assume little endian hence the flip.
    num = flip((16*num(:, 1:2:end) + num(:, 2:2:end)).');
    num = typecast(num(:), 'double');
end
