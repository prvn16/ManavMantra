classdef IppgeotransBuildable < coder.ExternalDependency %#codegen
    %IPPGEOTRANSBUILDABLE - Encapsulate ippgeotrans implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'ippgeotransBuildable';
        end
        
        function b = isSupportedContext(context)
            b = context.isMatlabHostTarget();
        end
        
        function updateBuildInfo(buildInfo, context)
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
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    linkFiles     = {'libmwippgeotrans'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    
                    nonBuildFiles = {'libmwippgeotrans','libmwipp','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(nonBuildFiles, execLibExt);
                    nonBuildFiles = strcat(binArch, nonBuildFiles);
                    
                case {'glnxa64', 'maci64'}
                    linkFiles     = {'mwippgeotrans','mwipp'};
                                        
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
                    
                    nonBuildFilesExt = {'libmwippgeotrans','libmwipp'};
                    nonBuildFilesExt = strcat(binArch,nonBuildFilesExt, execLibExt);
                    nonBuildFiles    = [libstdcpp nonBuildFilesExt nonBuildFilesNoExt];
                                       
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end
            
            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                linkPriority    = images.internal.coder.buildable.getLinkPriority('ipp');
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                                         linkPrecompiled,linkLinkonly,group);
            end
            
            % Non-build files
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
       
        
        function outputImage = ippgeotrans(fcnName,inputImage, outputImage, tForm, imageSize, interpEnum, fillVal) 
            coder.inline('always');
            coder.cinclude('libmwippgeotrans.h');
            
            imageSizeT = coder.internal.flipIf(coder.isRowMajor,imageSize);
            sizeInputImage = coder.internal.flipIf(coder.isRowMajor,size(inputImage));
            
            coder.ceval('-layout:any',fcnName,...
                coder.ref(outputImage),  ...
                imageSizeT,  ...
                ndims(outputImage), ...
                coder.rref(inputImage),  ...
                sizeInputImage, ...
                numel(inputImage), ...
                tForm, ...
                interpEnum, ...
                coder.rref(fillVal),...
                coder.isColumnMajor());
        end
    end
end
