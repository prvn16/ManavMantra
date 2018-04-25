%% Using MapReduce to Fit a Logistic Regression Model
% This example shows how to use |mapreduce| to carry out simple logistic
% regression using a single predictor. It demonstrates chaining multiple
% |mapreduce| calls to carry out an iterative algorithm. Since each
% iteration requires a separate pass through the data, an anonymous
% function passes information from one iteration to the next to supply
% information directly to the mapper.

% Copyright 1984-2014 The MathWorks, Inc.

%% Prepare Data
% Create a datastore using the |airlinesmall.csv| data set. This 12
% megabyte data set contains 29 columns of flight information for several
% airline carriers, including arrival and departure times. In this example,
% the variables of interest are |ArrDelay| (flight arrival delay) and
% |Distance| (total flight distance).
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'ArrDelay', 'Distance'}

%%
% |tabularTextDatastore| returns a |TabularTextDatastore| object for the data. This
% datastore treats |'NA'| strings as missing, and replaces the missing
% values with |NaN| values by default. Additionally, the
% |SelectedVariableNames| property allows you to work with only the
% specified variables of interest, which you can verify using |preview|.
preview(ds)

%% Perform Logistic Regression
% Logistic regression is a way to model the probability of an event as a
% function of another variable. In this example, logistic regression models
% the probability of a flight being more than 20 minutes late as a function
% of the flight distance, in thousands of miles.
%
% To accomplish this logistic regression, the mapper and reducer functions
% must collectively perform a weighted least-squares regression based on
% the current coefficient values. The mapper function computes a weighted
% sum of squares and cross product for each chunk of input data. 

%%
% Display the mapper function file.
type logitMapper

%%
% The reducer function computes the regression coefficient estimates from
% the sums of squares and cross products.

%%
% Display the reducer function file.
type logitReducer

%% Run MapReduce
% Run |mapreduce| iteratively by enclosing the calls to |mapreduce| in a
% loop. The loop runs until the convergence criteria are met, with a
% maximum of five iterations.

% Define the coefficient vector, starting as empty for the first iteration.
b = []; 

for iteration = 1:5
    b_old = b;
    iteration
    
    % Here we will use an anonymous function as our mapper. This function
    % definition includes the value of b computed in the previous
    % iteration.
    mapper = @(t,ignore,intermKVStore) logitMapper(b,t,ignore,intermKVStore);
    result = mapreduce(ds, mapper, @logitReducer, 'Display', 'off');
    
    tbl = readall(result);
    b = tbl.Value{1}
    
    % Stop iterating if we have converged.
    if ~isempty(b_old) && ...
       ~any(abs(b-b_old) > 1e-6 * abs(b_old))
       break
    end
end

%% View Results
% Use the resulting regression coefficient estimates to plot a probability
% curve. This curve shows the probability of a flight being more than 20
% minutes late as a function of the flight distance.
xx = linspace(0,4000);
yy = 1./(1+exp(-b(1)-b(2)*(xx/1000)));
plot(xx,yy); 
xlabel('Distance');
ylabel('Prob[Delay>20]')
