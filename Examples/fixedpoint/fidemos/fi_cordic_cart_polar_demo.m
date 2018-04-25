%% Convert Cartesian to Polar Using CORDIC Vectoring Kernel
% This example shows how to convert Cartesian to polar coordinates
% using a CORDIC vectoring kernel algorithm in MATLAB(R).
% CORDIC-based algorithms are critical to many embedded applications,
% including motor controls, navigation, signal processing, and wireless
% communications.
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


%% CORDIC Kernel Algorithm Using the Vectoring Computation Mode
%
% You can use a CORDIC vectoring computing mode algorithm to calculate
% |atan(y/x)|, compute cartesian-polar to cartesian conversions, and for
% other operations. In vectoring mode, the CORDIC rotator rotates the input
% vector towards the positive X-axis to minimize the  $$ y $$ component of
% the residual vector. For each iteration, if the $$ y $$ coordinate of the
% residual vector is positive, the CORDIC rotator rotates clockwise (using
% a negative angle); otherwise, it rotates counter-clockwise (using a
% positive angle). Each rotation uses a progressively smaller angle value.
% If the angle accumulator is initialized to 0, at the end of the
% iterations, the accumulated rotation angle is the angle of the original
% input vector.
%
% In vectoring mode, the CORDIC equations are: 
%
% $$ x_{i+1} = x_{i} - y_{i}*d_{i}*2^{-i} $$
%
% $$ y_{i+1} = y_{i} + x_{i}*d_{i}*2^{-i} $$
%
% $$ z_{i+1} = z_{i} + d_{i}*\mbox{atan}(2^{-i}) $$ is the angle accumulator
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
% $$ z_{N} = z_{0} + \mbox{atan}(y_{0}/x_{0}) $$
%
% Where:
%
% $$ A_{N} = \prod_{i=0}^{N-1}{\sqrt{1+2^{-2i}}} $$.
%
% Typically $$ N $$ is chosen to be a large-enough constant value. Thus,
% $$ A_{N} $$ may be pre-computed.


%% Efficient MATLAB Implementation of a CORDIC Vectoring Kernel Algorithm
%
% A MATLAB code implementation example of the CORDIC Vectoring Kernel
% algorithm follows (for the case of scalar |x|, |y|, and |z|). This same
% code can be used for both fixed-point and floating-point operation.
%
% *CORDIC Vectoring Kernel*
%
%   function [x, y, z] = cordic_vectoring_kernel(x, y, z, inpLUT, n)
%   % Perform CORDIC vectoring kernel algorithm for N iterations.
%   xtmp = x;
%   ytmp = y;
%   for idx = 1:n
%       if y < 0
%           x(:) = accumneg(x, ytmp);
%           y(:) = accumpos(y, xtmp);
%           z(:) = accumneg(z, inpLUT(idx));
%       else
%           x(:) = accumpos(x, ytmp);
%           y(:) = accumneg(y, xtmp);
%           z(:) = accumpos(z, inpLUT(idx));
%       end
%       xtmp = bitsra(x, idx); % bit-shift-right for multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % bit-shift-right for multiply by 2^(-idx)
%   end


%% CORDIC-Based Cartesian to Polar Conversion Using Normalized Input Units
%
% *Cartesian to Polar Computation Using the CORDIC Vectoring Kernel*
%
% The judicious choice of initial values allows the CORDIC kernel vectoring
% mode algorithm to directly compute the magnitude
% $$ R = \sqrt{x_{0}^2+y_{0}^2} $$ and angle
% $$ \theta = \mbox{atan}(y_{0}/x_{0}) $$.
%
% The input accumulators are initialized to the input coordinate values:
%
% * $$ x_{0} = X $$
% * $$ y_{0} = Y $$
%
% The angle accumulator is initialized to zero:
%
% * $$ z_{0} = 0 $$
%
% After $$ N $$ iterations, these initial values lead to the following
% outputs as $$ N $$ approaches $$ +\infty $$:
%
% * $$ x_{N} \approx A_{N}\sqrt{x_{0}^2+y_{0}^2} $$
% * $$ z_{N} \approx \mbox{atan}(y_{0}/x_{0}) $$
%
% Other vectoring-kernel-based function approximations are possible via
% pre- and post-processing and using other initial conditions (see [1,2]).
%
%
% *Example*
%
% Suppose that you have some measurements of Cartesian (X,Y) data,
% normalized to values between [-1, 1), that you want to convert into polar
% (magnitude, angle) coordinates. Also suppose that you have a 16-bit
% integer arithmetic unit that can perform add, subtract, shift, and memory
% operations. With such a device, you could implement the CORDIC vectoring
% kernel to efficiently compute magnitude and angle from the input (X,Y)
% coordinate values, without the use of multiplies or large lookup tables.
%

sumWL  = 16; % CORDIC sum word length
thNorm = -1.0:(2^-8):1.0; % Also using normalized [-1.0, 1.0] angle values
theta  = fi(thNorm, 1, sumWL); % Fixed-point angle values (best precision)
z_NT   = numerictype(theta);   % Data type for Z
xyCPNT = numerictype(1,16,15); % Using normalized X-Y range [-1.0, 1.0)
thetaRadians = pi/2 .* thNorm; % real-world range [-pi/2 pi/2] angle values
inXfix = fi(0.50 .* cos(thetaRadians), xyCPNT); % X coordinate values
inYfix = fi(0.25 .* sin(thetaRadians), xyCPNT); % Y coordinate values

niters = 13; % Number of CORDIC iterations
inpLUT = fi(atan(2 .^ (-((0:(niters-1))'))) .* (2/pi), z_NT); % Normalized
z_c2p  = fi(zeros(size(theta)), z_NT);   % Z array pre-allocation
x_c2p  = fi(zeros(size(theta)), xyCPNT); % X array pre-allocation
y_c2p  = fi(zeros(size(theta)), xyCPNT); % Y array pre-allocation

for idx = 1:length(inXfix)
    % CORDIC vectoring kernel iterations
    [x_c2p(idx), y_c2p(idx), z_c2p(idx)] = ...
        fidemo.cordic_vectoring_kernel(...
            inXfix(idx), inYfix(idx), fi(0, z_NT), inpLUT, niters);
end

% Get the Real World Value (RWV) of the CORDIC outputs for comparison
% and plot the error between the (magnitude, angle) values
AnGain       = prod(sqrt(1+2.^(-2*(0:(niters-1))))); % CORDIC gain
x_c2p_RWV    = (1/AnGain) .* double(x_c2p); % Magnitude (scaled by CORDIC gain)
z_c2p_RWV    =   (pi/2)   .* double(z_c2p); % Angles (in radian units)
[thRWV,rRWV] = cart2pol(double(inXfix), double(inYfix)); % MATLAB reference
magnitudeErr = rRWV - x_c2p_RWV;
angleErr     = thRWV - z_c2p_RWV;
figure;
subplot(411);
plot(thNorm, x_c2p_RWV);
axis([-1 1 0.25 0.5]);
title('CORDIC Magnitude (X) Values');
subplot(412);
plot(thNorm, magnitudeErr);
title('Error between Magnitude Reference Values and X Values');
subplot(413);
plot(thNorm, z_c2p_RWV);
title('CORDIC Angle (Z) Values');
subplot(414);
plot(thNorm, angleErr);
title('Error between Angle Reference Values and Z Values');


%% References
%
% # Jack E. Volder, The CORDIC Trigonometric Computing Technique, IRE
% Transactions on Electronic Computers, Volume EC-8, September 1959,
% pp330-334.
% # Ray Andraka, A survey of CORDIC algorithm for FPGA based computers,
% Proceedings of the 1998 ACM/SIGDA sixth international symposium on Field
% programmable gate arrays, Feb. 22-24, 1998, pp191-200

displayEndOfDemoMessage(mfilename)
