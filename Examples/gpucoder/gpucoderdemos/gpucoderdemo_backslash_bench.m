%% Benchmarking A\b with GPU Coder
% This example looks at how we can benchmark the solving of a linear system
% by generating GPU code.  The MATLAB(R) code to solve for |x| in |A*x = b|
% is very simple.  Most frequently, we use matrix left division, also known as
% |mldivide| or the backslash operator (\), to calculate |x| (that is, 
% |x = A\b|).
%

% Copyright 2017 The MathWorks, Inc.

%% Prerequisites
% * CUDA(R)-enabled NVIDIA(R) GPU with compute capability 3.5 or higher.
% * NVIDIA CUDA toolkit.
% * Environment variables for the compilers and libraries. For more 
% information see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_backslash_bench');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Determine the Maximum Data Size
% It is important to choose the appropriate matrix size for the
% computations.  We can do this by specifying the amount of system memory
% in GB available to the CPU and the GPU.  The default value is based only
% on the amount of memory available on the GPU, and you can specify a value
% that is appropriate for your system.
g = gpuDevice; 
maxMemory = 0.25*g.AvailableMemory/1024^3;

%% The Benchmarking Function
% We want to benchmark matrix left division (\), including the cost of
% transferring data between the CPU and GPU, to get a clear view of the
% total application time when using GPU Coder(TM), but not the time to create
% our data. We therefore separate the data generation from the function
% that solves the linear system, and will generate code and measure only
% that operation.
type getData.m

%% The Backslash Function
% The backslash function encapsulates the (\) operation for which we want 
% to generate code.
type backslash.m

%% Generating the GPU Code
% We create a function to generate the GPU MEX function based on the
% particular input data size. 
type genGpuCode.m

%% Choosing Problem Size
% As with a great number of other parallel algorithms, the performance of
% solving a linear system in parallel depends greatly on the matrix size.
% We compare the performance of the algorithm for different matrix sizes.

% Declare the matrix sizes to be a multiple of 1024.
sizeLimit = inf;
if ispc
    sizeLimit = double(intmax('int32'));
end
maxSizeSingle = min(floor(sqrt(maxMemory*1024^3/4)),floor(sqrt(sizeLimit/4)));
maxSizeDouble = min(floor(sqrt(maxMemory*1024^3/8)),floor(sqrt(sizeLimit/8)));
step = 1024;
if maxSizeDouble/step >= 10
    step = step*floor(maxSizeDouble/(5*step));
end
sizeSingle = 1024:step:maxSizeSingle;
sizeDouble = 1024:step:maxSizeDouble;
numReps = 5;

%% Comparing Performance: Speedup
% We use the total elapsed time as our measure of performance because that
% allows us to compare the performance of the algorithm for different
% matrix sizes. Given a matrix size, the benchmarking function creates the
% matrix |A| and the right-hand side |b| once, and then solves |A\b| a few
% times to get an accurate measure of the time it takes. 
%
type benchFcnMat.m

% We need to create a different function for GPU code execution that
% invokes the generated GPU MEX function.
type benchFcnGpu.m

%% Executing the Benchmarks
% Having done all the setup, it is straightforward to execute the
% benchmarks.  However, the computations can take a long time to complete,
% so we print some intermediate status information as we complete the
% benchmarking for each matrix size.  We also encapsulate the loop over
% all the matrix sizes in a function, to benchmark both single- and 
% double-precision computations.
%
% It is important to note that actual execution times will vary across
% different hardware configurations. This benchmarking was done using
% MATLAB 18a on a machine with an 8 core, 2.6GHz Intel(R) Xeon(R) CPU
% and an NVIDIA Titan X GPU.
type executeBenchmarks.m

%%
% We then execute the benchmarks in single and double precision.
[cpu, gpu] = executeBenchmarks('single', sizeSingle, numReps);
results.sizeSingle = sizeSingle;
results.timeSingleCPU = cpu;
results.timeSingleGPU = gpu;
[cpu, gpu] = executeBenchmarks('double', sizeDouble, numReps);
results.sizeDouble = sizeDouble;
results.timeDoubleCPU = cpu;
results.timeDoubleGPU = gpu;

%% Plotting the Performance
% We can now plot the results, and compare the performance on the CPU and
% the GPU, both for single and double precision.

%%
% First, we look at the performance of the backslash operator in single
% precision.
fig = figure;
ax = axes('parent', fig);
plot(ax, results.sizeSingle, results.timeSingleGPU, '-x', ...
     results.sizeSingle, results.timeSingleCPU, '-o')
grid on;
legend('GPU', 'CPU', 'Location', 'NorthWest');
title(ax, 'Single-precision performance')
ylabel(ax, 'Time (s)');
xlabel(ax, 'Matrix size');
drawnow;

%%
% Now, we look at the performance of the backslash operator in double
% precision.
fig = figure;
ax = axes('parent', fig);
plot(ax, results.sizeDouble, results.timeDoubleGPU, '-x', ...
     results.sizeDouble, results.timeDoubleCPU, '-o')
legend('GPU', 'CPU', 'Location', 'NorthWest');
grid on;
title(ax, 'Double-precision performance')
ylabel(ax, 'Time (s)');
xlabel(ax, 'Matrix size');
drawnow;

%%
% Finally, we look at the speedup of the backslash operator when comparing
% the GPU to the CPU.
speedupDouble = results.timeDoubleCPU./results.timeDoubleGPU;
speedupSingle = results.timeSingleCPU./results.timeSingleGPU;
fig = figure;
ax = axes('parent', fig);
plot(ax, results.sizeSingle, speedupSingle, '-v', ...
     results.sizeDouble, speedupDouble, '-*')
grid on;
legend('Single-precision', 'Double-precision', 'Location', 'SouthEast');
title(ax, 'Speedup of computations on GPU compared to CPU');
ylabel(ax, 'Speedup');
xlabel(ax, 'Matrix size');
drawnow;

%% Cleanup
% Remove the temporary files and return to the original folder.
cleanup

displayEndOfDemoMessage(mfilename)
