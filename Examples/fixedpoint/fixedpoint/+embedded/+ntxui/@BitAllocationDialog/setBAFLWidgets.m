function setBAFLWidgets(dlg)
% Update state of all Bit Allocation Fraction Length dialog widgets

%   Copyright 2010-2012 The MathWorks, Inc.

setBAFLMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all LSB controls, make them invisible
hAll = [dlg.hBAFLValuePrompt dlg.hBAFLPrompt...
    dlg.hBAFLSpecifyMagnitude dlg.hBAFLSpecifyBits];
set(hAll,'Visible','off');

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
set(dlg.hBAFLMethod,'Visible','on','Enable',ena,'Value',dlg.BAFLMethod);
set(dlg.hBAFLPrompt,'Visible','on','Enable',enaTxt);
switch dlg.BAFLMethod
    case 1 % Smallest magnitude
      set(dlg.hBAFLValuePrompt, ...
            'Visible','on','Enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLSpecifyMagnitude, ...
            'Visible','on','Enable',ena);

        % Enable extra bits in this mode
        % Choose "extra bits" tooltip based on mode
        tip = getString(message('fixed:NumericTypeScope:ExtraFLBitsToolTip'));
        set(dlg.hBAFLExtraBitsPrompt , ...
            'TooltipString',tip, ...
            'Visible','on','Enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLExtraBits, ...
            'TooltipString',tip, ...
            'Visible','on','Enable',ena);
        
    case 2 % Directly specify number of FL Bits
      set(dlg.hBAFLValuePrompt, ...
            'Visible','on','Enable',enaTxt); % enabled but drag-able
        set(dlg.hBAFLSpecifyBits, ...
            'Visible','on','Enable',ena);
        
        % Hide extra bits in this mode
        set([dlg.hBAFLExtraBitsPrompt ...
             dlg.hBAFLExtraBits],'Visible','off');

  otherwise
    % Internal message to help debugging. Not intended to be user-visible.
    error(message('fixed:NumericTypeScope:invalidBAFLMethod',dlg.BAFLMethod));
end
