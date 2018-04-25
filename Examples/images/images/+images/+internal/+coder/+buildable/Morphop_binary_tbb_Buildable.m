classdef Morphop_binary_tbb_Buildable < coder.ExternalDependency %#codegen
    % Encapsulate morphop implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    %#ok<*EMCA>    
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Morphop_binary_tbb_Buildable';
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
                    libDir          = images.internal.getImportLibDirName(context);
                    linkLibPath     = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles   = {'libmwmorphop_binary_tbb','libmwnhood','tbb','tbbmalloc'};
                    nonBuildFiles   = strcat(binArch,nonBuildFiles, execLibExt);
                    linkFiles       = {'libmwmorphop_binary_tbb'}; 
                    linkFiles       = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkLibPath     = binArch;
                    
                    % Non-build files
                    if strcmp(arch,'glnxa64')
                        libstdcpp          = strcat(sysOSArch,{'libstdc++.so.6'});
                        nonBuildFilesNoExt = {'libtbb.so.2'};
                        nonBuildFilesNoExt{end+1} = 'libtbbmalloc.so.2';
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt);
                    else
                        libstdcpp          = [];
                        nonBuildFilesNoExt = {'libtbb'};
                        nonBuildFilesNoExt{end+1} = 'libtbbmalloc';
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt, execLibExt);
                    end
                    
                    linkFiles        = {'mwmorphop_binary_tbb','mwnhood'}; 
                    
                    nonBuildFilesExt = {'libmwmorphop_binary_tbb','libmwnhood'};
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
            
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
          
        
        function b = morphop_binary_tbb(...
                fcnName, a, asize, adims, nhood, nsize, ndims, b)
            coder.inline('always');
            coder.cinclude('libmwmorphop_binary_tbb.h');
            
            asizeT = coder.internal.flipIf(coder.isRowMajor,asize);
            nsizeT = coder.internal.flipIf(coder.isRowMajor,nsize);
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(a), coder.rref(asizeT), adims,...
                coder.rref(nhood), coder.rref(nsizeT), ndims,...
                coder.ref(b));
        end
    end
end
