%% Compute Mean Value with MapReduce
% This example shows how to compute the mean of a single variable in a
% data set using |mapreduce|. It demonstrates a simple use of |mapreduce|
% with one key, minimal computation, and an intermediate state
% (accumulating intermediate sum and count).

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
% In this example, the mapper function finds the count and sum of the
% arrival delays in each chunk of data. The mapper function then stores
% these values as the intermediate values associated with the key
% |'PartialCountSumDelay'|.

%%
% Display the mapper function file.
type meanArrivalDelayMapper.m

%%
% The reducer function accepts the count and sum for each chunk stored by
% the mapper function. It sums up the values to obtain the total count and
% total sum. The overall mean arrival delay is a simple division of the
% values. |mapreduce| only calls this reducer function once, since the
% mapper function only adds a single unique key. The reducer function uses
% |add| to add a single key-value pair to the output.

%%
% Display the reducer function file.
type meanArrivalDelayReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
meanDelay = mapreduce(ds, @meanArrivalDelayMapper, @meanArrivalDelayReducer);

%%
% |mapreduce| returns a datastore, |meanDelay|, with files in the
% current folder.

%%
% Read the final result from the output datastore, |meanDelay|.
readall(meanDelay)
