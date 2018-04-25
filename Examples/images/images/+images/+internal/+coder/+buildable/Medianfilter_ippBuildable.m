classdef Medianfilter_ippBuildable < coder.ExternalDependency %#codegen
    %MEDIANFILTER_IPPBUILDABLE - encapsulate ippmedianfilter implementation 
    %library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Medianfilter_ippBuildable';
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
                case {'win32','win64'}                    
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    linkFiles     = {'libmwippmedianfilter'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    
                    nonBuildFiles = {'libmwippmedianfilter','libmwipp','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(nonBuildFiles, execLibExt);
                    nonBuildFiles = strcat(binArch, nonBuildFiles);                    
                    
                case {'glnxa64','maci64'}                    
                    linkFiles     = {'mwippmedianfilter','mwipp'};
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
                                        
                    nonBuildFilesExt = {'libmwippmedianfilter','libmwipp'};
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
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function outputImage = medianfilter_ippCore(fcnName, inputImage, inputSize, maskSize, outputImage)
            coder.inline('always');
            coder.cinclude('libmwippmedianfilter.h');
            
            inputSizeT = coder.internal.flipIf(coder.isRowMajor,inputSize);
            maskSizeT = coder.internal.flipIf(coder.isRowMajor,maskSize);
            
            coder.ceval('-layout:any',fcnName, ...
                coder.rref(inputImage),  ...
                coder.rref(inputSizeT), ...
                coder.rref(maskSizeT), ...
                coder.ref(outputImage));
        end
        
    end
    
end
