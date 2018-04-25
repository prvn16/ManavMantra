function updateNumericTypesAndSigns(ntx)
% Update numerictype dialog
%   update only if dialog panel is visible
%   update "numerictype()" only if DTX on
%   warning: icon, tooltip
%
% Update histogram title
%   update only if histogram visible
%   "numerictype()" if DTX, otherwise do same as Signed text
%
% Update Signed text
%   update only if histogram visible
%   Signed/Unsigned text
%   warning: icon, tooltip
%
% Update OptionSigned dialog controls
%   warning: change background color

%   Copyright 2010 The MathWorks, Inc.


s = getNumericTypeStrs(ntx);

% Check if numerictype changed. Though this is just a visual update, we
% need to make sure to react to any numerictype changes that was made by
% the autoscaling mechanism.
ht = ntx.htTitle;
dp = ntx.dp;
changed = ~strcmpi(get(ht,'String'),s.typeStr);
if changed
    datatypeChanged(ntx);
    
    % Update histogram title
    str = s.typeStr;
    tip = s.typeTip;
    set(ht,'String',str,'TooltipString',tip);
end

% After setting title string, update the "title" position.
% This requires text extent, hence the need to set string first.
ext = get(ht,'Extent');
pos_ax = get(ntx.hHistAxis,'Position'); % pixels
pos(1) = pos_ax(1)+pos_ax(3)-ext(3)-10;
pos(2) = pos_ax(2)+pos_ax(4)+4;
pos(3:4) = ext(3:4);
set(ht,'Position',pos);

% Update Signed text on histogram title line
%   update only if histogram visible
%   Signed/Unsigned text
%   warning: icon, tooltip
if s.isWarn
    icon = ntx.WarnIcon;
    tip = s.warnTip;
else
    icon = ntx.BlankIcon;
    tip = '';
end
set(ntx.htSigned, ...
    'String',s.signedStr, ...
    'TooltipString',tip, ...
    'CData',icon);

% OptionSigned dialog controls
%   warning: change background color
%   The po-up control does not render the color on MAC OSX. Use black text
%   instead.
if s.isWarn && ~ismac
    % Show overflow color as uicontrol background
    lightenUp = [0 .1 .1];
    clrp = ntx.ColorOverflowBar+lightenUp; % prompt
    clrw = clrp; % widget
    clrf = 'w';  % white text
else
    % xxx should be dp.hDialogPanel
    clrp = get(dp.hFigPanel,'BackgroundColor'); % prompt
    clrw = 'w'; % widget
    clrf = 'k'; % black text
end

setSignedPromptColor(ntx.hBitAllocationDialog,clrp,clrw,clrf);
