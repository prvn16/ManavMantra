
%   Copyright 2017 The MathWorks, Inc.

classdef MATLABFFTWGpuCallback < coder.CustomFFTCallback 
%#codegen
    methods(Static)
        function includeFFTHeader()
        end

        function y = fft1d(x, fftlen, nfft, isInverse)
            coder.inline('always');

            header_name = 'cufft.h';
            
            % Compute 1 or more 1D ffts of length fftlen
            y = coder.fftw.allocFftOutput(x,fftlen);

            if isreal(x)
                if isa(x,'double')
                    fcnname = 'gpufftD2Z';
                    itype = coder.opaque('cufftDoubleReal', 'HeaderFile', header_name);
                    otype = coder.opaque('cufftDoubleComplex', 'HeaderFile', header_name);
                    inPtr = coder.internal.opaquePtr('cufftDoubleReal', 'NULL');
                else
                    fcnname = 'gpufftR2C';
                    itype = coder.opaque('cufftReal', 'HeaderFile', header_name);
                    otype = coder.opaque('cufftComplex', 'HeaderFile', header_name);
                    inPtr = coder.internal.opaquePtr('cufftReal', 'NULL');
                end
            else
                if isa(x,'double')
                    fcnname = 'gpufftZ2Z';
                    itype = coder.opaque('cufftDoubleComplex', 'HeaderFile', header_name);
                    otype = coder.opaque('cufftDoubleComplex', 'HeaderFile', header_name);
                    inPtr = coder.internal.opaquePtr('cufftDoubleComplex', 'NULL');
                else
                    fcnname = 'gpufftC2C';
                    itype = coder.opaque('cufftComplex', 'HeaderFile', header_name);
                    otype = coder.opaque('cufftComplex', 'HeaderFile', header_name);
                    inPtr = coder.internal.opaquePtr('cufftComplex', 'NULL');
                end
            end

            if isInverse
                fftDirection = coder.internal.fftw.MATLABFFTWGpuCallback.cuFFTINVERSE;
            else
                fftDirection = coder.internal.fftw.MATLABFFTWGpuCallback.cuFFTFORWARD;
            end

            inSize = coder.opaque('size_t', '0'); %#ok<NASGU>
            inSize = coder.internal.csizeof(coder.internal.scalarEg(x), coder.internal.indexInt(numel(y)));
            inLen = coder.internal.indexInt(size(x,1));
            if (inLen < fftlen)
                inPitch = coder.internal.csizeof(coder.internal.scalarEg(x), inLen);
                outPitch = coder.internal.csizeof(coder.internal.scalarEg(x), fftlen);
                coder.ceval('cudaMalloc', coder.wref(inPtr), inSize);
                coder.ceval('cudaMemset', inPtr, coder.internal.indexInt(0), inSize);
                coder.ceval('cudaMemcpy2D', coder.wref(inPtr(1)), outPitch, ...
                            coder.rref(x(1)), inPitch, inPitch, nfft, ...
                            coder.opaque('cudaMemcpyKind','cudaMemcpyHostToDevice'));
                coder.ceval(fcnname, inPtr, ...
                            coder.wref(y(1), 'like', otype), ...
                            fftlen, fftlen, nfft, fftDirection);
            else
                coder.ceval(fcnname, coder.rref(x(1), 'like', itype), ...
                            coder.wref(y(1), 'like', otype), ...
                            fftlen, int32(size(x,1)), nfft, fftDirection);
            end
            
            if (isreal(x))
                coder.gpu.kernel()
                for i = 1 : nfft
                    coder.gpu.kernel();
                    for j = (ceil(fftlen / 2)) + 2 : 1 : fftlen
                        fftOff = (i-1) * fftlen;
                        rdOffset = fftOff + fftlen - (j) + 2;
                        wrOffset = fftOff + j;
                        if isInverse
                            y(wrOffset) = y(rdOffset);
                            y(rdOffset) = conj(y(rdOffset));
                        else
                            y(wrOffset) = conj(y(rdOffset));
                        end
                    end
                end
            end

            if isInverse
                if isa(x, 'double')
                    scal = double(fftlen);
                else
                    scal = single(fftlen);
                end
                y = y ./ scal;
            end
        end
        
        function updateBuildInfo(~,~)
        end
    end
    properties (Access = private, Constant)
        cuFFTFORWARD = int32(-1);
        cuFFTINVERSE = int32(1);
    end
end
