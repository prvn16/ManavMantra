function box(arg1, arg2)
%BOX    Axis box.
%   BOX ON adds a box to the current axes.
%   BOX OFF takes if off.
%   BOX, by itself, toggles the box state of the current axes.
%   BOX(AX,...) uses axes AX instead of the current axes.
%
%   BOX sets the Box property of an axes.
%
%   See also GRID, AXES.

%   Copyright 1984-2017 The MathWorks, Inc.

% To ensure the correct current handle is taken in all situations.

import matlab.graphics.internal.*;
opt_box = 0;
if nargin == 0
	ax = gca;
else
	if isempty(arg1)
		opt_box = lower(arg1);
	end
	if isCharOrString(arg1)
		% string input (check for valid option later)
		if nargin == 2
			error(message('MATLAB:box:HandleExpected'))
		end
		ax = gca;
		opt_box = lower(arg1);
	else
		% make sure non string is a scalar handle
		if length(arg1) > 1
			error(message('MATLAB:box:InvalidHandle'));
		end
		% handle must be a handle and axes handle
		if ~isempty(arg1) && (~ishghandle(arg1) || ~isprop(arg1,'Box'))
			error(message('MATLAB:box:ExpectedAxesHandle'));
		end
		ax = arg1;
		
		% check for string option
		if nargin == 2
			opt_box = lower(arg2);
		end
	end
end

if (isempty(opt_box))
	error(message('MATLAB:box:UnknownOption'));
end

matlab.graphics.internal.markFigure(ax);

if (char(opt_box) == 0)
	if (strcmp(get(ax,'Box'),'off'))
		set(ax,'Box','on');
	else
		set(ax,'Box','off');
	end
elseif (strcmp(opt_box, 'on'))
	set(ax,'Box', 'on');
elseif (strcmp(opt_box, 'off'))
	set(ax,'Box', 'off');
else
	error(message('MATLAB:box:CommandUnknown'));
end
