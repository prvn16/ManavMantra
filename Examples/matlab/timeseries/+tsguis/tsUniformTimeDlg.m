function varargout = tsUniformTimeDlg(h,action)

% Copyright 2006-2017 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import java.util.*;
import java.text.*;

uniformTimeDialog = UniformTimeDialog.getInstance;
switch action
    case 'ok'
        if isa(h,'timeseries')
            uniformTimeDialog.fNode = [];
            if uniformTimeDialog.fAbsTimeFlag
                h.TimeInfo.StartDate = char(uniformTimeDialog.getStartDateStr);
                h.TimeInfo.Format = char(uniformTimeDialog.getFormatString);
            else
                h.TimeInfo.StartDate = '';
                h.TimeInfo.Format = '';
            end
            h.TimeInfo.Units = char(uniformTimeDialog.getUnits);
            h.TimeInfo.Start = uniformTimeDialog.fStartTime;
            h.TimeInfo.Increment = uniformTimeDialog.getInterval;
            varargout{1} = h;
            uniformTimeDialog.fCurrentTimeStr = h.TimeInfo.getTimeStr;
        else
            h.settime(linspace(uniformTimeDialog.fStartTime,uniformTimeDialog.fEndTime,...
                uniformTimeDialog.fLength)',char(uniformTimeDialog.getUnits),...
                char(uniformTimeDialog.getStartDateStr),...
                char(uniformTimeDialog.getFormatString));
            uniformTimeDialog.fCurrentTimeStr = h.getTimeInfo.getTimeStr;
        end
        
    case 'help'
        tsdata.internal.tsDispatchHelp('uniform_time','modal',uniformTimeDialog);
    case 'open'
        if isa(h,'timeseries')
            thisTimeInfo = h.TimeInfo;
        else
            thisTimeInfo = h.getTimeInfo;
            uniformTimeDialog.fNode = h;
            uniformTimeDialog = UniformTimeDialog.getInstance;
        end
        if ~isempty(thisTimeInfo.StartDate)
            % Convert the time series start date to a java.util.Date
            try
                [y,m,d,h,mi,s] = datevec(thisTimeInfo.StartDate,thisTimeInfo.Format);
            catch %#ok<CTCH>
                [y,m,d,h,mi,s] = datestr(datenum(thisTimeInfo.StartDate));
            end
            uniformTimeDialog.fStartDate = GregorianCalendar(y,m-1+java.util.Calendar.JANUARY,d,h,mi,s).getTime;
            uniformTimeDialog.fAbsTimeFlag = true;
        else
            uniformTimeDialog.fStartDate = Date;
            uniformTimeDialog.fAbsTimeFlag = false;
        end
        uniformTimeDialog.fEndTime = thisTimeInfo.End;
        uniformTimeDialog.fLength = thisTimeInfo.Length;
        uniformTimeDialog.fStartTime = thisTimeInfo.Start;
        uniformTimeDialog.fCurrentTimeStr = thisTimeInfo.getTimeStr;
        uniformTimeDialog.update;
end