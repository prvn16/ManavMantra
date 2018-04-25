function header_name = getGpuBlasHeader()
%MATLAB GPU Code Generation Private Function

%#codegen
coder.allowpcode('plain');
coder.inline('always');

header_name = 'cublas_v2.h';

end
%--------------------------------------------------------------------------
