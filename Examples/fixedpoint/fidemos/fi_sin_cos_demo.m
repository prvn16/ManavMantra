%% Calculate Fixed-Point Sine and Cosine
% This example shows how to use both CORDIC-based and lookup table-based
% algorithms provided by the Fixed-Point Designer(TM) to approximate the
% MATLAB(R) sine (|SIN|) and cosine (|COS|) functions. Efficient
% fixed-point sine and cosine algorithms are critical to many embedded
% applications, including motor controls, navigation, signal processing,
% and wireless communications.
%
% Copyright 2009-2013 The MathWorks, Inc.

%% Calculating Sine and Cosine Using the CORDIC Algorithm
%
% *Introduction*
%
% The |cordiccexp|, |cordicsincos|, |cordicsin|, and |cordiccos| functions
% approximate the MATLAB |sin| and |cos| functions using a CORDIC-based
% algorithm. CORDIC is an acronym for COordinate Rotation DIgital Computer.
% The Givens rotation-based CORDIC algorithm (see [1,2]) is one of
% the most hardware efficient algorithms because it only requires iterative
% shift-add  operations. The CORDIC algorithm eliminates the need for
% explicit multipliers, and is suitable for calculating a variety of
% functions, such as sine, cosine, arcsine, arccosine, arctangent, vector
% magnitude, divide, square root, hyperbolic and logarithmic functions. 
%
% You can use the CORDIC rotation computing mode to calculate sine and
% cosine, and also polar-to-cartesian conversion operations. In this mode,
% the vector magnitude and an angle of rotation are known and the
% coordinate (X-Y) components are computed after rotation.
%
% *CORDIC Rotation Computation Mode*
%
% The CORDIC rotation mode algorithm begins by initializing an angle
% accumulator with the desired rotation angle. Next, the rotation decision
% at each CORDIC iteration is done in a way that decreases the magnitude of
% the residual angle accumulator. The rotation decision is based on the
% sign of the residual angle in the angle accumulator after each iteration.
%
% In rotation mode, the CORDIC equations are:
%
% $$ z_{i+1} = z_{i} - d_{i}*atan(2^{-i}) $$
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
% In rotation mode, the CORDIC algorithm is limited to rotation angles
% between $$ -\pi/2 $$ and $$ \pi/2 $$. To support angles outside of that
% range, the |cordiccexp|, |cordicsincos|, |cordicsin|, and |cordiccos|
% functions use quadrant correction (including possible extra negation)
% after the CORDIC iterations are completed.

%% Understanding the |CORDICSINCOS| Sine and Cosine Code
%
% *Introduction*
%
% The |cordicsincos| function calculates the sine and cosine of input
% angles in the range [-2*pi 2*pi) using the CORDIC algorithm. This function
% takes an angle $$ \theta $$ (radians) and the number of iterations as
% input arguments. The function returns approximations of sine and cosine.
%
% The CORDIC computation outputs are scaled by the rotator gain. This gain
% is accounted for by pre-scaling the initial $$ 1 / A_{N} $$ constant
% value.
%
% *Initialization*
%
% The |cordicsincos| function performs the following initialization steps:
%
% * The angle input look-up table |inpLUT| is set to |atan(2 .^ -(0:N-1))|.
% * $$ z_{0} $$ is set to the $$ \theta $$ input argument value.
% * $$ x_{0} $$ is set to $$ 1 / A_{N} $$.
% * $$ y_{0} $$ is set to zero.
%
% The judicious choice of initial values allows the algorithm to directly
% compute both sine and cosine simultaneously. After $$ N $$ iterations,
% these initial values lead to the following outputs as $$ N $$ approaches
% $$ +\infty $$:
%
% $$ x_{N} \approx cos(\theta) $$
%
% $$ y_{N} \approx sin(\theta) $$
%
% *Shared Fixed-Point and Floating-Point CORDIC Kernel Code*
%
% The MATLAB code for the CORDIC algorithm (rotation mode) kernel portion
% is as follows (for the case of scalar |x|, |y|, and |z|). This same code
% is used for both fixed-point and floating-point operations:
%
%   function [x, y, z] = cordic_rotation_kernel(x, y, z, inpLUT, n)
%   % Perform CORDIC rotation kernel algorithm for N kernel iterations.
%   xtmp = x;
%   ytmp = y;
%   for idx = 1:n
%       if z < 0
%           z(:) = z + inpLUT(idx);
%           x(:) = x + ytmp;
%           y(:) = y - xtmp;
%       else
%           z(:) = z - inpLUT(idx);
%           x(:) = x - ytmp;
%           y(:) = y + xtmp;
%       end
%       xtmp = bitsra(x, idx); % bit-shift-right for multiply by 2^(-idx)
%       ytmp = bitsra(y, idx); % bit-shift-right for multiply by 2^(-idx)
%   end

%% Visualizing the Sine-Cosine Rotation Mode CORDIC Iterations
%
% The CORDIC algorithm is usually run through a specified (constant) number
% of iterations since ending the CORDIC iterations early would break
% pipelined code, and the CORDIC gain $$ A_{n} $$ would not be constant
% because $$ n $$ would vary.
%
% For very large values of $$ n $$, the CORDIC algorithm is guaranteed to
% converge, but not always monotonically. As will be shown in the following
% example, intermediate iterations occasionally produce more accurate
% results than later iterations. You can typically achieve greater accuracy
% by increasing the total number of iterations.
%
% *Example*
%
% In the following example, iteration 5 provides a better estimate 
% of the result than iteration 6, and the CORDIC algorithm converges in
% later iterations.
%
theta   = pi/5; % input angle in radians
niters  = 10;   % number of iterations
sinTh   = sin(theta); % reference result
cosTh   = cos(theta); % reference result
y_sin   = zeros(niters, 1);
sin_err = zeros(niters, 1);
x_cos   = zeros(niters, 1);
cos_err = zeros(niters, 1);
fprintf('\n\nNITERS \tERROR\n');
fprintf('------\t----------\n');
for n = 1:niters
    [y_sin(n), x_cos(n)] = cordicsincos(theta, n);
    sin_err(n) = abs(y_sin(n) - sinTh);
    cos_err(n) = abs(x_cos(n) - cosTh);
    if n < 10
        fprintf('   %d \t %1.8f\n', n, cos_err(n));
    else
        fprintf('  %d \t %1.8f\n', n, cos_err(n));
    end
end
fprintf('\n');

%%
% *Plot the CORDIC approximation error on a bar graph*
%
figure(1); clf;
bar(1:niters, cos_err(1:niters));
xlabel('Number of iterations','fontsize',12,'fontweight','b');
ylabel('Error','fontsize',12,'fontweight','b');
title('CORDIC approximation error for cos(pi/5) computation',...
    'fontsize',12,'fontweight','b');
axis([0 niters 0 0.14]);

%%
% *Plot the X-Y results for 5 iterations*
%
Niter2Draw = 5;
figure(2), clf, hold on
plot(cos(0:0.1:pi/2), sin(0:0.1:pi/2), 'b--'); % semi-circle
for i=1:Niter2Draw
    plot([0 x_cos(i)],[0 y_sin(i)], 'LineWidth', 2); % CORDIC iteration result
    text(x_cos(i),y_sin(i),int2str(i),'fontsize',12,'fontweight','b');
end
plot(cos(theta), sin(theta), 'r*', 'MarkerSize', 20); % IDEAL result
xlabel('X (COS)','fontsize',12,'fontweight','b')
ylabel('Y (SIN)','fontsize',12,'fontweight','b')
title('CORDIC iterations for cos(pi/5) computation',...
    'fontsize',12,'fontweight','b')
axis equal;
axis square;

%% Computing Fixed-point Sine with |cordicsin|
%
% *Create 1024 points between [-2*pi, 2*pi)*
%
stepSize = pi/256;
thRadDbl = (-2*pi):stepSize:(2*pi - stepSize);
thRadFxp = sfi(thRadDbl, 12);     % signed, 12-bit fixed-point values
sinThRef = sin(double(thRadFxp)); % reference results

%%
% *Compare fixed-point CORDIC vs. double-precision trig function results*
%
% Use 12-bit quantized inputs and vary number of iterations from 4 to 10.
for niters = 4:3:10
    cdcSinTh  = cordicsin(thRadFxp,  niters);
    errCdcRef = sinThRef - double(cdcSinTh);
    figure; hold on; axis([-2*pi 2*pi -1.25 1.25]);
    plot(thRadFxp, sinThRef,  'b');
    plot(thRadFxp, cdcSinTh,  'g');
    plot(thRadFxp, errCdcRef, 'r');
    ylabel('sin(\Theta)','fontsize',12,'fontweight','b');
    set(gca,'XTick',-2*pi:pi/2:2*pi);
    set(gca,'XTickLabel',...
        {'-2*pi', '-3*pi/2', '-pi', '-pi/2', ...
        '0', 'pi/2', 'pi', '3*pi/2','2*pi'});
    set(gca,'YTick',-1:0.5:1);
    set(gca,'YTickLabel',{'-1.0','-0.5','0','0.5','1.0'});
    ref_str = 'Reference: sin(double(\Theta))';
    cdc_str = sprintf('12-bit CORDICSIN; N = %d', niters);
    err_str = sprintf('Error (max = %f)', max(abs(errCdcRef)));
    legend(ref_str, cdc_str, err_str);
    title(cdc_str,'fontsize',12,'fontweight','b');
end

%%
% *Compute the LSB Error for N = 10*
figure;
fracLen = cdcSinTh.FractionLength;
plot(thRadFxp, abs(errCdcRef) * pow2(fracLen));
set(gca,'XTick',-2*pi:pi/2:2*pi);
set(gca,'XTickLabel',...
    {'-2*pi', '-3*pi/2', '-pi', '-pi/2', ...
    '0', 'pi/2', 'pi', '3*pi/2','2*pi'});
ylabel(sprintf('LSB Error: 1 LSB = 2^{-%d}',fracLen),'fontsize',12,'fontweight','b');
title('LSB Error: 12-bit CORDICSIN; N=10','fontsize',12,'fontweight','b');
axis([-2*pi 2*pi 0 6]);

%%
% *Compute Noise Floor*
fft_mag = abs(fft(double(cdcSinTh)));
max_mag = max(fft_mag);
mag_db  = 20*log10(fft_mag/max_mag);
figure;
hold on;
plot(0:1023, mag_db);
plot(0:1023, zeros(1,1024),'r--');     % Normalized peak (0 dB)
plot(0:1023, -62.*ones(1,1024),'r--'); % Noise floor level
ylabel('dB Magnitude','fontsize',12,'fontweight','b');
title('62 dB Noise Floor: 12-bit CORDICSIN; N=10',...
    'fontsize',12,'fontweight','b');
% axis([0 1023 -120 0]); full FFT
axis([0 round(1024*(pi/8)) -100 10]); % zoom in
set(gca,'XTick',[0 round(1024*pi/16) round(1024*pi/8)]);
set(gca,'XTickLabel',{'0','pi/16','pi/8'});

%% Accelerating the Fixed-Point |CORDICSINCOS| Function with |FIACCEL|
% 
% You can generate a MEX function from MATLAB code using the MATLAB(R)
% <matlab:helpview([docroot,'/fixedpoint/ref/fiaccel.html']); fiaccel> function. Typically, running a generated
% MEX function can improve the simulation speed, although the actual speed
% improvement depends on the simulation platform being used. The following
% example shows how to accelerate the fixed-point |cordicsincos| function
% using |fiaccel|.
%
% The |fiaccel| function compiles the MATLAB code into a MEX function. 
% This step requires the creation of a temporary directory 
% and write permissions in this directory.
tempdirObj = fidemo.fiTempdir('fi_sin_cos_demo');

%%
% When you declare the number of iterations to be a constant (e.g., |10|)
% using |coder.newtype('constant',10)|, the compiled angle look-up table
% will also be constant, and thus won't be computed at each iteration.
% Also, when you call |cordicsincos_mex|, you will not need to give it the
% input argument for the number of iterations. If you pass in the number of
% iterations, the MEX-function will error.
% 
% The data type of the input parameters determines whether the 
% |cordicsincos| function performs fixed-point or floating-point
% calculations. When MATLAB generates code for this 
% file, code is only generated for the specific data type.  For example, 
% if the THETA input argument is fixed point, then only fixed-point code is
% generated.
%
inp = {thRadFxp, coder.newtype('constant',10)}; % example inputs for the function
fiaccel('cordicsincos', '-o', 'cordicsincos_mex',  '-args', inp)

%%
% First, calculate sine and cosine by calling |cordicsincos|.
tstart = tic; 
cordicsincos(thRadFxp,10);
telapsed_Mcordicsincos = toc(tstart);

%%
% Next, calculate sine and cosine by calling the MEX-function |cordicsincos_mex|.
cordicsincos_mex(thRadFxp); % load the MEX file
tstart = tic; 
cordicsincos_mex(thRadFxp);
telapsed_MEXcordicsincos = toc(tstart);

%%
% Now, compare the speed. Type the following at the MATLAB command line 
% to see the speed improvement on your platform:
fiaccel_speedup = telapsed_Mcordicsincos/telapsed_MEXcordicsincos;

%%
% To clean up the temporary directory, run the following commands:
clear cordicsincos_mex;
status = tempdirObj.cleanUp;

%% Calculating |SIN| and |COS| Using Lookup Tables
%
% There are many lookup table-based approaches that may be used to
% implement fixed-point sine and cosine approximations. The following is a
% low-cost approach based on a single real-valued lookup table and
% simple nearest-neighbor linear interpolation.

%% Single Lookup Table Based Approach
%
% The |sin| and |cos| methods of the |fi| object in the Fixed-Point Designer
% approximate the MATLAB(R) builtin floating-point |sin| and |cos|
% functions, using a lookup table-based approach with simple
% nearest-neighbor linear interpolation between values. This approach
% allows for a small real-valued lookup table and uses simple arithmetic.
%
% Using a single real-valued lookup table simplifies the index computation
% and the overall arithmetic required to achieve very good accuracy of the
% results. These simplifications yield relatively high speed performance
% and also relatively low memory requirements.

%% Understanding the Lookup Table Based |SIN| and |COS| Implementation
%
% *Lookup Table Size and Accuracy*
%
% Two important design considerations of a lookup table are its size and
% its accuracy. It is not possible to create a table for every possible
% input value $$ u $$. It is also not possible to be perfectly accurate due
% to the quantization of $$ sin(u) $$ or $$ cos(u) $$ lookup table values.
%
% As a compromise, the Fixed-Point Designer |SIN| and |COS| methods of |FI|
% use an 8-bit lookup table as part of their implementation. An 8-bit table
% is only 256 elements long, so it is small and efficient. Eight bits also
% corresponds to the size of a byte or a word on many platforms. Used in
% conjunction with linear interpolation, and 16-bit output (lookup table
% value) precision, an 8-bit-addressable lookup table provides both very
% good accuracy and performance.

%%
% *Initializing the Constant |SIN| Lookup Table Values*
%
% For implementation simplicity, table value uniformity, and speed, a full
% sinewave table is used. First, a quarter-wave |SIN| function is sampled
% at 64 uniform intervals in the range [0, pi/2) radians. Choosing a
% signed 16-bit fractional fixed-point data type for the table values,
% i.e., |tblValsNT = numerictype(1,16,15)|, produces best precision results
% in the |SIN| output range [-1.0, 1.0). The values are pre-quantized
% before they are set, to avoid overflow warnings.
%
tblValsNT = numerictype(1,16,15);
quarterSinDblFltPtVals  = (sin(2*pi*((0:63) ./ 256)))';
endpointQuantized_Plus1 = 1.0 - double(eps(fi(0,tblValsNT)));

halfSinWaveDblFltPtVals = ...
    [quarterSinDblFltPtVals; ...
    endpointQuantized_Plus1; ...
    flipud(quarterSinDblFltPtVals(2:end))];

fullSinWaveDblFltPtVals = ...
    [halfSinWaveDblFltPtVals; -halfSinWaveDblFltPtVals];

FI_SIN_LUT = fi(fullSinWaveDblFltPtVals, tblValsNT);

%%
% *Overview of Algorithm Implementation*
%
% The implementation of the Fixed-Point Designer |sin| and |cos| methods of
% |fi| objects involves first casting the fixed-point angle inputs $$ u $$
% (in radians) to a pre-defined data type in the range [0, 2pi]. For this
% purpose, a modulo-2pi operation is performed to obtain the fixed-point
% input value |inpValInRange| in the range [0, 2pi] and cast to in the best
% precision binary point scaled unsigned 16-bit fixed-point type
% |numerictype(0,16,13)|:
%
%   % Best UNSIGNED type for real-world value range [0,  2*pi],
%   % which maps to fixed-point stored integer vals [0, 51472].
%   inpInRangeNT = numerictype(0,16,13);
%
% Next, we get the 16-bit stored unsigned integer value from this in-range
% fixed-point FI angle value:
%
%   idxUFIX16 = fi(storedInteger(inpValInRange), numerictype(0,16,0));
%
% We multiply the stored integer value by a normalization constant,
% 65536/51472. The resulting integer value will be in a full-scale uint16
% index range:
%
%   normConst_NT = numerictype(0,32,31);
%   normConstant = fi(65536/51472, normConst_NT);
%   fullScaleIdx = normConstant * idxUFIX16;
%   idxUFIX16(:) = fullScaleIdx;
%
% The top 8 most significant bits (MSBs) of this full-scale unsigned 16-bit
% index |idxUFIX16| are used to directly index into the 8-bit sine lookup
% table. Two table lookups are performed, one at the computed table index
% location |lutValBelow|, and one at the next index location |lutValAbove|:
%
%   idxUint8MSBs = storedInteger(bitsliceget(idxUFIX16, 16, 9));
%   zeroBasedIdx = int16(idxUint8MSBs);
%   lutValBelow  = FI_SIN_LUT(zeroBasedIdx + 1);
%   lutValAbove  = FI_SIN_LUT(zeroBasedIdx + 2);
%
% The remaining 8 least significant bits (LSBs) of |idxUFIX16| are used to
% interpolate between these two table values. The LSB values are treated as
% a normalized scaling factor with 8-bit fractional data type |rFracNT|:
%
%   rFracNT      = numerictype(0,8,8); % fractional remainder data type
%   idxFrac8LSBs = reinterpretcast(bitsliceget(idxUFIX16,8,1), rFracNT);
%   rFraction    = idxFrac8LSBs;
%
% A real multiply is used to determine the weighted difference between the
% two points. This results in a simple calculation (equivalent to one
% product and two sums) to obtain the interpolated fixed-point sine result:
%
%   temp = rFraction * (lutValAbove - lutValBelow);
%   rslt = lutValBelow + temp;

%%
% *Example*
%
% Using the above algorithm, here is an example of the lookup table and
% linear interpolation process used to compute the value of
% |SIN| for a fixed-point input |inpValInRange = 0.425| radians:
%

% Use an arbitrary input value (e.g., 0.425 radians)
inpInRangeNT  = numerictype(0,16,13);    % best precision, [0, 2*pi] radians
inpValInRange = fi(0.425, inpInRangeNT); % arbitrary fixed-point input angle

% Normalize its stored integer to get full-scale unsigned 16-bit integer index
idxUFIX16     = fi(storedInteger(inpValInRange), numerictype(0,16,0));
normConst_NT  = numerictype(0,32,31);
normConstant  = fi(65536/51472, normConst_NT);
fullScaleIdx  = normConstant * idxUFIX16;
idxUFIX16(:)  = fullScaleIdx;

% Do two table lookups using unsigned 8-bit integer index (i.e., 8 MSBs)
idxUint8MSBs  = storedInteger(bitsliceget(idxUFIX16, 16, 9));
zeroBasedIdx  = int16(idxUint8MSBs);          % zero-based table index value
lutValBelow   = FI_SIN_LUT(zeroBasedIdx + 1); % 1st table lookup value
lutValAbove   = FI_SIN_LUT(zeroBasedIdx + 2); % 2nd table lookup value

% Do nearest-neighbor interpolation using 8 LSBs (treat as fractional remainder)
rFracNT       = numerictype(0,8,8); % fractional remainder data type
idxFrac8LSBs  = reinterpretcast(bitsliceget(idxUFIX16,8,1), rFracNT);
rFraction     = idxFrac8LSBs; % fractional value for linear interpolation
temp          = rFraction * (lutValAbove - lutValBelow);
rslt          = lutValBelow + temp;

%%
% Here is a plot of the algorithm results:
x_vals = 0:(pi/128):(pi/4);
xIdxLo = zeroBasedIdx - 1;
xIdxHi = zeroBasedIdx + 4;
figure; hold on; axis([x_vals(xIdxLo) x_vals(xIdxHi) 0.25 0.65]);
plot(x_vals(xIdxLo:xIdxHi), double(FI_SIN_LUT(xIdxLo:xIdxHi)), 'b^--');
plot([x_vals(zeroBasedIdx+1) x_vals(zeroBasedIdx+2)], ...
    [lutValBelow lutValAbove], 'k.'); % Closest values
plot(0.425, double(rslt), 'r*'); % Interpolated fixed-point result
plot(0.425, sin(0.425),   'gs'); % Double precision reference result
xlabel('X'); ylabel('SIN(X)');
lut_val_str = 'Fixed-point lookup table values';
near_str    = 'Two closest fixed-point LUT values';
interp_str  = 'Interpolated fixed-point result';
ref_str     = 'Double precision reference value';
legend(lut_val_str, near_str, interp_str, ref_str);
title('Fixed-Point Designer Lookup Table Based SIN with Linear Interpolation', ...
    'fontsize',12,'fontweight','b');

%% Computing Fixed-point Sine Using |SIN|
%
% *Create 1024 points between [-2*pi, 2*pi)*
stepSize = pi/256;
thRadDbl = (-2*pi):stepSize:(2*pi - stepSize); % double precision floating-point
thRadFxp = sfi(thRadDbl, 12); % signed, 12-bit fixed-point inputs

%%
% *Compare fixed-point SIN vs. double-precision SIN results*
fxpSinTh  = sin(thRadFxp); % fixed-point results
sinThRef  = sin(double(thRadFxp)); % reference results
errSinRef = sinThRef - double(fxpSinTh);
figure; hold on; axis([-2*pi 2*pi -1.25 1.25]);
plot(thRadFxp, sinThRef,  'b');
plot(thRadFxp, fxpSinTh,  'g');
plot(thRadFxp, errSinRef, 'r');
ylabel('sin(\Theta)','fontsize',12,'fontweight','b');
set(gca,'XTick',-2*pi:pi/2:2*pi);
set(gca,'XTickLabel',...
    {'-2*pi', '-3*pi/2', '-pi', '-pi/2', ...
    '0', 'pi/2', 'pi', '3*pi/2','2*pi'});
set(gca,'YTick',-1:0.5:1);
set(gca,'YTickLabel',{'-1.0','-0.5','0','0.5','1.0'});
ref_str = 'Reference: sin(double(\Theta))';
fxp_str = sprintf('16-bit Fixed-Point SIN with 12-bit Inputs');
err_str = sprintf('Error (max = %f)', max(abs(errSinRef)));
legend(ref_str, fxp_str, err_str);
title(fxp_str,'fontsize',12,'fontweight','b');

%%
% *Compute the LSB Error*
figure;
fracLen = fxpSinTh.FractionLength;
plot(thRadFxp, abs(errSinRef) * pow2(fracLen));
set(gca,'XTick',-2*pi:pi/2:2*pi);
set(gca,'XTickLabel',...
    {'-2*pi', '-3*pi/2', '-pi', '-pi/2', ...
    '0', 'pi/2', 'pi', '3*pi/2','2*pi'});
ylabel(sprintf('LSB Error: 1 LSB = 2^{-%d}',fracLen),'fontsize',12,'fontweight','b');
title('LSB Error: 16-bit Fixed-Point SIN with 12-bit Inputs','fontsize',12,'fontweight','b');
axis([-2*pi 2*pi 0 8]);

%%
% *Compute Noise Floor*
fft_mag = abs(fft(double(fxpSinTh)));
max_mag = max(fft_mag);
mag_db  = 20*log10(fft_mag/max_mag);
figure;
hold on;
plot(0:1023, mag_db);
plot(0:1023, zeros(1,1024),'r--');     % Normalized peak (0 dB)
plot(0:1023, -64.*ones(1,1024),'r--'); % Noise floor level (dB)
ylabel('dB Magnitude','fontsize',12,'fontweight','b');
title('64 dB Noise Floor: 16-bit Fixed-Point SIN with 12-bit Inputs',...
    'fontsize',12,'fontweight','b');
% axis([0 1023 -120 0]); full FFT
axis([0 round(1024*(pi/8)) -100 10]); % zoom in
set(gca,'XTick',[0 round(1024*pi/16) round(1024*pi/8)]);
set(gca,'XTickLabel',{'0','pi/16','pi/8'});

%% Comparing the Costs of the Fixed-Point Approximation Algorithms
%
% The fixed-point CORDIC algorithm requires the following operations:
%%
% * 1 table lookup *per iteration*
% * 2 shifts *per iteration*
% * 3 additions *per iteration*
%%
%
% The simplified single lookup table algorithm with nearest-neighbor
% linear interpolatiom requires the following operations:
%%
% * 2 table lookups
% * 1 multiplication
% * 2 additions
%%
%
% In real world applications, selecting an algorithm for the fixed-point
% trigonometric function calculations typically depends on the required 
% accuracy, cost and hardware constraints.

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
