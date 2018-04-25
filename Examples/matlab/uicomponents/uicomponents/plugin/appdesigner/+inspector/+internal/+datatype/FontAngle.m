classdef FontAngle < internal.matlab.variableeditor.datatype.BinaryStringEnumerationWithIcon	
  properties(Constant)													
		IconPath = fullfile(matlabroot, 'toolbox', 'matlab', 'uicomponents', 'uicomponents', 'plugin', 'appdesigner', '+inspector', '+internal', '+datatype', 'images', 'FontAngle.png')						
		
		EnumeratedValues = {...
			'normal', ...			
			'italic', ...			
			}			
	end	
end