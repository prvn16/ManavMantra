classdef Grayxform_tbbBuildable < coder.ExternalDependency %#codegen
    %GRAYXFORM_TBBBUILDABLE - Encapsulate grayxform_tbb implementation library
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Grayxform_tbbBuildable';
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

            switch arch
                case {'win32','win64'}                    
                    linkFiles     = {'libmwgrayxform_tbb'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    nonBuildFiles = {'libmwgrayxform_tbb', 'tbb','tbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);   
                    
                   
                case {'glnxa64','maci64'}
                    linkFiles     = {'mwgrayxform_tbb'}; %#ok<*EMCA>
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
                    
                    nonBuildFilesExt = {'libmwgrayxform_tbb'};
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
        
        function outputImage = grayxform_tbb(fcnName, inputImage, inNumElems, inRows, inColsEtc, tform, tformNumElems, outputImage) 
            coder.inline('always');
            coder.cinclude('libmwgrayxform_tbb.h');
            coder.ceval('-layout:any',fcnName,...
                        coder.rref(inputImage), ...
                        inNumElems,...
                        inRows,...
                        inColsEtc,...
                        coder.rref(tform),...
                        tformNumElems,...
                        coder.ref(outputImage));
        end
    end
end
