%#codegen
function C = matrixMatrixKernel(func, A, B, varargin)
coder.inline('always');
coder.extrinsic('coder.gpu.getGpuEnabled');
if (coder.target('MEX') || coder.target('Rtw'))
    ctx = eml_option('CodegenBuildContext');
    if coder.const(@coder.gpu.getGpuEnabled,ctx)
        C = gpucoder.internal.gpu_mm_kernel(func, A, B, varargin{:});
    else
        C = gpucoder.internal.cpu_mm_kernel(func, A, B, varargin{:});
    end
else
    C = gpucoder.internal.cpu_mm_kernel(func, A, B, varargin{:});
end
end