function bfitclearappdata(obj)
% BFITCLEARAPPDATA is used to remove Basic Fitting and Data Stats 
% application data from Basic Fitting and Data Stats objects (OBJ). 
% It should be used only by private Basic Fitting and Data Stats 
% functions. 

%   Copyright 1984-2005 The MathWorks, Inc.

ad = getappdata(double(obj));
names = fieldnames(ad);

% decrement figure's Data Counter if the line being removed
% is the last line in the legend. That way removing and
% adding while changing x and y data is a no-op.
try
  dname = ad.bfit_dataname;
  if strncmp(dname,'data ',5)
    n = str2double(dname(6:end));
    fig = ancestor(obj,'figure');
    countstart = getappdata(fig,'Basic_Fit_Data_Counter');
    if countstart == n+1
      setappdata(fig,'Basic_Fit_Data_Counter',countstart-1);
    end
  end
catch
end

for i = 1:length(names)
	if ( strncmp(names{i}, 'bfit', 4) || ...
		 strncmp(names{i}, 'Basic_Fit_', 10) || ...
		 strncmp(names{i}, 'Data_Stats_', 11))
		rmappdata(double(obj), names{i});
	end
end
