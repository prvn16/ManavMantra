classdef FFTWGpuApi < coder.ExternalDependency & coder.internal.JITSupportedExternalDependency
%MATLAB GPU Code Generation Private Class

%   Copyright 2017 The MathWorks, Inc.
%#codegen
    methods (Static)
        function className = getCallbackClassName()
            coder.extrinsic('coder.internal.fftw.getFFTWGpuCallbackName');
            gl = eml_option('CodegenBuildContext');
            className = coder.const(@coder.internal.fftw.getFFTWGpuCallbackName, gl);
        end
    end

    methods (Static)
        function includeFFTHeader()
            coder.inline('always');
            className = coder.internal.fftw.FFTWGpuApi.getCallbackClassName();
            if (~isempty(className))
                includeFcn = str2func([className '.includeFFTHeader']);
                includeFcn();
            end
        end

        function y = fft1d(data, fftlen, nfft, isInverse)
            coder.internal.fftw.FFTWGpuApi.includeFFTHeader();
            coder.inline('always');

            % Check for unbounded variables
            
            className = coder.internal.fftw.FFTWGpuApi.getCallbackClassName();
            if (isempty(className))
                y = coder.internal.fftw.MATLABFFTWGpuCallback.fft1d(data, fftlen, ...
                                                                  nfft, isInverse);
            else
                fft1dFcn = str2func([className '.fft1d']);
                y = fft1dFcn(data, fftlen, nfft, isInverse);
            end
        end
    end

    methods (Static)
        function bName = getDescriptiveName(~)
            bName = 'FFTWGpuApi';
        end

        function tf = isSupportedContext(~)
        % Require callers to set up the context properly
            tf = true;
        end

        function updateBuildInfo(buildInfo, ctx)
        % This function does nothing under MEX build.
            callbackClass = ctx.getConfigProp('CustomFFTCallback');
            callbackFcn = [callbackClass '.updateBuildInfo'];
            if ~isempty(callbackClass)
                try %#ok<EMTC>
                    feval(callbackFcn, buildInfo, ctx);
                catch ME
                    error(message('Coder:FE:FFTCallbackExecError', callbackFcn, ME.message));
                end
            else
                libName = 'cufft';
                libPath = getenv('CUDA_PATH');
                if ctx.isCodeGenTarget('mex')
                    if ispc
                        [~, libPath] = coder.internal.importLibDir(ctx);
                    elseif isunix || ismac
                        libPath = fullfile(matlabroot,'bin',computer('arch'));
                    end
                end
                if ~ispc
                    buildInfo.addSysLibs(libName, libPath);
                end
            end
        end 
    end
end
