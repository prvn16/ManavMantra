classdef Toolstrip < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access = private)
        hActiveContoursTab
        hFloodFillTab
        hMorphologyTab
        hSegmentTab
        hThresholdTab
        hGraphCutTab
        hFindCirclesTab
        hGrabCutTab
        
        TabList
    end
    
    methods
        
        function self = Toolstrip(toolGroup, mainApp)
            self.addToolstripTabs(toolGroup, mainApp)
        end
        
        function showSegmentTab(self)
            self.hSegmentTab.show()
            self.hSegmentTab.makeActive()
        end
        
        function showActiveContourTab(self)
            self.hActiveContoursTab.show()
            self.hActiveContoursTab.makeActive()
        end
        
        function showFloodFillTab(self)
            self.hFloodFillTab.show()
            self.hFloodFillTab.makeActive()
        end
        
        function showMorphologyTab(self)
            self.hMorphologyTab.show()
            self.hMorphologyTab.makeActive()
        end

        function showThresholdTab(self)
            self.hThresholdTab.show()
            self.hThresholdTab.makeActive()
        end
        
        function showGraphCutTab(self)
            self.hGraphCutTab.show()
            self.hGraphCutTab.makeActive()
        end
        
        function showGrabCutTab(self)
            self.hGrabCutTab.show()
            self.hGrabCutTab.makeActive()
        end
        
        function showFindCirclesTab(self)
            self.hFindCirclesTab.show()
            self.hFindCirclesTab.makeActive()
        end
        
        function hideSegmentTab(self)
            self.hSegmentTab.hide()
        end
        
        function hideActiveContourTab(self)
            self.hActiveContoursTab.hide()
        end
        
        function hideFloodFillTab(self)
            self.hFloodFillTab.hide()
        end
        
        function hideMorphologyTab(self)
            self.hMorphologyTab.hide()
        end

        function hideThresholdTab(self)
            self.hThresholdTab.hide()
        end
        
        function hideGraphCutTab(self)
            self.hGraphCutTab.hide()
        end
        
        function hideGrabCutTab(self)
            self.hGrabCutTab.hide()
        end
        
        function hideFindCirclesTab(self)
            self.hFindCirclesTab.hide()
        end
        
        function deleteTimers(self)
            self.hFindCirclesTab.deleteTimer();
            self.hActiveContoursTab.deleteTimer();
            delete(self.hSegmentTab.CreateGallery);
            delete(self.hSegmentTab.AddGallery);
            delete(self.hSegmentTab.RefineGallery);
        end
        
        function setMode(self, mode)
            
            for idx = 1:numel(self.TabList)
                tab = self.TabList{idx};
                tab.setMode(mode)
            end
            
        end
       
        function opacity = getOpacity(self)
            opacity = self.hSegmentTab.getOpacity();
        end
        
        function TF = loadImageInSegmentTab(self,im)
            TF = self.hSegmentTab.importImageData(im);
        end
        
        function idx = findVisibleTabs(self)
            idx = [];
            for p = 1:numel(self.TabList)
                if (self.TabList{p}.Visible)
                    idx(end + 1) = p; %#ok<AGROW>
                end
            end
        end
        
        function TF = tabHasUncommittedState(self, tabIndex)
            TF = self.TabList{tabIndex}.HasUncommittedState;
        end
        
        function closeTab(self, tabIndex)
            self.TabList{tabIndex}.onClose()
        end
        
        function applyCurrentSettings(self, tabIndex)
            self.TabList{tabIndex}.onApply()
        end
        
        function stopActiveContours(self)
            self.hActiveContoursTab.forceSegmentationToStop()
        end
    end
    
    % Layout
    methods (Access=private)
        
        function addToolstripTabs(self, toolGroup, mainApp)
            
            tabGroup = matlab.ui.internal.toolstrip.TabGroup();
            self.hSegmentTab = iptui.internal.segmenter.SegmentTab(toolGroup, tabGroup, self, mainApp, 1);
            self.hActiveContoursTab = iptui.internal.segmenter.ActiveContoursTab(toolGroup, tabGroup, self, mainApp, 2);
            self.hThresholdTab = iptui.internal.segmenter.ThresholdTab(toolGroup, tabGroup, self, mainApp, 3);
            self.hFloodFillTab = iptui.internal.segmenter.FloodFillTab(toolGroup, tabGroup, self, mainApp, 4);
            self.hMorphologyTab = iptui.internal.segmenter.MorphologyTab(toolGroup, tabGroup, self, mainApp, 5);
            self.hGraphCutTab = iptui.internal.segmenter.GraphCutTab(toolGroup, tabGroup, self, mainApp, 6);
            self.hFindCirclesTab = iptui.internal.segmenter.FindCirclesTab(toolGroup, tabGroup, self, mainApp, 7);
            self.hGrabCutTab = iptui.internal.segmenter.GrabCutTab(toolGroup, tabGroup, self, mainApp, 8);
            
            self.TabList = {self.hSegmentTab, ...
                self.hActiveContoursTab, ...
                self.hThresholdTab, ...
                self.hFloodFillTab, ...
                self.hMorphologyTab, ...
                self.hGraphCutTab, ...
                self.hFindCirclesTab, ...
                self.hGrabCutTab};

            toolGroup.addTabGroup(tabGroup);

        end
        
    end
    
end