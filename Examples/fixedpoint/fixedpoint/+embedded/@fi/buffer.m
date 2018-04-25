function varargout = buffer(this,nSamps)
%BUFFER Buffer a signal vector into a matrix of data frames
%  Refer to the Signal Processing Toolbox BUFFER reference page for more
%  information.
%
%  See also BUFFER 

%   Copyright 1999-2012 The MathWorks, Inc.
%     
% buffer(x,n) == reshape([x(:); zeros(n-rem(length(x),n),1)],n,[]) 

if ~license('test','Signal_Toolbox')
  error(message('fixed:fi:noSignalToolboxLicense',mfilename));
end

error(nargoutchk(0,2,nargout,'struct'));

[m,n] = size(this);
if (m ~= 1 && n~= 1) || this.numberofelements == 0
  error(message('fixed:fi:cannotOperateOnMatrix'));
end

tmp = reshape(this,m*n,1);
if nargout < 2
  varargout = cell(1);
  pad = nSamps-rem(m*n,nSamps);
  if pad < nSamps % pad == nSamps => no pad needed
    varargout{1} = reshape([tmp; zeros(pad,1)],nSamps,[]);
  else
    varargout{1} = reshape(tmp,nSamps,[]);
  end
else
  len = nSamps*floor(m*n/nSamps);
  varargout = cell(1,2);
  y = subscriptedreference(tmp,0:len-1);
  varargout{1} = reshape(y,nSamps,[]);
  z = subscriptedreference(this,len:m*n-1);
  varargout{2} = z;
end

% LocalWords:  Samps
