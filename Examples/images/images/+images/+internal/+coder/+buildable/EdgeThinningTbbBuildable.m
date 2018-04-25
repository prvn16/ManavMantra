classdef EdgeThinningTbbBuildable < coder.ExternalDependency %#codegen
    %EDGETHINNINGTBBBUILDABLE - encapsulate edge thinning implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName()
            name = 'EdgeThinningTbbBuildable';
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
                    linkFiles     = {'libmwedgethinning_tbb'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles = {'libmwedgethinning_tbb','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles     = {'mwedgethinning_tbb'}; %#ok<*EMCA>
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
                    
                    nonBuildFilesExt = {'libmwedgethinning_tbb'};
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
        
        
        function e = edgethinning_tbb(fcnName,b,bx,by,kx,ky,offset,epsval,cutoff,e,sz)
            coder.inline('always');
            coder.cinclude('libmwedgethinning_tbb.h');
            
            szT = coder.internal.flipIf(coder.isRowMajor,sz);
            if(coder.isRowMajor)
                b1 = by;
                b2 = bx;
                k1 = ky;
                k2 = kx;
            else
                b1 = bx;
                b2 = by;
                k1 = kx;
                k2 = ky;
            end
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(b),...
                coder.rref(b1),...
                coder.rref(b2),...
                k1,...
                k2,...
                coder.rref(offset),...
                epsval,...
                cutoff,...
                coder.ref(e),...
                coder.rref(szT));  
        end
    end
    
    
end
