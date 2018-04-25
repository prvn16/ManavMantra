function [outputData, timestamps, channelInfo] = thingSpeakRead( channelID, varargin )
%THINGSPEAKREAD Read data stored in a ThingSpeak channel.
%
%   Syntax
%   ------
%   data = thingSpeakRead(channelID)
%   [data,timestamps,channelInfo] = thingSpeakRead(__)
%   [__] = thingSpeakRead(__,Name,Value)
%
%   Description
%   ------------
%   data = thingSpeakRead(channelID) reads the most recent data from
%   all fields of the specified public channel on ThingSpeak.com.
%
%   [data,timestamps,channelInfo] = thingSpeakRead(__) reads the
%   most recent data from all fields of the specified channel on
%   ThingSpeak.com, including the timestamp, channel information, and
%   url information.
%
%   The structure of the channel information is:
%                ChannelID: 12397
%                     Name: 'WeatherStation'
%              Description: 'MathWorks Weather Station, West Garage, Natick, MA 01760, USA'
%                 Latitude: 42.2997
%                Longitude: -71.3505
%                 Altitude: 60
%                  Created: [1x1 datetime]
%                  Updated: [1x1 datetime]
%                LastEntry: 188212
%        FieldDescriptions: {1x8 cell}
%                 FieldIDs: [1 2 3 4 5 6 7 8]
%                      URL: 'http://api.thingspeak.com/channels/12397/feed.json?'
%
%   [__] = thingSpeakRead(__,Name,Value) specifies additional options with
%   one or more NAME,VALUE pair arguments, using any of the previous
%   syntaxes.  The name-value pair arguments that you can specify allow you
%   to specify a URL for a private ThingSpeak server installation (1),
%   control the number of points retrieved in various ways, and are
%   described in full below.
%
%   Input Arguments
%   ---------------
%
%   Name         Description                             Data Type
%   ----    --------------------                         ---------
%   channelID
%           Channel identification number.               positive integer
%
%   Name-Value Pair Arguments
%   -------------------------
%
%   Name         Description                             Data Type
%   ----    --------------------                         ---------
%
%   DateRange
%           A start and end date range of the data       1x2 array of datetime
%           to be retrieved.  The number of points
%           returned is always limited to a maximum of
%           8000 by the ThingSpeak.com server.  If you
%           hit the limit you may need to adjust your
%           ranges and make multiple calls, as needed.
%
%           DateRange cannot be used with:
%           - NumDays
%           - NumMinutes
%
%   Fields
%           Field IDs to retrieve data from in a        1x8 positive integer/s
%           channel. You can specify up to 8 fields to
%           read data from.
%
%   Location                                             logical
%           Specify TRUE (1) to return Latitude,
%           Longitude and Altitude data from the
%           channel.  Default is FALSE (0). If,
%           TRUE, then latitude, longitude and
%           Altitude are returned as the last three
%           columns of the returned data.
%
%   NumDays
%           Number of 24 hour periods to retrieve from   positive integer
%           the present time. The number of points
%           returned is always limited to a maximum
%           of 8000 by the ThingSpeak.com server
%           and therefore if you hit the limit you may
%           wish to use DateRange instead.
%
%           NumDays cannot be used with:
%           - NumMinutes
%           - DateRange
%
%   NumMinutes
%           Number of minutes from the present time to   positive integer
%           retrieve data from. The number of points
%           returned is always limited to a maximum of
%           8000 by the ThingSpeak.com server and
%           therefore if you hit the limit you may wish
%           to use DateRange instead.
%
%           NumMinutes cannot be used with:
%           - NumDays
%           - DateRange
%
%   NumPoints
%           Number of data points to retrieve           positive integer
%           from the present moment. The number of
%           points returned is limited to a maximum
%           of 8000 by the ThingSpeak.com server.
%
%           NumPoints cannot be used with:
%           - DateRange
%           - NumDays
%           - NumMinutes
%
%   OutputFormat
%           Specify the class of the output data.        string
%           Valid values are: 'matrix' or 'table'
%           or 'timetable'.
%           If 'table' or 'timetable' is chosen,
%           the right hand side outputs become:
%           [ table, channelInfo ]
%           The table will contain the timestamps and
%           the data from the fields. If OutputFormat is
%           not specified, the default value is
%           'matrix'.
%
%   ReadKey
%           Specify the Read APIKey of the channel.      string
%           Alternately, you can save your Read APIKey
%           just once for this MATLAB session by using
%           thingSpeakAuthenticate function. Following
%           this use thingSpeakRead function without
%           specifying Read APIKey again in the current
%           MATLAB session.
%
%   Timeout                                              positive number
%          Specify the timeout (in seconds) for
%          connecting to the server and reading data.
%          Default value is 10 seconds.
%
%   % Example 1
%   % ---------
%   % Retrieve the most recent result for all fields of a
%   % public channel including the timestamp.
%   [data,time] = thingSpeakRead(12397)
%
%   % Example 2
%   % ---------
%   % Retrieve data for August 8, 2014 through August 12, 2014 for
%   % fields 1 and 4 of a public channel, including the timestamp, and
%   % channel information.
%   [data,time,channelInfo] = ...
%   thingSpeakRead(12397,'Fields',[1 4],'DateRange',[datetime('Aug 8, 2014'),...
%                  datetime('Aug 12, 2014')])
%
%   % Example 3
%   % ---------
%   % Retrieve last ten points of data from fields 1 and 4 of a public
%   % channel. Return the data and timestamps in a table, and include the
%   % channel information.
%   [data,channelInfo] = ...
%   thingSpeakRead(12397,'Fields',[1 4],'NumPoints',10,'OutputFormat','table')
%
%   % Example 4
%   % ---------
%   % Retrieve last ten points of data from fields 1 and 4 of a public
%   % channel. Return the data in a timetable, and include the channel
%   % information.
%
%   [data,channelInfo] = ...
%   thingSpeakRead(12397,'Fields',[1, 4],'NumPoints',10,'OutputFormat','timetable');
%
%   % Example 5
%   % ---------
%   % Retrieve last 5 minutes of data from fields 1 and 4 of a public
%   % channel. Return only the data and timestamps.
%   [data, time] = thingSpeakRead(12397, 'Fields', [1, 4], 'NumMinutes', 5)
%
%   % Example 6
%   % ---------
%   % Retrieve last 2 days of data from fields 1 and 4 of a public
%   % channel. Return only the data and timestamps.
%   [data, time] = thingSpeakRead(12397, 'Fields', [1, 4], 'NumDays', 2)
%
%   % Example 7
%   % ---------
%   % Retrieve the most recent result for all fields of a private channel.
%   channelID = <Enter Channel ID>
%   readKey   = <Enter Read API Key>
%   data = thingSpeakRead(channelID, 'ReadKey', readKey)
%
%   % Example 8
%   % ---------
%   % Authenticate access once to a private channel for the current session
%   % of MATLAB using the THINGSPEAKAUTHENTICATE function.
%   channelID = <Enter Channel ID>
%   readKey   = <Enter Read API Key>
%   thingSpeakAuthenticate(channelID, 'ReadKey', readKey)
%   data1 = thingSpeakRead(channelID, 'NumPoints', 10)
%   data2 = thingSpeakRead(channelID, 'NumPoints', 20)
%
%   % Example 9
%   % ---------
%   % Retrieve latitude, longitude and altitude data along with the last
%   % 10 channel updates for all fields in a public channel and return the
%   % data as a table.
%   channelID = <Enter Channel ID>
%   data = thingSpeakRead(channelID, 'NumPoints', 10, 'Location', true, ...
%          'OutputFormat', 'table')
%
%   % Example 10
%   % ---------
%   % Set the timeout for reading 8000 data points from field 1 of a public
%   % channel.
%   data = thingSpeakRead(12397, 'Fields', 1, 'NumPoints', 8000, ...
%          'Timeout', 10)
%
%   % Example 11
%   % ---------
%   % Retrieve the last 10 points for all three fields of a
%   % public channel on a private ThingSpeak server installation and plot
%   % data vs. timestamps.
%   myURL = <Enter server URL>
%   [data,time] = thingSpeakRead(6,'NumPoints',10,...
%       'URL', myURL);
%   plot(time, data)

% Copyright 2015-2016 The MathWorks, Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));
% Check if the mltbx has been installed
try
   [outputData, timestamps, channelInfo] = tsfcncallrouter('thingSpeakRead', {channelID, varargin{:}}); %#ok<CCAT>
catch err    
    throwAsCaller(err);
end