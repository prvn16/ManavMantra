%% Stencil Processing on GPU
%
% This example shows how to generate CUDA(R) kernels for stencil type 
% operations by implementing John H. Conway's "Game of Life". 
% 
% "Game of Life" is a zero-player |cellular automaton| game that consists 
% of a collection of cells (|population|) in a rectangular grid 
% (|universe|). The cells evolve at discrete time steps known as 
% |generations|. A set of mathematical rules applied to the cells and its 
% neighbors control their life, death,and reproduction. This "Game of Life" 
% implementation is based on the example provided in Cleve Moler's e-book 
% <http://www.mathworks.com/moler/exm _Experiments in MATLAB_>.
% It follows a few simple rules:
% 
% * Cells are arranged in a 2D grid
% * At each step, the fate of each cell is determined by the vitality of
% its eight nearest neighbors
% * Any cell with exactly three live neighbors comes to life at the next
% step 
% * A live cell with exactly two live neighbors remains alive at the next
% step 
% * All other cells (including those with more than three neighbors) die
% at the next step or remain empty
% 
% Here are some examples of how a cell is updated:
% 
% <<gpucoderdemo_stencil_rules.png>> 
% 
% Many array operations can be expressed as a |stencil| operation,
% where each element of the output array depends on a small region of the 
% input array. The stencil in the example shown is therefore the 3x3 
% region around each cell. Finite differences, convolution, median 
% filtering, and finite-element methods are examples of other operations 
% that can be performed by stencil processing.

% Copyright 2016 - 2017 The MathWorks, Inc. 


%% Prerequisites
% * CUDA-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
% * NVIDIA CUDA toolkit.
% * Environment variables for the compilers and libraries. For more 
% information, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_stencil');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Generate a Random Initial Population
% Being zero-player, the evolution of the game is determined by its initial
% state. For this example, an initial population of cells is created on a 
% 2-dimensional grid with roughly 25% of the locations alive.
gridSize = 500;
numGenerations = 100;
initialGrid = (rand(gridSize,gridSize) > .75);

% Draw the initial grid
imagesc(initialGrid);
colormap([1 1 1;0 0.5 0]);
title('Initial Grid');

%% Playing the Game of Life
% The
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_stencil','gameoflife_orig.m'))
% gameoflife_orig.m> function is a fully vectorized implementation of 
% "Game of Life". The function updates all cells on the grid in one pass 
% per generation.
type gameoflife_orig
%%
% Now play the game by calling the |gameoflife_orig| function with an 
% initial population. The game iterates through 100 generations and 
% displays the population at each generation.
gameoflife_orig(initialGrid);

%% Converting the Game of Life for GPU Code Generation
% Looking at the calculations in the |updateGrid| function, it is apparent 
% that the same operations are applied at each grid location independently.
% However, each cell needs to know about its eight neighbors. The modified
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_stencil','gameoflife_stencil.m')) gameoflife_stencil.m>
% function uses the <matlab:doc('gpucoder.stencilKernel') gpucoder.stencilKernel> 
% pragma to compute a 3x3 region around each cell. The GPU Coder(TM) 
% implementation of the stencil kernel, computes one element of the grid 
% in each thread and uses shared memory to improve memory bandwidth and 
% data locality. 
type gameoflife_stencil

%% Generate CUDA MEX for the Function
% To generate CUDA MEX for the |gameoflife_stencil| function, create a code
% GPU code configuration object and use the |codegen| function. 
cfg = coder.gpuConfig('mex');
evalc('codegen -config cfg -args {initialGrid}  gameoflife_stencil');

%% Run the MEX Function
% Run generated |gameoflife_stencil_mex| with the random initial population.
gridGPU = gameoflife_stencil_mex(initialGrid);
% Draw the grid after 100 generations
imagesc(gridGPU);
colormap([1 1 1;0 0.5 0]);
title('Final Grid - CUDA MEX');

%% Conclusion
% In this example, CUDA code was generated for a simple stencil operation -
% Conway's "Game of Life". Implementation was accomplished by using the 
% |gpucoder.stencilKernel| pragma. This technique demonstrated in this 
% example can be used to implement a range of stencil operations including 
% finite-element algorithms, convolutions, and filters.
%% Cleanup
% Remove the generated files and return to the original folder.
cleanup


displayEndOfDemoMessage(mfilename)
