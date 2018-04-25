function iptabout(varargin)
%IPTABOUT About the Image Processing Toolbox.
%   IPTABOUT displays the version number of the Image Processing
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1993-2015 The MathWorks, Inc.

tlbx = ver('images');
tlbx = tlbx(1);

str = getString(message('images:iptabout:copyright', datestr(tlbx.Date,10)));
str = sprintf('%s %s\n%s', tlbx.Name, tlbx.Version, str);

s = load(fullfile(ipticondir, 'iptabout.mat'));
num_icons = numel(s.icons);
stream = RandStream('mcg16807', 'seed', sum(100*clock));
icon_idx = randi(stream, num_icons); % random integer in 1:num_icons

msgbox(str, tlbx.Name, 'custom', s.icons{icon_idx}, gray(64), 'modal');

