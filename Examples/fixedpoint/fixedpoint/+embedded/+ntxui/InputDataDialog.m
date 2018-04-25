classdef InputDataDialog < dialogmgr.DialogContent
    % Implement input data dialog for NTX

%   Copyright 2010-2012 The MathWorks, Inc.
    
    properties (Access=private)
        % Handles to widgets within the main dialog panel
        hcpStats % toggle panel
        htStatsPrompts
        htStatsInfo
        
        hcpCounts % toggle panel
        htCountPrompts
        htCountInfo
    end
    
    methods
        function dlg = InputDataDialog(ntx)
            dlg.Name = getString(message('fixed:NumericTypeScope:InputDataDialogName'));
            dlg.UserData = ntx; % record NTX application handle
        end
    end
    
    methods (Access=protected)
        function createContent(dlg)
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hParent = dlg.ContentPanel;
            set(hParent,'Tag','inputdata_dialog_panel');
            bg = get(hParent,'BackgroundColor');
            ppos = get(hParent,'Position');
            pdx = ppos(3); % initial width of parent panel, in pixels
            
            inBorder = 2;
            outBorder = 2;
            xL = inBorder; % # pix separation from border to widget
            xb = outBorder; % # pix on each side of panel taken by border line
            
            pixelFactor = dlg.UserData.dp.PixelFactor;
            % Statistics
            
            % Panel to contain content
            content_dy = 14*3*pixelFactor;
            stats_x    = 5;
            stats_y    = 1+inBorder;
            stats_dx   = pdx-8;
            stats_dy   = content_dy + 4;
            content_dx = stats_dx - 6;
            
            ppos = [stats_x stats_y stats_dx stats_dy];
            hcp = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ppos, ...
                'Tag','stats_toggle_panel',...
                'Title','Statistics');
            dlg.hcpStats = hcp;
            hPanel = hcp.Panel;
            
            pdx2 = floor(content_dx/2); % midpoint
            dxL  = pdx2-10-xb-xL;     % Make left side 10 pix narrower
            xR   = xL+dxL+3;          % 1-pix gap to start of right side
            dxR  = content_dx-xR-xb-xL;
            
            % Content of stats panel
            maxStr = getString(message('fixed:NumericTypeScope:UI_MaxStr'));
            avgStr = getString(message('fixed:NumericTypeScope:UI_AverageStr'));
            minStr = getString(message('fixed:NumericTypeScope:UI_MinStr'));
            str    = sprintf('  %s \n  %s \n  %s ', maxStr, avgStr, minStr);
            dlg.htStatsPrompts = uicontrol( ...
                'Parent', hPanel, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'HorizontalAlignment','right', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'Position', [1 2 dxL content_dy], ...
                'Style','text', ...
                'Tag','stats_prompt',...
                'String',str); 
            dlg.htStatsInfo = uicontrol( ...
                'Parent', hPanel, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'HorizontalAlignment','left', ...
                'Position', [xR 2 dxR content_dy], ...
                'Tag','stats_text',...
                'Style','text'); 

            % Counts
            
            % Panel to contain content
            stats_pos = get(hcp,'Position');
            content_dy = 14*4*pixelFactor;
            counts_x  = stats_pos(1);
            counts_y  = stats_pos(2) + stats_pos(4) + 2;
            counts_dx = stats_pos(3);
            counts_dy = content_dy+4;
            ppos = [counts_x counts_y counts_dx counts_dy];
            str = getString(message('fixed:NumericTypeScope:UI_CountsStr'));
            hcp = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ppos, ...
                'Tag','counts_toggle_panel',...
                'Title',str);
            dlg.hcpCounts = hcp;
            hPanel = hcp.Panel;
            
            % Content of counts panel
            totStr = getString(message('fixed:NumericTypeScope:UI_TotalStr'));
            posStr = getString(message('fixed:NumericTypeScope:UI_PositiveStr'));
            zerStr = getString(message('fixed:NumericTypeScope:UI_ZeroStr'));
            negStr = getString(message('fixed:NumericTypeScope:UI_NegativeStr'));
            str    = sprintf('  %s \n  %s \n  %s \n  %s ', totStr, posStr, zerStr, negStr);
            dlg.htCountPrompts = uicontrol( ...
                'Parent', hPanel, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'HorizontalAlignment','right', ...
                'Position', [1 2 dxL content_dy], ...
                'Tag','counts_prompt',...
                'Style','text', ...
                'String',str); 
            dlg.htCountInfo = uicontrol( ...
                'Parent', hPanel, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'HorizontalAlignment','left', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'Position', [xR 2 dxR content_dy], ...
                'Tag','counts_text',...
                'Style','text'); 
            
            % Final height
            bbox = get(hcp,'Position');
            pdy = bbox(2)+bbox(4);
            set(hParent,'Position',[1 1 pdx pdy]);
        end
        
        function updateContent(dlg)
            % Updates to widgets within dialog are performed in this method
            
            % Max/Avg/Min
            
            ntx = dlg.UserData; % get NTX application object
            dataCount = ntx.DataCount;
            if dataCount>0
                dataAvg = ntx.DataSum / dataCount;
            else
                dataAvg = 0;
            end
            % Print formatted text
            fmt = '%-7.5g\n%-7.5g\n%-7.5g';
            str = sprintf(fmt, ...
                ntx.DataMax,dataAvg,ntx.DataMin);
            set(dlg.htStatsInfo,'String',str);
            
            % Histogram Counts (pos/neg/zero/total)
            
            ntx = dlg.UserData; % get NTX application object
            % Determine largest # digits in ipos, izro, and ineg
            % Use this as the formatting field width for integers
            y = embedded.ntxui.intToCommaSepStr([ ...
                ntx.DataCount,...
                ntx.DataPosCnt, ...
                ntx.DataZeroCnt, ...
                ntx.DataNegCnt]);
            str = embedded.ntxui.leftJustifyCellStrs(y);
            set(dlg.htCountInfo,'String',str);
        end
    end
end
