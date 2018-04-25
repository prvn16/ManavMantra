function PreferenceUI(varargin)
%PREFERENCEUI Summary of this function goes here
%   Detailed explanation goes here


len = length(varargin);

if(len > 1)
    %error message
    return;
end

url = connector.getUrl('/matlab/toolbox/matlab/matlab_preferences/index.html');

if(isequal(len, 1))
    url = [url '&selection=' varargin{1}];
end

window = matlab.internal.webwindow(url);
window.Title = 'preferences';
window.Position = [505 240 925 645];
window.bringToFront;
