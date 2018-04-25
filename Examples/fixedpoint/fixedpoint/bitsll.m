function Y = bitsll(A,K)
%BITSLL Shift Left Logical
%
% SYNTAX
%   Y = BITSLL(A, K)
%
% DESCRIPTION
%   BITSLL performs a logical left shift by K bits on input operand A.
%   Input A can be any numeric type, including double, single, integer,
%   or fixed-point. K may be any FI type or any builtin numeric type.
%   K must be a scalar, integer-valued, and greater than or equal to zero.
%
%   BITSLL operates on both signed and unsigned inputs, shifting zeros
%   into the positions of bits that it shifts left.
%
%   There is no overflow/underflow checking. FIMATH properties are ignored.
%   The output has the same numeric type and fimath properties as input A.
%
%   See also BITSLL, BITSRL, BITSRA, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSRL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(2,2);

if ~isnumeric(K) || ~isscalar(K) || ~isequal(floor(K), K) || (K < 0)
    error(message('fixed:bitsxx:invalidShiftVal', 'BITSLL'));
end

switch class(A)
  case {'double','single'}
    Y = pow2(double(K)).*A;
    
  case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
    % Save existing FIPREF settings
    P = fipref;
    PreviousDTOMode = P.DataTypeOverride;
    PreviousLogMode = P.LoggingMode;
    
    % Temporarily turn off data type override and logging modes
    P.DataTypeOverride = 'ForceOff';
    P.LoggingMode      = 'Off';
    
    % Perform bit shift operation on equivalent FI data type
    Y = storedInteger(bitsll(fi(A),K));
    
    % Restore previous FIPREF settings
    P.DataTypeOverride = PreviousDTOMode;
    P.LoggingMode      = PreviousLogMode;
    
  otherwise
    error(message('fixed:bitsxx:invalidDataType', mfilename, class(A)));
end
