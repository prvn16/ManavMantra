classdef ResultingTypeDialog < dialogmgr.DialogContent
    % Implement counts dialog for NTX

%   Copyright 2010-2012 The MathWorks, Inc.
    
    properties (Access=private)
        % Handles to widgets within the main dialog panel
        hcNumericType         % Checkbox readout
        
        tpDynamicRange        % TogglePanel
        htDynamicRangePrompts % Text prompts
        htDynamicRange        % Text readouts
        
        tpTypeDetails         % TogglePanel
        htTypeDetailsPrompts  % Text prompts
        htTypeDetails         % Text readouts
    end
    
    properties (Constant)
        % Icon caches
        BlankIcon = embedded.ntxui.loadBlankIcon
        WarnIcon  = embedded.ntxui.loadWarnIcon
    end
    
    methods
        function dlg = ResultingTypeDialog(ntx)
            % Setup dialog
            dlg.Name = getString(message('fixed:NumericTypeScope:ResultingTypeDialogName'));
            dlg.UserData = ntx; % record NTX application handle
            dlg.CustomContextHandler = true; % use custom context menu
        end
        
        function buildDialogContextMenu(dc,dp)
            % Create context menu items specific to this dialog
            ntx = dc.UserData;
            hMainContext = dp.hContextMenu;
            
            % Build context menu for 'Suggest' dialog
            % Add to generic base menu
            % Copy numerictype display string to system clipboard
            % Only create context menu if DTX is turned on
            copyNTStr = sprintf('%s numerictype', getString(message('fixed:NumericTypeScope:UI_CopyStr')));
            embedded.ntxui.createContextMenuItem(hMainContext, ...
                copyNTStr, @(h,e)copyNumericTypeToClipboard(ntx));
            createBaseContext(dp,dc);
        end
    end
    
    methods (Access=protected)
        function createContent(dlg)
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hParent = dlg.ContentPanel;
            set(hParent,'Tag','resultingtype_dialog_panel');
            bg = get(hParent,'BackgroundColor');
            ppos = get(hParent,'Position');
            pdx = ppos(3); % initial width of parent panel, in pixels
            pixelFactor = dlg.UserData.dp.PixelFactor;
            
            % vertical gutter between bottom of parent panel and the start
            % of dialog content
            yLowerBorder = 4;
            
            outBorder = 2;
            xL = 2;  % # pix separation from border to widget
            xb = outBorder; % # pix on each side of panel taken by border line
            
            % == Type Details (TD) ==
            
            % Define inner position of content panel
            TD_content_dy = 14*6*pixelFactor; % content_dy drives inner pos
            TD_x  = 5;
            TD_y  = 1+yLowerBorder;
            TD_dx = pdx-8;
            TD_dy = TD_content_dy + 4;
            TD_content_dx = TD_dx-6; % inner pos dx drives content_dx
            
            ipos = [TD_x TD_y TD_dx TD_dy];
            dlg.tpTypeDetails = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ipos, ...
                'Tag','type_details_toggle_panel',...
                'Title',getString(message('fixed:NumericTypeScope:TypeDetailsTitleStr')));
            
            pdx2 = floor(TD_content_dx/2); % midpoint, shifted 6 pix
            dxL  = pdx2-4-xb-xL+20;     % Make left side 4 pix narrower
            xR   = xL+dxL+3;         % 1-pix gap to start of right side
            dxR  = TD_content_dx-xR-xb-xL;
            
            % Add content to Type Details panel
            hp = dlg.tpTypeDetails.Panel;
            
            %We would get the maximum width of each string entires for htTypeDetailsPrompts.
            %Then the original panel width of htTypeDetailsPrompts is compared with the maximum width from the above entries 
            %Maximum of both the entries is computed and thats made  the new width of  htTypeDetailsPrompts.
            %HtTypeDetails  is translated to right side in order to accomodate the new width of HtTypeDetailsPrompts 
            arrayOfPrompts={getString(message('fixed:NumericTypeScope:SignednessPrompt')), ...
                             getString(message('fixed:NumericTypeScope:WordLengthPrompt')), ...
                             getString(message('fixed:NumericTypeScope:IntegerLengthPrompt')), ...
                             getString(message('fixed:NumericTypeScope:FractionLengthPrompt')), ...
                             getString(message('fixed:NumericTypeScope:RepresentableMaxPrompt')), ...
                             getString(message('fixed:NumericTypeScope:RepresentableMinPrompt'))
                                };           
            maxWidth = 0;
            for ii = 1: numel(arrayOfPrompts)
                dummyControl=uicontrol('parent',hp,...
                                        'Style','text', ...
                                        'Units','pix',...
                                        'String',arrayOfPrompts{ii}); 
                                   
                extent = get(dummyControl,'Extent');
                if(maxWidth < extent(3))
                    maxWidth = extent(3);
                end
            end
           if(maxWidth > dxL)
                 dxL = maxWidth ;
                 xR = xL+dxL+3;         % 1-pix gap to start of right side
           end
           delete(dummyControl); 
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
            str = sprintf('%s\n%s\n%s\n%s\n%s\n%s', ...
                getString(message('fixed:NumericTypeScope:SignednessPrompt')), ...
                getString(message('fixed:NumericTypeScope:WordLengthPrompt')), ...
                getString(message('fixed:NumericTypeScope:IntegerLengthPrompt')), ...
                getString(message('fixed:NumericTypeScope:FractionLengthPrompt')), ...
                getString(message('fixed:NumericTypeScope:RepresentableMaxPrompt')), ...
                getString(message('fixed:NumericTypeScope:RepresentableMinPrompt')));
            
            dlg.htTypeDetailsPrompts = uicontrol( ...
                'Parent', hp, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'HorizontalAlignment','right', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'Position',[1 2 dxL TD_content_dy], ...
                'Style','text', ...
                'Tag','type_details_prompt',...
                'String',str); 
            dlg.htTypeDetails = uicontrol( ...
                'Parent', hp, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'HorizontalAlignment','left', ...
                'Tag','type_details_text',...
                'Position',[xR 2 dxR TD_content_dy], ...
                'Style','text'); 

            
            % == Dynamic Range (DR) ==
            
            % Panel to contain content
            TD_pos = get(dlg.tpTypeDetails,'Position');
            DR_content_dy = 14*3*pixelFactor;
            DR_x  = TD_pos(1);
            DR_y  = TD_pos(2) + TD_pos(4) + 2;
            DR_dx = TD_pos(3);
            DR_dy = DR_content_dy + 4;
            
            ipos = [DR_x DR_y DR_dx DR_dy];
            dlg.tpDynamicRange = dialogmgr.TogglePanel( ...
                'Parent',hParent, ...
                'BackgroundColor',bg, ...
                'BorderType','beveledin', ...
                'InnerPosition',ipos, ...
                'Tag','dynamic_range__toggle_panel',...
                'Title',getString(message('fixed:NumericTypeScope:DataDetailsTitleStr')));
            
            % Add content to Dynamic Range panel
            hp = dlg.tpDynamicRange.Panel;
            outRngeStr = getString(message('fixed:NumericTypeScope:UI_OutsideRangeStr'));
            blwPrecStr = getString(message('fixed:NumericTypeScope:UI_BelowPrecisionStr'));
            str = sprintf('  %s \n  %s \n  SQNR ', outRngeStr, blwPrecStr);
            
            dlg.htDynamicRangePrompts = uicontrol( ...
                'Parent', hp, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'HorizontalAlignment','right', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'Position',[1 2 dxL DR_content_dy], ...
                'Style','text', ...
                'Tag','dynamic_range_prompt',...
                'String',str); 
            dlg.htDynamicRange = uicontrol( ...
                'Parent', hp, ...
                'BackgroundColor', bg, ...
                'Units','pix', ...
                'Enable','inactive', ...  % allow mouse drag on panel
                'HorizontalAlignment','left', ...
                'Tag','dynamic_range_text',...
                'Position',[xR 2 dxR DR_content_dy], ...
                'Style','text'); 
            
            
            % == Numeric Type readout ==
            DR_pos = get(dlg.tpDynamicRange,'Position');

            NT_content_dy = 14*1.5*pixelFactor;
            NT_x  = DR_pos(1);
            NT_y  = DR_pos(2) + DR_pos(4);
            NT_dx = DR_pos(3);
            NT_dy = NT_content_dy;
            
            % We specifically do NOT put enable into 'inactive' state
            % The tooltip needs to work on this widget
            % We fore-go the ease-of-use for drag operations
            ipos = [NT_x NT_y NT_dx NT_dy];
            dlg.hcNumericType = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor',bg, ...
                'TooltipString','', ...
                'HorizontalAlignment','left', ...
                'Units','pix', ...
                'Position',ipos, ...
                'String','', ...
                'Style','checkbox', ...
                'Tag','numeric_type_text',...
                'CData',dlg.BlankIcon); 
            
            % Final height
            pdy = NT_y+NT_dy; % overall height of content
            set(hParent,'Position',[1 1 pdx pdy]);
        end
        
        function updateContent(dlg)
            % Updates all widgets within dialog
            
            ntx = dlg.UserData;
            
            % Update Numeric Type checkbox
            %
            s = getNumericTypeStrs(ntx);
            str = s.typeStr;
            if s.isWarn
                icon = dlg.WarnIcon;
                tip  = s.warnTip;
            else
                icon = dlg.BlankIcon;
                tip  = s.typeTip;
            end
            set(dlg.hcNumericType, ...
                'String',str, ...
                'TooltipString',tip, ...
                'CData',icon);
            
            % Update Dynamic Range text
            %
            [ofCnt,ofPct] = getTotalOverflows(ntx);
            [ufCnt,ufPct] = getTotalUnderflows(ntx);
            ycnt = embedded.ntxui.intToCommaSepStr([ofCnt,ufCnt]);
            snr = getSNR(ntx);
            if isnan(snr)
                snrStr = '-'; % reset / unknown
            else
                snrStr = sprintf('%.1f dB', snr);
            end
            str = sprintf([ ...
                '%s (%.1f%%)\n' ...
                '%s (%.1f%%)\n' ...
                '%s'], ...
                ycnt{1},ofPct,ycnt{2},ufPct,snrStr);
            set(dlg.htDynamicRange,'String',str);
            
            % Update Type Details text
            %
            % Include guard- and precision-bits
            qlowerbound = 0;qupperbound = 0;
            [intBits,fracBits,wordBits,isSigned] = getWordSize(ntx,1);
            if ~isempty(wordBits)
                Tx = numerictype('Signed',isSigned,'WordLength',wordBits,...
                    'FractionLength',fracBits,'DataTypeOverride','Off');
                try
                    fiObj = fi(0,Tx);
                    [qlowerbound, qupperbound] = range(fiObj);
                    qlowerbound = double(qlowerbound);
                    qupperbound = double(qupperbound);
                catch ntx_exception %#ok<NASGU>
                end
            end
            
            if isSigned
                signedStr = getString(message('fixed:NumericTypeScope:UI_SignedStr'));
            else
                signedStr = getString(message('fixed:NumericTypeScope:UI_UnsignedStr'));
            end
            bitsStr = getString(message('fixed:NumericTypeScope:UI_bits_Str'));
            
            % Signedness, WordBits, IntBits, FracBits, TypeMax, TypeMin
            str = sprintf('%s\n%d %s\n%d %s\n%d %s\n%-+7.5g\n%-+7.5g', ...
                signedStr, ...
                wordBits, bitsStr, ...
                intBits,  bitsStr, ...
                fracBits, bitsStr, ...
                qupperbound,qlowerbound);
            set(dlg.htTypeDetails,'String',str);
        end
    end
end
