classdef FontWeight < internal.matlab.variableeditor.datatype.BinaryStringEnumerationWithIcon	
  properties(Constant)													
		IconPath = fullfile(matlabroot, 'toolbox', 'matlab', 'uicomponents', 'uicomponents', 'plugin', 'appdesigner', '+inspector', '+internal', '+datatype', 'images', 'FontWeight.png')						
		
		EnumeratedValues = {...
			'normal', ...			
			'bold', ...			
			}			
	end	
end