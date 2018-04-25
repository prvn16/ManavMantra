function varargout = radon(varargin)
%RADON Radon transform.
%   The RADON function computes the Radon transform, which is the
%   projection of the image intensity along a radial line oriented at a
%   specific angle.
%
%   R = RADON(I,THETA) returns the Radon transform of the intensity
%   gpuArray image I for the angle THETA degrees. If THETA is a scalar, the
%   result R is a gpuArray column vector containing the Radon transform for
%   THETA degrees. If THETA is a vector, then R is a gpuArray matrix in
%   which each column is the Radon transform for one of the angles in
%   THETA. If you omit THETA, it defaults to 0:179.
%
%   [R,Xp] = RADON(...) returns a gpuArray vector Xp containing the radial
%   coordinates corresponding to each row of R.
%
%   Class Support
%   -------------
%   I can be a gpuArray with underlying class uint8, uint16, uint32, int8, 
%   int16, int32, logical, single or double and must be two-dimensional. 
%   THETA is a double vector or gpuArray vector of underlying class double.  
%   Neither of the inputs can be sparse.
%
%   Example
%   -------
%       iptsetpref('ImshowAxesVisible','on')
%       I = gpuArray(phantom(256));
%       theta = 0:179;
%       [R,xp] = radon(I,theta);
%       imshow(R,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(gca,hot), colorbar
%
%   See also FAN2PARA, FANBEAM, IFANBEAM, IRADON, PARA2FAN, PHANTOM.

%   Copyright 2013-2016 The MathWorks, Inc.

%Dispatch to CPU as needed.
if ~isa(varargin{1},'gpuArray')
    varargin = gatherIfNecessary(varargin{:});
    
    switch nargout
        case {0,1}
            varargout{1} = radon(varargin{:});
        case 2
            [varargout{1},varargout{2}] = radon(varargin{:});
        otherwise
            error(message('images:radonc:tooManyOutputs'));
    end
else
    
    switch nargout
        case {0,1}
            varargout{1} = images.internal.gpu.radon(varargin{:});    
        case 2
            [varargout{1},varargout{2}] = images.internal.gpu.radon(varargin{:});
        otherwise
            error(message('images:radonc:tooManyOutputs'));
    end
end

