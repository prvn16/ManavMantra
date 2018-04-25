%% Compute Sine and Cosine Using CORDIC Rotation Kernel
% This example shows how to compute sine and cosine using a
% CORDIC rotation kernel in MATLAB(R). CORDIC-based algorithms are critical
% to many embedded applications, including motor controls, navigation,
% signal processing, and wireless communications.
%
% Copyright 2009-2012 The MathWorks, Inc.

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


%% CORDIC Kernel Algorithm Using the Rotation Computation Mode
%
% You can use a CORDIC rotation computing mode algorithm to calculate sine
% and cosine simultaneously, compute polar-to-cartesian conversions, and
% for other operations. In the rotation mode, the vector magnitude and an
% angle of rotation are known and the coordinate (X-Y) components are
% computed after rotation.
%
% The CORDIC rotation mode algorithm begins by initializing an angle
% accumulator with the desired rotation angle. Next, the rotation decision
% at each CORDIC iteration is done in a way that decreases the magnitude of
% the residual angle accumulator. The rotation decision is based on the
% sign of the residual angle in the angle accumulator after each iteration.
%
% In rotation mode, the CORDIC equations are:
%
% $$ z_{i+1} = z_{i} - d_{i}*\mbox{atan}(2^{-i}) $$
%
% $$ x_{i+1} = x_{i} - y_{i}*d_{i}*2^{-i} $$
%
% $$ y_{i+1} = y_{i} + x_{i}*d_{i}*2^{-i} $$
%
% where 
%   $$  d_{i} = -1 $$  if  $$ z_{i} < 0 $$, and $$ +1  $$ otherwise;
%
% $$ i = 0, 1, ..., N-1 $$, and $$ N $$ is the total number of iterations.
%
% This provides the following result as $$ N $$ approaches $$ +\infty $$:
%
% $$ z_{N} = 0 $$
%
% $$ x_{N} = A_{N}(x_{0}\cos{z_{0}} - y_{0}\sin{z_{0}}) $$
%
% $$ y_{N} = A_{N}(y_{0}\cos{z_{0}} + x_{0}\sin{z_{0}}) $$
%
% Where:
%
% $$ A_{N} = \prod_{i=0}^{N-1}{\sqrt{1+2^{-2i}}} $$.
%
% Typically $$ N $$ is chosen to be a large-enough constant value. Thus,
% $$ A_{N} $$ may be pre-computed.
%
% In rotation mode, the CORDIC algorithm is limited to rotation angles
% between $$ -\pi/2 $$ and $$ \pi/2 $$. To support angles outside of that
% range, quadrant correction is often used.


%% Efficient MATLAB Implementation of a CORDIC Rotation Kernel Algorithm
%
% A MATLAB code implementation example of the CORDIC Rotation Kernel
% algorithm follows (for the case of scalar |x|, |y|, and |z|). This same
% code can be used for both fixed-point and floating-point operation.
%
% *CORDIC Rotation Kernel*
%
%   function [x, y, z] = cordic_rotation_kernel(x, y, z, inpLUT, n)
%   % Perform CORDIC rotation kernel algorithm for N iterations.
%   xtmp = x;
%   ytmp = y;
%   for idx = 1:n
%       if z < 0
%           z(:) = accumpos(z, inpLUT(idx));
%           x(:) = accumpos(x, ytmp);
%           y(:) = accumneg(y, xtmp);
%       else
%           z(:) = accumneg(z, inpLUT(idx));
%           x(:) = accumneg(x, ytmp);
%           y(:) = accumpos(y, xtmp);
%       end
%       xtmp = bitsra(x, idx); % bit-shift-right for multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % bit-shift-right for multiply by 2^(-idx)
%   end


%% CORDIC-Based Sine and Cosine Computation Using Normalized Inputs
%
% *Sine and Cosine Computation Using the CORDIC Rotation Kernel*
%
% The judicious choice of initial values allows the CORDIC kernel rotation
% mode algorithm to directly compute both sine and cosine simultaneously.
%
% First, the following initialization steps are performed:
%
% * The angle input look-up table |inpLUT| is set to |atan(2 .^ -(0:N-1))|.
% * $$ z_{0} $$ is set to the $$ \theta $$ input argument value.
% * $$ x_{0} $$ is set to $$ 1 / A_{N} $$.
% * $$ y_{0} $$ is set to zero.
%
% After $$ N $$ iterations, these initial values lead to the following
% outputs as $$ N $$ approaches $$ +\infty $$:
%
% * $$ x_{N} \approx cos(\theta) $$
% * $$ y_{N} \approx sin(\theta) $$
%
% Other rotation-kernel-based function approximations are possible via pre-
% and post-processing and using other initial conditions (see [1,2]).
%
% The CORDIC algorithm is usually run through a specified (constant) number
% of iterations since ending the CORDIC iterations early would break
% pipelined code, and the CORDIC gain $$ A_{n} $$ would not be constant
% because $$ n $$ would vary.
%
% For very large values of $$ n $$, the CORDIC algorithm is guaranteed to
% converge, but not always monotonically. You can typically achieve greater
% accuracy by increasing the total number of iterations.
%
%
% *Example*
%
% Suppose that you have a rotation angle sensor (e.g. in a servo motor)
% that uses formatted integer values to represent measured angles of
% rotation. Also suppose that you have a 16-bit integer arithmetic unit
% that can perform add, subtract, shift, and memory operations. With such a
% device, you could implement the CORDIC rotation kernel to efficiently
% compute cosine and sine (equivalently, cartesian X and Y coordinates)
% from the sensor angle values, without the use of multiplies or large
% lookup tables.
%

sumWL  = 16; % CORDIC sum word length
thNorm = -1.0:(2^-8):1.0; % Normalized [-1.0, 1.0] angle values
theta  = fi(thNorm, 1, sumWL); % Fixed-point angle values (best precision)

z_NT   = numerictype(theta);             % Data type for Z
xyNT   = numerictype(1, sumWL, sumWL-2); % Data type for X-Y
x_out  = fi(zeros(size(theta)), xyNT);   % X array pre-allocation
y_out  = fi(zeros(size(theta)), xyNT);   % Y array pre-allocation
z_out  = fi(zeros(size(theta)), z_NT);   % Z array pre-allocation

niters = 13; % Number of CORDIC iterations
inpLUT = fi(atan(2 .^ (-((0:(niters-1))'))) .* (2/pi), z_NT); % Normalized
AnGain = prod(sqrt(1+2.^(-2*(0:(niters-1))))); % CORDIC gain
inv_An = 1 / AnGain; % 1/A_n inverse of CORDIC gain

for idx = 1:length(theta)
    % CORDIC rotation kernel iterations
    [x_out(idx), y_out(idx), z_out(idx)] = ...
        fidemo.cordic_rotation_kernel(...
            fi(inv_An, xyNT), fi(0, xyNT), theta(idx), inpLUT, niters);
end

% Plot the CORDIC-approximated sine and cosine values
figure;
subplot(411);
plot(thNorm, x_out);
axis([-1 1 -1 1]);
title('Normalized X Values from CORDIC Rotation Kernel Iterations');
subplot(412);
thetaRadians = pi/2 .* thNorm; % real-world range [-pi/2 pi/2] angle values
plot(thNorm, cos(thetaRadians) - double(x_out));
title('Error between MATLAB COS Reference Values and X Values');
subplot(413);
plot(thNorm, y_out);
axis([-1 1 -1 1]);
title('Normalized Y Values from CORDIC Rotation Kernel Iterations');
subplot(414);
plot(thNorm, sin(thetaRadians) - double(y_out));
title('Error between MATLAB SIN Reference Values and Y Values');


%% References
%
% # Jack E. Volder, The CORDIC Trigonometric Computing Technique, IRE
% Transactions on Electronic Computers, Volume EC-8, September 1959,
% pp330-334.
% # Ray Andraka, A survey of CORDIC algorithm for FPGA based computers,
% Proceedings of the 1998 ACM/SIGDA sixth international symposium on Field
% programmable gate arrays, Feb. 22-24, 1998, pp191-200

displayEndOfDemoMessage(mfilename)
