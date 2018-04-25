%% Compute Summary Statistics by Group Using MapReduce
% This example shows how to compute summary statistics organized by group
% using |mapreduce|. It demonstrates the use of an anonymous function to
% pass an extra grouping parameter to a parameterized mapper function. This
% parameterization allows you to quickly recalculate the statistics using a
% different grouping variable.

% Copyright 1984-2014 The MathWorks, Inc.
%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. For this
% example, select |Month|, |UniqueCarrier| (airline carrier ID), and
% |ArrDelay| (flight arrival delay) as the variables of interest.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'Month', 'UniqueCarrier', 'ArrDelay'}

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
% In this example, the mapper function computes the grouped statistics for
% each chunk of data and stores the statistics as intermediate key-value
% pairs. Each intermediate key-value pair has a key for the group level and
% a cell array of values with the corresponding statistics.
%
% This mapper function accepts four input arguments, whereas the
% |mapreduce| function requires the mapper function to accept exactly three
% input arguments. The call to |mapreduce| (below) shows how to pass in
% this extra parameter.

%%
% Display the mapper function file.
type statsByGroupMapper.m

%%
% After the Map phase, |mapreduce| groups the intermediate key-value pairs
% by unique key (in this case, the airline carrier ID), so each call to the
% reducer function works on the values associated with one airline. The
% reducer function receives a list of the intermediate statistics for the
% airline specified by the input key (|intermKey|) and combines the
% statistics into separate vectors: |n|, |m|, |v|, |s|, and |k|. Then, the
% reducer uses these vectors to calculate the count, mean, variance,
% skewness, and kurtosis for a single airline. The final key is the airline
% carrier code, and the associated values are stored in a structure with
% five fields.

%%
% Display the reducer function file.
type statsByGroupReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|. Since the parameterized mapper function accepts four
% inputs, use an anonymous function to pass in the airline carrier IDs as
% the fourth input.
outds1 = mapreduce(ds, ...
    @(data,info,kvs)statsByGroupMapper(data,info,kvs,'UniqueCarrier'), ...
    @statsByGroupReducer);

%%
% |mapreduce| returns a datastore, |outds1|, with files in the current
% folder.

%%
% Read the final results from the output datastore.
r1 = readall(outds1)

%% Organize Results
% To organize the results better, convert the structure containing the
% statistics into a table and use the carrier IDs as the row names.
% |mapreduce| returns the key-value pairs in the same order as they were
% added by the reducer function, so sort the table by carrier ID.
statsByCarrier = struct2table(cell2mat(r1.Value), 'RowNames', r1.Key);
statsByCarrier = sortrows(statsByCarrier, 'RowNames')

%% Change Grouping Parameter
% The use of an anonymous function to pass in the grouping variable allows
% you to quickly recalculate the statistics with a different grouping.
%
% For this example, recalculate the statistics and group the results by
% |Month|, instead of by the carrier IDs, by simply passing the |Month|
% variable into the anonymous function.
outds2 = mapreduce(ds, ...
    @(data,info,kvs)statsByGroupMapper(data,info,kvs,'Month'), ...
    @statsByGroupReducer);

%%
% Read the final results and organize them into a table.
r2 = readall(outds2);
r2 = sortrows(r2,'Key');
statsByMonth= struct2table(cell2mat(r2.Value));
mon = {'Jan','Feb','Mar','Apr','May','Jun', ...
       'Jul','Aug','Sep','Oct','Nov','Dec'};
statsByMonth.Properties.RowNames = mon
