function varargout = isstatstbxinstalled(arg) %#ok<INUSD>
%ISSTATSTBXINSTALLED Returns true if Statistics and Machine Learning toolbox is installed.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Sep-2006.
%   Last Revision: 23-Oct-2014.
%   Copyright 1995-2014 The MathWorks, Inc.

strMSG(1) = {getWavMSG('Wavelet:mdw1dRF:Stats_NotAvailable');};
strMSG(2) = {' '};
b = license('test','Statistics_Toolbox') && ~isempty(ver('stats'));
if b
    errstr = getWavMSG('Wavelet:mdw1dRF:Stats_Available'); errID = 0;
else
    errID = 2;
    strMSG(3) = {...
        'To use clustering functionality tool make sure that'};
    strMSG(4) = {...    
        ['the Statistics and Machine Learning Toolbox is installed and '...
        'that a license is available.']};
end

if errID>0
    errstr = sprintf('%s\n%s\n%s\n%s',strMSG{:});    
end

if nargin<1
    varargout = {b,errstr,errID};
else
    varargout = {errstr};
end
