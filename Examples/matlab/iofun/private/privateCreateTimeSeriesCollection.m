function tsc = privateCreateTimeSeriesCollection(objinfo,data,time,start,daqevents)
%PRIVATECREATETIMESERIESCOLLECTION Create a time series collection from acquired data.
%
%    TSC = PRIVATECREATETIMESERIESCOLLECTION(OBJINFO, DATA, TIME, START, DAQEVENTS)
%    Creates a time series collection based on a data acquisition session 
%    described by OBJINFO, a structure with the scalar samplerate field, 
%    cell arrays containing fields channelnames (string) and channelunits (string)
%    (the physical units that the data is in), and a vector of hwids (integers), 
%    In addition, the function expects a matrix of data DATA, a vector of time
%    stamps, the absolute start time of START (t=0 in the TIME vector), and 
%    an array of data acquisition event structures, DAQEVENTS.  The
%    resulting time series in TSC will be in the 'seconds' time base, and
%    use a default interpolation method of zero order hold.
%

%    PRIVATECREATETIMESERIESCOLLECTION is a helper function for 
%    DAQREAD and GETDATA.  It is copied by the once stage make file to
%    matlab/toolbox/matlab/iofun/private so that it works in MATLAB when
%    Data Acquisition Toolbox is not installed.  Note that unlike DAQREAD,
%    a copy also remains in matlab/toolbox/daq/daq/private to support
%    GETDATA.
%
%    Copyright 2006-2012 The MathWorks, Inc.

    % Data Acquisition Toolbox returns NaNs in the timestamp vector and the
    % data matrix to indicate that discontinuities occurred (triggers).
    % Time series expects that the NaNs will appear in the data matrix, but
    % not in the timestamp vector.  Extrapolate the time of the NaN from
    % the next point, and decrement by EPS.  Note that no valid time vector
    % will have a Nan as the last element.
    locNan = find(isnan(time));
    if any(locNan < 2)
        % no valid NaN in time vector should appear in element 1
        error(message('MATLAB:daqread:invalidTimeSeries'));
    end
    time(locNan) = time(locNan + 1) - eps(time(locNan + 1));

    tsc = tscollection(time,'name',['Acquired ' datestr(start,'local')]);
    tsc.TimeInfo.units = 'seconds';
    tsc.TimeInfo.Startdate = datestr(start);
    
    % Validate all channel names before adding any to the tscollection
    for iChannel =1:length(objinfo.channelnames)
        %Check that the channel name is a valid MATLAB identifier
        if ~isvarname(objinfo.channelnames{iChannel})
            % if not, change it to "ChannelX"
            objinfo.channelnames{iChannel} = sprintf('Channel%d',objinfo.hwids(iChannel)); %#ok<AGROW>
        end

        % Find all channels with the same name as this one
        indexOfDupChannels = find(strcmpi(objinfo.channelnames{iChannel},objinfo.channelnames));
        % We'll always get at least one match (the channel name matching
        % itself).  But, if we get more than 1, then there are duplicates
        while length(indexOfDupChannels) > 1
            for iDupChannel = 1:length(indexOfDupChannels)
                % Loop through the duplicates, and rename them "ChannelX"
                objinfo.channelnames{indexOfDupChannels(iDupChannel)} =...
                    sprintf('Channel%d',objinfo.hwids(indexOfDupChannels(iDupChannel))); %#ok<AGROW>
            end
            
            % Repeat in (the unlikely) case that the new name is a dup
            indexOfDupChannels = find(strcmpi(objinfo.channelnames{iChannel},objinfo.channelnames));
        end
    end
    
    % Add the time series to the tscollection
    for iChannel =1:length(objinfo.channelnames)
        % Create the new timeseries, and add it to the collection
        tsc = addts(tsc,localCreateTimeSeries(...
                            tsc,...
                            objinfo.channelnames{iChannel},...
                            data(:,iChannel),...
                            time,...
                            objinfo.channelunits{iChannel}));
    end %for iChannel
    
    function [ts] = localCreateTimeSeries(tsc,tsName,data,time,units)
        
        % create the time series object with data and time information.  Use
        % the channel name as the name of the time series
        ts = timeseries(data,time,'Name',tsName);

        % Make sure that the data, if resampled, resamples using a zero
        % order hold by default.
        ts = ts.setinterpmethod('zoh');

        % set the units for the time series to the units for the channel
        ts.Datainfo.Unit = units;

        % make sure that the time series time info is in seconds, and set the
        % start time that acquisition was started.
        ts.TimeInfo.units = tsc.TimeInfo.units;
        ts.TimeInfo.Startdate = tsc.TimeInfo.Startdate;
        ts.TimeInfo.Format = tsc.TimeInfo.Format;
        
        % Make a list of event names
        eventName = {daqevents.Type};
        
        % Make event objects for each event that took place
        for iEvent = 1:length(daqevents)

            % Find all events with the same name as this one
            indexOfDupEvents = find(strcmpi(eventName{iEvent},eventName));
            % We'll always get at least one match (the event name matching
            % itself).  But, if we get more than 1, then there are duplicates
            if length(indexOfDupEvents) > 1
                newEventIndex = 1;
                for iDupEvent = 1:length(indexOfDupEvents)
                    % Loop through the duplicates, and append an integer
                    % number on to the end.
                    eventName{indexOfDupEvents(iDupEvent)} =...
                        sprintf('%s%d',...
                                eventName{indexOfDupEvents(iDupEvent)},...
                                newEventIndex); %#ok<AGROW> 
                    newEventIndex = newEventIndex + 1;
                end
            end

            % Create the new event, and add it to the timeseries
            ts = addevent(ts,localCreateEvent(...
                                eventName{iEvent},...
                                daqevents(iEvent)));
        end % for iEvent
    end % localCreateTimeSeries

    function [e] = localCreateEvent(eventName,daqevent)
        % create the event.  Use the name from the DAT event, and the time.
        % DAT reports event time as an absolute, but time series wants it
        % as a relative, so calculate that from the start time.
        e = tsdata.event(eventName,etime(daqevent.Data.AbsTime,start));
        e.StartDate = tsc.TimeInfo.Startdate;
        e.units = tsc.TimeInfo.units;

        % attach the DAT event structure to the event
        e.EventData = daqevent;
    end % localCreateEvent
end %privateCreateTimeSeriesCollection
