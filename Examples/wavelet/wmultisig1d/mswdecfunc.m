function varargout = mswdecfunc(option,dec,varargin)
%MSWDECFUNC Multisignal 1-D utilities functions.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Mar-2006.
%   Last Revision: 14-Nov-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

switch option
    case 'dircat'
        switch dec.dirDec
            case 'r' , varargout = {1};
            case 'c' , varargout = {2};
        end
        
    case {'flip','transpose'}
        switch dec.dirDec
            case 'r' , dec.dirDec = 'c'; dirCAT = 1;
            case 'c' , dec.dirDec = 'r'; dirCAT = 2;
        end
        dec.dataSize = fliplr(dec.dataSize);
        dec.ca = dec.ca';
        for k = 1:dec.level , dec.cd{k} = dec.cd{k}'; end
        varargout = {dec,dirCAT};

    case {'longs','decSizes'}
        level = dec.level;
        decSizes = zeros(level+2,2);
        decSizes(end,:) = dec.dataSize;
        for j = 1:level , decSizes(end-j,:) = size(dec.cd{j}); end
        decSizes(1,:) = size(dec.ca);
        if length(varargin)>0 , decSizes = flipud(decSizes); end
        switch dec.dirDec
            case 'r' , dirCAT = 2;
            case 'c' , dirCAT = 1;
        end
        switch option
            case 'decSizes' ,  varargout = {decSizes,dirCAT};
            case 'longs'
                longs = decSizes(:,dirCAT);
                if isequal(dec.dirDec,'r') , longs = longs'; end
                varargout = {longs,dirCAT};
        end
end
