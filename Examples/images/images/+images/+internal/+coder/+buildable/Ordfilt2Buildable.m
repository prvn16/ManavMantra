classdef Ordfilt2Buildable < coder.ExternalDependency %#codegen
    %ORDFILT2BUILDABLE - Encapsulate ordfilt2 implementation library
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Ordfilt2Buildable';
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
                    linkFiles   = {'libmwordfilt2'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',arch,libDir);
                    
                    nonBuildFiles = {'libmwordfilt2' , 'tbb'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                    
                case 'glnxa64'
                    linkFiles   = {'mwordfilt2'}; %#ok<*EMCA>
                    linkLibPath = binArch;
                    libOrdfilt = strcat('libmwordfilt2',execLibExt);
                    nonBuildFiles = {libOrdfilt, 'libtbb.so.2', 'libtbbmalloc.so.2'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles);
                    
                case 'maci64'
                    linkFiles   = {'mwordfilt2'}; %#ok<*EMCA>
                    linkLibPath = binArch;
                    nonBuildFiles = {'libmwordfilt2', 'libtbb', 'libtbbmalloc'};
                    nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
                
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

            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
                        
        end
        
        
        function B = ordfilt2core(fcnName, A, order, offsets, startIdx, domainSize, B)
            coder.inline('always');
            coder.cinclude('libmwordfilt2.h');
            
            sizeA = coder.internal.flipIf(coder.isRowMajor,size(A));
            sizeB = coder.internal.flipIf(coder.isRowMajor,size(B));
            domainSizeT =  coder.internal.flipIf(coder.isRowMajor,domainSize);
            startIdxT =  coder.internal.flipIf(coder.isRowMajor,startIdx);
            
            coder.ceval('-layout:any',fcnName,...
                    coder.rref(A),...
                    sizeA(1),...
                    coder.rref(startIdxT),...
                    coder.rref(offsets), ...
                    numel(offsets), ...
                    coder.rref(domainSizeT), ...
                    order, ...
                    coder.ref(B),...
                    sizeB,...
                    coder.isColumnMajor);                        
       end
       
       function B = ordfilt2offsetscore(fcnName, A, order, offsets, startIdx, domainSize, s, B)
            coder.inline('always');
            coder.cinclude('libmwordfilt2.h');
            
            sizeA = coder.internal.flipIf(coder.isRowMajor,size(A));
            sizeB = coder.internal.flipIf(coder.isRowMajor,size(B));
            domainSizeT =  coder.internal.flipIf(coder.isRowMajor,domainSize);
            startIdxT =  coder.internal.flipIf(coder.isRowMajor,startIdx);
            
            coder.ceval('-layout:any',fcnName,...
                    coder.rref(A),...
                    sizeA(1),...
                    coder.rref(startIdxT),...
                    coder.rref(offsets), ...
                    numel(offsets), ...
                    coder.rref(domainSizeT), ...
                    order, ...
                    coder.rref(s) , ...
                    coder.ref(B),...
                    sizeB);
                
       end
        
    end
end
