%% Using MapReduce to Compute Covariance and Related Quantities
% This example shows how to compute the mean and covariance for several
% variables in a large data set using |mapreduce|. It then uses the
% covariance to perform several follow-up calculations that do not require
% another iteration over the entire data set.

% Copyright 1984-2014 The MathWorks, Inc.

%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. In this example,
% select |ActualElapsedTime| (total flight time), |Distance| (total flight
% distance), |DepDelay| (flight departure delay), and |ArrDelay| (flight
% arrival delay) as the variables of interest.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'ActualElapsedTime', 'Distance', ...
                                     'DepDelay', 'ArrDelay'}

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
% In this example, the mapper function computes the count, mean, and
% covariance for the variables in each chunk of data in the datastore,
% |ds|. Then, the mapper function stores the computed values for each chunk
% as an intermediate key-value pair consisting of a single key with a cell
% array containing the three computed values.

%%
% Display the mapper function file.
type covarianceMapper

%%
% The reducer function combines the intermediate results for each chunk to
% obtain the count, mean, and covariance for each variable of interest in
% the entire data set. The reducer function stores the final key-value
% pairs for the keys |'count'|, |'mean'|, and |'cov'| with the
% corresponding values for each variable.

%%
% Display the reducer function file.
type covarianceReducer

%%
% Use |mapreduce| to apply the mapper and reducer functions to the
% datastore, |ds|.
outds = mapreduce(ds, @covarianceMapper, @covarianceReducer);

%%
% |mapreduce| returns a datastore, |outds|, with files in the current
% folder.

%%
% View the results of the |mapreduce| call by using the |readall| function
% on the output datastore.
results = readall(outds)
Count = results.Value{1};
MeanVal = results.Value{2};
Covariance = results.Value{3};

%% Compute Correlation Matrix
% The covariance, mean, and count values are useful to perform further
% calculations. Compute a correlation matrix by finding the standard
% deviations and normalizing them to correlation form.
s = sqrt(diag(Covariance));
Correlation = Covariance ./ (s*s')

%%
% The elapsed time (first column) and distance (second column) are highly
% correlated, since |Correlation(2,1) = 0.9666|. The departure delay (third
% column) and arrival delay (fourth column) are also highly correlated,
% since |Correlation(4,3) = 0.8748|.

%% Compute Regression Coefficients
% Compute some regression coefficients to predict the arrival
% delay, |ArrDelay|, using the other three variables as predictors.
slopes = Covariance(1:3,1:3)\Covariance(1:3,4);
intercept = MeanVal(4) - MeanVal(1:3)*slopes;
b = table([intercept; slopes], 'VariableNames', {'Estimate'}, ...
    'RowNames', {'Intercept','ActualElapsedTime','Distance','DepDelay'})

%% Perform PCA
% Use |svd| to perform PCA (principal components analysis). PCA is a
% technique for finding a lower dimensional summary of a data set. The
% following calculation is a simplified version of PCA, but more options
% are available from the |pca| and |pcacov| functions in Statistics and
% Machine Learning Toolbox(TM).
%
% You can carry out PCA using either the covariance or correlation. In this
% case, use the correlation since the difference in scale of the variables
% is large. The first two components capture most of the variance.
[~,latent,pcacoef] = svd(Correlation);
latent = diag(latent)

%%
% Display the coefficient matrix. Each column of the coefficients matrix
% describes how one component is defined as a linear combination of the
% standardized original variables. The first component is mostly an average
% of the first two variables, with some additional contribution from the
% other variables. Similarly, the second component is mostly an average of
% the last two variables.
pcacoef
