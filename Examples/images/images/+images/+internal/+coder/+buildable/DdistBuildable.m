classdef DdistBuildable < coder.ExternalDependency %#codegen
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'ddistBuildable';
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
                    linkFiles   = {'libmwddist'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwddist','mwnhood'};
                    linkLibPath = binArch;
                    
                otherwise
                    % unsupported
                    assert(false,[ arch ' operating system not supported']);
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
            nonBuildFiles = {'libmwddist', 'libmwnhood'};
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        
        function [D, idxout] = bwdist(BW, conn, weights, D, idxout)
            
            
            coder.inline('always');
            coder.cinclude('libmwddist.h');
            if(nargout==1)
                coder.ceval('ddist32_boolean',...
                    coder.rref(BW),    ...
                    size(BW),          ...
                    ndims(BW),         ...
                    coder.rref(conn),  ...
                    size(conn),        ...
                    ndims(conn),       ...
                    coder.rref(weights), ...
                    coder.ref(D),  ...
                    coder.opaque('void*', 'NULL'));                
            else
                coder.ceval('ddist32_boolean',...
                    coder.rref(BW),    ...
                    size(BW),          ...
                    ndims(BW),         ...
                    coder.rref(conn),  ...
                    size(conn),        ...
                    ndims(conn),       ...
                    coder.rref(weights), ...
                    coder.ref(D),  ...
                    coder.ref(idxout));
            end
        end
    end
end
