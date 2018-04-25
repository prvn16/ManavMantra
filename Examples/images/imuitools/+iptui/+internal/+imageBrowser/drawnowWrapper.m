function drawnowWrapper
% wrap the call to drawnow to allow overloads in test environments
% (g1547142).
drawnow limitrate