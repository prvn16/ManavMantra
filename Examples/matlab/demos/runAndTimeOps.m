function [meanTime, names] = runAndTimeOps
% Time a number of operations and return the times plus their names.
% Other functions can be inserted here by replicating the code sections.

%   Copyright 2006-2014 The MathWorks, Inc.

% Set parameters
numRuns = 10;                 % Number of runs to average over
dataSize = 500;               % Data size to test
x = rand(dataSize,dataSize);  % Random square matrix

% Matrix multiplication (*)
func = 1; % Initialize function counter
tic;
for i = 1:numRuns
   y = x*x;                  % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = '*';            % Store string describing function
func = func+1;                % Increment function counter

% Matrix divide (\)
tic;
for i = 1:numRuns
   y = x\x(:,1);             % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = '\';            % Store string describing function
func = func+1;                % Increment function counter

% QR decomposition
tic;
for i = 1:numRuns
   y = qr(x);                 % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = 'qr';           % Store string describing function
func = func+1;                % Increment function counter

% LU decomposition
tic;
for i = 1:numRuns
   y = lu(x);                % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = 'lu';           % Store string describing function
func = func+1;                % Increment function counter

% Sine of argument in radians
tic;
for i = 1:numRuns
   y = sin(x);               % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = 'sin';          % Store string describing function
func = func+1;                % Increment function counter

% Array power
tic;
for i = 1:numRuns
   y = x.^x;                 % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = '.^';           % Store string describing function
func = func+1;                % Increment function counter

% Square root
for i = 1:numRuns
   y = sqrt(x);              % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = 'sqrt';         % Store string describing function
func = func+1;                % Increment function counter

% Element-wise multiplication (.*)
tic;
for i = 1:numRuns
   y = x.*x;                 % Call function
end
meanTime(func) = toc/numRuns; % Divide time by number of runs
names{func} = '.*';           % Store string describing function
func = func+1;                % Increment function counter