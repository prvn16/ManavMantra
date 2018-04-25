function varargout = hdf5(functionName, varargin)
%HDF5 A gateway to the HDF5 MEX library.
%
%   This function is not recommended.  Use the individual HDF5 packages instead.

%   Copyright 2006-2013 The MathWorks, Inc.

% Check the number of arguments
narginchk(1,Inf);
validateattributes(functionName,{'char'},{'nonempty'},'','FUNCTIONNAME');

% Invalidate the identifier if we are closing it.
if ((numel(functionName) > 5) && strcmpi(functionName(end-4:end), 'close'))
    close(varargin{1});
    return
end

switch(functionName)
    case {'H5close','H5garbage_collect','H5get_libversion','H5open','H5set_free_list_limits'}
        fname = sprintf('H5.%s',functionName(3:end));
    otherwise
        fname = sprintf('%s.%s',functionName(1:3),functionName(4:end));
end

[varargout{1:nargout}] = feval(fname,varargin{:});
