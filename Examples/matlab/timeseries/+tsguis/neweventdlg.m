function h = neweventdlg(h,action,varargin)

% Copyright 2006-2017 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import java.util.*;

newEventDialog = NewEventDialog.getInstance;
switch action
    case 'ok'
        evName = deblank(char(newEventDialog.getName));
        if isa(h,'timeseries')
            if ~isempty(h.TimeInfo.StartDate)
                evTime = (datenum(char(newEventDialog.getTime))-...
                    datenum(h.TimeInfo.StartDate))*...
                    tsunitconv(h.TimeInfo.Units,'days');
                e = tsdata.event(evName,evTime);
            else
                evTime = eval(char(newEventDialog.getTime));
                e = tsdata.event(evName,evTime);
            end
            e.Units = h.TimeInfo.Units;
            e.StartDate = h.TimeInfo.StartDate;
            h = addevent(h,e);
        else
            timeInfo = h.getTimeInfo;
            if ~isempty(timeInfo.StartDate)
                evTime = (datenum(char(newEventDialog.getTime))-...
                    datenum(timeInfo.StartDate))*...
                    tsunitconv(timeInfo.Units,'days');
                e = tsdata.event(evName,evTime);
            else
                evTime = eval(char(newEventDialog.getTime));
                e = tsdata.event(evName,evTime);
            end
            e.Units = timeInfo.Units;
            e.StartDate = timeInfo.StartDate;
            h.addEvent(e); % Adds to the node with recording etc.
        end
        awtinvoke(newEventDialog,'setVisible(Z)',false);
    case 'help'
        tsdata.internal.tsDispatchHelp('d_define_event','modal',newEventDialog);
    case 'open'
        if isa(h,'timeseries')
            newEventDialog.fNode = [];
            if nargin>=3
                newEventDialog.open(varargin{1});
            else
                newEventDialog.open(h.TimeInfo.StartDate);
            end
        else
            newEventDialog.fNode = h;
            if nargin>=3
                newEventDialog.open(varargin{1});
            else
                newEventDialog.open(h.getTimeInfo.StartDate);
            end
        end
end