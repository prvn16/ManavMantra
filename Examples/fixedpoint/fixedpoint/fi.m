function a = fi(varargin)
%FI     Fixed-point numeric object
%
%   Syntax:
%     a = fi
%     a = fi(v)
%     a = fi(v, s)
%     a = fi(v, s, w)
%     a = fi(v, s, w, f)
%     a = fi(v, s, w, slope, bias)
%     a = fi(v, s, w, slopeadjustmentfactor, fixedexponent, bias)
%     a = fi(v, T)
%     a = fi(v, T, F)
%     a = fi(v, F)
%     a = fi(v, s, F)
%     a = fi(v, s, w, F)
%     a = fi(v, s, w, f, F)
%     a = fi(v, s, w, slope, bias, F)
%     a = fi(v, s, w, slopeadjustmentfactor, fixedexponent, bias, F) 
%     a = fi(..., property1, value1, ...)
%     a = fi(property1, value1, ...)
%
%   Description:
%     fi is the default constructor and returns a signed fixed-point object
%     with no value, 16-bit word length, and 15-bit fraction length.
%
%     fi(v) returns a signed fixed-point object with value v, 16-bit
%     word length, and best-precision fraction length. Best-precision
%     is when the fraction length is set automatically to accommodate the
%     value v for the given word length.
%
%     fi(v,s) returns a fixed-point object with value v, signed property value s,
%     16-bit word length, and best-precision fraction length. s can be 0
%     (false) for unsigned or 1 (true) for signed.
%
%     fi(v,s,w) returns a fixed-point object with value v, signed property value s,
%     word length w, and best-precision fraction length.
%
%     fi(v,s,w,f) returns a fixed-point object with value v, signed property value
%     s, word length w, and fraction length f.
%
%     fi(v,s,w,slope,bias) returns a fixed-point object with value v,
%     signed property value s, word length w, slope, and bias.
%
%     fi(v,s,w,slopeadjustmentfactor,fixedexponent,bias) returns a
%     fixed-point object with value v, signed property value s, word length w,
%     slopeadjustmentfactor, fixedexponent, and bias.
%
%     fi(v,T) returns a fixed-point object with value v and
%     embedded.numerictype T.
%
%     fi(v,T,F) returns a fixed-point object with value v,
%     embedded.numerictype T, and embedded.fimath F.
%
%     fi(v,F) returns a fixed-point object with value v and embedded.fimath F.
%     The numerictype is the same as the numerictype of fi(v).  If v is a fi
%     object, then the numerictype of v is the same as the numerictype of
%     fi(v,F). 
%
%     fi(v,s,F) returns a fixed-point object with value v,
%     signed property value s, 16-bit wordlength, best-precision fraction length, and 
%     embedded.fimath F.
%
%     fi(v,s,w,F) returns a fixed-point object with value v,
%     signed property value s, wordlength w, best precision fraction-length and 
%     embedded.fimath F.
%
%     fi(v,s,w,f,F) returns a fixed-point object with value v,
%     signed property value s, wordlength w, fraction-length f and 
%     embedded.fimath F.
%
%     fi(v,s,w,slope,bias,F) returns a fixed-point object with value v,
%     signed property value s, wordlength w, slope and bias, and 
%     embedded.fimath F.
%
%     fi(v,s,w,slopeadjustmentfactor,fixedexponent,bias,F) returns a 
%     fixed-point object with value v, signed property value s, 
%     wordlength w, slopeadjustmentfactor, fixedexponent and bias, 
%     and embedded.fimath F.
%     
%     fi(...'PropertyName',PropertyValue...) and
%     fi('PropertyName',PropertyValue...) allow you to set fixed-point
%     properties for a fi object by property name/property value pairs.
%
%   The fi object has the following three general types of properties:
%     DATA Properties
%     FIMATH Properties
%     NUMERICTYPE Properties
%
%   DATA Properties:
%     The data properties of a fi object are always writable.
%
%     bin    - Stored integer value of a fi object in binary
%     data   - Numerical real-world value of a fi object
%     dec    - Stored integer value of a fi object in decimal
%     double - Numerical real-world value fi object, stored as a MATLAB double
%     hex    - Stored integer value of a fi object in hexadecimal
%     oct    - Stored integer value of a fi object in octal
%
%   FIMATH Properties:
%     When you create a fi object without explicitly specifying a fimath object or property in the constructor,
%     the resulting fi object associates itself with the global fimath.
%
%     To configure the global fimath, use the globalfimath function.
%
%     To create a fi object with a local fimath object, you can:
%      * Specify a fimath object or property in the fi object constructor
%      * Use dot notation to set a fimath object property of an existing fi object
%
%     To find out whether a fi object is using the global fimath or has a local 
%     fimath object use the <a href="matlab:help embedded.fi.isfimathlocal">isfimathlocal</a> function.
%
%     FIMATH                - fimath object associated with a fi object
%
%     The following fimath properties are, by transitivity, also
%     properties of a fi object. The properties of the fimath object
%     listed below are always writable.
%
%     CastBeforeSum                - Whether both operands are cast to the sum 
%                                    data type before addition
%     MaxProductWordLength         - Maximum allowable word length for the
%                                    product data type
%     MaxSumWordLength             - Maximum allowable word length for the sum 
%                                    data type
%     OverflowAction               - Overflow action
%     ProductBias                  - Bias of the product data type
%     ProductFixedExponent         - Fixed exponent of the product data type
%     ProductFractionLength        - Fraction length, in bits, of the product
%                                    data type
%     ProductMode                  - Defines how the product data type is determined
%     ProductSlope                 - Slope of the product data type
%     ProductSlopeAdjustmentFactor - Slope adjustment factor of the product data type
%     ProductWordLength            - Word length, in bits, of the product data type
%     RoundingMethod               - Rounding method
%     SumBias                      - Bias of the sum data type
%     SumFixedExponent             - Fixed exponent of the sum data type
%     SumFractionLength            - Fraction length, in bits, of the sum data type
%     SumMode                      - Defines how the sum data type is determined
%     SumSlope                     - Slope of the sum data type
%     SumSlopeAdjustmentFactor     - Slope adjustment factor of the sum data type
%     SumWordLength                - Word length, in bits, of the sum data type
% 
%   NUMERICTYPE Properties:
%     When you create a fi object, a numerictype object is also
%     automatically created as a property of the fi object.
%
%     NUMERICTYPE           - Object containing all the numeric type 
%                             attributes of a fi object
%
%     The following numerictype properties are, by transitivity, also
%     properties of a fi object.  The properties of the numerictype
%     object listed below are not writable once the fi object has been
%     created. However, you can create a copy of a fi object with new
%     values specified for the numerictype properties.
%
%     Bias                  - Bias of a fi object
%     DataType              - Data type category associated with a fi object
%     DataTypeMode          - Data type and scaling mode of a fi object
%     DataTypeOverride      - Data type override for applying fipref data
%                             type override settings to a fi object
%     FixedExponent         - Fixed-point exponent associated with a fi object
%     SlopeAdjustmentFactor - Slope adjustment associated with a fi
%                             object
%     FractionLength        - Fraction length of the stored integer value of a
%                             fi object in bits
%     Scaling               - Fixed-point scaling mode of a fi object
%     Signed                - Whether a fi object is signed or unsigned
%     Signedness            - Whether the object is signed, unsigned, or 
%                             has an unspecified sign
%     Slope                 - Slope associated with a fi object
%     WordLength            - Word length of the stored integer value of a fi 
%                             object in bits
%
%   The display, logging, and data type override preferences for fi objects are 
%   controlled by the properties of the fipref object. See FIPREF for more 
%   information.
%
%   The functions that work with fi objects are listed <a href="matlab:help tocfifunctions">here</a>.
%
%
%   Examples:
%
%     % If you omit all properties other than the value, the word length
%     % defaults to 16 bits, the fraction length sets itself to the best 
%     % precision possible, and signed is true.
%     a = fi(pi)
%
%     % The value v can also be an array. 
%     a = fi(magic(3))
%
%     % An unsigned fi.
%     a = fi(pi, 0)
%
%     % A signed fi with word length 8 bits, and fraction length best 
%     % precision.
%     a = fi(pi, 1, 8)
%
%     % Using property name/property value pairs to set the rounding method
%     % to floor, and the overflow action to wrap.
%     a = fi(pi, 'RoundingMethod', 'Floor', 'OverflowAction','Wrap')
%
%     % Setting the stored integer value from hex strings.  
%     % Can you identify these three familiar numbers from
%     %  their signed 32-bit hex representations?
%     a = fi(0,1,32,29);
%     a.hex = ['6487ed51';'56fc2a2c';'03333333']
%
%     % Getting the binary representation of a 16-bit sine wave.
%     a = fi(sin(2*pi*((0:10)'*0.1)))
%     a.bin
%
%   See also SFI, UFI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, GLOBALFIMATH, <a href="matlab:help embedded.fi.isfimathlocal">isfimathlocal</a>
%            FIXEDPOINT, FORMAT, FISCALINGDEMO

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2017 The MathWorks, Inc.


% Check to see if a global fimath has been saved in the preferences.
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

embedded.setdefaultfimathfrompref;

a = embedded.fi(varargin{:});
