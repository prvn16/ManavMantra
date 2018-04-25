classdef LinkTargetGenerator < handle
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(Access = private)
        LinkMap
    end
    
    methods
        function linkgen = LinkTargetGenerator()
            linkgen.LinkMap = containers.Map;
        end
    end
    
    methods
        function linkTarget = getDetailsLinkTargetForBaseFolder(linkgen,baseFolder)
            targetStr = sprintf('DETAILS{BF:%s}',baseFolder);
            linkTarget = linkgen.getLinkTargetForString(targetStr);
        end
        
        function linkTarget = getDetailsLinkTargetForTestIndex(linkgen,index)
            targetStr = sprintf('DETAILS{IDX:%u}',index);
            linkTarget = linkgen.getLinkTargetForString(targetStr);
        end
        
        function linkTarget = getDetailsLinkTargetForBaseFolderAndTestParentName(linkgen,baseFolder,testParentName)
            targetStr = sprintf('DETAILS{BF:%s}{PN:%s}',baseFolder,testParentName);
            linkTarget = linkgen.getLinkTargetForString(targetStr);
        end
        
        function linkTarget = getOverviewLinkTargetForBaseFolderAndTestParentName(linkgen,baseFolder,testParentName)
            targetStr = sprintf('OVERVIEW{BF:%s}{PN:%s}',baseFolder,testParentName);
            linkTarget = linkgen.getLinkTargetForString(targetStr);
        end

        function linkTarget = getLinkTargetForString(linkgen,str)
            import mlreportgen.dom.LinkTarget;
            if linkgen.LinkMap.isKey(str)
                linkTarget = LinkTarget(linkgen.LinkMap(str));
            else
                linkNum = linkgen.LinkMap.Count+1;
                linkStr = sprintf('Link%u',linkNum);
                linkgen.LinkMap(str) = linkStr;
                linkTarget = LinkTarget(linkStr);
            end
        end
    end
end