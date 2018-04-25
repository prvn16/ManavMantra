classdef BwunpackBuildable < coder.ExternalDependency %#codegen
    %BWUNPACKBUILDABLE - Encapsulate bwunpack implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'bwunpackBuildable';
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
                    linkFiles   = {'libmwbwunpackc'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwbwunpackc'};
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
            nonBuildFiles = {'libmwbwunpackc'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function BW = bwunpackc(BWP, BW) 
            coder.inline('always');
            coder.cinclude('libmwbwunpackc.h');
            
            bwpSize = coder.internal.flipIf(coder.isRowMajor,size(BWP));
            bwSize = coder.internal.flipIf(coder.isRowMajor,size(BW));
            
            coder.ceval('-layout:any','bwUnpacking',...
                coder.rref(BWP),  ...
                bwpSize,  ...
                coder.ref(BW),  ...
                bwSize,...
                coder.isColumnMajor);
        end
    end
end
