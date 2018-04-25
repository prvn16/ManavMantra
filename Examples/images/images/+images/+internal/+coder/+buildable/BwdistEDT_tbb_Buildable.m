classdef BwdistEDT_tbb_Buildable < coder.ExternalDependency %#codegen
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'bwdistEDT_tbb_Buildable';
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
            switch arch
                case {'win32','win64'}
                    linkFiles     = {'libmwbwdistEDT_tbb'};
                    linkFiles     = strcat(linkFiles, linkLibExt);          
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles = {'libmwbwdistEDT_tbb','tbb','tbbmalloc'}; %#ok<*EMCA>
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles     = {'mwbwdistEDT_tbb'};
                    linkLibPath   = binArch;
                    
                    % Non-build files
                    if strcmp(arch,'glnxa64')
                        libstdcpp          = strcat(sysOSArch,{'libstdc++.so.6'});
                        nonBuildFilesNoExt = {'libtbb.so.2','libtbbmalloc.so.2'};
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt);
                    else
                        libstdcpp          = [];
                        nonBuildFilesNoExt = {'libtbb','libtbbmalloc'};
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt,execLibExt);
                    end
                    
                    nonBuildFilesExt = {'libmwbwdistEDT_tbb'};
                    nonBuildFilesExt = strcat(binArch,nonBuildFilesExt, execLibExt);
                    nonBuildFiles    = [libstdcpp nonBuildFilesExt nonBuildFilesNoExt];
                    
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
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function D = bwdist(BW, D)
            coder.inline('always');
            coder.cinclude('libmwbwdistEDT_tbb.h');
            coder.ceval('bwdistEDT_tbb_boolean',...
                coder.rref(BW),    ...
                size(BW),          ...
                ndims(BW),         ...
                coder.ref(D));
        end
    end
end
