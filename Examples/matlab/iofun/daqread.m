function [data, time, abstime, eventinfo, daqinfo] = daqread(filename, varargin)
%DAQREAD Read Data Acquisition Toolbox (.daq) data file.
%
%    DATA = DAQREAD('FILENAME') reads the data acquisition file, FILENAME,
%    and returns a M-by-N data matrix, DATA, where M specifies the number
%    of samples and N specifies the number of channels.  If data from
%    multiple triggers is read, the data from each trigger is separated by
%    a NaN.
%
%    [DATA, TIME] = DAQREAD('FILENAME') reads the data acquisition file, 
%    FILENAME, and returns the time-value pairs.  TIME is a vector, the 
%    same length of DATA indicating the relative time of each data sample
%    relative to the first trigger.
%
%    [DATA, TIME, ABSTIME] = DAQREAD('FILENAME') returns the absolute time, 
%    ABSTIME, of the first trigger.  ABSTIME is returned as a CLOCK vector.
%
%    [DATA, TIME, ABSTIME, EVENTS] = DAQREAD('FILENAME') returns a
%    structure, EVENTS, which contains a log of events.
%
%    [DATA,...] = DAQREAD('FILENAME', 'P1', V1, 'P2', V2,...) specifies the 
%    amount of data to be read from the file, FILENAME, the format of the
%    DATA matrix, the format of the TIME matrix, and whether to return a
%    time series collection object.
%
%      Valid Property Names (P1, P2,...) and Property Values (V1, V2,...)
%      include:
%
%         Samples    -  [sample range]
%         Time       -  [time range in seconds]
%         Triggers   -  [trigger range]
%         Channels   -  [channel indices or cell array of ChannelNames]
%         DataFormat -  [ {double} | native ]
%         TimeFormat -  [ {vector} | matrix ]
%         OutputFormat -  [ {matrix} | tscollection ]
%
%      The Samples, Time and Triggers properties are mutually exclusive,
%      i.e. either Samples, Triggers or Time can be defined at once.
%
%      The TimeFormat and OutputFormat properties are mutually exclusive,
%      i.e. either TimeFormat or OutputFormat can be defined at once.
%
%      The default values for the DataFormat, TimeFormat, and OutputFormat
%      properties are indicated by braces {}.
%
%      Setting the OutputFormat property to 'tscollection' causes DAQREAD
%      to return a time series collection object.  In this case, only the
%      DATA left hand argument is used.
%
%    If DAQREAD returns a time series collection object, DATA will contain
%    an absolute time series object for each channel in the file, with time=0
%    set to InitialTriggerTime property of the file. Each time series object is
%    given a name corresponding to the Name property of the channel. If
%    this name cannot be used as a time series object name, the name will
%    be set to 'Channel' with the HwChannel property of the channel
%    appended. If the DataFormat property is set to 'double', each time
%    series object in the collection will have the Units field of its
%    DataInfo property set to the Units property of the corresponding
%    channel in the file.  If the DataFormat property is set to 'native', the
%    Units property is set to 'native'.  In addition, each time series
%    object will have tsdata.event objects attached corresponding to the
%    log of events associated with the file. If DAQREAD returns data from
%    multiple triggers, the data from each trigger is separated by a NaN in
%    the time series data.  This will increase the length of data and time
%    vectors in the time series object by the number of triggers.  
%
%
%    DAQINFO = DAQREAD('FILENAME', 'info') reads the data acquisition file, 
%    FILENAME, and returns a structure, DAQINFO, which contains the
%    information:
%
%       DAQINFO.ObjInfo - a structure containing PV pairs for the data
%                         acquisition object used to create the file,
%                         FILENAME. Note: The UserData property value is
%                         not restored.
%       DAQINFO.HwInfo  - a structure containing hardware information.
%
%    The DAQINFO structure can also be obtained with the following syntax:
%    [DATA, TIME, ABSTIME, EVENTS, DAQINFO] = DAQREAD('FILENAME')
%    
%    Data Acquisition Toolbox (.daq) data files are created by specifying
%    a value for the LogFileName property and setting the LoggingMode 
%    property to 'Disk' or 'Disk&Memory'.
%
%    Examples:
%      To read all the data from the file, data.daq:
%         [data, time] = daqread('data.daq');
%
%      To read all the data from the file, data.daq, and return it as a
%      time series collection object:
%         data = daqread('data.daq','OutputFormat','tscollection');
%
%      To read only samples 1000 to 2000 of channel indices 2, 4 and 7 in 
%      native format from the file, data.daq:
%         data = daqread('data.daq', 'Samples', [1000 2000],...
%                                'Channels', [2 4 7], 'DataFormat', 'native');
%
%      To read only the data which represents the first and second triggers on 
%      all channels from the file, data.daq:
%         [data, time] = daqread('data.daq', 'Triggers', [1 2]);
%
%      To obtain the property values of the channels from the file, data.daq:
%         daqinfo = daqread('data.daq', 'info');
%         chaninfo = daqinfo.ObjInfo.Channel;
%     
%    See also DAQHELP, GETDATA, TIMESERIES, TSCOLLECTION.
%

%    DAQREAD is a part of core MATLAB.  It is moved by the once stage make
%    file to matlab/toolbox/matlab/iofun/private so that it works in MATLAB
%    when Data Acquisition Toolbox is not installed.  Note that DAQREAD is
%    not released in matlab/toolbox/daq/daq, since it will be available as
%    part of core MATLAB.
%
%    Copyright 1998-2015 The MathWorks, Inc.

warning(message('MATLAB:daqread:legacySupportDeprecated', 'daqread'));

if nargin < 1
    error(message('MATLAB:daqread:notEnoughInputs'));
elseif nargin > 9
    error(message('MATLAB:daqread:tooManyInputs'));
end

if nargout > 5 
    error(message('MATLAB:daqread:tooManyOutputs'));
end
   


% Error if the first input is not a string.
if ~ischar(filename)
   error(message('MATLAB:daqread:invalidFilename'));
end


% Determine if an extension was given.  If not add a .daq.
[path,name,ext] = fileparts(filename);
if isempty(ext)
   filename = [filename '.daq'];
end

% Open the specified file.
fid = fopen(filename, 'r', 'ieee-le');
if fid < 3
   error(message('MATLAB:daqread:invalidFile', filename));
end

% Verify that file is DAQ file.
FileKey=fscanf(fid,'%32c',1);
% now check the file key
if ~( strcmp(FileKey,['MATLAB Data Acquisition File.' 0 25 0]))
   fclose(fid);
   error(message('MATLAB:daqread:invalidDAQFile', filename));
end

% Read in the creation time and engine time offset used for time calculations.
headersize=fread(fid, 1, 'int32');
fileVer=fread(fid, 2, 'int16'); %#ok<NASGU>
creationTime=fread(fid, 6, 'double');
engineOffset=fread(fid, 1, 'double');

% Store the headersize - 512.
pos = headersize;  
 
% Determine the size of the file.
% pos = Original position of file position indicator.
fseek(fid, 0, 1);
fsize = ftell(fid);
fseek(fid, pos, -1);

% Determine the number of samples logged, the number of blocks 
% logged and the state of the object at the end of the acquisition.
[samplesacquired,num_of_blocks,info,lastheaderloc,errorDuringRead] = localPreprocessFile(fid,fsize);
fseek(fid, pos, -1);

% If the call to localPreprocessFile failed due to the last block not being 
% written or an unknown error, initialize the lastheaderloc and num_of_blocks
% variables.
if errorDuringRead
    
    % If the flag is set it indicates that we've handled a truncated file.
    warning(message('MATLAB:daqread:truncatedFile'));

   % Calculate the number of blocks.
   if isempty(num_of_blocks)
      try
         tempinfo = readObject(fid, pos);
         num_of_blocks = ceil((1.15*(fsize/(tempinfo.ObjInfo.BufferingConfig(1)*2))+4));
      catch e
        fclose(fid);
        % Geck 188845:  An error occurred reading the file.  We used to
        % warn 'Data acquisition file is corrupted and cannot be read.'  The
        % file might be corrupt, but there are other possible reasons.
        % here's the improved error message, with
        % the read error message appended.
        error(message('MATLAB:daqread:cannotRead', e.message));
      end
   end
   % Set the amount of data to read in to the size of the file (fsize).
   if isempty(lastheaderloc)
      lastheaderloc = fsize;
   end
end
 
% Determine the block locations, types and sizes. CHART contains the fields:
% firstheader : contains the location after reading the first header.
% pos         : contains the block locations.
% type        : contains the block type where 0:header, 1:data, 2:event.
% blockSize   : contains the size of each block.
% headerSize  : contains the size of each header.
% 4 is subtracted for the end header, the object info header, the
% hardware info header, and the engine info header.
try
	chart = localReadChart(fid, pos, lastheaderloc, num_of_blocks-4);
catch e
    fclose(fid);
    % Geck 188845:  An error occurred reading the file.  We used to
    % warn "Warning: The data file is corrupted.  All the requested
    % samples may not have been read."  The file might be corrupt, but
    % there are other possible reasons.
    % here's the improved error message, with
    % the read error message appended.
    error(message('MATLAB:daqread:cannotRead', e.message));
end;   

% To move through the data:
% To get the header information - fseek(chart.firstheader+chart.pos)
% To get the data information - fseek(char.pos+chart.headerSize)

% Read and parse the initial state of the object.  If the final state of the
% object was successfully read into the variable info by localPreprocessFile,
% parse the final state of the object.  Replace the object information in
% objinfo with the final state information in out.
try
   [objinfo, sampleTimes] = localReadInfo(fid,chart,creationTime,engineOffset);
catch e
    fclose(fid);
    % Geck 188845:  An error occurred reading the file.  We used to
    % warn 'Data acquisition file is corrupted and cannot be read.'  The
    % file might be corrupt, but there are other possible reasons.
    % here's the improved error message, with
    % the read error message appended.
    error(message('MATLAB:daqread:cannotRead', e.message));
end
if ~isempty(info)
   out = localHeaderFormat(info);
   out.ObjInfo.Running = 'Off';
   out.ObjInfo.Channel = objinfo.ObjInfo.Channel;
   out.ObjInfo.EventLog = objinfo.ObjInfo.EventLog;
   out.HwInfo.NativeDataType = lower(out.HwInfo.NativeDataType);
   % special case for IOTech adaptor.  It reports a native data type of 4
   % byte real, which maps to single precision in MATLAB.
   if strcmp(out.HwInfo.NativeDataType,'real4')                           
       out.HwInfo.NativeDataType='single';                                
   end                                                                                                                                                                             
   % special case for NIDAQmx adaptor.  It reports a native data type of 8
   % byte real, which maps to double precision in MATLAB.
   if strcmp(out.HwInfo.NativeDataType,'real8')                           
       out.HwInfo.NativeDataType='double';                                
   end                                                                                                                                                                             
   objinfo = out;
end

% Determine the number of channels.
try
   num_chans = length(objinfo.ObjInfo.Channel);
catch e
    fclose(fid);
    % Geck 188845:  An error occurred reading the file.  We used to
    % warn 'Data acquisition file is corrupted and cannot be read.'  The
    % file might be corrupt, but there are other possible reasons.
    % here's the improved error message, with
    % the read error message appended.
    error(message('MATLAB:daqread:cannotRead', e.message));
end

% Initialize variables.

nanLoc = [];
storetimerange = [];
extractEvents = 0;

% Initialize variables depending on the number of input arguments.
switch nargin
case 1  % DATA = daqread(FILENAME);
   % Initialize variables.
   samples = [];
   timerange = [];
   triggers=[];
   channels = [];
   dataformat = 'double';
   timeformat = 'vector';
   outputformat = 'matrix';
case 2   % DAQINFO = daqread(FILENAME, 'info');
   % Error if an invalid second argument is passed.
   if ~strcmpi(varargin{1}, 'info')
      fclose(fid);
      error(message('MATLAB:daqread:invalidSecondArgument'));
   end
   % Read in the Object information and Event information.
   data = objinfo;
   fclose(fid);
   return;
otherwise % DATA = daqread(FILENAME,P1,V1,P2,V2,...);
   % Parse input into samples, channels, etc.
   try
       [samples,timerange,triggers,channels,dataformat,timeformat,outputformat]= ...
          localParseInput(objinfo, num_chans, samplesacquired, varargin{:});
   catch e
      % Error if an invalid property was passed.
      fclose(fid);
      rethrow(e)
   end
   
   % Determine if the event log needs to be modified because either
   % the number of samples, the number of triggers or the time
   % range was specified.
   if ~isempty(samples) || ~isempty(triggers) || ~isempty(timerange)
      extractEvents = 1;
   end
end

% Enforce the restriction that only one left hand arg is valid when
% outputformat is tscollection
if nargout ~= 1 && strncmpi(outputformat, 'tscollection', length(outputformat))
    fclose(fid);
    error(message('MATLAB:daqread:onlyDataReturned'));
end

% Enforce the restriction that outputformat==tscollection and
% timeformat=matrix are mutually exclusive
if (strncmpi(timeformat, 'matrix', length(timeformat)) && strncmpi(outputformat, 'tscollection', length(outputformat)))
    fclose(fid);
    error(message('MATLAB:daqread:noMatrixTimeWithTSC'));
end

% Depending on the number of output variables, calculate data, time,
% absolute time, events and info structure.

% Read data.
if nargout >= 0 && all(sampleTimes ~= -1)
   % Determine the number of SamplesPerTrigger (for placing NaNs).
   samplesPerTrigger = objinfo.ObjInfo.SamplesPerTrigger;
   
   % If SamplesPerTrigger is set to INF then the number of samples per
   % trigger is the number of samples acquired.
   if isinf(samplesPerTrigger) && ~isempty(samplesacquired)
      samplesPerTrigger = samplesacquired;
   end
   
   % If the samples to read in is specified in time, convert to samples.
   if ~isempty(timerange)
      sampleRate = objinfo.ObjInfo.SampleRate;
      clockSource = objinfo.ObjInfo.ClockSource;
      if ~strcmpi(clockSource, 'internal')
        warning(message('MATLAB:daqread:warnSampleRange'));
      end
      
      samples = floor(timerange*sampleRate + [1 1]);
   end
            
   % If the samples to read in is specified in triggers, convert to samples.
   if ~isempty(triggers)
      if ~isinf(samplesPerTrigger)
         if length(triggers) == 2
            samples = [samplesPerTrigger*(triggers(1)-1)+1 samplesPerTrigger*triggers(2)];
         else
            samples = [samplesPerTrigger*(triggers(1)-1)+1 samplesPerTrigger*(triggers(1))];
         end
      else
         fclose(fid);
         error(message('MATLAB:daqread:errorSampleRange'));
      end
   end
      
   % If samples is empty define it.
   if isempty(samples) && ~isempty(samplesacquired)
      samples = [1 samplesacquired];
   end
   
   % Determine if the maximum samples requested is more than the number of
   % samples available. 
   if ~isempty(samples) && ~isempty(samplesacquired)
      max_available = samplesacquired;
      if samples(2) > max_available
         samples(2) = max_available;
            warning(message('MATLAB:daqread:tooManySamples', num2str(max_available)));
      end
   end
   
   % Read the data in.
   try
      [data, nanLoc] = localReadData(fid,chart,num_chans,samples,channels,objinfo);
   catch e
       fclose(fid);
       % Geck 188845:  An error occurred reading the file.  We used to
       % warn "Warning: The data file is corrupted.  All the requested
       % samples may not have been read."  This is simply untrue, and from
       % the user's point of view, the data wasn't read in at all, since
       % the data that was read in was discarded when the error happened in
       % localReadData.
       if strcmp(e.identifier,'MATLAB:pmaxsize')
           % Special case for file too large.  This is the most common case
           % where a customer is attempting to open a file that has more
           % than 536,870,911 data points on 32 bit MATLAB.
           error(message('MATLAB:daqread:fileTooLarge'));
       else
           % In all other cases, here's the improved error message, with
           % the read error message appended.
           error(message('MATLAB:daqread:cannotRead', e.message));
       end
   end
   
   % If the SamplesPerTrigger is Inf and couldn't be calculated from
   % the data file, calculate it from the data.
   if isinf(samplesPerTrigger)
      triggerRepeat = length(nanLoc);
      samplesPerTrigger = ceil(length(data)/(triggerRepeat+1))-1;
      samples = [1 (triggerRepeat+1)*samplesPerTrigger];
   end
else
   data = [];
end
   
% Calculate time.
% Always get this info if we're returning a time series collection
if (nargout >= 2 && all(sampleTimes ~= -1)) || strncmpi(outputformat, 'tscollection', length(outputformat))
   % Need ChannelSkew, TriggerDelay and TriggerDelayUnits to calculate
   % the time matrix or vector.
   channelSkew = objinfo.ObjInfo.ChannelSkew;
   triggerDelay = objinfo.ObjInfo.TriggerDelay;
   triggerDelayUnits = objinfo.ObjInfo.TriggerDelayUnits;
   sampleRate = objinfo.ObjInfo.SampleRate;
   
   % Get the trigger times.
   ttimes = sampleTimes;
   
   % Determine which trigger occurred.
   trig = localLocateTrigger(samples, samplesPerTrigger);
   ttimes = ttimes(trig); %ttimes(trig)
   
   % ttimes may be modified based on TriggerDelay.
   if triggerDelay ~= 0
      if strcmp(triggerDelayUnits, 'Samples')
         triggerDelay = triggerDelay/sampleRate;
      else
         %round trigger delay to nearest sample
         triggerDelay = floor(triggerDelay*sampleRate+0.5)/sampleRate;
      end
      
      ttimes = ttimes + triggerDelay;
   end
   
   % The length of the vector will be the same as the length of the data.
   time = zeros(size(data,1), 1);
   
   % Initialize variables.
   startindex = 1;
   triggerNum = 1;
   starttime = ttimes(triggerNum);
   
   % Calculate the length of the first time block.
   if ~isempty(nanLoc)
      firstlength = nanLoc(1);
      endtime = starttime+((samplesPerTrigger-1)/sampleRate);
      addNaN = 1;
      starttime = starttime+((samples(1)-((trig(1)-1)*samplesPerTrigger)-1)/sampleRate);
   else
      % samples = [100 200]
      starttime = starttime+((samples(1)-((trig(1)-1)*samplesPerTrigger)-1)/sampleRate);
      firstlength = samples(2) - samples(1)+2;
      endtime = starttime+(samples(2)-samples(1))/sampleRate;
      addNaN = 0;
   end
   
   % Fill in the first time block.
   time(startindex:firstlength-1) = starttime:(1/sampleRate):endtime;
   if addNaN
      time(firstlength) = NaN;
   end
   startindex = firstlength+1;
   triggerNum = triggerNum+1;
   
   % Fill in the middle time blocks.
   for i = 2:length(ttimes)-1
      starttime = ttimes(triggerNum);
      time(startindex:startindex+samplesPerTrigger-1) = starttime:1/sampleRate:...
         starttime+((samplesPerTrigger-1)/sampleRate);
      time(startindex+samplesPerTrigger) = NaN;
      startindex = startindex+samplesPerTrigger+1;
      triggerNum = triggerNum+1;
   end
   
   % Fill in the last time block.
   if length(ttimes) > 1
      starttime = ttimes(triggerNum);
      lastlength = length(time) - startindex + 1;
      time(startindex:startindex+lastlength - 1) = starttime:1/sampleRate:...
         starttime+((lastlength-1)/sampleRate);
      if (startindex+lastlength-1 == nanLoc(end))
         time(startindex+lastlength-1) = NaN;
      end
   end
      
   % If TimeFormat is set to 'matrix', calculate time matrix using ChannelSkew.
   if strncmpi(timeformat, 'matrix', length(timeformat))
      t1 = time; 
      time = zeros(length(t1), num_chans);
      time(:,1) = t1;
      for i = 2:num_chans
         time(:,i) = t1+(channelSkew*(i-1));
      end
   end
else
   time = [];
end

% Calculate absolute time zero.
% Always get this info if we're returning a time series collection
if nargout >= 3 || strncmpi(outputformat, 'tscollection', length(outputformat))
   abstime = objinfo.ObjInfo.InitialTriggerTime;
end

% Return just the event information.
% Always get this info if we're returning a time series collection
if nargout >= 4 || strncmpi(outputformat, 'tscollection', length(outputformat))
   if extractEvents
      eventinfo = localExtractEvents(objinfo.ObjInfo,samples,triggers,storetimerange);
   else
      eventinfo = objinfo.ObjInfo.EventLog;
   end
end

% Return object information.
if nargout == 5
   daqinfo = objinfo;
end

% Convert the data to double if specified.
if strncmpi(dataformat, 'double', length(dataformat))
   try
      if ~isempty(data)
         data = localConvertDataDouble(data, objinfo, channels);
      end
   catch e
       warnstate = warning('on','daq:daqread:dataconversion');
       warning(message('MATLAB:daqread:dataConversion'));
       warning(warnstate);
      fclose(fid);
      return;
   end
   if ~isempty(nanLoc)
      data(nanLoc,:) = NaN;
   end
end

% Close the file.
fclose(fid);

% Render the output as a time series collection if the customer requests it
if strncmpi(outputformat, 'tscollection', length(outputformat))
    % Generate a cell array of the various units from each channel
    if isempty(channels)
        channelList = 1:length(objinfo.ObjInfo.Channel);
    else
        channelList = channels;
    end
    infotopass.samplerate = objinfo.ObjInfo.SampleRate;
    %Preallocate for performance
    cChannel = length(channelList);
    infotopass.channelnames = cell(cChannel,1);
    infotopass.hwids = zeros(cChannel,1);
    infotopass.channelunits = cell(cChannel,1);
    for iChannel = 1:cChannel
        infotopass.channelnames{iChannel} = objinfo.ObjInfo.Channel(channelList(iChannel)).ChannelName;
        infotopass.hwids(iChannel) = objinfo.ObjInfo.Channel(channelList(iChannel)).HwChannel;  
        if strncmpi(dataformat, 'double', length(dataformat))
            % if the customer asks for 'double' data, set the data units to
            % whatever is set in the object (like 'Volts).
            infotopass.channelunits{iChannel} = objinfo.ObjInfo.Channel(channelList(iChannel)).Units;
        else
            % if the customer asks for 'native' data, set the data units to
            % 'native'
            infotopass.channelunits{iChannel} = 'native';
        end
    end
    % We use time(:,1) in case the user set timeformat to matrix
    data = privateCreateTimeSeriesCollection(infotopass,data,time(:,1),abstime,eventinfo);
end

% ***************************************************************
% Determine the number of samples logged, the number of blocks 
% logged and the state of the object at the end of the acquisition.
function [samplesacquired,num_of_blocks,info,lastheaderloc,flag] = localPreprocessFile(fid,fsize)

% Initialize variables.
flag = 0;

try
   % Read the end block to determine the number of samples acquired and
   % where the end object is stored.
   fseek(fid, fsize-16, -1);
   samplesacquired = fread(fid,1,'int64');
   lastheaderloc = fread(fid, 1, 'int64');

   % Position file indicator to the location of the last header information.
   fseek(fid, lastheaderloc, -1);
   pos = ftell(fid);

   %preallocate info blocks for performance
   numberofblocks  = 3;
   info(numberofblocks).blocksize = 0;
   info(numberofblocks).blocktype = 0;
   info(numberofblocks).headersize = 0;
   info(numberofblocks).number = 0;
   info(numberofblocks).hdr.typestr = 0;
   info(numberofblocks).data = '';
   
   % Loop through and get the object information, hardware information and
   % engine information.
   for i = 1:numberofblocks
      info(i).blocksize=fread(fid,1,'int32');
      info(i).blocktype=fread(fid,1,'int32');
      info(i).headersize=fread(fid,1,'int32');
      info(i).number=fread(fid,1,'uint32');
      info(i).hdr.typestr=fscanf(fid,'%16c',1);
      fseek(fid,pos+info(i).headersize,-1);
      info(i).data=fscanf(fid,['%' int2str(info(i).blocksize-info(i).headersize) 'c'],1);
      fseek(fid,pos+info(i).blocksize,-1);
      pos=ftell(fid);
   end

   % The number of blocks equals the number of the last entry in the last 
   % header plus the end block.
   num_of_blocks = info(3).number+1;
catch e
   % Reset all variables since they are most likely corrupted if an error
   % occurred somewhere while reading them.  Set the flag and return.
   samplesacquired = [];
   num_of_blocks = [];
   info = [];
   lastheaderloc = [];
   flag = 1;
   return
end
   
% ***************************************************************
% Determine the location and types of the blocks.
function temp = localReadChart(fid, pos, fsize, blocks)

% firstheader : contains the location after reading the first header.
% pos         : contains the block locations.
% type        : contains the block type where 0 - header, 1 - data
%               and 2 - event information.
% blockSize   : contains the size of each block.
% headerSize  : contains the size of each header.

% Initialize variables.
temp.pos = -ones(1,blocks);
temp.blockSize = -ones(1,blocks);
temp.type = -ones(1,blocks);
temp.headerSize = -ones(1,blocks);

% Read in the first block and the firstheader (which only has to be done once).
temp.pos(1) = pos;
temp.blockSize(1) = fread(fid,1,'int32');
temp.type(1) = fread(fid,1,'int32');
temp.headerSize(1) = fread(fid,1,'int32');
temp.number(1) = fread(fid,1,'uint32');
temp.firstheader = ftell(fid) - pos;

% Adjust the file position indicator by the blocksize.
fseek(fid, pos+temp.blockSize(1), -1);
   
% Get the new file position which is pos+info.blocksize.
pos = ftell(fid);

% Create a counter.
k = 2;

% Loop through and get the blocksize, headersize and type information.
while (pos<fsize)
   temp.pos(k) = pos;
   temp.blockSize(k) = fread(fid,1,'int32');
   
   % If the blocksize is not greater than zero, which could happen if we
   % have a truncated file, get out now.
   if (temp.blockSize(k) <= 0)
       break;
   end
   
   temp.type(k) = fread(fid,1,'int32');
   temp.headerSize(k) = fread(fid,1,'int32');

   % Adjust the file position indicator by the blocksize.
   status = fseek(fid, pos+temp.blockSize(k), -1);
   
   % If there was a problem with the fseek, which could happen if we have a
   % truncated file, get out now.
   if (status ~= 0)
       break;
   end
   
   % Get the new file position which is pos+temp.blocksize.
   pos = ftell(fid);
   
   % Determine if more space is needed to store the file information.
   % If so, increase it by twenty-five percent.
   if k > blocks
      add_blocks = ceil(.25*(blocks));
      temp.pos = [temp.pos -ones(1,add_blocks)];
      temp.blockSize = [temp.blockSize -ones(1,add_blocks)];
      temp.type = [temp.type -ones(1,add_blocks)];
      temp.headerSize = [temp.headerSize -ones(1,add_blocks)];
      blocks = blocks + add_blocks;
   end
   % Increment the counter.
   k=k+1;
end

%*********************************************************************
% Determine which triggers occurred.
function trig = localLocateTrigger(samples,samplesPerTrigger)

% Find the trigger values.
tloc = ceil(samples(1)/samplesPerTrigger)*samplesPerTrigger:samplesPerTrigger:samples(2);

% If tloc is empty than a single trigger occurred - samples = [100 200];
if isempty(tloc)
   trig = ceil(samples(1)/samplesPerTrigger);
   return;
end

% Determine if the trigger before tloc is needed - samples = [1000 2000];
if samples(1)<=tloc(1)
   tloc = [tloc(1)-samplesPerTrigger tloc];
end

% If last sample is the last value of the data matrix remove the extra
% trigger from tloc - samples = [1 4096];
if samples(2) == tloc(end)
   tloc = tloc(1:end-1);
end

% Determine the trigger number: [0 1024 2048] ==> [1 2 3]
trig = (tloc/samplesPerTrigger) + 1;

%*********************************************************************
% Read the data information.
function [data, nanLoc] = localReadData(fid,chart,num_chans,samples,channels,info)

% Initialize variables.
flag = 0;
startloc = 1;
nanLoc = [];
samplesPerTrigger = info.ObjInfo.SamplesPerTrigger;
engineBlockSize = info.ObjInfo.BufferingConfig(1);
datatype = info.HwInfo.NativeDataType;

% Data information has a type of 1.
data_loc = find(chart.type == 1);
data_pos = chart.pos(data_loc);
data_block = chart.blockSize(data_loc);
data_header = chart.headerSize(data_loc);

% Create a matrix of NaNs the size of the data matrix to be returned.
if ~isempty(channels)
   numcols = length(channels);
else
   numcols = num_chans;
end

% Determine the number of triggers for the supplied samples range.
if ~isempty(samples)
   tloc = ceil(samples(1)/samplesPerTrigger)*samplesPerTrigger:samplesPerTrigger:samples(2);
   num_trig = length(tloc);
   % Add in the number of triggers (TriggerRepeat+1) to the number of rows.
   if num_trig == 0
      numrows = samples(2)-samples(1)+1;
   else
      numrows = samples(2)-samples(1)-1+num_trig+1;
   end
else
   % The number of samples could not be determined from the data file
   % (either SamplesPerTrigger or TriggerRepeat was inf and was not 
   % supplied as input).
   numrows = ceil((engineBlockSize/num_chans)*length(data_loc));
end

% Initialize data.
data = repmat(feval(lower(datatype), 0),numrows, numcols); 
infost=whos('data');
sizebytes=infost.bytes/(numrows*numcols);

% Determine the datattype to use when reading in the block of information.
datatype = ['*' lower(datatype)];

% Create a counter for the samples to read in.
countsamples = samples;

startlocation = chart.firstheader;
% Build up the data array.  
for i = 1:length(data_pos)
   % To get the header information - fseek(startlocation+chart.pos)
   loc=ftell(fid);   
   newpos=startlocation+data_pos(i);
   % Geck 332171: FREAD is much higher performance than FSEEK when doing
   % short, forward moves in the file.
   if ((newpos-loc) >0 && (newpos-loc)<1000) 
        fread(fid,newpos-loc,'*int8');
   else
        fseek(fid,newpos-loc,0);
   end
   currentinfo.starttime=fread(fid,1,'double');
   currentinfo.endtime=fread(fid,1,'double');
   currentinfo.startsample=fread(fid,1,'int64');
   currentinfo.intrigger=fread(fid,1,'int32');
   currentinfo.flags=fread(fid,1,'uint32');
   
   % Position the file indicator and determine the number of points to read.
   fseek(fid, data_pos(i)+data_header(i), -1);
   num_points = ((data_block(i)-data_header(i))/sizebytes)/num_chans;
   
   % Determine if the data block needs to be read in or if the for loop
   % should be incremented to the next data block.
   if isempty(samples)
      readblock = 1;
   elseif currentinfo.startsample + 1 + num_points <= samples(1) &&...
         ~(currentinfo.startsample == 0 && num_points >= samples(1))
      readblock = 0;
      countsamples = countsamples - num_points;
   else
      readblock = 1;
   end
   
   if readblock
      % Read the data block.
      block = fread(fid, [num_chans num_points], datatype);
      block = block';
      
      % Extract the requested channels.
      if ~isempty(channels)
         block = block(:, channels);
      end
      
      if ~isempty(samples)
         % Extract the samples from block.
         mins = countsamples(1);
         maxs = countsamples(2);
         if num_points >= maxs
            % If the maximum samples to get is less than the number
            % of samples in the block, extract the samples and return.
            % Ex. samples = [1 100]; blocksize = 200;
            block = block(mins:maxs,:);
            flag = 1;
         elseif num_points >= mins
            % If the number of samples in the block is greater than the
            % lower sample range, extract from the lower sample range to
            % the number of samples in the block.
            % Ex. range = [400 1000]; blocksize = 600;
            block = block(mins:num_points,:);
            % countsamples is reset to range from 1 to the remainder.
            countsamples = [1 maxs-size(block,1)-mins+1];
            if samples(2) == 0
               flag = 1;
            end
         else
            % Extract no samples and readjust the samples range by the blocksize.
            % Ex. range = [400 1000]; blocksize = 200;
            countsamples = [mins-size(block,1) maxs-size(block,1)];

            block = [];
         end
      end
      % Determine the number of rows in the data.
      blocksize = size(block,1);
      
      % Concatenate the block into the data matrix.
      if ~isempty(block)
        %  if num_trig>1 %Special case for IOTech: We should never be adding
            % NaN unless we have multiple triggers. The problem seems to be
            % when we wrote this file we put flag=7 and this is forcing
            % mod(flag,2)==1 on all reads of blocks above 1.
            if i > 1 && mod(currentinfo.flags,2)== 1 && startloc ~= 1
                data(startloc,:) = NaN;
                nanLoc = [nanLoc startloc]; %#ok<AGROW>
                startloc = startloc + 1;
         
            end
         data(startloc:startloc+blocksize-1,:) = block(1:blocksize,:);
         startloc = startloc+blocksize;
      end
      
      % Return if all the samples requested has been read.
      if flag
         return;
      end
      if i == length(data_pos) && isempty(samples)
         data = data(1:startloc-1,:);
      end
   end
end

%*********************************************************************
% Convert the data to double with engineering units.
function data = localConvertDataDouble(data, info, channels)

% Initialize variables.
data = double(data);
if isempty(channels),
    channels=1:size(data,2);
end

% Need to loop through each column of data which represents one channel.
for i = 1:size(data,2)
   slope = info.ObjInfo.Channel(channels(i)).NativeScaling;
   intercept = info.ObjInfo.Channel(channels(i)).NativeOffset;

   % Convert the data.
   data(:,i) = slope*data(:,i) + intercept;
end

%*********************************************************************
% Read the headers and event information.
function [out1, ttimes] = localReadInfo(fid,chart,creationTime,engineOffset)

% Read the header information - Header information has a type of 0. 
header_loc = find(chart.type == 0);
header_pos = chart.pos(header_loc);
header_block = chart.blockSize(header_loc);
header_header = chart.headerSize(header_loc);
startlocation = chart.firstheader;

% Index 1: Object information.
% Index 2: Hardware information.
% Index 3: Engine information.
% Remaining headers are the number of channels.

% Preallocate hinfo for performance
hinfo(length(header_loc)).hdr.typestr = [];
hinfo(length(header_loc)).data = [];

for i = 1:length(header_loc)
   fseek(fid, header_pos(i)+startlocation, -1);
   hinfo(i).hdr.typestr = fscanf(fid, '%16c', 1);
   % Move the file position indicator by the size of the header.
   fseek(fid, header_pos(i)+header_header(i), -1);
   % Read in the property information.  
   % size of property information =  blocksize - headersize.
   hinfo(i).data = fscanf(fid, ['%' int2str(header_block(i)-header_header(i)) 'c'],1);
end

% Read the event information - Event information has a type of 2. 
event_loc = find(chart.type == 2);
event_pos = chart.pos(event_loc);
event_block = chart.blockSize(event_loc); %#ok<NASGU>
event_header = chart.headerSize(event_loc);

% Initialize einfo
einfo.hdr.entries = [];
einfo.data = [];

for j = 1:length(event_pos)
   % Adjust the file position indicator.
   fseek(fid, event_pos(j)+startlocation, -1);
   % Read the number of events logged.
   einfo.hdr.entries(j) = fread(fid,1,'int32');
   
   % Adjust the file position indicator by the size of the header.
   fseek(fid,event_pos(j)+event_header(j),-1);
   
   % Loop through the events.
   for i = 1:einfo.hdr.entries(j)
      k = length(einfo.data);
      einfo.data(k+1).timestamp = fread(fid,1,'double');
      einfo.data(k+1).samplestamp = fread(fid,1,'int64');
      einfo.data(k+1).logtype = fread(fid,1,'int16');
      einfo.data(k+1).entrysize = fread(fid,1,'int16');
      %block alignment issue.
      fread(fid, 1, 'int32');
      einfo.data(k+1).string=fscanf(fid,['%' int2str(einfo.data(k+1).entrysize-24) 'c'],1);
   end
end

% Convert the header information and event information to output format.
out1 = localHeaderFormat(hinfo);
eventinfo = localEventFormat(einfo,creationTime,engineOffset);

% Add the eventinfo information to the EventLog field.
out1.ObjInfo.EventLog = eventinfo;

% Determine the triggertimes from the event information and add to output.
[ttimes] = localFindTriggerTime(eventinfo,out1.ObjInfo.SampleRate);

%*********************************************************************
% Convert the header structure into the correct output format.
function out = localHeaderFormat(header)

% Index 1: Object information.
% Index 2: Hardware information.
% Index 3: Engine information.
% Remaining headers are the number of channels.
for i = 1:length(header)
   header(i).data = strrep(header(i).data, '1.#INF', 'inf');

   % EVAL statement produces a structure called 'x'.
   x = [];
      
   try
      eval(header(i).data);
   catch e %#ok<NASGU>
      % Try to recover if one of the string properties contains a
      % carriage return.       
      tempHeader = localCheckQuote(header(i).data);
      eval(tempHeader);
   end
   
   % Depending on where we get the header from the type is stored differently.
   if isfield(header,'hdr')
       typestr = header(i).hdr.typestr;
   elseif (isfield(header, 'typestr'))
       typestr = header(i).typestr;
   else
        error(message('MATLAB:daqread:noRecordType'));
   end
   
   typestr(typestr == 0) = ' '; % convert all zeros (nulls) to blanks
   switch deblank(typestr)
   case {'Analog Input','AnalogInput'} 
      out.ObjInfo = x;
      
      % Add an empty EventLog field if it didn't exist in the file.
      if ~isfield(out.ObjInfo, 'EventLog')
          out.ObjInfo.EventLog = [];
          
          % Sort the field alphabetically.
          names = lower(fieldnames(out.ObjInfo));
          [names,perm] = sort(names);
          out.ObjInfo = orderfields(out.ObjInfo,perm);
      end
   case 'DaqHwInfo'
      out.HwInfo = x;
   case 'Channel'
      % Newer versions of the log file don't have Parent.
      if isfield(x, 'Parent')
          x = rmfield(x, 'Parent');
      end
      Channel(i-3) = x; %#ok<AGROW>
   end
end

% Add the Channel information to the Channel field.
if length(header) > 3
   out.ObjInfo.Channel = Channel;
end

% *********************************************************************
% Convert the event structure into the correct output format.
function out = localEventFormat(event,creationTime,engineOffset)

%Preallocate for performance
out(length(event.data)).Type = [];

% Create the event structure.
for i = 1:length(event.data)
   % Initialize variables.
   x = [];
   
   % Depending on the logtype, set the Type field of the event
   % structure.  eval is called if the event has additional
   % fields (other than TimeStamp and SampleStamp).
   switch event.data(i).logtype
   case 0
      out(i).Type = 'Start';
      out(i).Data.AbsTime = localEventTime(event.data(i).timestamp, creationTime, engineOffset);
   case 1
      out(i).Type = 'Stop';
      out(i).Data.AbsTime = localEventTime(event.data(i).timestamp, creationTime, engineOffset);
   case 2
      out(i).Type = 'Trigger';
      out(i).Data.AbsTime = localEventTime(event.data(i).timestamp, creationTime, engineOffset);
      eval(event.data(i).string);
   case 3
      out(i).Type = 'RunTimeError';
      out(i).Data.AbsTime = localEventTime(event.data(i).timestamp, creationTime, engineOffset);
      x = event.data(i).string;
   case 4
      out(i).Type = 'Overrange';
      eval(event.data(i).string);
   case 5
      out(i).Type = 'DataMissed';
   case 6
      out(i).Type = 'SamplesAcquired';
   end
   
   % Set the RelSample field (every event has at least this field).
   out(i).Data.RelSample = event.data(i).samplestamp;
   
   % The Trigger, RunTimeError and Overrange events have additional
   % fields for the event structure.  Create them here.
   switch event.data(i).logtype
   case 2  % Trigger.
      if ~isempty(x)
         if x.Channel == -1
            x.Channel = [];
         end
         out(i).Data.Channel = x.Channel;
         out(i).Data.Trigger = x.Trigger;
      end
   case 3  % RunTimeError.
      if ~isempty(x)
         out(i).Data.String = x;
      end
   case 4  % Overrange.
      if ~isempty(x)
         out(i).Data.Channel = x.Channel;
         out(i).Data.Overrange = x.Overrange;
      end
   end
end

% *********************************************************************
% Convert the seconds logged to a clock.
function time = localEventTime(sec, creationTime, engineOffset)

% Store the fractional part of sec to add in later.
temp = floor(sec);
dif = sec - temp;
sec = temp;

% Take fractional part off of engineOffset.
engineOffset = floor(engineOffset);

% Subtract the engine offset from the event time.
time = sec - engineOffset;

% Remove the fractional part of the seconds from CreationTime.
creationTime(6) = floor(creationTime(6));

% Convert both time and creationTime to datenums.
creationTime = num2cell(creationTime);
creationTime = datenum(creationTime{:});
time = time/86400;

% Add two together and convert back to clock.
time = time + creationTime;
[y,m,d,h,mi,s] = datevec(time);
s = s+dif;

time = [y,m,d,h,mi,s];

%*********************************************************************
% Read the object header information only.  This is needed if the last
% data block was not logged to the file (e.g. the file was truncated).
function out1 = readObject(fid, pos)

% We will need to return the file to the current position to allow the
% caller to continue processing.
currentPos = ftell(fid);
i = 1;

% We are currently positioned at the first header. Read and store all of
% the headers, stopping when we encounter a record that is not a header.
while (1)
    % Have to get to the type field to see if we're still int he header.
    % We read the data, but don't store it yet in the header holder.
    blockSize = fread(fid,1,'int32');
    type = fread(fid,1,'int32');

    % The records we are interested in at the beginning of the file are all
    % of type 0 and are written contiguously. Get out when encountering the
    % first non-header record.
    % Type stands for: 0:header, 1:data, 2:event. 
    if (type ~= 0)
        break;
    end

    % Yes, it's a header so store the data read so far and keep reading.
    temp(i).pos = pos; %#ok<AGROW>
    temp(i).blockSize = blockSize; %#ok<AGROW>
    temp(i).type = type; %#ok<AGROW>

    temp(i).headerSize = fread(fid,1,'int32'); %#ok<AGROW>
    temp(i).number = fread(fid,1,'uint32'); %#ok<AGROW>
    temp(i).typestr = fscanf(fid, '%16c',1); %#ok<AGROW>
    
    % Only save the firstheader position once.
    if ~isfield(temp, 'firstheader')
        temp.firstheader = ftell(fid);
    end

    temp(i).data=fscanf(fid,['%' int2str(temp(i).blockSize-temp(i).headerSize) 'c'],1); %#ok<AGROW>
    pos=ftell(fid);
    i = i + 1;
end

% Convert the data to the output structure.
out1 = localHeaderFormat(temp);

% Put the file back to where it was because the caller is expecting that.
fseek(fid, currentPos, 'bof');

%*********************************************************************
% Determine the trigger times from the event information.
function [ttimes] = localFindTriggerTime(events,sampleRate)

% If a trigger event did not occur, want to return the object information
% but no data.
try
   triggerindex = find(strcmp('Trigger', {events(:).Type}));
   temp = {events(triggerindex).Data}; %#ok<FNDSB>
   temp = [temp{:}];
   out = [temp.RelSample];  
   
   % ttimes is used to calculate the time vector.   
   ttimes = out/sampleRate;
catch e %#ok<NASGU>
  % out = [];
   ttimes = -1;
end
   
%*********************************************************************
% Determine the trigger times from the event information.
function out = localExtractEvents(objinfo,samples,triggers,timerange)

% Initialize variables.
events = objinfo.EventLog;
samplesPerTrigger = objinfo.SamplesPerTrigger;

% If SamplesPerTrigger is set to INF then the number of samples per
% trigger is the number of samples acquired.
if isinf(samplesPerTrigger)
   samplesPerTrigger = objinfo.SamplesAcquired;
end

% If the original call to daqread was in terms of samples, convert
% samples to triggers.
if isempty(triggers) && isempty(timerange)
   % SamplesPerTrigger = 1000. samples = [1000 4000];  triggers = [2 5];

   % Calculate the first trigger.
   if samples(1) == 1
      triggers(1) = 1;
   else
      triggers(1) = ceil(samples(1)/samplesPerTrigger);
   end

   % Calculate the second trigger.
   triggers(2) = ceil(samples(2)/samplesPerTrigger);
end

% Extract the correct event information either in terms of triggers
% or in terms of time.
if isempty(triggers)
   % Data was specified in terms of time.
   
   % Preallocate for performance
   eventtimes = zeros(length(events),1);
   % Extract all the event times.
   for i = 1:length(events)
      eventtimes(i) = events(i).Data.TimeStamp;
   end
   
   % Find the location of the first time.
   index = find(timerange(1) > eventtimes);
   if isempty(index)
      value(1) = 1;
   else
      value(1) = index(end)+ 1;
   end

   % Find the location of the second time.
   index = find(timerange(2) < eventtimes);
   if isempty(index)
      value(2) = length(events);
   else
      value(2) = index(1)-1;
   end

   % Extract only those events for the specified times.
   out = events(value(1):value(2));
else
   % Data was specified in either triggers or samples.  But samples
   % has been converted to triggers.  Triggers will be used.
   
   % Determine the location of the trigger events.
   trigloc = find(strcmp('Trigger', {events.Type}));

   % Extract the trigger events and any other events that may have occurred 
   % in between triggers.
   trigevent = events(min(trigloc):max(trigloc));

   % Determine the new location of the trigger events in the structure.
   newtrigloc = find(strcmp('Trigger', {trigevent.Type}));
   if isempty(newtrigloc)
      % This would happen if no triggers ever arrived. For example if
      % TriggerType was set to manual but the trigger command was never
      % issued.
      out = [];
      return
   end
   
   % Create a temp event structure which contains only the information
   % requested.
   if length(triggers) == 1
      % In case Triggers was defined as 2.
      out =  trigevent(newtrigloc(triggers(1)));
   else
      out =  trigevent(newtrigloc(triggers(1)):newtrigloc(triggers(2)));
   end
end
   
% *********************************************************************
% Parse the input to determine the PV pairs specified.
function [samp,timer,trigger,chan,dataf,timef,outputf]=localParseInput(objinfo,num_chans,samplesacquired,varargin)

% Initialize variables.
pv = varargin;
samp = [];
timer = [];
trigger = [];
chan = [];
dataf = 'double';
timef = 'vector';
outputf = 'matrix';

% Error if invalid PV pairs were passed.
if rem(length(pv), 2) ~= 0
   error(message('MATLAB:daqread:invalidPropertyValuePair'));
end

% Determine what properties were specified and it's value.
for i = 1:2:length(pv)
   if strncmpi(pv{i}, 'samples', length(pv{i}))
      samp = pv{i+1};
      if iscell(samp)
         if strcmp(samp{2}, 'end') && ~isempty(samplesacquired)
            temp(1) = samp{1};
            temp(2) = samplesacquired;
            samp=temp;
         else
            error(message('MATLAB:daqread:invalidSamplesRange'));
         end
      end
      % Error if the samples specified is negative or is not a range.
      index = find(samp <= 0,1);
      if ~isempty(index) 
         error(message('MATLAB:daqread:invalidSamplesRange'));
      elseif ~(length(samp) == 2 && min(size(samp)) == 1 && samp(2) > samp(1))
         error(message('MATLAB:daqread:invalidSamplesTwoElementRange'));
      elseif any(round(samp) ~= samp)
         error(message('MATLAB:daqread:invalidSamplesInt'));
      elseif ~isempty(timer) 
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Time', 'Samples'));
     elseif ~isempty(trigger) 
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Triggers', 'Samples'));
      end
   elseif strncmpi(pv{i}, 'time', length(pv{i}))
      timer = pv{i+1};
      % Error if the Time specified is negative or is not a range.
      if ~(length(timer) == 2 && min(size(timer)) == 1 && timer(2) > timer(1))
         error(message('MATLAB:daqread:timeTwoElement'));
      elseif timer < 0
         error(message('MATLAB:daqread:timePositive'));
      elseif ~isempty(samp) 
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Samples', 'Time'));
      elseif ~isempty(trigger)
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Triggers', 'Time'));
      end
   elseif strncmpi(pv{i}, 'triggers', length(pv{i}))
      trigger = pv{i+1};
      % Error if the triggers specified is negative.
      if min(trigger) < 1  
         error(message('MATLAB:daqread:invalidTriggerIndex', num2str(min(trigger))));
      elseif ~(~isempty(trigger == 1) || length(trigger) == 2)
         error(message('MATLAB:daqread:invalidTrigger'));
      elseif length(trigger) == 2
         if ~(min(size(trigger)) == 1 && trigger(2) > trigger(1))
            error(message('MATLAB:daqread:invalidTrigger'));
         end
      elseif any(round(trigger) ~= trigger)
         error(message('MATLAB:daqread:triggerInt'));
      elseif ~isempty(samp) 
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Samples', 'Triggers'));
      elseif ~isempty(timer)
         error(message('MATLAB:daqread:mutuallyExclusiveProperties', 'Time', 'Triggers'));
      end
   elseif strncmpi(pv{i}, 'channels', length(pv{i}))
      chan = pv{i+1};
      % Error if the channels specified is less than 1 or greater than
      % the number of channels logged.
      if iscell(chan)
         index = localFindChannel(objinfo, chan);
         if length(index) ~= length(chan)
            error(message('MATLAB:daqread:invalidChannelName'));
         else
            chan = index;
         end
      end
      if min(chan) < 1  
         error(message('MATLAB:daqread:invalidChannelsIndex', num2str(min(chan))));
      elseif max(chan) > num_chans
         error(message('MATLAB:daqread:invalidChannelsIndexMax', ...
             num2str(max(chan)),...
             num2str(num_chans)));
      elseif any(round(chan) ~= chan)
         error(message('MATLAB:daqread:invalidChannelsInt'));
      end
   elseif strncmpi(pv{i}, 'dataformat', length(pv{i}))
      dataf = pv{i+1};
      % Error if an invalid DataFormat is specified.
      if ~(strncmpi(dataf, 'double', length(dataf)) || ...
            strncmpi(dataf, 'native', length(dataf)))
            error(message('MATLAB:daqread:invalidDataFormat', dataf));
      end
   elseif strncmpi(pv{i}, 'timeformat', length(pv{i}))
      timef = pv{i+1};
      % Error if an invalid TimeFormat is specified.
      if ~(strncmpi(timef, 'vector', length(timef)) || ...
            strncmpi(timef, 'matrix', length(timef)))
            error(message('MATLAB:daqread:invalidTimeFormat', timef));
      end
   elseif strncmpi(pv{i}, 'outputformat', length(pv{i}))
      outputf = pv{i+1};
      % Error if an invalid OutputFormat is specified.
      if ~(strncmpi(outputf, 'matrix', length(outputf)) || ...
            strncmpi(outputf, 'tscollection', length(outputf)))
            error(message('MATLAB:daqread:invalidOutputFormat', outputf));
      end
   else
      % Error if an invalid property is specified.
        error(message('MATLAB:daqread:invalidProperty', pv{i}));
   end
end

% *********************************************************************
% Convert the channelnames to channel indices.
function temp = localFindChannel(objinfo, name)

% Get all the Channel Names and indices.
channelnames = {objinfo.ObjInfo.Channel.ChannelName};
index = {objinfo.ObjInfo.Channel.Index};
temp = [];

% Loop through and determine if the specified name equals one
% of the channelnames.
for i = 1:length(name)
   i2 = find(strcmp(name{i}, channelnames));
   if ~isempty(i2)
      temp = [temp index{i2}]; %#ok<AGROW>
   end
end

% *********************************************************************
% If the string cannot be evaluated check if the correct number of quotes
% have been used.
function str = localCheckQuote(str)

% Find the single quote and semi-colon locations.
quoteLoc = strfind(str, '''');
semiLoc = strfind(str, ';x.');

% Loop through to verify that there are an even number of quotes
% before each ';x.'.  If that is not the case, add a single quote
% before the 'x; and after the ';'.  If a single quote is added,
% the locations of single quotes and ';x.' will have to be recalculated.
for i = 1:length(semiLoc)
   index = find(quoteLoc<semiLoc(i));
   if mod(length(index),2) ~= 0
      str = [str(1:semiLoc(i)-1) '''' str(semiLoc(i):end)];
      quoteLoc = strfind(str, '''');
      semiLoc = strfind(str, ';');
      i = i-1; %#ok<FXSET>
   end      
end



   
