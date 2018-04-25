function [channels, val] = getChannelsForDiff(h)
%GETCHANNELSFORDIFF Get the channels on selection for differencing.
%   OUT = GETCHANNELSFORDIFF(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.


me = fxptui.getexplorer;
channels = '';
val = 0;
if isempty(me); return; end
selection = me.getSelectedListNodes;
cnt = 1;
for k = 1:numel(selection.getTimeSeriesID)
    if (selection.getTimeSeriesID(k) ~= 0)
        if isequal(length(selection.getTimeSeriesID),length(selection.getSignalName)) && ~strcmpi(selection.getSignalName(k),' ')
            channels{cnt} = sprintf('%s (%s)',num2str(k),selection.getSignalName(k)); %#ok<AGROW>
        else
            channels{cnt} = num2str(k); %#ok<AGROW>
        end
        cnt = cnt+1;
    end
end
val = 0;
if isempty(h.selectedChannelForDiff) && isempty(h.selectedChannelForDiff)
    h.selectedChannelForDiff = 1;
end

% [EOF]

