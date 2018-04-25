function this = fimath(varargin)
%FIMATH Constructor for FIMATH object
%   F = FIMATH constructs a fixed-point math object. The property values are either set to the 
%   MATLAB factory default or to the user configured default.
%
%   F = FIMATH('PropertyName1',PropertyValue1,...) constructs a
%   fixed-point math object with the named properties set to their
%   corresponding values.
%
%   FIMATH properties:
%     CastBeforeSum                - Whether both operands are cast to the sum 
%                                    data type before addition
%     MaxProductWordLength         - Maximum allowable word length for the
%                                    product data type (range: 2 to 65535)
%     MaxSumWordLength             - Maximum allowable word length for the sum 
%                                    data type (range: 2 to 65535)
%     OverflowAction               - Overflow action: {Saturate, Wrap}
%     ProductBias                  - Bias of the product data type
%     ProductFixedExponent         - Fixed exponent of the product data type
%     ProductFractionLength        - Fraction length, in bits, of the product
%                                    data type
%     ProductMode                  - Defines how the product data type is determined:
%                                       {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}
%     ProductSlope                 - Slope of the product data type
%     ProductSlopeAdjustmentFactor - Slope adjustment factor of the product data type
%     ProductWordLength            - Word length, in bits, of the product data type
%     RoundingMethod               - Rounding method: {Ceiling, Convergent, Floor, Nearest, Round, Zero}
%     SumBias                      - Bias of the sum data type
%     SumFixedExponent             - Fixed exponent of the sum data type
%     SumFractionLength            - Fraction length, in bits, of the sum data type
%     SumMode                      - Defines how the sum data type is determined:
%                                       {FullPrecision, KeepLSB, KeepMSB, SpecifyPrecision}
%     SumSlope                     - Slope of the sum data type
%     SumSlopeAdjustmentFactor     - Slope adjustment factor of the sum data type
%     SumWordLength                - Word length, in bits, of the sum data type when ProductMode 
%                                    is one of KeepLSB, KeepMSB, or SpecifyPrecision
% 
%
%   Example:
%     F = fimath
%     F.RoundingMethod = 'Floor'
%     F.OverflowAction = 'Wrap'
%     F.SumMode        = 'KeepLSB'
%     F.SumWordLength  = 40
%     F.CastBeforeSum  = false
%
%   See also GLOBALFIMATH, FI, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, RESETGLOBALFIMATH, REMOVEGLOBALFIMATHPREF, FIXEDPOINT

%   Copyright 2003-2017 The MathWorks, Inc.

% Check to see if default fimath preference exists & set the default fimath if it does
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

embedded.setdefaultfimathfrompref;

n1=0;
if nargin > 0 && isfimath(varargin{1})
  this = varargin{1};
  n1 = n1 + 1;
elseif nargin > 0 && ischar(varargin{1}) && embedded.fimath.FimathDictionaryTagExists(varargin{1})
    % Get the fimath from the fimath dictionary
    this = embedded.fimath.GetFromFimathDictionary(varargin{1});
    n1 = n1 + 1;
else
  this = embedded.fimath;
end
n2 = nargin - n1;
if fix(n2/2)~=n2/2
  error(message('fixed:fimath:invalidPVPairs'));
end
for k=(n1+1):2:n2
  this.(varargin{k}) = varargin{k+1};
end
