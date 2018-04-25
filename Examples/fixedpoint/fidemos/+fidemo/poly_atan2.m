function z = poly_atan2(y,x,N,constA,Tz,RoundingMethodStr)
% Calculate the four quadrant inverse tangent via Chebyshev polynomial 
% approximation. Chebyshev polynomials of the first kind are used.
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA : coefficients of the Chebyshev polynomial
%  Tz     : numerictype of the output angle only required for fixed-point
%           algorithm
%  RoundingMethodStr: RoundingMethod setting only required for fixed-point algorithm
% Output:
%  z  : angle that equals atan2(y,x), in radians
%       the output angle range is within (-pi, +pi]
%
%    Copyright 1984-2012 The MathWorks, Inc.

if nargin < 5
    % floating-point algorithm
    fhandle = @chebyPoly_atan_fltpt;
    Tz = [];
    RoundingMethodStr = [];
    z = zeros(size(y));
else
    % fixed-point algorithm
    fhandle = @chebyPoly_atan_fixpt;
    %pre-allocate output
    z = fi(zeros(size(y)), 'numerictype', Tz, 'RoundingMethod', RoundingMethodStr);
end

% Turn off the warning because the behavior change of Heterogeneous Math Operation Rules 
% is desired in following operations
warning('off', 'fixed:incompatibility:fi:behaviorChangeHeterogeneousMathOperationRules');
% Apply angle correction to obtain four quadrant output
for idx = 1:length(y)  
   % first quadrant 
   if abs(x(idx)) >= abs(y(idx)) 
       % (0, pi/4]
       z(idx) = feval(fhandle, abs(y(idx)), abs(x(idx)), N, constA, Tz, RoundingMethodStr);
   else
       % (pi/4, pi/2)
       z(idx) = pi/2 - feval(fhandle, abs(x(idx)), abs(y(idx)), N, constA, Tz, RoundingMethodStr);
   end
   
   if x(idx) < 0
       % second and third quadrant
       if y(idx) < 0
           z(idx) = -pi + z(idx);
       else
           z(idx) = pi - z(idx);
       end      
   else % fourth quadrant
       if y(idx) < 0
           z(idx) = -z(idx);
       end
   end
end
%resume the default warning state in a MATLAB session
warning('on', 'fixed:incompatibility:fi:behaviorChangeHeterogeneousMathOperationRules');

end % function poly_atan2


% ===============================================================
function z = chebyPoly_atan_fltpt(y,x,N,constA,~,~) %#codegen
% Calculate arctangent using Chebyshev polynomial approximation
% Chebyshev polynomials of the first kind are used.
% x and y must be scalar, y/x must be within [-1,+1]
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA: coefficients of the Chebyshev polynomial
%  Tz : ignored for floating-point algorithm
%  RoundingMethodStr : ignored for floating-point algorithm
% Output:
%  z  : angle that equals atan(y/x) within [-pi/4, pi/4], in radians
%
tmp = y/x;

switch N
    case 3
        z = constA(1)*tmp + constA(2)*tmp^3;
    case 5
        z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5;
    case 7
        z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5 + constA(4)*tmp^7;
    otherwise
        disp('Supported order of Chebyshev polynomials are 3, 5 and 7');
end

end % function chebyPoly_atan_fltpt


% ===============================================================
function z = chebyPoly_atan_fixpt(y,x,N,constA,Tz,RoundingMethodStr) %#codegen
% Calculate arctangent using Chebyshev polynomial approximation
% Chebyshev polynomials of the first kind are used.
% x and y must be scalar, y/x must be within [-1,+1]
% Full precision Fimath is used in all fixed-point operations
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA: coefficients of the Chebyshev polynomial
%  Tz : numerictype of the output angle
%  RoundingMethodStr: RoundingMethod setting
% Output:
%  z  : angle that equals atan(y/x) within [-pi/4, pi/4] in radians
%
z = fi(0,'numerictype', Tz, 'RoundingMethod', RoundingMethodStr);
Tx = numerictype(x);
tmp = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
tmp(:) = Tx.divide(y, x); % y/x;

tmp2 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
tmp3 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
tmp2(:) = tmp*tmp;  % (y/x)^2
tmp3(:) = tmp2*tmp; % (y/x)^3


z(:) = constA(1)*tmp + constA(2)*tmp3; % for order N = 3

if (N == 5) || (N == 7)
    tmp5 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
    tmp5(:) = tmp3 * tmp2; % (y/x)^5
    z(:) = z + constA(3)*tmp5; % for order N = 5
    
    if N == 7
        tmp7 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
        tmp7(:) = tmp5 * tmp2; % (y/x)^7
        z(:) = z + constA(4)*tmp7; %for order N = 7
    end
end

end % function chebyPoly_atan_fixpt
