% Time series data visualization and exploration.
%
% General.
%   timeseries              - Create a time series object.
%   timeseries/tsprops      - Help on time series object properties.
%   timeseries/get          - Query time series property values.
%   timeseries/set          - Set time series property values.
%
% Manipulations.
%   timeseries/addsample    - Add sample(s) to a time series object.
%   timeseries/delsample    - Delete sample(s) from a time series object.
%   timeseries/synchronize  - Synchronize two time series objects onto a common time vector.
%   timeseries/resample     - Resample time series data.
%   timeseries/vertcat      - Vertical concatenation of time series objects.
%   timeseries/getsampleusingtime - Extract data in the specified time range to a new object. 
%
%   timeseries/ctranspose   - Transpose of time series data.
%   timeseries/isempty      - True for empty time series object.
%   timeseries/length       - Length of the time vector.
%   timeseries/size         - Size of the time series object.
%   timeseries/fieldnames   - Cell array of time series property names.
%   timeseries/getdatasamplesize - Size of time series data.
%   timeseries/getqualitydesc - Quality description of the time series data.
%
%   timeseries/detrend      - Remove mean or best-fit line and all NaNs from time series data.
%   timeseries/filter       - Shape time series data.
%   timeseries/idealfilter  - Apply an ideal (non-causal) filter to time series data.
%
%   timeseries/getabstime   - Extract a date string time vector into a cell array.
%   timeseries/setabstime   - Set time using date strings.
%   timeseries/getinterpmethod - Interpolation method name for a time series object.
%   timeseries/setinterpmethod - Set default interpolation method in a time series.
%
%   timeseries/plot         - Plot time series data.
%
% Time Series events.
%   tsdata.event            - Construct an event object for a time series.
%   timeseries/addevent     - Add events.
%   timeseries/delevent     - Remove events.
%   timeseries/gettsafteratevent - Extract samples occurring at or after a specified event.
%   timeseries/gettsafterevent - Extract samples occurring after a specified event.
%   timeseries/gettsatevent - Extract samples occurring at a specified event.
%   timeseries/gettsbeforeatevent - Extract samples occurring at or before a specified event.
%   timeseries/gettsbeforeevent - Extract samples occurring before a specified event.
%   timeseries/gettsbetweenevents - Extract samples occurring between two specified events.
%
% Overloaded arithmetic operations.
%   timeseries/plus         - (+)   Add time series.
%   timeseries/minus        - (-)   Subtract time series.
%   timeseries/times        - (.*)  Multiply time series.
%   timeseries/mtimes       - (*)   Matrix multiplication of time series.
%   timeseries/rdivide      - (./)  Right array divide time series.
%   timeseries/mrdivide     - (/)   Right matrix division of time series.
%   timeseries/ldivide      - (.\)  Left array divide time series.
%   timeseries/mldivide     - (\)   Left matrix division of time series.
%
% Overloaded statistical functions.
%   timeseries/iqr          - Interquartile range of the time series data.
%   timeseries/max          - Max of the time series data.
%   timeseries/mean         - Mean of the time series data.
%   timeseries/median       - Median of the time series data.
%   timeseries/min          - Min of the time series data.
%   timeseries/std          - Standard deviation of the time series data.
%   timeseries/sum          - Sum of the time series data.
%   timeseries/var          - Variance of the time series data.
%
%
% Time Series collection general.
%   tscollection            - Create a time series collection object.
%   tscollection/get        - Query time series collection property values.
%   tscollection/set        - Set time series collection property values.
%
% Time Series collection manipulations.
%   tscollection/addts      - Add data vector or time series object to a collection.
%   tscollection/removets   - Remove time series object(s) from a collection.
%   tscollection/addsampletocollection - Add sample(s) to a collection.
%   tscollection/delsamplefromcollection - Remove sample(s) from a collection.
%   tscollection/resample   - Resample time series members of a collection.
%   tscollection/vertcat    - Vertical concatenation of tscollection objects.
%   tscollection/horzcat    - Horizontal concatenation of tscollection objects.
%   tscollection/getsampleusingtime - Extract samples from a collection between specified time values.
%
%   tscollection/isempty    - True for empty tscollection objects.
%   tscollection/length     - Length of the time vector.
%   tscollection/size       - Size of a tscollection object.
%   tscollection/fieldnames - Cell array of time series collection property names.
%
%   tscollection/getabstime   - Extract a date string time vector into a cell array.
%   tscollection/setabstime   - Set time of a collection using date strings.
%   tscollection/gettimeseriesnames - Cell array of names of time series in tscollection.
%   tscollection/settimeseriesnames - Change the name of a time series member of a collection.
%

%   Copyright 2004-2005 The MathWorks, Inc.
