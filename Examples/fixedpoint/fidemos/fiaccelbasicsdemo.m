%% Accelerate Fixed-Point Simulation
% This example shows how to accelerate fixed-point algorithms using
% |fiaccel| function. You generate a MEX function from MATLAB(R) code, run the
% generated MEX function, and compare the execution speed with MATLAB code
% simulation.
%
% Copyright 1984-2013 The MathWorks, Inc.

%% Description of the Example
% This example uses a first-order feedback loop. It also uses a quantizer
% to avoid infinite bit growth. The output signal is delayed by one sample
% and fed back to dampen the input signal.
%
% <<fiaccelbasicsdemo_signal_diagram.png>>
%% Copy Required File
% You need this MATLAB-file to run this example. Copy it to a temporary
% directory. This step requires write-permission to the system's temporary
% directory.
tempdirObj = fidemo.fiTempdir('fiaccelbasicsdemo');
fiacceldir = tempdirObj.tempDir;
fiaccelsrc = ...
    fullfile(matlabroot,'toolbox','fixedpoint','fidemos','+fidemo','fiaccelFeedback.m');
copyfile(fiaccelsrc,fiacceldir,'f');
%% Inspect the MATLAB Feedback Function Code
% The MATLAB function that performs the feedback loop is in the file
% |fiaccelFeedback.m|. This code quantizes the input, and performs the
% feedback loop action :
type(fullfile(fiacceldir,'fiaccelFeedback.m'))
%%
% The following variables are used in this function:
% 
% * |x| is the input signal vector.
% * |y| is the output signal vector.
% * |a| is the feedback gain.
% * |w| is the unit-delayed output signal.

%% Create the Input Signal and Initialize Variables
rng('default');                      % Random number generator
x = fi(2*rand(1000,1)-1,true,16,15); % Input signal
a = fi(.9,true,16,15);               % Feedback gain
y = fi(zeros(size(x)),true,16,12);   % Initialize output. Fraction length 
                                     % is chosen to prevent overflow
w = fi(0,true,16,12);                % Initialize delayed output
A = coder.Constant(a);               % Declare "a" constant for code 
                                     % generation

%% Run Normal Mode
tic,
y = fiaccelFeedback(x,a,y,w);
t1 = toc;

%% Build the MEX Version of the Feedback Code
fiaccel fiaccelFeedback -args {x,A,y,w} -o fiaccelFeedback_mex

%% Run the MEX Version 
tic
y2 = fiaccelFeedback_mex(x,y,w);
t2 = toc;

%% Acceleration Ratio
% Code acceleration provides optimizations for accelerating fixed-point
% algorithms through MEX file generation. Fixed-Point Designer(TM) provides a
% convenience function |fiaccel| to convert your MATLAB code to a MEX
% function, which can greatly accelerate the execution speed of your
% fixed-point algorithms.
r = t1/t2

%% Clean up Temporary Files
clear fiaccelFeedback_mex;
tempdirObj.cleanUp;


displayEndOfDemoMessage(mfilename)
