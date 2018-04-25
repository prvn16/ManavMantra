%% Simple Data Subsetting Using MapReduce
% This example shows how to extract a subset of a large data set.
%
% There are two aspects of subsetting, or performing a query. One is
% selecting a subset of the variables (columns) in the data set.
% The other is selecting a subset of the observations, or rows.
%
% In this example, the selection of variables takes place in the definition
% of the datastore. (The mapper function could perform a further
% sub-selection of variables, but that is not within the scope of this
% example.) In this example, the role of the mapper function is to perform
% the selection of observations. The role of the reducer function is to
% concatenate the subsetted records extracted by each call to the mapper
% function. This approach assumes that the data set can fit in memory after
% the Map phase.

% Copyright 1984-2014 The MathWorks, Inc.

%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. This example
% uses 15 variables out of the 29 variables available in the data.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = ds.VariableNames([1 2 5 9 12 13 15 16 17 ...
    18 20 21 25 26 27]);
ds.SelectedVariableNames

%%
% |tabularTextDatastore| returns a |TabularTextDatastore| object for the data. This
% datastore treats |'NA'| strings as missing, and replaces the missing
% values with |NaN| values by default. Additionally, the
% |SelectedVariableNames| property allows you to work with only the
% specified variables of interest, which you can verify using |preview|.
preview(ds)

%% Run MapReduce
% The |mapreduce| function requires a mapper function and a reducer
% function. The mapper function receives chunks of data and outputs
% intermediate results. The reducer function reads the intermediate results
% and produces a final result.

%% 
% In this example, the mapper function receives a table with the variables
% described by the |SelectedVariableNames| property in the datastore. Then,
% the mapper function extracts flights that had a high amount of delay
% after pushback from the gate. Specifically, it identifies flights with a
% duration exceeding 2.5 times the length of the scheduled duration. The
% mapper function ignores flights prior to 1995, because some of the
% variables of interest for this example were not collected before that
% year.

%%
% Display the mapper function file.
type subsettingMapper.m

%% 
% The reducer function receives the subsetted observations obtained from
% the mapper function and simply concatenates them into a single table. The
% reducer function returns one key (which is relatively meaningless) and
% one value (the concatenated table).

%%
% Display the reducer function file.
type subsettingReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
result = mapreduce(ds, @subsettingMapper, @subsettingReducer);

%%
% |mapreduce| returns an output datastore, |result|, with files in
% the current folder.

%% Display Results
% Look for patterns in the first 10 variables that were pulled
% from the data set. These variables identify the airline, the destination,
% and the arrival airports, as well as some basic delay information.
r = readall(result);
tbl = r.Value{1};
tbl(:,1:10)

%% 
% Looking at the first record, a US Airways flight departed the gate 14
% minutes after its scheduled departure time and arrived 118 minutes late.
% The flight experienced a delay of 104 minutes after pushback from the
% gate which is the difference between |ActualElapsedTime| and
% |CRSElapsedTime|.
%
% There is one anomalous record. In February of 2006, a JetBlue flight had
% a departure time of 3:24 a.m. and an elapsed flight time of 1650 minutes,
% but an arrival delay of only 415 minutes. This might be a data entry
% error.
%
% Otherwise, there are no clear cut patterns concerning when and where
% these exceptionally delayed flights occur. No airline, time of year, time
% of day, or single airport dominates. Some intuitive patterns, such as
% O'Hare (ORD) in the winter months, are certainly present.

%% Delay Patterns
% Beginning in 1995, the airline system performance data began including
% measurements of how much delay took place in the taxi phases of a flight.
% Then, in 2003, the data also began to include certain causes of delay.

%%
% Examine these two variables in closer detail.
tbl(:,[1,7,8,11:end])

%% 
% For these exceptionally delayed flights, the great majority of delay
% occurs during taxi out, on the tarmac. Moreover, the major cause of the
% delay is _NASDelay_. NAS delays are holds imposed by the national
% aviation authorities on departures headed for an airport that is forecast
% to be unable to handle all scheduled arrivals at the time the flight is
% scheduled to arrive. NAS delay programs in effect at any given time are
% posted at http://www.fly.faa.gov/ois/.
%
% Preferably, when NAS delays are imposed, boarding of the aircraft is
% simply delayed. Such a delay would show up as a departure delay. However,
% for most of the flights selected for this example, the delays took place
% largely after departure from the gate, leading to a taxi delay.

%% Rerun MapReduce
% The previous mapper function had the subsetting criteria hard-wired in
% the function file. A new mapper function would have to be written for any 
% new query, such as flights departing San Francisco on a given day. 
%
% A generic mapper can be more adaptive by separating out the subsetting
% criteria from the mapper function definition and using an anonymous
% function to configure the mapper function for each query. This generic
% mapper function uses a fourth input argument that supplies the desired
% query variable.

%%
% Display the generic mapper function file.
type subsettingMapperGeneric.m

%% 
% Create an anonymous function that performs the same selection of rows
% that is hard-coded in |subsettingMapper.m|.
inFlightDelay150percent =  @(data) data.Year > 1994 & ...
    (data.ActualElapsedTime - data.CRSElapsedTime) > ...
    1.50 * data.CRSElapsedTime;

%% 
% Since the |mapreduce| function requires the mapper and reducer functions
% to accept exactly three inputs, use another anonymous function to specify
% the fourth input to the mapper function, |subsettingMapperGeneric.m|.
% Subsequently, you can use this anonymous function to call
% |subsettingMapperGeneric.m| using only three arguments (the fourth is
% implicit).
configuredMapper = ...
    @(data, info, intermKVStore) subsettingMapperGeneric(...
    data, info, intermKVStore, inFlightDelay150percent);

%%
% Use |mapreduce| to apply the generic mapper function to the input
% datastore.
result2 = mapreduce(ds, configuredMapper, @subsettingReducer);

%%
% |mapreduce| returns an output datastore, |result2|, with files in
% the current folder.

%% Verify Results
% Confirm that the generic mapper gets the same result as with the
% hard-wired subsetting logic.

r2 = readall(result2);
tbl2 = r2.Value{1};

if isequaln(tbl, tbl2)
    disp('Same results with the configurable mapper.')
else
    disp('Oops, back to the drawing board.')
end
