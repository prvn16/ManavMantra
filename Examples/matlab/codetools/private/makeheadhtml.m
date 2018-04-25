function htmlOut = makeheadhtml
% MAKEHEADHTML  Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 1984-2014 MathWorks, Inc.

h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

% Use charset=UTF-8, g589137 g589371
encoding = 'UTF-8';
h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

% Add cascading style sheet link
cssfile = which('matlab-report-styles.css');
h4 = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);

htmlOut = [h1 h2 h3 h4];
