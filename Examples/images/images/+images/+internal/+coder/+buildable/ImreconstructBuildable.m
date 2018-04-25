classdef ImreconstructBuildable < coder.ExternalDependency %#codegen
    %IMRECONSTRUCTBUILDABLE - encapsulate imreconstruct implementation library
    
    % Copyright 2012-2016 The MathWorks, Inc.
    
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'ImreconstructBuildable';
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
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',computer('arch'),libDir);
                    linkFiles   = {'libmwimreconstruct'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwimreconstruct','mwnhood'};
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
            nonBuildFiles = {'libmwnhood', 'libmwimreconstruct'};
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function marker = imreconstructcore(fcnName, marker, mask, nimdims, imSize, conn, nconndims, connSize)
            coder.inline('always');
            coder.cinclude('libmwimreconstruct.h');
            
            imSizeT = coder.internal.flipIf(coder.isRowMajor,imSize);
            connSizeT = coder.internal.flipIf(coder.isRowMajor,connSize);
            
            coder.ceval('-layout:any',fcnName,...
                coder.ref(marker),...
                coder.rref(mask),...
                nimdims,...
                coder.rref(imSizeT),...
                coder.rref(conn),...
                nconndims,...
                coder.rref(connSizeT));
        end
        
        
    end
    
    
end
