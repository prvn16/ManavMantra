%% Calculate Fixed-Point Arctangent
% This example shows how to use the CORDIC algorithm, polynomial
% approximation, and lookup table approaches to calculate the fixed-point,
% four quadrant inverse tangent. These implementations are approximations
% to the MATLAB(R) built-in function |atan2|. An efficient fixed-point
% arctangent algorithm to estimate an angle is critical to many
% applications, including control of robotics, frequency tracking in
% wireless communications, and many more.
%
% Copyright 2008-2013 The MathWorks, Inc.

%% Calculating |atan2(y,x)| Using the CORDIC Algorithm
%
% *Introduction*
%
% The |cordicatan2| function approximates the MATLAB(R) |atan2| function,
% using a CORDIC-based algorithm. CORDIC is an acronym for COordinate
% Rotation DIgital Computer. The Givens rotation-based CORDIC algorithm
% (see [1,2]) is one of the most hardware efficient algorithms because it
% only requires iterative shift-add operations. The CORDIC algorithm
% eliminates the need for explicit multipliers, and is suitable for
% calculating a variety of functions, such as sine, cosine, arcsine,
% arccosine, arctangent, vector magnitude, divide, square root, hyperbolic
% and logarithmic functions. 
%
% *CORDIC Vectoring Computation Mode*
%
% The CORDIC vectoring mode equations are widely used to calculate
% |atan(y/x)|. In vectoring mode, the CORDIC rotator rotates the input
% vector towards the positive X-axis to minimize the  $$ y $$ component of
% the residual vector. For each iteration, if the $$ y $$ coordinate of the
% residual vector is positive, the CORDIC rotator rotates clockwise (using
% a negative angle); otherwise, it rotates counter-clockwise (using a
% positive angle). If the angle accumulator is initialized to 0, at the end
% of the iterations, the accumulated rotation angle is the angle of the
% original input vector.
%
% In vectoring mode, the CORDIC equations are: 
%
% $$ x_{i+1} = x_{i} - y_{i}*d_{i}*2^{-i} $$
%
% $$ y_{i+1} = y_{i} + x_{i}*d_{i}*2^{-i} $$
%
% $$ z_{i+1} = z_{i} + d_{i}*atan(2^{-i}) $$ is the angle accumulator
%
% where 
%   $$  d_{i} = +1 $$  if  $$ y_{i} < 0 $$, and $$ -1  $$ otherwise;
%
% $$ i = 0, 1, ..., N-1 $$, and $$ N $$ is the total number of iterations.
%
% As $$ N $$ approaches $$ +\infty $$ :
%
% $$ x_{N} = A_{N}\sqrt{x_{0}^2+y_{0}^2} $$
%
% $$ y_{N} = 0 $$
%
% $$ z_{N} = z_{0} + atan(y_{0}/x_{0}) $$
%
% $$ A_{N} =
% 1/(cos(atan(2^{0}))*cos(atan(2^{-1}))*...*cos(atan(2^{-(N-1)}))) 
%  = \prod_{i=0}^{N-1}{\sqrt{1+2^{-2i}}}
%  $$
%
% As explained above, the arctangent can be directly 
% computed using the vectoring mode CORDIC rotator with the angle 
% accumulator initialized to zero, 
% i.e., $$ z_{0}=0, $$ and $$ z_{N} \approx atan(y_{0}/x_{0}) $$.
%

%% Understanding the |CORDICATAN2| Code
%
% *Introduction*
%
% The |cordicatan2| function computes the four quadrant arctangent
% of the elements of x and y, where $$ -\pi \leq ATAN2(y,x) \leq +\pi $$.
% |cordicatan2| calculates the arctangent using the vectoring mode CORDIC
% algorithm, according to the above CORDIC equations.
%
% *Initialization*
%
% The |cordicatan2| function performs the following initialization steps:
%
% * $$ x_{0} $$ is set to the initial X input value.
% * $$ y_{0} $$ is set to the initial Y input value.
% * $$ z_{0} $$ is set to zero.
%
% After $$ N $$ iterations, these initial values lead to $$ z_{N} \approx atan(y_{0}/x_{0}) $$
%
% *Shared Fixed-Point and Floating-Point CORDIC Kernel Code*
%
% The MATLAB code for the CORDIC algorithm (vectoring mode) kernel portion
% is as follows (for the case of scalar |x|, |y|, and |z|). This same code
% is used for both fixed-point and floating-point operations:
%
%   function [x, y, z] = cordic_vectoring_kernel(x, y, z, inpLUT, n)
%   % Perform CORDIC vectoring kernel algorithm for N kernel iterations.
%   xtmp = x;
%   ytmp = y;
%   for idx = 1:n
%       if y < 0
%           x(:) = x - ytmp;
%           y(:) = y + xtmp;
%           z(:) = z - inpLUT(idx);
%       else
%           x(:) = x + ytmp;
%           y(:) = y - xtmp;
%           z(:) = z + inpLUT(idx);
%       end
%       xtmp = bitsra(x, idx); % bit-shift-right for multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % bit-shift-right for multiply by 2^(-idx)
%   end

%% Visualizing the Vectoring Mode CORDIC Iterations
%
% The CORDIC algorithm is usually run through a specified (constant) number
% of iterations since ending the CORDIC iterations early would break
% pipelined code, and the CORDIC gain $$ A_{n} $$ would not be constant
% because $$ n $$ would vary.
%
% For very large values of $$ n $$, the CORDIC algorithm is guaranteed to
% converge, but not always monotonically. As will be shown in the following
% example, intermediate iterations occasionally rotate the vector closer to
% the positive X-axis than the following iteration does. You can typically
% achieve greater accuracy by increasing the total number of iterations.
%
% *Example*
%
% In the following example, iteration 5 provides a better estimate 
% of the angle than iteration 6, and the CORDIC algorithm converges 
% in later iterations.
%
% Initialize the input vector with angle   $$ \theta = 43 $$ degrees, 
% magnitude = 1
origFormat = get(0, 'format'); % store original format setting;
                               % restore this setting at the end.
format short
%
theta = 43*pi/180;  % input angle in radians
Niter = 10;         % number of iterations
inX   = cos(theta); % x coordinate of the input vector 
inY   = sin(theta); % y coordinate of the input vector 
%
% pre-allocate memories
zf = zeros(1, Niter);  
xf = [inX, zeros(1, Niter)];
yf = [inY, zeros(1, Niter)];
angleLUT = atan(2.^-(0:Niter-1)); % pre-calculate the angle lookup table
%
% Call CORDIC vectoring kernel algorithm
for k = 1:Niter
   [xf(k+1), yf(k+1), zf(k)] = fixed.internal.cordic_vectoring_kernel_private(inX, inY, 0, angleLUT, k);
end

%%
% The following output shows the CORDIC angle accumulation (in degrees)
% through 10 iterations. Note that the 5th iteration produced less 
% error than the 6th iteration, and that the calculated angle quickly
% converges to the actual input angle afterward.
angleAccumulator = zf*180/pi; angleError = angleAccumulator - theta*180/pi;
fprintf('Iteration: %2d, Calculated angle: %7.3f, Error in degrees: %10g, Error in bits: %g\n',...
        [(1:Niter); angleAccumulator(:)'; angleError(:)';log2(abs(zf(:)'-theta))]);
%%
% As N approaches $$ +\infty $$, the CORDIC rotator gain $$ A_{N} $$ 
% approaches 1.64676. In this example, the input $$ (x_{0},y_{0}) $$ was 
% on the unit circle, so the initial rotator magnitude is 1. The following
% output shows the rotator magnitude through 10 iterations:
rotatorMagnitude = sqrt(xf.^2+yf.^2); % CORDIC rotator gain through iterations
fprintf('Iteration: %2d, Rotator magnitude: %g\n',...
    [(0:Niter); rotatorMagnitude(:)']);
%%
% Note that $y_{n}$ approaches 0, and $x_{n}$ approaches 
% $$ A_{n} \sqrt{x_{0}^{2} + y_{0}^{2}} = A_{n}, $$ 
% because $$ \sqrt{x_{0}^{2} + y_{0}^{2}} = 1 $$.
y_n = yf(end)
%%
x_n = xf(end)
%%
figno = 1; 
fidemo.fixpt_atan2_demo_plot(figno, xf, yf) %Vectoring Mode CORDIC Iterations
%%
figno = figno + 1; %Cumulative Angle and Rotator Magnitude Through Iterations
fidemo.fixpt_atan2_demo_plot(figno,Niter, theta, angleAccumulator, rotatorMagnitude)
%%

%% Performing Overall Error Analysis of the CORDIC Algorithm
% The overall error consists of two parts:
%
% # The algorithmic error that results from the CORDIC rotation angle
%    being represented by a finite number of basic angles.
% # The quantization or rounding error that results from the finite 
%    precision representation of the angle lookup table, and from the
%    finite precision arithmetic used in fixed-point operations.

%% 
% *Calculate the CORDIC Algorithmic Error*
%
theta  = (-178:2:180)*pi/180; % angle in radians
inXflt = cos(theta); % generates input vector
inYflt = sin(theta);
Niter  = 12; % total number of iterations
zflt   = cordicatan2(inYflt, inXflt, Niter); % floating-point results
%% 
% Calculate the maximum magnitude of the CORDIC algorithmic error by 
% comparing the CORDIC computation to the builtin |atan2| function.
format long
cordic_algErr_real_world_value = max(abs((atan2(inYflt, inXflt) - zflt)))
%%
% The log base 2 error is related to the number of iterations.  In this
% example, we use 12 iterations (i.e., accurate to 11 binary digits), so 
% the magnitude of the error is less than $$ 2^{-11} $$
cordic_algErr_bits = log2(cordic_algErr_real_world_value)

%%
% _Relationship Between Number of Iterations and Precision_
%
% Once the quantization error dominates the overall error, i.e., the 
% quantization error is greater than the algorithmic error, increasing the 
% total number of iterations won't significantly decrease the overall 
% error of the fixed-point CORDIC algorithm. You should pick your fraction
% lengths and total number of iterations to ensure that the quantization
% error is smaller than the algorithmic error.  In the CORDIC algorithm,
% the precision increases by one bit every iteration. Thus, there is no
% reason to pick a number of iterations greater than the precision of the
% input data.
%
% Another way to look at the relationship between the number of iterations
% and the precision is in the right-shift step of the algorithm. For
% example, on the counter-clockwise rotation
%
%  x(:) = x0 - bitsra(y,i); 
%  y(:) = y + bitsra(x0,i); 
%
% if i is equal to the word length of y and x0, then |bitsra(y,i)| and
% |bitsra(x0,i)| shift all the way to zero and do not contribute 
% anything to the next step.
%
% To measure the error from the fixed-point algorithm, and not the
% differences in input values, compute the floating-point reference with
% the same inputs as the fixed-point CORDIC algorithm.

inXfix = sfi(inXflt, 16, 14);
inYfix = sfi(inYflt, 16, 14);
zref   = atan2(double(inYfix), double(inXfix));
zfix8  = cordicatan2(inYfix, inXfix, 8);
zfix10 = cordicatan2(inYfix, inXfix, 10);
zfix12 = cordicatan2(inYfix, inXfix, 12);
zfix14 = cordicatan2(inYfix, inXfix, 14);
zfix15 = cordicatan2(inYfix, inXfix, 15);
cordic_err = bsxfun(@minus,zref,double([zfix8;zfix10;zfix12;zfix14;zfix15]));

%%
% The error depends on the number of iterations and the precision of
% the input data.  In the above example, the input data is in the range
% [-1, +1], and the fraction length is 14.  From the following tables 
% showing the maximum error at each iteration, and the figure showing the 
% overall error of the CORDIC algorithm, you can see that the error 
% decreases by about 1 bit per iteration until the precision of the data 
% is reached.

iterations = [8, 10, 12, 14, 15];
max_cordicErr_real_world_value = max(abs(cordic_err'));
fprintf('Iterations: %2d, Max error in real-world-value: %g\n',...
    [iterations; max_cordicErr_real_world_value]);
%%
max_cordicErr_bits = log2(max_cordicErr_real_world_value);
fprintf('Iterations: %2d, Max error in bits: %g\n',[iterations; max_cordicErr_bits]);
%%
figno = figno + 1; 
fidemo.fixpt_atan2_demo_plot(figno, theta, cordic_err)

%% Accelerating the Fixed-Point |CORDICATAN2| Algorithm Using |FIACCEL|
% 
% You can generate a MEX function from MATLAB code using the MATLAB(R)
% <matlab:helpview([docroot,'/fixedpoint/ref/fiaccel.html']); fiaccel> command. Typically, running a generated
% MEX function can improve the simulation speed, although the actual speed
% improvement depends on the simulation platform being used. The following
% example shows how to accelerate the fixed-point |cordicatan2| algorithm
% using |fiaccel|.
%
% The |fiaccel| function compiles the MATLAB code into a MEX function. 
% This step requires the creation of a temporary directory 
% and write permissions in that directory.
tempdirObj = fidemo.fiTempdir('fixpt_atan2_demo');

%%
% When you declare the number of iterations to be a constant (e.g., |12|)
% using |coder.newtype('constant',12)|, the compiled angle lookup table
% will also be constant, and thus won't be computed at each iteration.
% Also, when you call the compiled MEX file |cordicatan2_mex|, you will not
% need to give it the input argument for the number of iterations. If you
% pass in the number of iterations, the MEX function will error.
% 
% The data type of the input parameters determines whether the 
% |cordicatan2| function performs fixed-point or floating-point 
% calculations. When MATLAB generates code for this 
% file, code is only generated for the specific data type. For example, 
% if the inputs are fixed point, only fixed-point code is generated.
%
inp = {inYfix, inXfix, coder.newtype('constant',12)}; % example inputs for the function
fiaccel('cordicatan2', '-o', 'cordicatan2_mex',  '-args', inp)
%%
% First, calculate a vector of 4 quadrant |atan2| by calling  
% |cordicatan2|.
tstart = tic; 
cordicatan2(inYfix,inXfix,Niter);
telapsed_Mcordicatan2 = toc(tstart);
%%
% Next, calculate a vector of 4 quadrant |atan2| by calling the
% MEX-function |cordicatan2_mex|
cordicatan2_mex(inYfix,inXfix); % load the MEX file
tstart = tic; 
cordicatan2_mex(inYfix,inXfix);
telapsed_MEXcordicatan2 = toc(tstart);
%%
% Now, compare the speed. Type the following in the MATLAB command window 
% to see the speed improvement on your specific platform:

fiaccel_speedup = telapsed_Mcordicatan2/telapsed_MEXcordicatan2;

%%
% To clean up the temporary directory, run the following commands:
clear cordicatan2_mex;
status = tempdirObj.cleanUp;

%% Calculating |atan2(y,x)| Using Chebyshev Polynomial Approximation
%
% Polynomial approximation is a multiply-accumulate (MAC) centric 
% algorithm. It can be a good choice for DSP implementations of  
% non-linear functions like |atan(x)|.
%
% For a given degree of polynomial, and a given function |f(x) = atan(x)| 
% evaluated over the interval of [-1, +1], the polynomial approximation 
% theory tries to find the polynomial that minimizes the maximum value 
% of $$ |P(x)-f(x)| $$, where |P(x)| is the approximating polynomial. In 
% general, you can obtain polynomials very close to the optimal one by 
% approximating the given function in terms of Chebyshev polynomials and 
% cutting off the polynomial at the desired degree.
%
% The approximation of arctangent over the interval of [-1, +1] using
% the Chebyshev polynomial of the first kind is summarized in the following
% formula:
%
% $$ atan(x) = 2\sum_{n=0}^{\infty} {(-1)^{n}q^{2n+1} \over (2n+1)}
% T_{2n+1}(x) $$
%
% where 
%
% $$ q = 1/(1+\sqrt{2}) $$ 
%
% $$ x \in [-1, +1] $$ 
% 
% $$ T_{0}(x) = 1 $$
%
% $$ T_{1}(x) = x $$
%
% $$ T_{n+1}(x) = 2xT_{n}(x) - T_{n-1}(x). $$
%
% Therefore, the 3rd order Chebyshev polynomial approximation is 
% 
% $$ atan(x) = 0.970562748477141*x - 0.189514164974601*x^{3}. $$
%
% The 5th order Chebyshev polynomial approximation is 
%
% $$ atan(x) = 0.994949366116654*x - 0.287060635532652*x^{3} 
%    + 0.078037176446441*x^{5}. $$
%
% The 7th order Chebyshev polynomial approximation is 
%
% $$ \begin{array}{lllll}
%  atan(x) & = & 0.999133448222780*x     & - & 0.320533292381664*x^{3} \\
%          & + & 0.144982490144465*x^{5} & - & 0.038254464970299*x^{7}.
% \end{array} $$
%
% You can obtain four quadrant output through angle correction based on the 
% properties of the arctangent function.

 
%% Comparing the Algorithmic Error of the CORDIC and Polynomial Approximation Algorithms
%
% In general, higher degrees of polynomial approximation produce more 
% accurate final results. However, higher degrees of polynomial
% approximation also increase the complexity of the algorithm and require 
% more MAC operations and more memory. To be consistent with the CORDIC
% algorithm and the MATLAB |atan2| function, the input arguments 
% consist of both |x| and |y| coordinates instead of the ratio |y/x|.
%
% To eliminate quantization error, floating-point implementations of the 
% CORDIC and Chebyshev polynomial approximation algorithms are used in the
% comparison below. An algorithmic error comparison reveals that increasing
% the number of CORDIC iterations results in less error. It also reveals
% that the CORDIC algorithm with 12 iterations provides a slightly better
% angle estimation than the 5th order Chebyshev polynomial approximation.
% The approximation error of the 3rd order Chebyshev Polynomial is about 8 
% times larger than that of the 5th order Chebyshev polynomial. You should
% choose the order or degree of the polynomial based on the required
% accuracy of the angle estimation and the hardware constraints.
%
% The coefficients of the Chebyshev polynomial approximation for |atan(x)| 
% are shown in ascending order of |x|.

constA3 = [0.970562748477141, -0.189514164974601]; % 3rd order
constA5 = [0.994949366116654,-0.287060635532652,0.078037176446441]; % 5th order
constA7 = [0.999133448222780 -0.320533292381664 0.144982490144465...
          -0.038254464970299]; % 7th order
      
theta   = (-90:1:90)*pi/180; % angle in radians
inXflt  = cos(theta);
inYflt  = sin(theta);    
zfltRef = atan2(inYflt, inXflt); % Ideal output from ATAN2 function
zfltp3  = fidemo.poly_atan2(inYflt,inXflt,3,constA3); % 3rd order polynomial
zfltp5  = fidemo.poly_atan2(inYflt,inXflt,5,constA5); % 5th order polynomial
zfltp7  = fidemo.poly_atan2(inYflt,inXflt,7,constA7); % 7th order polynomial
zflt8   = cordicatan2(inYflt, inXflt,  8); % CORDIC alg with 8 iterations
zflt12  = cordicatan2(inYflt, inXflt, 12); % CORDIC alg with 12 iterations

%%
% The maximum algorithmic error magnitude (or infinity norm of the 
% algorithmic error) for the CORDIC algorithm with 8 and 12 iterations 
% is shown below:
cordic_algErr    = [zfltRef;zfltRef] - [zflt8;zflt12];
max_cordicAlgErr = max(abs(cordic_algErr'));
fprintf('Iterations: %2d, CORDIC algorithmic error in real-world-value: %g\n',...
    [[8,12]; max_cordicAlgErr(:)']);
%%
% The log base 2 error shows the number of binary digits of accuracy. The
% 12th iteration of the CORDIC algorithm has an estimated angle accuracy of
% $$ 2^{-11} $$:
max_cordicAlgErr_bits = log2(max_cordicAlgErr);
fprintf('Iterations: %2d, CORDIC algorithmic error in bits: %g\n',...
    [[8,12]; max_cordicAlgErr_bits(:)']);
%%
% The following code shows the magnitude of the maximum algorithmic error 
% of the polynomial approximation for orders 3, 5, and 7:
poly_algErr    = [zfltRef;zfltRef;zfltRef] - [zfltp3;zfltp5;zfltp7]; 
max_polyAlgErr = max(abs(poly_algErr'));
fprintf('Order: %d, Polynomial approximation algorithmic error in real-world-value: %g\n',...
    [3:2:7; max_polyAlgErr(:)']);
%%
% The log base 2 error shows the number of binary digits of accuracy.
max_polyAlgErr_bits = log2(max_polyAlgErr);
fprintf('Order: %d, Polynomial approximation algorithmic error in bits: %g\n',...
    [3:2:7; max_polyAlgErr_bits(:)']);

%%
figno = figno + 1; 
fidemo.fixpt_atan2_demo_plot(figno, theta, cordic_algErr, poly_algErr)

%% Converting the Floating-Point Chebyshev Polynomial Approximation Algorithm to Fixed Point
%
% Assume the input and output word lengths are constrained to 16 bits by 
% the hardware, and the 5th order Chebyshev polynomial is used in the 
% approximation. Because the dynamic range of inputs  |x|, |y| and |y/x|
% are all within [-1, +1], you can avoid overflow by picking a signed 
% fixed-point input data type with a word length of 16 bits and a fraction 
% length of 14 bits. The coefficients of the polynomial are purely 
% fractional and within (-1, +1), so we can pick their data types as 
% signed fixed point with a word length of 16 bits and a fraction length 
% of 15 bits (best precision). The algorithm is robust because  
% $$ (y/x)^{n} $$ is within [-1, +1], and the multiplication of the 
% coefficients and  $$ (y/x)^{n} $$ is within (-1, +1). Thus, the dynamic 
% range will not grow, and due to the pre-determined fixed-point data 
% types, overflow is not expected.
%
% Similar to the CORDIC algorithm, the four quadrant polynomial 
% approximation-based |atan2| algorithm outputs estimated angles within 
% $$ [-\pi,  \pi] $$. Therefore, we can pick an output fraction length of 
% 13 bits to avoid overflow and provide a dynamic range of 
% [-4, +3.9998779296875]. 
% 
%% 
% The basic floating-point Chebyshev polynomial approximation of arctangent 
% over the interval [-1, +1] is implemented as the |chebyPoly_atan_fltpt|
% local function in the |poly_atan2.m| file.
%
%     function z = chebyPoly_atan_fltpt(y,x,N,constA,Tz,RoundingMethodStr)
% 
%     tmp = y/x;
%     switch N
%         case 3
%             z = constA(1)*tmp + constA(2)*tmp^3;
%         case 5
%             z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5;
%         case 7
%             z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5 + constA(4)*tmp^7;
%         otherwise
%             disp('Supported order of Chebyshev polynomials are 3, 5 and 7');
%     end 

%%
% The basic fixed-point Chebyshev polynomial approximation of arctangent 
% over the interval [-1, +1] is implemented as the |chebyPoly_atan_fixpt|
% local function in the |poly_atan2.m| file.
%
%     function z = chebyPoly_atan_fixpt(y,x,N,constA,Tz,RoundingMethodStr)
%     
%     z = fi(0,'numerictype', Tz, 'RoundingMethod', RoundingMethodStr);
%     Tx = numerictype(x);
%     tmp = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
%     tmp(:) = Tx.divide(y, x); % y/x;
%     
%     tmp2 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
%     tmp3 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
%     tmp2(:) = tmp*tmp;  % (y/x)^2
%     tmp3(:) = tmp2*tmp; % (y/x)^3
%     
%     z(:) = constA(1)*tmp + constA(2)*tmp3; % for order N = 3
%     
%     if (N == 5) || (N == 7)
%         tmp5 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
%         tmp5(:) = tmp3 * tmp2; % (y/x)^5
%         z(:) = z + constA(3)*tmp5; % for order N = 5
%     
%         if N == 7
%             tmp7 = fi(0, 'numerictype',Tx, 'RoundingMethod', RoundingMethodStr);
%             tmp7(:) = tmp5 * tmp2; % (y/x)^7
%             z(:) = z + constA(4)*tmp7; %for order N = 7
%         end
%     end
     
%%
% The universal four quadrant |atan2| calculation using Chebyshev 
% polynomial approximation is implemented in the |poly_atan2.m| file. 
%
%     function z = poly_atan2(y,x,N,constA,Tz,RoundingMethodStr)
%     
%     if nargin < 5
%         % floating-point algorithm
%         fhandle = @chebyPoly_atan_fltpt;
%         Tz = [];
%         RoundingMethodStr = [];
%         z = zeros(size(y));
%     else
%         % fixed-point algorithm
%         fhandle = @chebyPoly_atan_fixpt;
%         %pre-allocate output
%         z = fi(zeros(size(y)), 'numerictype', Tz, 'RoundingMethod', RoundingMethodStr);
%     end
%   
%     % Apply angle correction to obtain four quadrant output
%     for idx = 1:length(y)  
%        % first quadrant 
%        if abs(x(idx)) >= abs(y(idx)) 
%            % (0, pi/4]
%            z(idx) = feval(fhandle, abs(y(idx)), abs(x(idx)), N, constA, Tz, RoundingMethodStr);
%        else
%            % (pi/4, pi/2)
%            z(idx) = pi/2 - feval(fhandle, abs(x(idx)), abs(y(idx)), N, constA, Tz, RoundingMethodStr);
%        end
%        
%        if x(idx) < 0 
%            % second and third quadrant
%            if y(idx) < 0
%                z(idx) = -pi + z(idx);
%            else
%               z(idx) = pi - z(idx);
%            end      
%        else % fourth quadrant
%            if y(idx) < 0
%                z(idx) = -z(idx);
%            end
%        end
%     end

%% Performing the Overall Error Analysis of the Polynomial Approximation Algorithm
%
% Similar to the CORDIC algorithm, the overall error of the polynomial 
% approximation algorithm consists of two parts - the algorithmic
% error and the quantization error. The algorithmic error of the polynomial 
% approximation algorithm was analyzed and compared to the algorithmic 
% error of the CORDIC algorithm in a previous section.

%%
% *Calculate the Quantization Error*
%
% Compute the quantization error by comparing the fixed-point polynomial
% approximation to the floating-point polynomial approximation.
%
% Quantize the inputs and coefficients with convergent rounding:
inXfix = fi(fi(inXflt,  1, 16, 14,'RoundingMethod','Convergent'),'fimath',[]);
inYfix = fi(fi(inYflt,  1, 16, 14,'RoundingMethod','Convergent'),'fimath',[]);
constAfix3 = fi(fi(constA3, 1, 16,'RoundingMethod','Convergent'),'fimath',[]); 
constAfix5 = fi(fi(constA5, 1, 16,'RoundingMethod','Convergent'),'fimath',[]); 
constAfix7 = fi(fi(constA7, 1, 16,'RoundingMethod','Convergent'),'fimath',[]);

%%
% Calculate the maximum magnitude of the quantization error using |Floor|
% rounding:
ord    = 3:2:7; % using 3rd, 5th, 7th order polynomials
Tz     = numerictype(1, 16, 13); % output data type
zfix3p = fidemo.poly_atan2(inYfix,inXfix,ord(1),constAfix3,Tz,'Floor'); % 3rd order
zfix5p = fidemo.poly_atan2(inYfix,inXfix,ord(2),constAfix5,Tz,'Floor'); % 5th order
zfix7p = fidemo.poly_atan2(inYfix,inXfix,ord(3),constAfix7,Tz,'Floor'); % 7th order
poly_quantErr = bsxfun(@minus, [zfltp3;zfltp5;zfltp7], double([zfix3p;zfix5p;zfix7p]));
max_polyQuantErr_real_world_value = max(abs(poly_quantErr'));
max_polyQuantErr_bits = log2(max_polyQuantErr_real_world_value);
fprintf('PolyOrder: %2d, Quant error in bits: %g\n',...
    [ord; max_polyQuantErr_bits]);

%% 
% *Calculate the Overall Error*
%
% Compute the overall error by comparing the fixed-point polynomial
% approximation to the builtin |atan2| function. The ideal reference output
% is |zfltRef|. The overall error of the 7th order polynomial approximation
% is dominated by the quantization error, which is due to the finite
% precision of the input data, coefficients and the rounding effects from
% the fixed-point arithmetic operations.
poly_err = bsxfun(@minus, zfltRef, double([zfix3p;zfix5p;zfix7p])); 
max_polyErr_real_world_value = max(abs(poly_err'));
max_polyErr_bits = log2(max_polyErr_real_world_value);
fprintf('PolyOrder: %2d, Overall error in bits: %g\n',...
    [ord; max_polyErr_bits]);
%%
figno = figno + 1; 
fidemo.fixpt_atan2_demo_plot(figno, theta, poly_err)

%%
% _The Effect of Rounding Modes in Polynomial Approximation_
%
% Compared to the CORDIC algorithm with 12 iterations and a 13-bit 
% fraction length in the angle accumulator, the fifth order Chebyshev 
% polynomial approximation gives a similar order of quantization error.
% In the following example, |Nearest|, |Round| and |Convergent| 
% rounding modes give smaller quantization errors than 
% the |Floor| rounding mode.
% 
% Maximum magnitude of the quantization error using |Floor| rounding
poly5_quantErrFloor = max(abs(poly_quantErr(2,:)));
poly5_quantErrFloor_bits = log2(poly5_quantErrFloor)

%%
% For comparison, calculate the maximum magnitude of the quantization error 
% using |Nearest| rounding:
zfixp5n = fidemo.poly_atan2(inYfix,inXfix,5,constAfix5,Tz,'Nearest');
poly5_quantErrNearest = max(abs(zfltp5 - double(zfixp5n)));
poly5_quantErrNearest_bits = log2(poly5_quantErrNearest)
set(0, 'format', origFormat); % reset MATLAB output format

%% Calculating |atan2(y,x)| Using Lookup Tables
%
% There are many lookup table based approaches that may be used to
% implement fixed-point argtangent approximations. The following is a
% low-cost approach based on a single real-valued lookup table and
% simple nearest-neighbor linear interpolation.

%% Single Lookup Table Based Approach
%
% The |atan2| method of the |fi| object in the Fixed-Point Designer(TM)
% approximates the MATLAB(R) builtin floating-point |atan2| function, using
% a single lookup table based approach with simple nearest-neighbor linear
% interpolation between values. This approach allows for a small
% real-valued lookup table and uses simple arithmetic.
%
% Using a single real-valued lookup table simplifies the index computation
% and the overall arithmetic required to achieve very good accuracy of the
% results. These simplifications yield a relatively high speed performance
% as well as relatively low memory requirements.

%% Understanding the Lookup Table Based |ATAN2| Implementation
%
% *Lookup Table Size and Accuracy*
%
% Two important design considerations of a lookup table are its size and
% its accuracy. It is not possible to create a table for every possible
% $$ y/x $$ input value. It is also not possible to be perfectly accurate
% due to the quantization of the lookup table values.
%
% As a compromise, the |atan2| method of the Fixed-Point Designer |fi|
% object uses an 8-bit lookup table as part of its implementation. An 8-bit
% table is only 256 elements long, so it is small and efficient. Eight bits
% also corresponds to the size of a byte or a word on many platforms. Used
% in conjunction with linear interpolation, and 16-bit output (lookup table
% value) precision, an 8-bit-addressable lookup table provides very good
% accuracy as well as performance.

%%
% *Overview of Algorithm Implementation*
%
% To better understand the Fixed-Point Designer implementation,
% first consider the symmetry of the four-quadrant |atan2(y,x)| function.
% If you always compute the arctangent in the first-octant of the x-y space
% (i.e., between angles 0 and pi/4 radians), then you can perform octant
% correction on the resulting angle for any y and x values.
%
% As part of the pre-processing portion, the signs and relative magnitudes
% of y and x are considered, and a division is performed. Based on the
% signs and magnitudes of y and x, only one of the following values is
% computed: y/x, x/y, -y/x, -x/y, -y/-x, -x/-y. The unsigned result that is
% guaranteed to be non-negative and purely fractional is computed, based on
% the a priori knowledge of the signs and magnitudes of y and x. An
% unsigned 16-bit fractional fixed-point type is used for this value.
%
% The 8 most significant bits (MSBs) of the stored unsigned integer
% representation of the purely-fractional unsigned fixed-point result is
% then used to directly index an 8-bit (length-256) lookup table value
% containing angle values between 0 and pi/4 radians. Two table lookups are
% performed, one at the computed table index location |lutValBelow|, and
% one at the next index location |lutValAbove|:
%
%   idxUint8MSBs = bitsliceget(idxUFIX16, 16, 9);
%   zeroBasedIdx = int16(idxUint8MSBs);
%   lutValBelow  = FI_ATAN_LUT(zeroBasedIdx + 1);
%   lutValAbove  = FI_ATAN_LUT(zeroBasedIdx + 2);
%
% The remaining 8 least significant bits (LSBs) of idxUFIX16 are used to
% interpolate between these two table values. The LSB values are treated as
% a normalized scaling factor with 8-bit fractional data type |rFracNT|:
%
%   rFracNT      = numerictype(0,8,8); % fractional remainder data type
%   idxFrac8LSBs = reinterpretcast(bitsliceget(idxUFIX16,8,1), rFracNT);
%   rFraction    = idxFrac8LSBs;
%
% The two lookup table values, with the remainder (rFraction) value,
% are used to perform a simple nearest-neighbor linear interpolation.
% A real multiply is used to determine the weighted difference between the
% two points. This results in a simple calculation (equivalent to one
% product and two sums) to obtain the interpolated fixed-point result:
%
%   temp = rFraction * (lutValAbove - lutValBelow);
%   rslt = lutValBelow + temp;
%
% Finally, based on the original signs and relative magnitudes of y and x,
% the output result is formed using simple octant-correction logic and
% arithmetic. The first-octant [0, pi/4] angle value results are added or
% subtracted with constants to form the octant-corrected angle outputs.

%% Computing Fixed-point Argtangent Using |ATAN2|
%
% You can call the |atan2| function directly using fixed-point or
% floating-point inputs. The lookup table based algorithm is used for the
% fixed-point |atan2| implementation:
%
zFxpLUT = atan2(inYfix,inXfix);

%% 
% *Calculate the Overall Error*
%
% You can compute the overall error by comparing the fixed-point lookup
% table based approximation to the builtin |atan2| function. The ideal
% reference output is |zfltRef|.
%
lut_err = bsxfun(@minus, zfltRef, double(zFxpLUT)); 
max_lutErr_real_world_value = max(abs(lut_err'));
max_lutErr_bits = log2(max_lutErr_real_world_value);
fprintf('Overall error in bits: %g\n', max_lutErr_bits);
%%
figno = figno + 1; 
fidemo.fixpt_atan2_demo_plot(figno, theta, lut_err)

%% Comparison of Overall Error Between the Fixed-Point Implementations
%
% As was done previously, you can compute the overall error by comparing
% the fixed-point approximation(s) to the builtin |atan2| function. The
% ideal reference output is |zfltRef|.
%%
zfixCDC15      = cordicatan2(inYfix, inXfix, 15);
cordic_15I_err = bsxfun(@minus, zfltRef, double(zfixCDC15));
poly_7p_err    = bsxfun(@minus, zfltRef, double(zfix7p));
figno = figno + 1;
fidemo.fixpt_atan2_demo_plot(figno, theta, cordic_15I_err, poly_7p_err, lut_err)

%% Comparing the Costs of the Fixed-Point Approximation Algorithms
%
% The fixed-point CORDIC algorithm requires the following operations:
%%
% * 1 table lookup *per iteration*
% * 2 shifts *per iteration*
% * 3 additions *per iteration*
%%
% The N-th order fixed-point Chebyshev polynomial approximation algorithm
% requires the following operations:
%%
% * 1 division
% * (N+1) multiplications
% * (N-1)/2 additions
%%
%
% The simplified single lookup table algorithm with nearest-neighbor
% linear interpolation requires the following operations:
%%
% * 1 division
% * 2 table lookups
% * 1 multiplication
% * 2 additions
%%
%
% In real world applications, selecting an algorithm for the fixed-point
% arctangent calculation typically depends on the required accuracy, cost 
% and hardware constraints.

%%
close all; % close all figure windows

%% References
%
% # Jack E. Volder, The CORDIC Trigonometric Computing Technique, IRE
% Transactions on Electronic Computers, Volume EC-8, September 1959,
% pp330-334.
% # Ray Andraka, A survey of CORDIC algorithm for FPGA based computers,
% Proceedings of the 1998 ACM/SIGDA sixth international symposium on Field
% programmable gate arrays, Feb. 22-24, 1998, pp191-200

displayEndOfDemoMessage(mfilename)
