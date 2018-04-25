function setBAILWidgets(dlg)
% Update state of all Bit Allocation Integer Length dialog widgets

%   Copyright 2010-2012 The MathWorks, Inc.

setBAILMethodTooltip(dlg);

% Determine enable state for widgets, taking care to enable text widgets
% into the 'inactive' state for drag-ability
enaTxt = 'inactive';
ena = 'on';

% Define all MSB controls, make them invisible
hAll = [dlg.hBAILValuePrompt dlg.hBAILPrompt dlg.hBAILPercent ...
    dlg.hBAILCount dlg.hBAILUnits ...
    dlg.hBAILSpecifyMagnitude dlg.hBAILSpecifyBits];
set(hAll,'Visible','off');

set(dlg.hBAILMethod,'Visible','on','Enable',ena,'Value',dlg.BAILMethod);
set(dlg.hBAILPrompt,'Visible','on','Enable',enaTxt);
switch dlg.BAILMethod
  case 1 % Maximum Overflow
         % Turn on units
         % Select which edit box to turn on
    if dlg.BAILUnits==1 % Percent
        h = dlg.hBAILPercent;
    else % Count
        h = dlg.hBAILCount;
    end
    set([h dlg.hBAILUnits dlg.hBAILGuardBits], ...
        'Visible','on','Enable',ena);
    set(dlg.hBAILGuardBitsPrompt, ...
        'Visible','on','Enable',enaTxt);
    
  case 2 % Specify Magnitude
         % Show magtext control
    set([dlg.hBAILValuePrompt dlg.hBAILGuardBitsPrompt], ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set([dlg.hBAILSpecifyMagnitude dlg.hBAILGuardBits], ...
        'Visible','on','Enable',ena);
    
  case 3 % Directly specify number of IL Bits
    set(dlg.hBAILValuePrompt, ...
        'Visible','on','Enable',enaTxt); % enabled but drag-able
    set(dlg.hBAILSpecifyBits, ...
        'Visible','on','Enable',ena);
    
    % Hide guard bits in this mode
    set([dlg.hBAILGuardBitsPrompt ...
         dlg.hBAILGuardBits],'Visible','off');
    
  otherwise
    error(message('fixed:NumericTypeScope:invalidBAILMethod',dlg.BAILMethod));
end
