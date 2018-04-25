classdef StringEnumerationWithIcon 
	% This is an interface for data types that want to have their
	% editor be shown with a group of toggle buttons w/ icons.
	%
	% Copyright 2017 The MathWorks, Inc.
	
	properties(Abstract, Constant)		
		% EnumeratedValues
		%
		% A 1xN cell array of chars, where each value corresponds to a
		% valid enumerated value for the property
		%
		% Ex: {
		%      'left',
		%      'right'
		%      }
		EnumeratedValues
		
		% IconPaths
		%
		% A 1xN cell array of chars, where each value is a full file path
		% to a 16x16 icon file.
		%
		% The iTH element of IconPaths corresponds to the iTH
		% EnumeratedValues element.
		%
		% Ex: {
		%      fullfile(matlabroot,'toolbox','mytoolbox','myimages','left.png'),
		%      fullfile(matlabroot,'toolbox','mytoolbox','myimages','right.png'),
		%      }		
		IconPaths					
	end		
end

