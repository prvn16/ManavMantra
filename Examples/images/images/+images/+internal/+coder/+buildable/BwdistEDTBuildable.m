classdef BwdistEDTBuildable < coder.ExternalDependency %#codegen
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'bwdistEDTBuildable';
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
                    linkFiles   = {'libmwbwdistEDT'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwbwdistEDT'}; %#ok<*EMCA>
                    linkLibPath = binArch;
        
                otherwise
                    % unsupported
                    assert(false,[ arch ' operating system not supported']);
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
            nonBuildFiles = {'libmwbwdistEDT'};
            nonBuildFiles = strcat(binArch,nonBuildFiles,execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function D = bwdist(BW, D)
            coder.inline('always');
            coder.cinclude('libmwbwdistEDT.h');
            coder.ceval('bwdistEDT_boolean',...
                coder.rref(BW),    ...
                size(BW),          ...
                ndims(BW),         ...
                coder.ref(D));
        end
    end
end
