function errString = error_msg()
%H5ML.error_msg  Retrieves error message from error stack.
%
%   H5ML.error_msg is not recommended.  Use TRY/CATCH instead.

%   This function walks the default error stack and retrieves the last
%   (outermost) error message.

%   Copyright 2006-2013 The MathWorks, Inc.

    errString = '';

	% We know that this is the correct value for H5E_WALK_UPWARD.  Were 
	% we to retrieve it using H5ML.get_constant_value, this would have 
	% the effect of clearing the error stack and defeating the entire
	% purpose for this routine.
	direction = H5ML.get_constant_value('H5E_WALK_UPWARD');
    H5E.walk(direction, @errorIterator);


    % Print the specifics of the HDF5 error iterator.
    function output = errorIterator(n, H5err_struct) %#ok<INUSL>
        errString = sprintf('\n"%s"', H5err_struct.desc);
        output = 1;
    end

end
