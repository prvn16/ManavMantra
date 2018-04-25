classdef EdgeSobelPrewittTbbBuildable < coder.ExternalDependency %#codegen
    %EDGESOBELPREWITTTBBBUILDABLE - encapsulate sobel and prewitt edge implementation library
    
    % Copyright 2016 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName()
            name = 'EdgeSobelPrewittTbbBuildable';
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
            arch            = computer('arch');
            binArch         = fullfile(matlabroot,'bin',arch,filesep);
            
            switch arch
                case {'win32','win64'}
                    libDir          = images.internal.getImportLibDirName(context);
                    linkLibPath     = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    nonBuildFiles = {'libmwedgesobelprewitt_tbb','tbb','tbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                    
                case {'glnxa64','maci64'}
                    linkLibPath     = binArch;
                    
                    % Non-build files
                    if strcmp(arch,'glnxa64')
                        nonBuildFilesNoExt = {'libtbb.so.2'};
                        nonBuildFilesNoExt{end+1} = 'libtbbmalloc.so.2';
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt);
                    else
                        nonBuildFilesNoExt = {'libtbb'};
                        nonBuildFilesNoExt{end+1} = 'libtbbmalloc';
                        nonBuildFilesNoExt = strcat(binArch,nonBuildFilesNoExt, execLibExt);
                    end
                    
                    nonBuildFilesExt = {'libmwedgesobelprewitt_tbb'};
                    nonBuildFilesExt = strcat(binArch,nonBuildFilesExt, execLibExt);
                    nonBuildFiles = [nonBuildFilesExt nonBuildFilesNoExt];
                    
                otherwise
                    % unsupported
                    assert(false,[ arch ' operating system not supported']);
            end

            linkFiles       = {'libmwedgesobelprewitt_tbb'}; %#ok<*EMCA>
            linkFiles       = strcat(linkFiles, linkLibExt);
            linkPriority    = images.internal.coder.buildable.getLinkPriority('tbb');
            linkPrecompiled = true;
            linkLinkonly    = true;
            buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                linkPrecompiled,linkLinkonly,group);
            
            % Non-build files
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
                        
        end
        
        
        function [pGradientX, pGradientY, pMagnitude] = ...
                edgesobelprewitt_tbb(fcnName,pImage,srcSize,isSobel,kx,ky,pGradientX,pGradientY,pMagnitude)
            coder.inline('always');
            coder.cinclude('libmwedgesobelprewitt_tbb.h');
            
            srcSizeT = coder.internal.flipIf(coder.isRowMajor,srcSize);
            if (coder.isRowMajor)
                k1 = ky;
                k2 = kx;
                pGradient1 = pGradientY;
                pGradient2 = pGradientX;
            else
                k1 = kx;
                k2 = ky;
                pGradient1 = pGradientX;
                pGradient2 = pGradientY;
            end
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(pImage),...
                coder.rref(srcSizeT),...
                isSobel,...
                k1,...
                k2,...
                coder.ref(pGradient1),...
                coder.ref(pGradient2),...
                coder.ref(pMagnitude));
            
            if (coder.isRowMajor)
                pGradientY = pGradient1;
                pGradientX = pGradient2;
            else
                pGradientX = pGradient1;
                pGradientY = pGradient2;
            end
        end
    end
    
    
end