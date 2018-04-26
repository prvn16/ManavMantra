%
%   ---------------------------------------------------------------------
%
%   Copyright 2010 The MathWorks, Inc.
%
%   ---------------------------------------------------------------------
%
function plot_trajectory(z,y)
title('Trajectory of object [blue] its Kalman estimate[green]');
xlabel('horizontal position');
ylabel('vertical position');
plot(z(1), z(2), 'bx-');
plot(y(1), y(2), 'go-');
axis([-1.1, 1.1, -1.1, 1.1]);
pause(0.02);
end