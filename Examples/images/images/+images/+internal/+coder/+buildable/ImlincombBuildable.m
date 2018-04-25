classdef ImlincombBuildable < coder.ExternalDependency %#codegen
    %IMLINCOMBBUILDABLE - Encapsulate imlincomb implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'ImlincombBuildable';
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

            libstdcpp = [];
            % include libstdc++.so.6 on linux
            if strcmp(arch,'glnxa64')
                libstdcpp = strcat(sysOSArch,{'libstdc++.so.6'});
            end

            switch arch
                case {'win32','win64'}
                    linkFiles   = {'libmwimlincomb'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',arch,libDir);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwimlincomb'}; %#ok<*EMCA>
                    linkLibPath = binArch;
                
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end

            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                linkPriority    = '';
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                                         linkPrecompiled,linkLinkonly,group);
            end
            
            % Non-build files
            nonBuildFiles = {'libmwimlincomb'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
                        
        end
        
        function outputImage = imlincombCore_1(fcnName, scalars, numScalars, outputImage, outputClassEnum, numElem, numInputImages, I1) 
            coder.inline('always');
            coder.cinclude('libmwimlincomb.h');
            coder.ceval('-layout:any',fcnName,...
                        coder.ref(scalars), ...
                        numScalars,...
                        coder.ref(outputImage),...
                        outputClassEnum,...
                        numElem, ...
                        numInputImages, ...
                        coder.rref(I1));
        end
        
        function outputImage = imlincombCore_2(fcnName, scalars, numScalars, outputImage, outputClassEnum, numElem, numInputImages, I1, I2) 
            coder.inline('always');
            coder.cinclude('libmwimlincomb.h');
            coder.ceval('-layout:any',fcnName,...
                        coder.ref(scalars), ...
                        numScalars,...
                        coder.ref(outputImage),...
                        outputClassEnum,...
                        numElem, ...
                        numInputImages, ...
                        coder.rref(I1),...
                        coder.rref(I2));
        end
        
        function outputImage = imlincombCore_3(fcnName, scalars, numScalars, outputImage, outputClassEnum, numElem, numInputImages, I1, I2, I3) 
            coder.inline('always');
            coder.cinclude('libmwimlincomb.h');
            coder.ceval('-layout:any',fcnName,...
                        coder.ref(scalars), ...
                        numScalars,...
                        coder.ref(outputImage),...
                        outputClassEnum,...
                        numElem, ...
                        numInputImages, ...
                        coder.rref(I1),...
                        coder.rref(I2),...
                        coder.rref(I3));
        end
        
        function outputImage = imlincombCore_4(fcnName, scalars, numScalars, outputImage, outputClassEnum, numElem, numInputImages, I1, I2, I3, I4) 
            coder.inline('always');
            coder.cinclude('libmwimlincomb.h');
            coder.ceval('-layout:any',fcnName,...
                        coder.ref(scalars), ...
                        numScalars,...
                        coder.ref(outputImage),...
                        outputClassEnum,...
                        numElem, ...
                        numInputImages, ...
                        coder.rref(I1),...
                        coder.rref(I2),...
                        coder.rref(I3),...
                        coder.rref(I4));
        end
        
    end
end
