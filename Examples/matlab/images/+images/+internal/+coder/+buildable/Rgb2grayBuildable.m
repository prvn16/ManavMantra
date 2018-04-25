classdef Rgb2grayBuildable < coder.ExternalDependency %#codegen
    %RGB2GRAYBUILDABLE - encapsulate rgb2gray implementation library
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Rgb2grayBuildable';
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
            arch            = computer('arch');
            binArch         = fullfile(matlabroot,'bin',arch,filesep);
            sysOSArch = fullfile(matlabroot,'sys','os',arch,filesep);
            
            switch arch
                case {'win32','win64'}
                    linkFiles       = {'libmwrgb2gray_tbb'}; %#ok<*EMCA>            
                    linkFiles       = strcat(linkFiles, linkLibExt);
                    libDir        = coder.internal.importLibDir(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles = {'libmwrgb2gray_tbb','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                
                case {'glnxa64','maci64'}
                    linkFiles       = {'mwrgb2gray_tbb'};
                    linkLibPath     = binArch;
                    
                    % Non-build files
                    if strcmp(arch,'glnxa64')
                        libstdcpp          = strcat(sysOSArch,{'libstdc++.so.6'});
                        nonBuildFilesNoExt = {'libtbb.so.2','libtbbmalloc.so.2'};
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt);
                    else
                        libstdcpp          = [];
                        nonBuildFilesNoExt = {'libtbb','libtbbmalloc'};
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt, execLibExt);
                    end
                    
                    nonBuildFilesExt = {'libmwrgb2gray_tbb'};
                    nonBuildFilesExt = strcat(binArch,nonBuildFilesExt, execLibExt);
                    nonBuildFiles = [libstdcpp nonBuildFilesExt nonBuildFilesNoExt];
  
                otherwise
                    % unsupported
                    assert(false,[ arch ' operating system not supported']);
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
        
        
        function outputImage = rgb2graycore(fcnName, inputImage, numPixels, outputImage)
            coder.inline('always');
            coder.cinclude('libmwrgb2gray_tbb.h');
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(inputImage),...
                numPixels,...
                coder.ref(outputImage),...
                coder.isColumnMajor());
        end
        
    end
    
    
end
