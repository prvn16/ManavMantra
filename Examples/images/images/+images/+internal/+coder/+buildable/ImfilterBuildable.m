classdef ImfilterBuildable < coder.ExternalDependency %#codegen
    %IMFILTERBUILDABLE - encapsulate imfilter implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'ImfilterBuildable';
        end
         
        function b = isSupportedContext(context)
            b = context.isMatlabHostTarget();
        end
        
        function updateBuildInfo(buildInfo, context)
            % File extensions
            [~, linkLibExt, execLibExt] = ...
                context.getStdLibInfo();
            group = 'BlockModules';
            
            % Header paths
            buildInfo.addIncludePaths(fullfile(matlabroot,'extern','include'));
            
            % Platform specific link and non-build files
            arch      = computer('arch');
            binArch   = fullfile(matlabroot,'bin',arch,filesep);
            sysOSArch = fullfile(matlabroot,'sys','os',arch,filesep);

            libstdcpp = [];
            % include libstdc++.so.6
            if strcmp(arch,'glnxa64')
                libstdcpp = strcat(sysOSArch,{'libstdc++.so.6'});
            end

            switch arch
                case {'win32','win64'}
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    linkFiles   = {'libmwimfilter'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwimfilter','mwnhood'};
                    linkLibPath = binArch;
                
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end

            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                linkPriority    = '';
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                                         linkPrecompiled,linkLinkonly,group);
            end
            
            % Non-build files
            nonBuildFiles = {'libmwnhood', 'libmwimfilter'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
                        
        end
        
        
        function out = imfiltercore(fcnName,a, out, nimdims, outSize, numPadDims, padSize, nonZeroKernel, numKernElem, conn, nconnDims, connDims, start, numStartElem, sameSize, convMode)
            coder.inline('always');
            coder.cinclude('libmwimfilter.h');

            padSizeT = coder.internal.flipIf(coder.isRowMajor,padSize);
            outSizeT = coder.internal.flipIf(coder.isRowMajor,outSize);
            connDimsT = coder.internal.flipIf(coder.isRowMajor,connDims);
            startT = coder.internal.flipIf(coder.isRowMajor,start);
         
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(a),...
                coder.ref(out),...
                nimdims,...
                coder.rref(outSizeT),...
                numPadDims,...
                coder.rref(padSizeT),...
                coder.rref(nonZeroKernel),...
                numKernElem,...
                coder.rref(conn),...
                nconnDims,...
                coder.rref(connDimsT),...
                coder.rref(startT),...
                numStartElem,...
                sameSize,...
                convMode);
        end
        
        
    end
    
    
end
