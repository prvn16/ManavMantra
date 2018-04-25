
%   Copyright 2017 The MathWorks, Inc.

classdef SobelAPI < coder.ExternalDependency
    %#codegen
    
    methods (Static)
        
        function bName = getDescriptiveName(~)
            bName = 'SobelAPI';
        end
        
        function tf = isSupportedContext(ctx)
            if  ctx.isMatlabHostTarget()
                tf = true;
            else
                error('sobel library not available for this target');
            end
        end
        
        function updateBuildInfo(buildInfo, ctx)
            [~, linkLibExt, execLibExt, ~] = ctx.getStdLibInfo();
            
            % Header files
            hdrFilePath = fullfile(pwd, 'codegen', 'dll', 'sobelEdge');
            buildInfo.addIncludePaths(hdrFilePath);
            
            % Link files
            linkFiles = strcat('sobelEdge', linkLibExt);
            linkPath = hdrFilePath;
            linkPriority = '';
            linkPrecompiled = true;
            linkLinkOnly = true;
            group = '';
            buildInfo.addLinkObjects(linkFiles, linkPath, ...
                linkPriority, linkPrecompiled, linkLinkOnly, group);
            
            % Non-build files
            nbFiles = 'sobelEdge';
            nbFiles = strcat(nbFiles, execLibExt);
            buildInfo.addNonBuildFiles(nbFiles,'','');
        end
        
        %API for library function 'sobelEdge'
        function c = sobelEdge(I)
            % running in generated code, call library function
            coder.cinclude('sobelEdge.h');
            
            c = coder.nullcopy(I);
            coder.ceval('sobelEdge', coder.rref(I), coder.wref(c));
        end
    end
end

% LocalWords:  sobel
