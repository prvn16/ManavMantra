function label = getDisplayLabel(this)
% GETDISPLAYNAME Gets the name to be displayed for the node in the FPT

% Copyright 2013 MathWorks, Inc

label = '';
if(isa(this.DAObject, 'DAStudio.Object') || isa(this.DAObject, 'Simulink.ModelReference'))
    lblstr = this.DAObject.getDisplayLabel;
    logstr = getlogstr(this);
    dtostr = getdtostr(this);
    label = getlblstr(lblstr, logstr, dtostr);
end
%--------------------------------------------------------------------------
function logstr = getlogstr(this)
logstr = '';
if(~this.isDominantSystem('MinMaxOverflowLogging'))
    return;
end
logvalue = this.getParameterValue('MinMaxOverflowLogging'); 
% Use a switchyard instead of ismember() to improve performance.
switch logvalue
  case 'UseLocalSettings'
    logstr = '';
  case 'MinMaxAndOverflow'
    logstr = 'mmo'; 
  case 'OverflowOnly'
    logstr = 'o'; 
  case 'ForceOff'
    logstr = 'off'; 
  otherwise
    %do nothing;
end

%--------------------------------------------------------------------------
function dtostr = getdtostr(this)
dtostr = '';
if(~this.isDominantSystem('DataTypeOverride'))
    return;
end
dtovalue = this.getParameterValue('DataTypeOverride'); 

% Use a switchyard instead of ismember() to improve performance.
switch dtovalue
  case 'UseLocalSettings'
    dtostr = '';
  case {'ScaledDoubles', 'ScaledDouble'}
    dtostr = 'scl'; 
  case {'TrueDoubles', 'Double'}
    dtostr = 'dbl'; 
  case {'TrueSingles', 'Single'}
    dtostr = 'sgl'; 
  case {'ForceOff', 'Off'}
    dtostr = 'off';
  otherwise
    %do nothing;
end

%--------------------------------------------------------------------------
function lblstr = getlblstr(lblstr, logstr, dtostr)
if(isempty(logstr) && isempty(dtostr))
    return;
end
dash = '';
lblstr = [lblstr ' (' logstr];
if(~isempty(dtostr))
    if(~isempty(logstr))
        dash = '-';
    end
    %append the dto string to the label
    lblstr = [lblstr dash dtostr];
end
lblstr = [lblstr ')'];
