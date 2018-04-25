function p = useFFTWGpu()
%#codegen

%   Copyright 2017 The MathWorks, Inc.

eml_heisenfun;
coder.inline('always');
coder.extrinsic('coder.internal.fftw.isGpuFFT');
gl = eml_option('CodegenBuildContext');
p = ~coder.target('MATLAB') && eml_option('UseFFTW') && ...
    coder.const(@coder.internal.fftw.isGpuFFT, gl);

end
