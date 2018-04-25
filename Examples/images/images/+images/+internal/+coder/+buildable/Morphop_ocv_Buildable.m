classdef Morphop_ocv_Buildable < coder.ExternalDependency %#codegen
    % Encapsulate morphop implementation library
    
    % Copyright 2016 The MathWorks, Inc.
    
    %#ok<*EMCA>
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Morphop_ocv_Buildable';
        end
        
        function b = isSupportedContext(context)
            b = context.isMatlabHostTarget();
        end
        
        function updateBuildInfo(buildInfo,context)
            % File extensions
            [linkLibPath, linkLibExt, execLibExt] = ...
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
                case {'win64'}
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    linkFiles     = {'libmwmorphop_ocv'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    
                    nonBuildFilesNoExt = ['libmwmorphop_ocv'];
                    nonBuildFiles = strcat(binArch,nonBuildFilesNoExt, execLibExt);
                case {'glnxa64','maci64'}
                    if strcmpi(arch,'glnxa64')
                        % Needed for linking
                        linkFiles = 'mwmorphop_ocv';
                        % Not needed while linking, just when running
                        nonBuildFiles{1} = strcat(binArch,'libtbb.so.2');
                        nonBuildFiles{end+1} = strcat(binArch,'libtbbmalloc.so.2');
                        nonBuildFiles{end+1} = strcat(binArch,'libmwmorphop_ocv.so');
                        
                    else % maci64
                        % Needed for linking
                        linkFiles = 'mwmorphop_ocv';
                        % Not needed while linking, just when running
                        nonBuildFiles{1} = strcat(binArch,'libtbb.dylib');
                        nonBuildFiles{end+1} = strcat(binArch,'libmwmorphop_ocv.dylib');
                    end
                    
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
            nonBuildFiles = [nonBuildFiles libstdcpp];
            
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
            images.internal.coder.buildable ...
                .portableOpenCVBuildInfo(buildInfo, context,'');
        end
        
        function b = morphop_ocv(...
                fcnName, a, asize, nhood, nsize, b)
            coder.inline('always');
            coder.cinclude('libmwmorphop_ocv.h');
            
            asizeT = coder.internal.flipIf(coder.isRowMajor,asize);
            nsizeT = coder.internal.flipIf(coder.isRowMajor,nsize);
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(a), coder.rref(asizeT), ...
                coder.rref(nhood), coder.rref(nsizeT), ...
                coder.ref(b));
        end
                               
    end
end
