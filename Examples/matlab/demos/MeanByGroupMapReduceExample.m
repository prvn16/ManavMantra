%% Compute Mean by Group Using MapReduce
% This example shows how to compute the mean by group in a data set using
% |mapreduce|. It demonstrates how to do computations on subgroups of data.

% Copyright 1984-2014 The MathWorks, Inc.
%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. In this example,
% select |DayOfWeek| and |ArrDelay| (flight arrival delay) as the variables
% of interest.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'ArrDelay', 'DayOfWeek'}

%%
% |tabularTextDatastore| returns a |TabularTextDatastore| object for the data. This
% datastore treats |'NA'| strings as missing, and replaces the missing
% values with |NaN| values by default. Additionally, the
% |SelectedVariableNames| property allows you to work with only the
% selected variables of interest, which you can verify using |preview|.
preview(ds)

%% Run MapReduce
% The |mapreduce| function requires a mapper function and a reducer
% function. The mapper function receives chunks of data and outputs
% intermediate results. The reducer function reads the intermediate results
% and produces a final result.

%% 
% In this example, the mapper function computes the count and sum of delays
% by the day of week in each chunk of data, and then stores the results as
% intermediate key-value pairs. The keys are integers (1 to 7) representing
% the days of the week and the values are two-element vectors representing
% the count and sum of the delay of each day.

%%
% Display the mapper function file.
type meanArrivalDelayByDayMapper.m

%%
% After the Map phase, |mapreduce| groups the intermediate key-value pairs
% by unique key (in this case, day of the week). Thus, each call to the
% reducer function works on the values associated with one day of the week.
% The reducer function receives a list of the intermediate count and sum of
% delays for the day specified by the input key (|intermKey|) and sums up
% the values into the total count, |n| and total sum |s|. Then, the reducer
% function calculates the overall mean. and adds one final key-value pair
% to the output. This key-value pair represents the mean flight arrival
% delay for one day of the week.

%%
% Display the reducer function file.
type meanArrivalDelayByDayReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
meanDelayByDay = mapreduce(ds, @meanArrivalDelayByDayMapper, ...
                               @meanArrivalDelayByDayReducer);

%%
% |mapreduce| returns a datastore, |meanDelayByDay|, with files in the
% current folder.

%%
% Read the final result from the output datastore, |meanDelayByDay|.
result = readall(meanDelayByDay)

%% Organize Results
% The integer keys (1 to 7) represent the days of the week. To organize the
% results more, convert the keys to a categorical array, retrieve the
% numeric values from the single element cells, and rename the variable
% names of the resulting table.
result.Key = categorical(result.Key, 1:7, ...
               {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'});
result.Value = cell2mat(result.Value);
result.Properties.VariableNames = {'DayOfWeek', 'MeanArrDelay'}

%%
% Sort the rows of the table by mean flight arrival delay. This reveals
% that Saturday is the best day of the week to travel, whereas Friday is
% the worst.
result = sortrows(result,'MeanArrDelay')
