function buildContextMenu(ntx,hMainContext)
% Dynamically build "body" context menu
%
% This method is executed automatically by the DialogPanel object
% on a context menu invocation on the BodyPanel

%   Copyright 2010-2012 The MathWorks, Inc.

% Cache handle of current object,
%   guides us into which context menu to show
hco = gco;

% Determine if this object has a context menu
% If it doesn't, use the default context menu
tag = get(hco,'Tag');
if isempty(tag)
    buildAxisContextMenu(ntx)
else
    countStr   = getString(message('fixed:NumericTypeScope:UI_CountStr'));
    percentStr = getString(message('fixed:NumericTypeScope:UI_PercentStr'));
    percentAndParensStr = sprintf('%s (', percentStr);
    percentAndSymbolStr = strcat(percentAndParensStr, '%', ')');
    
    switch tag
      case 'HistogramAxis'
        buildAxisContextMenu(ntx);
      case 'NumericTypeString'
        buildAxisContextMenu(ntx);
      case 'YAxis'
        % Y-axis units
        hm(1) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            percentAndSymbolStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',1);
        hm(2) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            countStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',2);
        set(hm(ntx.HistVerticalUnits),'Checked','on');
        
      case 'WordSpan'
        % Options are part of DTX: suppress menu if shut off
        % Local context disabled - show the background context
        buildAxisContextMenu(ntx);
        
      case 'IntSpan'
        % Options are part of DTX: suppress menu if shut off
        % Local context disabled - show the background context
        buildAxisContextMenu(ntx);
        
      case 'FracSpan'
        % Options are part of DTX: suppress menu if shut off
        % Build fraction text context menu
        % Include guard bits/extra bits in count
        hm(1) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            getString(message('fixed:NumericTypeScope:UI_FLStr')), ...
            @(hThis,e)changeDTXFracSpanText(ntx,hThis), ...
            'userdata',1);
        hm(2) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            getString(message('fixed:NumericTypeScope:UI_SlopeStr')), ...
            @(hThis,e)changeDTXFracSpanText(ntx,hThis), ...
            'userdata',2);
        set(hm(ntx.DTXFracSpanText),'Checked','on');
        
      case 'Underflows'
        % part of datatype explorer - suppress menu if shut off
        % Build underflows text context menu
        %
        % Shared context menu with several other submenus
        hm(1) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            percentAndSymbolStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',1);
        hm(2) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            countStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',2);
        set(hm(ntx.HistVerticalUnits),'Checked','on');
        
      case 'Overflows'
        % part of datatype explorer - suppress menu if shut off
        % Build overflows text context menu
        % Shared context menu with several other submenus
        hm(1) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            percentAndSymbolStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',1);
        hm(2) = embedded.ntxui.createContextMenuItem(hMainContext, ...
            countStr, @(hThis,e)changeVerticalUnitsOption(ntx,hThis), ...
            'userdata',2);
        set(hm(ntx.HistVerticalUnits),'Checked','on');
        
      otherwise
        %Internal message to help with debugging. Not intended to be user-visible.
        error(message('fixed:NumericTypeScope:UnhandledContextMenuTag',tag));
    end
end
