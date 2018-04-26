% Figure setup
clear all;
load position.mat
numPts = 300;
frame=10;
numFrms=300/frame;

figure;hold;grid;
% Kalman filter loop
for i = 1: numFrms
    % Generate the location data
    z = position(:,frame*(i-1)+1:frame*i);

    % Use Kalman filter to estimate the location
    y = kalman03(z);
    
    % Plot the results
    for n=1:frame
    plot_trajectory(z(:,n),y(:,n));
    end
end
hold;
