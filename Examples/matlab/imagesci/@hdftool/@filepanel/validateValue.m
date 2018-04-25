function valid = validateValue(this, name, valueCell, minValue, maxValue)
%VALIDATEVALUE attempt to validate a value.
%   If the value is invalid, then an error dialog will be displayed.
%
%   Function arguments
%   ------------------
%   NAME: the name by which the value will be referred to
%     in the error dialog (in case the value is not valid).
%   VALUE: the value for which validation is requested.
%   MIN: The minimum value for the value.
%   MAX: The maximum value for the value.

%   Copyright 2005-2013 The MathWorks, Inc.
    valid=1;
    
    bNonEmpty = true;
    value = [valueCell{:}];
	dlgNameStr = getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection'));

    % Check the lower bound
    if any(value < minValue) && valid
	    errDlgStr = getString(message('MATLAB:imagesci:hdftool:validateLowerBound',name,num2str(minValue)));
        errordlg( errDlgStr, dlgNameStr );
        valid = 0;
    end

    % Check the upper bound
    if any(value > maxValue)
	    errDlgStr = getString(message('MATLAB:imagesci:hdftool:validateUpperBound',name,num2str(maxValue)));
        errordlg( errDlgStr, dlgNameStr );
        valid = 0;
    end

    % Determine if the value is required to be non-empty
    empty = cellfun('isempty', valueCell);
    if bNonEmpty && any(empty(:))
	    errDlgStr = getString(message('MATLAB:imagesci:hdftool:validateNotEmpty',name));
        errordlg( errDlgStr, dlgNameStr );
        valid = 0;
    end

    % Finally, thow an error which the caller should catch.
    if ~valid
        error(message('MATLAB:imagesci:hdftool:invalidValue'));
    end
    
end

