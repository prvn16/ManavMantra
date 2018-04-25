function setBAILFLWidgets(dlg)
% Update state of the IF+FL optimization choices in the dialog

%   Copyright 2010-2012 The MathWorks, Inc.

setBAILFLMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all MSB controls, make them invisible
hAll = [dlg.hBASpecifyPrompt dlg.hBAILFLMethod dlg.hBAILFLValuePrompt...
    dlg.hBAILFLPercent dlg.hBAILFLCount dlg.hBAILFLUnits...
    dlg.hBAILFLSpecifyMSBMagnitude dlg.hBAILFLSpecifyILBits...
    dlg.hBAILFLSpecifyLSBMagnitude dlg.hBAILFLSpecifyFLBits,...
    dlg.hBAILFLGuardBitsPrompt dlg.hBAILFLGuardBits,...
    dlg.hBAILFLExtraBitsPrompt dlg.hBAILFLExtraBits];

set(hAll,'Visible','off');

set([dlg.hBASpecifyPrompt dlg.hBAILFLMethod],'Visible','on');

switch dlg.BAILFLMethod
  case 1 % maximum Overflow
         % Turn on units
         % Select which edit box to turn on
    if dlg.BAILUnits==1 % Percent
        h = dlg.hBAILFLPercent;
    else % Count
        h = dlg.hBAILFLCount;
    end
    set([h dlg.hBAILFLUnits dlg.hBAILFLGuardBits], ...
        'Visible','on','Enable',ena);
    set(dlg.hBAILFLGuardBitsPrompt, ...
        'Visible','on','Enable',enaTxt);
  case 2 % Specify Magnitude
           % Show magtext control
    set([dlg.hBAILFLValuePrompt dlg.hBAILFLGuardBitsPrompt], ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set([dlg.hBAILFLSpecifyMSBMagnitude dlg.hBAILFLGuardBits], ...
        'Visible','on','Enable',ena);
  case 3 % Integer bits
    
    set(dlg.hBAILFLValuePrompt, ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyILBits, ...
        'Visible','on','Enable',ena);
    
    % Hide guard bits in this mode
    set([dlg.hBAILFLGuardBitsPrompt ...
         dlg.hBAILFLGuardBits],'Visible','off');
    
  case 4 % Specify precision
         % Show specify precision controls
       
    set(dlg.hBAILFLValuePrompt, ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyLSBMagnitude, ...
        'Visible','on','Enable',ena);
    
    % Enable extra bits in this mode
    % Choose "extra bits" tooltip based on mode
    tip = getString(message('fixed:NumericTypeScope:ExtraFLBitsToolTip'));
    set(dlg.hBAILFLExtraBitsPrompt , ...
        'TooltipString',tip, ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLExtraBits, ...
        'TooltipString',tip, ...
        'Visible','on','Enable',ena);
    
  case 5 % Fractional bits
    set(dlg.hBAILFLValuePrompt, ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILFLSpecifyFLBits, ...
        'Visible','on','Enable',ena);
    
    % Hide extra bits in this mode
    set([dlg.hBAILFLExtraBitsPrompt ...
         dlg.hBAILFLExtraBits],'Visible','off');
    
  otherwise
    % Internal message to help debugging. Not intended to be user-visible.
    error(message('fixed:NumericTypeScope:invalidBAILFLMethod',dlg.BAILFLMethod));
end
