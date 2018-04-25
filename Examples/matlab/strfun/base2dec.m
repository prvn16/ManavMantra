function dec = base2dec(str,base)
%BASE2DEC Convert text representation of number in base B to decimal integer
%   BASE2DEC(S,B) converts S, text that represents a number in base B, to
%   its decimal (base 10) equivalent.  B must be an integer between 2 and
%   36. S must represent a non-negative integer value. If S represents an
%   integer value greater than flintmax, BASE2DEC might not return an exact
%   conversion.
%
%   S can be a character array, a cell array of character vectors, or a
%   string array. If S is a character array, each row is taken to represent
%   a number in base B.
%
%   Example
%      base2dec('212',3) returns 23
%
%   See also DEC2BASE, HEX2DEC, BIN2DEC, FLINTMAX.

%   Copyright 1984-2016 The MathWorks, Inc.

%   Douglas M. Schwarz, 18 February 1996

    narginchk(2,2);
    if (base < 1 || base > 36 || floor(base) ~= base)
        error(message('MATLAB:base2dec:InvalidBase'));
    elseif ~isstring(str)        
        dec = base2decImpl(str,base);
    elseif any(ismissing(str(:)))
        error(message('MATLAB:string:MissingNotSupported'));
    else
        % Handle string arrays
        dec = zeros(size(str));
        for i = 1:numel(str)
           dec(i) = base2decImpl(str(i),base);
        end
    end
end

function d = base2decImpl(h,b)
    h = char(h);
    if isempty(h)
        d = []; 
        return;
    end

    if ~isempty(find(h==' ' | h==0,1)) 
      h = strjust(h);
      h(h==' ' | h==0) = '0';
    end
    
    % BASE2DEC accepts numbers like 12abf in base 16
    h = upper(h);

    [m,n] = size(h);
    bArr = [ones(m,1) cumprod(b(ones(m,n-1)),2)];
    values = -1*ones(256,1);
    values(double('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')) = 0:35;
    if any(any(values(h) >= b | values(h) < 0))
        error(message('MATLAB:base2dec:NumberOutsideRange', h,b));
    end
    a = fliplr(reshape(values(abs(h)),size(h)));
    d = sum((bArr .* a),2);
end