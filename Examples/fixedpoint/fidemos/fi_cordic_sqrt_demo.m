%% Compute Square Root Using CORDIC
% This example shows how to compute square root using a CORDIC
% kernel algorithm in MATLAB(R). CORDIC-based algorithms are critical to
% many embedded applications, including motor controls, navigation, signal
% processing, and wireless communications.
%
% Copyright 2009-2013 The MathWorks, Inc.

%% Introduction
% CORDIC is an acronym for COordinate Rotation DIgital Computer.
% The Givens rotation-based CORDIC algorithm (see [1,2]) is one of
% the most hardware efficient algorithms because it only requires iterative
% shift-add  operations. The CORDIC algorithm eliminates the need for
% explicit multipliers, and is suitable for calculating a variety of
% functions, such as sine, cosine, arcsine, arccosine, arctangent, vector
% magnitude, divide, square root, hyperbolic and logarithmic functions. 
%
% The fixed-point CORDIC algorithm requires the following operations:
%
% * 1 table lookup *per iteration*
% * 2 shifts *per iteration*
% * 3 additions *per iteration*
%
% Note that for hyperbolic CORDIC-based algorithms, such as square root,
% certain iterations (i = 4, 13, 40, 121, ..., k, 3k+1, ...) are repeated
% to achieve result convergence.


%% CORDIC Kernel Algorithms Using Hyperbolic Computation Modes
%
% You can use a CORDIC computing mode algorithm to calculate hyperbolic
% functions, such as hyperbolic trigonometric, square root, log, exp, etc.
%
% *CORDIC EQUATIONS IN HYPERBOLIC VECTORING MODE*
%
% The hyperbolic vectoring mode is used for computing *square root*.
%
% For the vectoring mode, the CORDIC equations are as follows:
%
% $$ x_{i+1} = x_{i} + y_{i}*d_{i}*2^{-i} $$
%
% $$ y_{i+1} = y_{i} + x_{i}*d_{i}*2^{-i} $$
%
% $$ z_{i+1} = z_{i} - d_{i}*\mbox{atanh}(2^{-i}) $$
%
% where
%
% $$  d_{i} = +1 $$  if  $$ y_{i} < 0 $$, and $$ -1  $$ otherwise.
% 
% This mode provides the following result as $$ N $$ approaches $$ +\infty $$:
%
% * $$ x_{N} \approx A_{N}\sqrt{x_{0}^2-y_{0}^2} $$
% * $$ y_{N} \approx 0 $$
% * $$ z_{N} \approx z_{0} + \mbox{atanh}({y_{0}/x_{0}}) $$
%
% where
%
% $$ A_{N} = \prod_{i=0}^{N-1}{\sqrt{1-2^{-2i}}} $$.
%
% Typically $$ N $$ is chosen to be a large-enough constant value. Thus,
% $$ A_{N} $$ may be pre-computed.
%
% Note also that for *square root* we will use only the $$ x_{N} $$ result.
%


%% MATLAB Implementation of a CORDIC Hyperbolic Vectoring Algorithm
%
% A MATLAB code implementation example of the CORDIC Hyperbolic Vectoring
% Kernel algorithm follows (for the case of scalar |x|, |y|, and |z|). This
% same code can be used for both fixed-point and floating-point data types.
%
% *CORDIC Hyperbolic Vectoring Kernel*
%
%   k = 4; % Used for the repeated (3*k + 1) iteration steps
%   
%   for idx = 1:n
%       xtmp = bitsra(x, idx); % multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % multiply by 2^(-idx)
%       if y < 0
%           x(:) = x + ytmp;
%           y(:) = y + xtmp;
%           z(:) = z - atanhLookupTable(idx);
%       else
%           x(:) = x - ytmp;
%           y(:) = y - xtmp;
%           z(:) = z + atanhLookupTable(idx);
%       end
%       
%       if idx==k
%           xtmp = bitsra(x, idx); % multiply by 2^(-idx)
%           ytmp = bitsra(y, idx); % multiply by 2^(-idx)
%           if y < 0
%               x(:) = x + ytmp;
%               y(:) = y + xtmp;
%               z(:) = z - atanhLookupTable(idx);
%           else
%               x(:) = x - ytmp;
%               y(:) = y - xtmp;
%               z(:) = z + atanhLookupTable(idx);
%           end
%           k = 3*k + 1;
%        end
%   end % idx loop


%% CORDIC-Based Square Root Computation
%
% *Square Root Computation Using the CORDIC Hyperbolic Vectoring Kernel*
%
% The judicious choice of initial values allows the CORDIC kernel
% hyperbolic vectoring mode algorithm to compute square root.
%
% First, the following initialization steps are performed:
%
% * $$ x_{0} $$ is set to $$ v + 0.25 $$.
% * $$ y_{0} $$ is set to $$ v - 0.25 $$.
%
% After $$ N $$ iterations, these initial values lead to the following
% output as $$ N $$ approaches $$ +\infty $$:
%
% $$ x_{N} \approx A_{N}\sqrt{(v + 0.25)^2 - (v - 0.25)^2} $$
%
% This may be further simplified as follows:
%
% $$ x_{N} \approx A_{N}\sqrt{v} $$
%
% where $$ A_{N} $$ is the CORDIC gain as defined above.
%
% Note: for square root, $$ z $$ and |atanhLookupTable| have no impact on
% the result. Hence, $$ z $$ and |atanhLookupTable| are not used.
%


%% MATLAB Implementation of a CORDIC Square Root Kernel
%
% A MATLAB code implementation example of the CORDIC Square Root Kernel
% algorithm follows (for the case of scalar |x| and |y|). This same code
% can be used for both fixed-point and floating-point data types.
%
% *CORDIC Square Root Kernel*
%
%   k = 4; % Used for the repeated (3*k + 1) iteration steps
%   
%   for idx = 1:n
%       xtmp = bitsra(x, idx); % multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % multiply by 2^(-idx)
%       if y < 0
%           x(:) = x + ytmp;
%           y(:) = y + xtmp;
%       else
%           x(:) = x - ytmp;
%           y(:) = y - xtmp;
%       end
%       
%       if idx==k
%           xtmp = bitsra(x, idx); % multiply by 2^(-idx)
%           ytmp = bitsra(y, idx); % multiply by 2^(-idx)
%           if y < 0
%               x(:) = x + ytmp;
%               y(:) = y + xtmp;
%           else
%               x(:) = x - ytmp;
%               y(:) = y - xtmp;
%           end
%           k = 3*k + 1;
%        end
%   end % idx loop
%
% This code is identical to the *CORDIC Hyperbolic Vectoring Kernel*
% implementation above, except that |z| and |atanhLookupTable| are not used.
% This is a cost savings of 1 table lookup and 1 addition per iteration.
%
%
% *Example*
%
% Use the CORDICSQRT function to compute the approximate square root of
% |v_fix| using ten CORDIC kernel iterations:
%

step  = 2^-7;
v_fix = fi(0.5:step:(2-step), 1, 20); % fixed-point inputs in range [.5, 2)
niter = 10; % number of CORDIC iterations
x_sqr = cordicsqrt(v_fix, niter);

% Get the Real World Value (RWV) of the CORDIC outputs for comparison
% and plot the error between the MATLAB reference and CORDIC sqrt values
x_cdc = double(x_sqr); % CORDIC results (scaled by An_hp)
v_ref = double(v_fix); % Reference floating-point input values
x_ref = sqrt(v_ref);   % MATLAB reference floating-point results
figure;
subplot(211);
plot(v_ref, x_cdc, 'r.', v_ref, x_ref, 'b-');
legend('CORDIC', 'Reference', 'Location', 'SouthEast');
title('CORDIC Square Root (In-Range) and MATLAB Reference Results');
subplot(212);
absErr = abs(x_ref - x_cdc);
plot(v_ref, absErr);
title('Absolute Error (vs. MATLAB SQRT Reference Results)');


%%
% *Overcoming Algorithm Input Range Limitations*
%
% Many square root algorithms normalize the input value, $$ v $$, to within
% the range of [0.5, 2) range. This pre-processing is typically done using
% a fixed word length normalization, and can be used to support small as
% well as large input value ranges.
%
% The CORDIC-based square root algorithm implementation is particularly
% sensitive to inputs outside of this range. The function CORDICSQRT
% overcomes this algorithm range limitation through a normalization
% approach based on the following mathematical relationships:
%
% $$ v = u * 2^{n} $$, for some $$ 0.5 <= u < 2 $$ and some even integer $$ n $$.
%
% Thus:
%
% $$ \sqrt{v} = \sqrt{u} * 2^{n/2} $$
%
% In the CORDICSQRT function, the values for $$ u $$ and $$ n $$, described
% above, are found during normalization of the input $$ v $$. $$ n $$ is
% the number of leading zero most significant bits (MSBs) in the binary
% representation of the input $$ v $$. These values are found through a
% series of bitwise logic and shifts. Note: because $$ n $$ must be even,
% if the number of leading zero MSBs is odd, one additional bit shift is
% made to make $$ n $$ even. The resulting value after these shifts is the
% value $$ 0.5 <= u < 2 $$.
%
% $$ u $$ becomes the input to the CORDIC-based square root kernel, where
% an approximation to $$ \sqrt{u} $$ is calculated. The result is then
% scaled by $$ 2^{n/2} $$ so that it is back in the correct output range.
% This is achieved through a simple bit shift by $$ n/2 $$ bits. The (left
% or right) shift direction dependends on the sign of $$ n $$.
%
%
% *Example*
%
% Compute the square root of 10-bit fixed-point input data with a small
% non-negative range using CORDIC. Compare the CORDIC-based algorithm
% results to the floating-point MATLAB reference results over the same
% input range.

step     = 2^-8;
u_ref    = 0:step:(0.5-step); % Input array (small range of values)
u_in_arb = fi(u_ref,0,10); % 10-bit unsigned fixed-point input data values
u_len    = numel(u_ref);
sqrt_ref = sqrt(double(u_in_arb)); % MATLAB sqrt reference results
niter    = 10;
results  = zeros(u_len, 2);
results(:,2) = sqrt_ref(:);

% Compute the equivalent Real World Value result for plotting.
% Plot the Real World Value (RWV) of CORDIC and MATLAB reference results.
x_out = cordicsqrt(u_in_arb, niter);
results(:,1) = double(x_out);
figure;
subplot(211);
plot(u_ref, results(:,1), 'r.', u_ref, results(:,2), 'b-');
legend('CORDIC', 'Reference', 'Location', 'SouthEast');
title('CORDIC Square Root (Small Input Range) and MATLAB Reference Results');
axis([0 0.5 0 0.75]);
subplot(212);
absErr = abs(results(:,2) - results(:,1));
plot(u_ref, absErr);
title('Absolute Error (vs. MATLAB SQRT Reference Results)');


%%
% *Example*
%
% Compute the square root of 16-bit fixed-point input data with a large
% positive range using CORDIC. Compare the CORDIC-based algorithm results
% to the floating-point MATLAB reference results over the same input range.
%

u_ref    = 0:5:2500;       % Input array (larger range of values)
u_in_arb = fi(u_ref,0,16); % 16-bit unsigned fixed-point input data values
u_len    = numel(u_ref);
sqrt_ref = sqrt(double(u_in_arb)); % MATLAB sqrt reference results
niter    = 16;
results  = zeros(u_len, 2);
results(:,2) = sqrt_ref(:);

% Compute the equivalent Real World Value result for plotting.
% Plot the Real World Value (RWV) of CORDIC and MATLAB reference results.
x_out = cordicsqrt(u_in_arb, niter);
results(:,1) = double(x_out);
figure;
subplot(211);
plot(u_ref, results(:,1), 'r.', u_ref, results(:,2), 'b-');
legend('CORDIC', 'Reference', 'Location', 'SouthEast');
title('CORDIC Square Root (Large Input Range) and MATLAB Reference Results');
axis([0 2500 0 55]);
subplot(212);
absErr = abs(results(:,2) - results(:,1));
plot(u_ref, absErr);
title('Absolute Error (vs. MATLAB SQRT Reference Results)');


%% References
%
% # Jack E. Volder, The CORDIC Trigonometric Computing Technique, IRE
% Transactions on Electronic Computers, Volume EC-8, September 1959,
% pp330-334.
% # Ray Andraka, A survey of CORDIC algorithm for FPGA based computers,
% Proceedings of the 1998 ACM/SIGDA sixth international symposium on Field
% programmable gate arrays, Feb. 22-24, 1998, pp191-200

displayEndOfDemoMessage(mfilename)
