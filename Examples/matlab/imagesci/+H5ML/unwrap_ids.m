function varargout = unwrapIds(varargin)
% Preprocess the inputs to the HDF5 library MEX-function.
% Turn H5ML.ids into doubles when calling the library.

%   Copyright 2013 The MathWorks, Inc.

for i=1:nargin      % nargin must be equal to nargout
    if isa(varargin{i}, 'H5ML.id')
        varargout{i} = varargin{i}.identifier;
    else
        varargout{i} = varargin{i};
    end
end
