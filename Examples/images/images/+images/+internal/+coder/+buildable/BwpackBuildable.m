classdef BwpackBuildable < coder.ExternalDependency %#codegen
    %BWPACKBUILDABLE - Encapsulate bwpack implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'bwpackBuildable';
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
                    linkFiles   = {'libmwbwpackc'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwbwpackc'};
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
            nonBuildFiles = {'libmwbwpackc'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function BWP = bwpackc(BW, BWP) 
            coder.inline('always');
            coder.cinclude('libmwbwpackc.h');
            
            bwSize = coder.internal.flipIf(coder.isRowMajor,size(BW));
            bwpSize = coder.internal.flipIf(coder.isRowMajor,size(BWP));
                        
            coder.ceval('-layout:any','bwPacking',...
                coder.rref(BW),  ...
                bwSize,  ...
                coder.ref(BWP),  ...
                bwpSize,...
                coder.isColumnMajor);
        end
    end
end
