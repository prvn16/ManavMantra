classdef BoxfilterBuildable < coder.ExternalDependency %#codegen
    %BOXFILTER - Encapsulate boxfilter implementation library
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'boxfilterBuildable';
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
            % include libstdc++.so.6 on linux
            if strcmp(arch,'glnxa64')
                libstdcpp = strcat(sysOSArch,{'libstdc++.so.6'});
            end

            switch arch
                case {'win32','win64'}
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    linkFiles   = {'libmwboxfilter'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwboxfilter'};
                    linkLibPath = binArch;
                    
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end
            
            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                
                linkPriority    = images.internal.coder.buildable.getLinkPriority('tbb');
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                                         linkPrecompiled,linkLinkonly,group);
            end            
            
            % Non-build files
            nonBuildFiles = {'libmwboxfilter'};
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
                
        function out = boxfiltercore(fcnName, intA, imSize, kernelSize, kernelWeight, pre, out, outSize, nPlanes)
            coder.inline('always');
            coder.cinclude('libmwboxfilter.h');
            
            imSizeT = coder.internal.flipIf(coder.isRowMajor,imSize);
            outSizeT = coder.internal.flipIf(coder.isRowMajor,outSize);
            kernelSizeT = coder.internal.flipIf(coder.isRowMajor,kernelSize);
                        
            coder.ceval('-layout:any',fcnName,...
                coder.rref(intA),...
                coder.rref(imSizeT),...
                coder.rref(kernelSizeT),...
                kernelWeight,...
                coder.rref(pre),...
                coder.ref(out),...
                coder.ref(outSizeT),...
                nPlanes);
        end
        
    end
end
