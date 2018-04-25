function varargout = de1dtool(option,varargin)
%DE1DTOOL Density estimation 1-D tool.
%   VARARGOUT = DE1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Nov-98.
%   Last Revision 08-May-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
switch option
    case 'create'
        win_tool = wdretool('createDEN');
        if nargout>0 , varargout{1} =  win_tool; end

    case 'close' , wdretool('close');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
