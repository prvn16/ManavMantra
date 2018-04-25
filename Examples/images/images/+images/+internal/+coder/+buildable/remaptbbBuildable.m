classdef remaptbbBuildable < coder.ExternalDependency %#codegen
    %REMAPTBBBUILDABLE - Encapsulate remap implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'remaptbbBuildable';
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

            % include libstdc++.so.6 on linux
            libstdcpp = [];

            switch arch
                case {'win32','win64'}                    
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    linkFiles     = {'libmwremaptbb'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    
                    nonBuildFiles = {'libmwremaptbb', 'tbb', 'libmwipp'};
                    nonBuildFiles = strcat(nonBuildFiles, execLibExt);
                    nonBuildFiles = strcat(binArch, nonBuildFiles);   
                    
                   
                case 'glnxa64'
                    libstdcpp     = strcat(sysOSArch,{'libstdc++.so.6'});

                    linkFiles     = {'mwremaptbb'};

                    nonBuildFiles = {'libmwremaptbb'};
                    nonBuildFiles = strcat(nonBuildFiles, execLibExt);
                    
                    %Make sure TBB appears before IPP
                    %g1052652
                    nonBuildFiles{end+1} = 'libtbb.so.2';
                    nonBuildFiles{end+1} = 'libtbbmalloc.so.2';
                    nonBuildFiles{end+1} =  strcat('libmwipp', execLibExt);
                    
                    nonBuildFiles = strcat(binArch, nonBuildFiles);
                                        
                case 'maci64'      
                    linkFiles     = {'mwremaptbb','mwipp'};

                    nonBuildFiles = {'libmwremaptbb', 'libtbb', 'libtbbmalloc','libmwipp'};
                    nonBuildFiles = strcat(nonBuildFiles, execLibExt);
                    nonBuildFiles = strcat(binArch, nonBuildFiles);
                                 
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
        
                
        function outputImage = remapCore(fcnName, inputImage, Y, X, methodEnum, fillValues, outputImage) 
            coder.inline('always');
            coder.cinclude('libmwremaptbb.h');
            
            inputImageSize = coder.internal.flipIf(coder.isRowMajor,size(inputImage));
            outputImageSize = coder.internal.flipIf(coder.isRowMajor,size(outputImage));
            if coder.isRowMajor
                X_T = Y;
                Y_T = X;
            else                    
                X_T = X;
                Y_T = Y;
            end
            
            coder.ceval('-layout:any',fcnName,...
                        coder.rref(inputImage),...
                        inputImageSize, ...
                        ndims(inputImage), ...
                        coder.ref(Y_T), ...
                        coder.ref(X_T), ...
                        methodEnum, ...
                        coder.ref(fillValues), ...
                        coder.ref(outputImage),...
                        outputImageSize, ...
                        numel(outputImage));
        end
    end
end
