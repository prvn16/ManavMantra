classdef Grayto16Buildable < coder.ExternalDependency %#codegen
    %GRAYTO16BUILDABLE - Encapsulate grayto16 implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName()
            name = 'grayto16Buildable';
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
                    linkFiles   = {'libmwgrayto16'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwgrayto16'};
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
            nonBuildFiles = {'libmwgrayto16'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function IM2 = grayto16core_double(IM1, IM2, numElems)
            coder.inline('always');
            coder.cinclude('libmwgrayto16.h');
            coder.ceval('-layout:any','grayto16_double',...
                coder.rref(IM1), ...
                coder.ref(IM2), ...
                numElems);
        end
        
        function IM2 = grayto16core_single(IM1, IM2, numElems)
            coder.inline('always');
            coder.cinclude('libmwgrayto16.h');
            coder.ceval('-layout:any','grayto16_single',...
                coder.rref(IM1),...
                coder.ref(IM2), ...
                numElems);
        end
        
        function IM2 = grayto16core_uint8(IM1, IM2, numElems)
            coder.inline('always');
            coder.cinclude('libmwgrayto16.h');
            coder.ceval('-layout:any','grayto16_uint8',...
                coder.rref(IM1),...
                coder.ref(IM2), ...
                numElems);
        end
    end
end
