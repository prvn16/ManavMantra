% Figure setup
clear all;
load position.mat
numPts = 300;
figure;hold;grid;

% Kalman filter loop
for idx = 1: numPts
    % Generate the location data
    z = position(:,idx);

    % Use Kalman filter to estimate the location
    y = kalman02(z);
    
    % Plot the results
    plot_trajectory(z,y);
end
hold;
