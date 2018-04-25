classdef Morphop_packed_Buildable < coder.ExternalDependency %#codegen
    % Encapsulate morphop implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    %#ok<*EMCA>    
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Morphop_packed_Buildable';
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
                    linkFiles   = {'libmwmorphop_packed'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwmorphop_packed','mwnhood'};
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
            nonBuildFiles = {'libmwnhood', 'libmwmorphop_packed'};
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function b = erode_packed(...
                fcnName, a, asize, adims, nhood, nsize, ndims, unpacked_M, b)
            coder.inline('always');
            coder.cinclude('libmwmorphop_packed.h');
            
            asizeT = coder.internal.flipIf(coder.isRowMajor,asize);
            nsizeT = coder.internal.flipIf(coder.isRowMajor,nsize);
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(a), coder.rref(asizeT), adims,...
                coder.rref(nhood), coder.rref(nsizeT), ndims,...
                unpacked_M,...
                coder.ref(b),...
                coder.isColumnMajor);
        end
        
        function b = dilate_packed(...
                fcnName, a, asize, adims, nhood, nsize, ndims, b)
            coder.inline('always');
            coder.cinclude('libmwmorphop_packed.h');
           
            asizeT = coder.internal.flipIf(coder.isRowMajor,asize);
            nsizeT = coder.internal.flipIf(coder.isRowMajor,nsize);
            
            coder.ceval('-layout:any',fcnName,...
                coder.rref(a), coder.rref(asizeT), adims,...
                coder.rref(nhood), coder.rref(nsizeT), ndims,...
                coder.ref(b),...
                coder.isColumnMajor);
        end
        
    end
end
