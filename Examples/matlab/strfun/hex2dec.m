function d = hex2dec(h)
%HEX2DEC Convert text representation of hexadecimal number to decimal integer
%   D = HEX2DEC(H) interprets H and returns D as the equivalent decimal number. 
%   H contains text that represents hexadecimal numbers. If H represents an 
%   integer value greater than flintmax, HEX2DEC might not return an exact conversion 
%   of H.
%  
%   If H is a character array, HEX2DEC interprets each row as a hexadecimal number.
%   If H is cell array of character vectors or a string array, HEX2DEC interprets 
%   each element as a hexadecimal number.
%
%   EXAMPLES:
%       hex2dec('12B') and hex2dec('12b') both return 299
%
%   See also DEC2HEX, HEX2NUM, BIN2DEC, BASE2DEC, FLINTMAX.

%   Author: L. Shure, Revised: 12-23-91, CBM.
%   Copyright 1984-2016 The MathWorks, Inc.

    if ischar(h) || isnumeric(h)
        d = hex2decImpl(h);
    elseif iscellstr(h)
        d = hex2decImpl(char(h));
    elseif isstring(h)
        d = zeros(size(h));
        for i = 1:numel(h)
           d(i) = hex2decImpl(char(h(i)));
        end
    else        
        error(message('MATLAB:hex2dec:InputMustBeString'))
    end
end


function dec = hex2decImpl(hex)
    if isempty(hex)
        dec = [];
        return;
    end

    % Work in upper case.
    hex = upper(hex);

    [m,n]=size(hex);

    % Right justify strings and form 2-D character array.
    if ~isempty(find((hex==' ' | hex==0),1))
        hex = strjust(hex);

        % Replace any leading blanks and nulls by 0.
        hex(cumsum(hex ~= ' ' & hex ~= 0,2) == 0) = '0';
    else
        hex = reshape(hex,m,n);
    end

    % Check for out of range values
    if nnz(~((hex>='0' & hex<='9') | (hex>='A'&hex<='F')))
        error(message('MATLAB:hex2dec:IllegalHexadecimal'));
    end

    sixteen = 16;
    p = fliplr(cumprod([1 sixteen(ones(1,n-1))]));
    p = p(ones(m,1),:);

    dec = hex <= 64; % Numbers
    hex(dec) = hex(dec) - 48;

    dec =  hex > 64; % Letters
    hex(dec) = hex(dec) - 55;

    dec = sum(hex.*p,2);
end