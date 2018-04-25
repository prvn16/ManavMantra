function Y = abs(A, varargin)
%ABS    Absolute value of fi object
%   The absolute value Y of a real input A is defined as 
%       Y = A if A >= 0; Y = -A if A < 0
%   The absolute value Y of a complex input A is related to its 
%   real and imaginary parts by
%       Y = sqrt(real(A)*real(A) + imag(A)*imag(A))
%
%   ABS supports the following syntaxes for both real and complex inputs:
%
%   Y = ABS(A) returns a fi object with a value equal to the absolute value
%   of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using the fimath associated with A. 
%
%   Y = ABS(A,T) returns a fi object with a value equal to the absolute 
%   value of A and numerictype object T. 
%   Intermediate quantities are calculated using the fimath associated with A. 
%   The data type propagation rules described below are followed.
%
%   Y = ABS(A,F) returns a fi object with a value equal to the absolute
%   value of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using fimath object F.
%
%   Y = ABS(A,T,F) returns a fi object with a value equal to the absolute
%   value of A and with a numerictype object T. Intermediate
%   quantities are calculated using fimath object F. The data type 
%   propagation rules described below are followed.
%
%   Method:
%   Although the above syntaxes are supported for both real and complex
%   fi objects, the algorithm for real inputs involves sign checking and
%   negation based on sign; while, the algorithm for complex inputs 
%   uses the following steps:
%       1) Isolate the real and imaginary parts of A using re = real(A) and
%          im = imag(A).
%       2) Compute the squares of re and im using either the specified 
%          fimath F or the fimath associated with A if F is not specified as an argument.
%       3) Cast the squares of re and im to unsigned types if the input is 
%          signed.
%       4) Add the squares of re and im using either the specified fimath F
%          or the fimath associated with A if F is not specified as an argument.
%       5) Compute the square root of the sum computed in (4) using the 
%          SQRT function and any appropriate additional arguments, such as
%          the specified numerictype or numerictype of A and the specified 
%          fimath or fimath associated with A.
%   Note that step (3) prevents the sum of the squares of the real and 
%   imaginary components from taking a negative value, which would have 
%   caused SQRT to error when either of these components has the maximum 
%   negative value and the 'OverflowAction' property is set to 'Wrap'.
%
%   Limitations/Assumptions:
%   ABS only supports fi objects with [Slope Bias] scaling when the bias 
%   is zero and the fractional slope is one. ABS does not support complex 
%   fi inputs with data type Boolean.
%
%   Data Type Propagation Rules:
%   For syntaxes for which you specify a numerictype object T, the abs 
%   function follows the data type propagation rules listed in the 
%   following table. In general, these rules can be summarized as 
%   "floating-point data types are propagated." This allows you to write 
%   code that can be used with both fixed-point and floating-point inputs.
%
%     Data Type of Input|Data Type of numerictype| Data Type of 
%        fi Object A    |       object T         |    Output C
%
%         fiFixed       |        fiFixed         |    Data type of  
%                       |                        | numerictype object T
%      fiScaledDouble   |       fiFixed          |   ScaledDouble with 
%                       |                        |properties of numerictype 
%                       |                        |      object T
%         fidouble      |       fiFixed          |      fidouble
%         fisingle      |       fiFixed          |      fisingle
%     Any fi data type  |       fidouble         |      fidouble
%     Any fi data type  |       fisingle         |      fisingle
%
%
%   When the object A is real and has a signed data type, the absolute 
%   value of the most negative value is problematic since it is not
%   representable. In this case, the absolute value saturates to the most
%   positive value representable by the data type if the 'OverflowAction'
%   property is set to 'Saturate'. If 'OverflowAction' is 'Wrap', the absolute
%   value of the most negative value has no effect.
%
%   Examples:
%     % The following example shows the difference between the absolute value
%     % results for the most negative value representable by a signed data
%     % type when 'OverflowAction' is 'Saturate' or 'Wrap'.
%
%     a = fi(-128,'OverflowAction','Saturate');
%     abs(a)
%     % returns 127.9961, which is a result of saturation to the maximum
%     % positive value.
%
%     b = fi(-128,'OverflowAction','Wrap');
%     abs(b)
%     % returns -128, which is a result of wrapping back to the most
%     % negative value
%
%     % The following example shows the difference between the absolute value 
%     % results for complex and real fi inputs that have the most negative 
%     % value representable by the data type when the 'OverflowAction' is 
%     % 'Wrap'.
%
%     re = fi(-1,1,16,15)
%     % re = -1 
%     im = fi(0,1,16,15)
%     a = complex(re,im)
%     % a = -1 + j0; a is complex, but numerically equal to re which is
%     % real
%
%     abs(a,re.numerictype,fimath('OverflowAction','Wrap'))
%     % returns fi object which is the output derived from steps outlined 
%     % in the section 'Method', with value 1, and with the specified 
%     % numerictype
%
%     abs(re,re.numerictype,fimath('OverflowAction','Wrap'))
%     % returns fi object with value -1 and with the specified numerictype, 
%     % the result under OverflowAction 'Wrap'
%
%
%     % The following example shows how to specify numerictype and fimath
%     % objects as optional arguments to control the result of the ABS 
%     % function for real inputs.
%
%     a = fi(-1,1,6,5,'OverflowAction','Wrap')
%     abs(a)
%     % Returns output that is identical to the input, which might be
%     % undesirable because the absolute value is expected to be positive.
%
%     f = fimath('OverflowAction','Saturate')
%     abs(a,f)
%     % Returns a fi object with a saturated value of 0.9688 and the same
%     % numerictype object as the input. Because the output of abs 
%     % is always expect to be positive, we may specify an unsigned 
%     % numerictype for the output.
%
%     t = numerictype(a.numerictype, 'Signed', false)
%     abs(a,t,f)
%     % Returns a fi object with a value of 1 and the specified numerictype,
%     % which enables better precision.
%
%     % The following example shows the way to specify numerictype and fimath
%     % as optional arguments to control the result of the function for
%     % complex inputs.
%
%     a = fi(-1-i,1,16,15,'OverflowAction','Wrap')
%     t = numerictype(a.numerictype,'Signed',false)
%     abs(a,t)
%     % Returns a fi object with value 1.4142 and the specified unsigned
%     % numerictype. The fimath used for intermediate calculation and the 
%     % fimath of the output are same as that of the input.
%
%     % Now specify a fimath object different from that of a as follows:
%
%     % now let us say that we want to specify a fimath different from that
%     % of a; we could do as follows
%
%     f = fimath('OverflowAction','Saturate','SumMode','KeepLSB',...
%       'SumWordLength',a.WordLength,'ProductMode','specifyprecision',...
%            'ProductWordLength',a.WordLength, ...
%                 'ProductFractionLength',a.FractionLength)
%     abs(a,t,f)
%     % The specified fimath object is used for intermediate calculation. 
%     % The fimath associated with the output is the default fimath.
%
%   See also EMBEDDED.FIMATH/ABS, EMBEDDED.NUMERICTYPE/ABS, 
%            EMBEDDED.FI/COMPLEXABS, FI

%   Copyright 1999-2012 The MathWorks, Inc.

narginchk(1, 3);        
if isreal(A)
    Y = realabs(A,varargin{:});
else
    Y = complexabs(A,varargin{:});
end

% LocalWords:  im fidouble fisingle specifyprecision
