function correction = solarCorrection(DOY, longitude, UTCoff)
% The function solarCorrection calculates the difference between local and
% solar time for a given location
%
% Inputs:
%   DOY = Day of the year
%   longitude = longitude of location
%   UTCoff = offset from coordinated universal time (UTC)
%
% Outputs:
%   correction = The difference (in minutes) between local and solar time

% Calculate the Equation of Time correction
B = 360*(DOY - 81)/365;
E = 9.87*sind(2*B) - 7.53*cosd(B) - 1.5*sind(B);

% Calculate the correction to convert local time to solar time
correction = 4*(longitude - 15*UTCoff) + E;

end