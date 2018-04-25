classdef CannyThresholdingTbbBuildable < coder.ExternalDependency %#codegen
    %CANNYTHRESHOLDINGTBBBUILDABLE - encapsulate canny local mazima implementation library
    
    % Copyright 2016 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName()
            name = 'CannyThresholdingTbbBuildable';
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
                    linkFiles     = {'libmwcannythresholding_tbb'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles = {'libmwcannythresholding_tbb','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles     = {'mwcannythresholding_tbb'}; %#ok<*EMCA>
                    linkLibPath   = binArch;
                    
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
                    
                    nonBuildFilesExt = {'libmwcannythresholding_tbb'};
                    nonBuildFilesExt = strcat(binArch,nonBuildFilesExt, execLibExt);
                    nonBuildFiles = [libstdcpp nonBuildFilesExt nonBuildFilesNoExt];
                    
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
        
        
        function E = cannythresholding_tbb(fcnName,ix,iy,mag,sz,lowThresh,E)
            coder.inline('always');
            coder.cinclude('libmwcannythresholding_tbb.h');
            
            szT = coder.internal.flipIf(coder.isRowMajor,sz);
            if (coder.isRowMajor)
                i1 = iy;
                i2 = ix;
            else
                i1 = ix;
                i2 = iy;
            end
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(i1),...
                coder.rref(i2),...
                coder.rref(mag),...
                coder.rref(szT),...
                lowThresh,...
                coder.ref(E));  
        end
    end
    
    
end
