%% Simulate Diffraction Patterns using CUDA FFT Libraries
% This example demonstrates how to use GPU Coder(TM) to leverage the CUDA(R) 
% Fast Fourier Transform library (cuFFT) and compute two-dimensional FFT on 
% a NVIDIA(R) GPU. The two-dimensional Fourier transform is used in optics 
% to calculate far-field diffraction patterns. These diffraction patterns 
% are observed when a monochromatic light source passes through a small 
% aperture, such as in Young's double-slit experiment.

% Copyright 2016-2017 The MathWorks, Inc.


%% Prerequisites
% * CUDA-enabled NVIDIA GPU with compute capability 3.0 or higher.
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
gpucoderdemo_setup('gpucoderdemo_fft');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Defining the Coordinate System
% Before we simulate the light that has passed through an aperture, we must
% define our coordinate system. To get the correct numerical behavior when
% we call |fft2|, we must carefully arrange |x| and |y| so that the zero
% value is in the correct place. |N2| is half the size in each dimension.
N2 = 1024;
[gx, gy] = meshgrid(-1:1/N2:(N2-1)/N2);

%% Simulating the Diffraction Pattern for a Rectangular Aperture
% We simulate the effect of passing a parallel beam of monochromatic light
% through a small rectangular aperture. The two-dimensional Fourier transform
% describes the light field at a large distance from the aperture. We start
% by forming |aperture| as a logical mask based on the coordinate system,
% then the light source is simply a double-precision version of the
% aperture. The far-field light signal is found using |fft2|.

aperture       = ( abs(gx) < 4/N2 ) .* ( abs(gy) < 2/N2 );
lightsource    = double( aperture );
farfieldsignal = fft2( lightsource );

%% Displaying the Light Intensity for a Rectangular Aperture
% The
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_fft','visualize.m'))
% visualize.m> function displays the light intensity for a rectangular 
% aperture. First, we calculate the far-field light intensity from the 
% magnitude squared of the light field. Finally, we use |fftshift| to aid 
% visualization.
type visualize
%%
str = sprintf('Rectangular Aperture Far-field Diffraction Pattern in MATLAB');
visualize(farfieldsignal,str);

%% Generate CUDA MEX for the Function
% For this example, we don't have to create an entry-point function and can
% directly generate code for the MATLAB |fft2| function.To generate CUDA 
% MEX for the MATLAB |fft2| function, set |EnablecuFFT| and use the 
% |codegen| function. Setting the |EnablecuFFT| property in 
% configuration object enables GPU Coder to replace |fft|, |ifft|, |fft2|,
% |ifft2|, |fftn|, and |ifftn| function calls in your MATLAB code 
% to the appropriate cuFFT library calls. For two-dimensional transforms 
% and higher, GPU Coder creates multiple 1-D batched transforms. These 
% batched transforms have higher performance than single transforms. After 
% generating the MEX function, you can verify that it has the same 
% functionality as the original MATLAB entry-point function. Run the 
% generated |fft2_mex| and plot the results. 
cfg = coder.gpuConfig('mex');
cfg.GpuConfig.EnableCUFFT = 1;
codegen -config cfg -args {lightsource} fft2

farfieldsignalGPU = fft2_mex( lightsource );
str = sprintf('Rectangular Aperture Far-field Diffraction Pattern on GPU');
visualize(farfieldsignalGPU,str);

%% Simulating Young's Double-Slit Experiment
% One of the most famous experiments in optics is Young's double-slit
% experiment which shows light interference when an aperture comprises two
% parallel slits. A series of bright points is visible where constructive
% interference takes place. In this case, we form the aperture representing
% two slits. We restrict the aperture in the |y| direction to ensure that
% the resulting pattern is not entirely concentrated along the horizontal
% axis.

slits          = (abs( gx ) <= 10/N2) .* (abs( gx ) >= 8/N2);
aperture       = slits .* (abs(gy) < 20/N2);
lightsource    = double( aperture );

%% Displaying the Light Intensity for Young's Double-Slit
% Since the size, type and complexity of the inputs remains the same, we 
% can reuse the  |fft2_mex| functions generated in the previous section. 
% We calculate and display the intensity as before.
farfieldsignalGPU = fft2_mex( lightsource );
str = sprintf('Double Slit Far-field Diffraction Pattern on GPU');
visualize(farfieldsignalGPU,str);

%% Cleanup
% Remove the generated files and return to the original folder.
cleanup

displayEndOfDemoMessage(mfilename)
