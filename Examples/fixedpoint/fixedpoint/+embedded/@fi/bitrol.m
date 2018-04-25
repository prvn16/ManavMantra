function y = bitrol(a,kin)       
% BITROL Rotate Left
%
% SYNTAX
%   C = BITROL(A, ROTATE_LEN)
% 
% DESCRIPTION
%   BITROL(A, ROTATE_LEN) performs a rotate-left operation on the stored
%   integer bits of A. Input A must be a FI fixed-point type. ROTATE_LEN
%   may be any FI type or any builtin numeric type.
%
%   ROTATE_LEN must be a constant integer value >= 0. ROTATE_LEN can be greater
%   than wordlength of A, and is normalized to mod(wordlength(A), ROTATE_LEN).
%
%   BITROL rotates both unsigned and signed fixed point inputs. There is no
%   overflow/underflow checking. FIMATH properties are ignored. The output
%   has the same numeric type and fimath properties as input A.
%
%  See also EMBEDDED.FI/BITROR, EMBEDDED.FI/BITSHIFT
%           EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRL, EMBEDDED.FI/BITSRA,            
%           EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2013 The MathWorks, Inc.

% Error checking
narginchk(2,2);

if ~(isfi(a) && isfixed(a))
    error(message('fixed:coder:fiFcnDTypeErrorFixPtOnly','BITROL'));
end

wl_a = a.WordLength;

if (wl_a == 1)
    error(message('fixed:fi:notDefinedForOneBitFi','BITROL'));
end

if ~isnumeric(kin) || ~isscalar(kin) || ~isreal(kin) || (kin < 0)
    error(message('fixed:bitsxx:invalidShiftVal','BITROL'));
end

if (kin == 0)
    y = a;
    return;
end

% normalize rotate index
kin_dbl = mod(double(kin), wl_a);

if (kin_dbl == 0)
    y = a;
    return;
end

% x << n | x >>> wl - n
t1 = bitsll(a, kin_dbl);
t2 = bitsrl(a, wl_a - kin_dbl);
y  = bitor(t1, t2);

% LocalWords:  wlen wl
