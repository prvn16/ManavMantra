classdef ExceptionDisplay < handle
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties
        hParent
        hTextBox;
        hPanelContainer;
    end
    
    
    methods
        function exceptionDisplay = ExceptionDisplay(parentHandle, exp)                        
            
            exceptionDisplay.hParent = parentHandle;
            
            exceptionDisplay.hTextBox = uicontrol('Parent', parentHandle,...
                'Style', 'text',...
                'HorizontalAlignment', 'left',...
                'BackgroundColor','w',...
                'Tag','exceptionText',...
                'String', getString(message('images:imageBatchProcessor:exceptionHeaderInfo')));
            
            jlinkHandler = javaObjectEDT(com.mathworks.mlwidgets.MatlabHyperlinkHandler);
            jlinkText    = javaObjectEDT(com.mathworks.widgets.HyperlinkTextLabel);
            jlinkText.setAccessibleName('exceptionLinkText');
            jlinkText.setHyperlinkHandler(jlinkHandler);
            
            report = exceptionDisplay.trimReport(exp.getReport());
            jlinkText.setText(report);
            jlinkText.setBackgroundColor(java.awt.Color.white);
            
            hPanel = javaObjectEDT('javax.swing.JScrollPane',jlinkText.getComponent());
            hPanel.setBackground(java.awt.Color.white);
            
            [~, exceptionDisplay.hPanelContainer] = ...
                javacomponent(hPanel, [1 1 10 10 ], parentHandle);
            
            exceptionDisplay.positionControls();
            parentHandle.SizeChangedFcn = @exceptionDisplay.positionControls;
        end
        
        function positionControls(exceptionDisplay, varargin)
            canvas = getpixelposition(exceptionDisplay.hParent);
            
            width  = canvas(3);
            height = canvas(4);
            bottom = height;
            
            % Pad on top
            bottom = bottom-20;
            
            % Place header
            headerHeight = 20;
            bottom         = bottom - headerHeight;
            exceptionDisplay.hTextBox.Position = ...
                [1, bottom, width, headerHeight];
            
            % Pad
            bottom = bottom-20;
            
            % Use all remaining height for image list box
            panelHeight  = bottom;
            exceptionDisplay.hPanelContainer.Position = [1, 1, width, panelHeight];
            
        end
        
        function report = trimReport(~, report)
            internalStart = regexp(report,'\nError in [^\n]*batchProcessor');
            if(~isempty(internalStart))
                report = report(1:(internalStart-1));
            end
            % Convert to HTML breaks
            report = strrep(report,sprintf('\n'),'<br>');
        end
        
        function delete(exceptionDisplay)
            if(isvalid(exceptionDisplay.hParent))
                % Reset callback
                exceptionDisplay.hParent.SizeChangedFcn = [];
            end
            delete(exceptionDisplay.hPanelContainer);
            delete(exceptionDisplay.hTextBox);
        end
        
    end
end