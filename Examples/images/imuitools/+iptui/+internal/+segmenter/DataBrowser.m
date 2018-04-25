classdef DataBrowser < handle
    
    % Copyright 2015
    
    properties (Access = private)
        hTCDataBrowser
        
        HistoryPanel
        HistoryList
        SegmentationPanel
        SegmentationList
    end
    
    methods
        
        function self = DataBrowser(hApp)
            self.hTCDataBrowser = constructToolstripDataBrowser();
            self.createSegmentationsSection2(hApp)
            self.createHistorySection(hApp)
            self.setInitialSplitbarLocation()
        end
        
        function addToToolGroup(self, toolgroup)
            toolgroup.setDataBrowser(self.hTCDataBrowser.getPanel())
        end
        
        function hBrowser = getHistoryBrowser(self)
            hBrowser = self.HistoryList;
        end
        
        function hBrowser = getSegmentationBrowser(self)
            hBrowser = self.SegmentationList;
        end
        
    end
    
    methods (Access = private)
        
        function createSegmentationsSection(self)
            import javax.swing.BoxLayout
            
            self.SegmentationPanel = createPanel('SegmentationPanel');
            panel = createScrollablePanel(self.SegmentationPanel);
            
            segmentationSectionTitle = getString(message('images:imageSegmenter:segmentationsBrowserLabel'));
            self.hTCDataBrowser.addPanel('S', segmentationSectionTitle, panel);
        end
        
        function createSegmentationsSection2(self, hApp)
            self.SegmentationPanel = javaObjectEDT('javax.swing.JPanel');
            self.SegmentationPanel.setBackground(java.awt.Color.white);
            self.SegmentationPanel.setLayout(javax.swing.BoxLayout(...
                self.SegmentationPanel, javax.swing.BoxLayout.Y_AXIS));
            
            segmentationSectionTitle = getString(message('images:imageSegmenter:segmentationsBrowserLabel'));
            self.hTCDataBrowser.addPanel('S', segmentationSectionTitle, self.SegmentationPanel);
            
            self.SegmentationList = iptui.internal.segmenter.SegmentationBrowser(self.SegmentationPanel, hApp);
        end
        
        function createHistorySection(self, hApp)
            
            self.HistoryPanel = javaObjectEDT('javax.swing.JPanel');
            self.HistoryPanel.setBackground(java.awt.Color.white);
            self.HistoryPanel.setLayout(javax.swing.BoxLayout(...
                self.HistoryPanel, javax.swing.BoxLayout.Y_AXIS));

            historySectionTitle = getString(message('images:imageSegmenter:historyBrowserLabel'));
            self.hTCDataBrowser.addPanel('H', historySectionTitle, self.HistoryPanel);
            
            self.HistoryList = iptui.internal.segmenter.HistoryBrowser(self.HistoryPanel, hApp);
        end
        
        function setInitialSplitbarLocation(self)
            self.hTCDataBrowser.setDividerLocation(0, .4);
        end
        
    end
    
end

function hPanel = createPanel(internalName)

import javax.swing.BoxLayout

hPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
hPanel.setBackground(java.awt.Color.WHITE);
hPanel.setLayout(BoxLayout(hPanel, BoxLayout.Y_AXIS));
hPanel.setName(internalName);

end

function panel = createScrollablePanel(hParent)

scrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane', hParent);
scrollPane.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
scrollPane.setVerticalScrollBarPolicy(com.mathworks.mwswing.MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);

panel = com.mathworks.mwswing.MJPanel();
panel.setBackground(java.awt.Color.WHITE);
panel.setLayout(java.awt.BorderLayout());
panel.add(scrollPane, java.awt.BorderLayout.CENTER);

end
        
function hBrowser = constructToolstripDataBrowser()

hBrowser = com.mathworks.toolbox.shared.controllib.databrowser.TCDataBrowser();

end
