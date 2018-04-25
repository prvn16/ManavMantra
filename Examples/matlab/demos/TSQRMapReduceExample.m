%% Tall Skinny QR (TSQR) Matrix Factorization Using MapReduce
% This example shows how to compute a tall skinny QR (TSQR) factorization
% using |mapreduce|. It demonstrates how to chain MapReduce calls to
% perform multiple iterations of factorizations, and uses the |info|
% argument of the mapper function to compute numeric keys.

% Copyright 1984-2014 The MathWorks, Inc.

%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. In this example,
% the variables of interest are |ArrDelay| (flight arrival
% delay),|DepDelay| (flight departure delay) and |Distance| (total flight
% distance).
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.ReadSize = 1000;
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay', 'Distance'}

%%
% |tabularTextDatastore| returns a |TabularTextDatastore| object for the data. This
% datastore treats |'NA'| strings as missing and replaces the missing
% values with |NaN| values by default. The |ReadSize| property lets you
% specify how to partition the data into chunks. Additionally, the
% |SelectedVariableNames| property allows you to work with only the
% specified variables of interest, which you can verify using |preview|.
preview(ds)

%% Chain |mapreduce| Calls
% The implementation of the multi-iteration TSQR algorithm needs to chain
% consecutive |mapreduce| calls. To demonstrate the general chaining design
% pattern, this example uses two MapReduce iterations. The output from the
% mapper function calls is passed into a large set of reducers, and then
% the output of these reducers becomes the input for the next MapReduce
% iteration.

%% First MapReduce Iteration
%%
% In the first iteration, the mapper function, |tsqrMapper|, receives one
% chunk (the ith) of data, which is a table of size $N_i\times 3$. The
% mapper computes the $R$ matrix of this chunk of data and stores it as an
% intermediate result. Then, |mapreduce| aggregates the intermediate
% results by unique key before sending them to the reducer function. Thus,
% |mapreduce| sends all intermediate $R$ matrices with the same key to the
% same reducer.
%
% Since the reducer uses |qr|, which is an in-memory MATLAB function, it's
% best to first make sure that the $R$ matrices fit in memory. This example
% divides the dataset into eight partitions. The |mapreduce| function reads
% the data in chunks and passes the data along with some meta information
% to the mapper function. The |info| input argument is the second input to
% the mapper function and it contains the read offset and file size
% information that are necessary to generate the key,
%
%    key = ceil(offset/fileSize/numPartitions).
%

%%
% Display the mapper function file.
type tsqrMapper.m

%%
% The reducer function receives a list of the intermediate $R$ matrices,
% vertically concatenates them, and computes the $R$ matrix of the
% concatenated matrix.

%%
% Display the reducer function file.
type tsqrReducer.m

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
outds1 = mapreduce(ds, @tsqrMapper, @tsqrReducer);

%%
% |mapreduce| returns an output datastore, |outds1|, with files in
% the current folder.

%% Second MapReduce Iteration
% The second iteration uses the output of the first iteration, |outds1|,
% as its input. This iteration uses an identity mapper function,
% |identityMapper|, which simply copies over the data using a single key,
% |'Identity'|.

%%
% Display the identity mapper function file.
type identityMapper.m

%%
% The reducer function is the same in both iterations. The use of a single
% key by the mapper function means that |mapreduce| only calls the reducer
% function once in the second iteration.

%%
% Display the reducer function file.
type tsqrReducer.m

%%
% Use |mapreduce| to apply the identity mapper and the same reducer to the
% output from the first |mapreduce| call.
outds2 = mapreduce(outds1, @identityMapper, @tsqrReducer);

%% View Results
% Read the final results from the output datastore.
r = readall(outds2);
r.Value{:}

%% Reference
% 
% # Paul G. Constantine and David F. Gleich. 2011. Tall and skinny QR
% factorizations in MapReduce architectures. In Proceedings of the Second
% International Workshop on MapReduce and Its Applications (MapReduce '11).
% ACM, New York, NY, USA, 43-50. DOI=10.1145/1996092.1996103
% <http://doi.acm.org/10.1145/1996092.1996103>
