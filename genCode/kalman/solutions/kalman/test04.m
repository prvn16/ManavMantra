% Figure setup
clear all;
load position.mat
% Set up indexing to generate different size inputs
Idx=[ 1 10;  % 10 inputs 
     11 30;  % 20 inputs
     31 70;  % 40 inputs
     71 100; % 30 inputs
    101 200; % 100 inputs
    201 250  % 50 inputs
    251 300];% 50 inputs

figure;hold;grid;
% Kalman filter loop
for i = 1:size(Idx,1)
    % Generate the location data
    % Use each vector in Idx in turn to provide
    % different size inputs to the filter at each
    % iteration through the loop
    z = position(1:2,Idx(i,1):Idx(i,2));

    % Use Kalman filter to estimate the location
    y = kalman03(z);
    
    % Plot the results
    for n=1:size(z,2)
        plot_trajectory(z(:,n),y(:,n));
    end
end
hold;