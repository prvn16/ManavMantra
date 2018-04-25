
%   Copyright 2017 The MathWorks, Inc.

%
% This class is an implementation of the LAPACKCallback API used
%   by MATLAB Coder for stand-alone configuration of LAPACK libraries.
%   This implementation is set up to configure C LAPACK and cuSOLVER
%   for GPU code generation.
%
classdef defaultLAPACKApi < coder.LAPACKCallback
    methods (Static)

        % Return the header file name of the local C LAPACK library
        function hn = getHeaderFilename()
            hn = 'lapacke.h';
        end

        % updateBuildInfo should all the C LAPACK and cuSOLVER libraries
        %   to the buildInfo object, so these libraries will be linked 
        %   when the generated code is built. Building with cuSOLVER also
        %   requires the openMP libraries to be linked.
        %
        function updateBuildInfo(buildInfo, buildctx)
            if ispc
                cudaPath = getenv('CUDA_PATH');
                libPath = 'lib\x64';
            else
                cudaPath = '/usr/local/cuda';
                libPath = 'lib64';
            end

            buildInfo.addIncludePaths(fullfile(cudaPath,'include'));
            libName = 'cusolver';
            libPath = fullfile(cudaPath,libPath);
            buildInfo.addSysLibs(libName, libPath);
            %buildInfo.addSysLibs('iomp', '/usr/lib');
            buildInfo.addLinkFlags('-Xlinker --unresolved-symbols=ignore-in-shared-libs');
            buildInfo.addSysLibs('lapack', '/usr/lib');
            
            %libName = 'liblapack';
            %[~, libExt] = buildctx.getStdLibInfo();
            %libName = [libName libExt];
            %addLinkObjects(buildInfo, libName, libPath, 1000, true, true);

            buildInfo.addDefines('HAVE_LAPACK_CONFIG_H');
            buildInfo.addDefines('LAPACK_COMPLEX_STRUCTURE');
        end
    end
end
