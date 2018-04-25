function varargout=warndlg(varargin)

% Copyright 2010 The MathWorks, Inc.
mgg = 'off';
try 
    mgg=mls.internal.feature('graphicsAndGuis');
catch err
    %do nothing
end

if strcmp(mgg,'on')
   org = pwd;
   c = onCleanup(@()cleanup(org));
   cd(fullfile(matlabroot, 'toolbox','matlab','uitools'));
   if nargin==3
        if isstruct(varargin{3})
           varargin{3}.WindowStyle='non-modal';
        else
           varargin{3}='non-modal';
        end
   end
   handle=warndlg(varargin{:});
   if nargout==1
      varargout={handle};
   end
else 
   nse = connector.internal.notSupportedError;
   nse.throwAsCaller;
end

% cleanup the current directory and path
function cleanup(pth)
   cd(pth);
end

end