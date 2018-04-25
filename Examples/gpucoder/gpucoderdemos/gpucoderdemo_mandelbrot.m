%% GPU Code Generation: The Mandelbrot Set
%
% This example shows how to generate CUDA(R) code from a simple MATLAB(R)
% function by using GPU Coder(TM). A Mandelbrot set implementation by using 
% standard MATLAB commands acts as the entry-point function. This example
% uses the |codegen| command to generate a MEX function that runs on the
% GPU. You can run the MEX function to check for run-time errors.   

% Copyright 2016 - 2017 The MathWorks, Inc. 


%% Prerequisites
% * CUDA-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
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
gpucoderdemo_setup('gpucoderdemo_mandelbrot');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Mandelbrot Set
% The Mandelbrot set is the region in the complex plane consisting of the 
% values $z_0$ for which the trajectories defined by
%
% $$z_{k+1} = {z_k}^2 + z_0, k = 0,1,...$$
%
% remain bounded at $k\rightarrow\infty$. The overall geometry of the 
% Mandelbrot set is shown in the figure. This view does not have the 
% resolution to show the richly detailed structure of the fringe just 
% outside the boundary of the set.
%
% <<mandelbrotSet.png>> 
%

%% Define Input Regions
% For this tutorial, pick a set of limits that specify a highly zoomed part
% of the Mandelbrot set in the valley between the main cardioid and the 
% $p/q$ bulb to its left. A |1000x1000| grid of $Re\{x\}$ and $Im\{y\}$ is 
% created between these two limits. The Mandelbrot algorithm is then 
% iterated at each grid location. An iteration number of 500 is enough to 
% render the image in full resolution.
maxIterations = 500;
gridSize = 1000;
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [ 0.123640844894862,  0.123640851045266];

x = linspace( xlim(1), xlim(2), gridSize );
y = linspace( ylim(1), ylim(2), gridSize );
[xGrid,yGrid] = meshgrid( x, y );
%% About the Mandelbrot Function
% The
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_mandelbrot','mandelbrot_count.m'))
% mandelbrot_count.m> function contains a vectorized implementation of the
% Mandelbrot set based on the code provided in Cleve Moler's e-book 
% <http://www.mathworks.com/moler/exm _Experiments in MATLAB_>. The
% %#codegen directive turns on MATLAB for code generation error checking.
% When GPU Coder encounters the |coder.gpu.kernelfun| pragma, it 
% attempts to parallelize all the computation within this function and then 
% maps it to the GPU.
type mandelbrot_count

%% Test the Functionality of |mandelbrot_count|
% Run the |mandelbrot_count| function with the xGrid, yGrid values that 
% were previously generated  and plot the results.
count = mandelbrot_count(maxIterations, xGrid, yGrid);

figure(2), imagesc( x, y, count );
colormap( [jet();flipud( jet() );0 0 0] );
title('Mandelbrot Set on MATLAB');
axis off

%% Generate CUDA MEX for the Function
% To generate CUDA MEX for the |mandelbrot_count| function, create a GPU 
% code configuration object and use the |codegen| function. Because of 
% architectural differences between the CPU and GPU, numerical verification
% does not always match. This scenario is specially true when using single 
% data type in your MATLAB code and performing accumulation operations on 
% these single data type values. However, there are cases like this 
% Mandelbrot example where even double data types cause numerical errors. 
% One reason for this mismatch is that the GPU floating point units use 
% fused Floating-point Multiply-Add (FMAD) instructions while the CPU does 
% not use these instructions. The |fmad=false| option that is passed to the
% |nvcc| compiler turns off this FMAD optimization.
cfg = coder.gpuConfig('mex');
cfg.GpuConfig.CompilerFlags = '--fmad=false';
codegen -config cfg -args {maxIterations,xGrid,yGrid} mandelbrot_count

%% Run the MEX Function
% After you generate a MEX function, you can verify that it has the same 
% functionality as the original MATLAB entry-point function. Run the 
% generated |mandelbrot_count_mex| and plot the results.
countGPU = mandelbrot_count_mex(maxIterations, xGrid, yGrid);

figure(2), imagesc( x, y, countGPU );
colormap( [jet();flipud( jet() );0 0 0] );
title('Mandelbrot Set on GPU');
axis off

%% Conclusion
% In this example, CUDA code was generated for a simple MATLAB function 
% implementing the Mandelbrot set. Implementation was accomplished by using 
% the |coder.gpu.kernelfun| pragma and invoking the |codegen| command to 
% generate MEX function. Additional compiler flags, namely FMAD=false was 
% passed to the |nvcc| compiler to disable floating-point multiply-add 
% optimization that the NVIDIA compilers perform. 
%% Cleanup
% Remove the generated files and return to the original folder.
cleanup


displayEndOfDemoMessage(mfilename)
