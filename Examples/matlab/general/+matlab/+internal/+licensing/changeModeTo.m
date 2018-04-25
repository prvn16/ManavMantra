function changeModeTo(lmode)
%Change licensing mode that is used the next time MATLAB starts.
%   changeModeTo('file') changes to file mode.
%   changeModeTo('online') changes to online mode.

%   Copyright 2012 The MathWorks, Inc.


% Arg checking
narginchk(1, 1);
nargoutchk(0, 0);

% Call class based on input string
if (~strcmp(lmode, 'file') && ~strcmp(lmode,'online'))
    error('Input must be the string ''file'' or ''online''');
end

try
	myObj = com.mathworks.instutil.licensefiles.LModeSwitchingUtility();
	myObj.installMarkerFile(matlabroot, lmode);
catch x
	error(x.message)
end


