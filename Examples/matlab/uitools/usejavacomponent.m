function result = usejavacomponent
% WARNING: This feature is not supported in MATLAB
% and the API and functionality may change in a future release.

% RESULT = USEJAVACOMPONENT Returns whether JAVACOMPONENT is supported on the
% platform. This function will return TRUE if the JAVACOMPONENT function is
% supported and return FALSE otherwise.
% If JAVACOMPONENT is called on a platform that returns FALSE for
% USEJAVACOMPONENT, JAVACOMPONENT will throw an errror.
%
% Examples:
%
%   f = figure;
%   if (usejavacomponent)
%     b = javacomponent('javax.swing.JButton'); % Thread safe creation
%     set(b,'ActionPerformedCallback','disp Hi!');
%   end
%
% See also JAVACOMPONENT, AWTCREATE, AWTINVOKE

% Copyright 2006 The MathWorks, Inc.

result = usejava('awt');
