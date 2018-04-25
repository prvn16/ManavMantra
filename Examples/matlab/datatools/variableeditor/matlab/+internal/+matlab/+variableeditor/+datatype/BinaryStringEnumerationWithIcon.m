classdef BinaryStringEnumerationWithIcon 
	% This is an interface for data types that want to have their
	% editor be shown with a single toggle buttons with an icon
	%
	% Copyright 2017 The MathWorks, Inc.
	
	properties(Abstract, Constant)		
		% EnumeratedValues
		%
		% A 1xN cell array of chars, where the first value corresponds to
		% the toggle button being unchecked, and the second value
		% corresponds to the toggle button being checked
		%
		% Ex: {
		%      'off',
		%      'on'
		%      }
		EnumeratedValues
		
		% IconPath
		%
		% A full file path to a 16x16 icon file.		
		%		
		% Ex:  fullfile(matlabroot,'toolbox','mytoolbox','myimages','on.png'),		
		%     
		IconPath
	end		
end

