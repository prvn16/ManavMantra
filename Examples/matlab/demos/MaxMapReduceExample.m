%% Find Maximum Value with MapReduce
% This example shows how to find the maximum value of a single variable in
% a data set using |mapreduce|. It demonstrates the simplest use of
% |mapreduce| since there is only one key and minimal computation.

% Copyright 1984-2014 The MathWorks, Inc.
%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. In this example,
% select |ArrDelay| (flight arrival delay) as the variable of interest.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = 'ArrDelay'

%%
% |tabularTextDatastore| returns a |TabularTextDatastore| object for the data. This
% datastore treats |'NA'| strings as missing, and replaces the missing
% values with |NaN| values by default. Additionally, the
% |SelectedVariableNames| property allows you to work with only the
% selected variable of interest, which you can verify using |preview|.
preview(ds)

%% Run MapReduce
% The |mapreduce| function requires a mapper function and a reducer
% function. The mapper function receives chunks of data and outputs
% intermediate results. The reducer function reads the intermediate results
% and produces a final result.

%% 
% In this example, the mapper function finds the maximum arrival delay in
% each chunk of data. The mapper function then stores these maximum values
% as the intermediate values associated with the key
% |'PartialMaxArrivalDelay'|.

%%
% Display the mapper function file.
type maxArrivalDelayMapper.m

%%
% The reducer function receives a list of the maximum arrival delays for
% each chunk and finds the overall maximum arrival delay from the list of
% values. |mapreduce| only calls this reducer function once, since the
% mapper function only adds a single unique key. The reducer function uses
% |add| to add a final key-value pair to the output.

%%
% Display the reducer function file.
type maxArrivalDelayReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
maxDelay = mapreduce(ds, @maxArrivalDelayMapper, @maxArrivalDelayReducer);

%%
% |mapreduce| returns a datastore, |maxDelay|, with files in the
% current folder.

%%
% Read the final result from the output datastore, |maxDelay|.
readall(maxDelay)
