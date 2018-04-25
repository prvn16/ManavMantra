function [coefs,longs,dirCAT] = wdec2cl(dec,type,varargin)
%WDEC2CL Convert multisignal 1-D decomposition structure.
%   Using the wavelet decomposition structure DEC(see MDWTDEC),
%   [C,L] = WDEC2CL(DEC) returns a matrix C and a vector L.
%   When DEC.dirDec = 'r' (resp. 'c'), each row (resp. column) 
%   of C contains the concatenation of coefficients of the 
%   decompositions of the corresponding row (resp. column)
%   of the original matrix X. L is a row (resp. column)
%   vector which contains the lengths of each family of
%   coefficients. (See WAVEDEC for more information on 
%   (C,L) structure).
%
%   [C,L] = WDEC2CL(DEC,'ca') returns the coefficients and the
%   length of the approximation at level LEVDEC = DEC.level.
%
%   [C,L] = WDEC2CL(DEC,'cd',LEV) returns the coefficients and 
%   the length of the detail at level LEV.
%
%   [C,L] = WDEC2CL(DEC,'cd') returns the coefficients and the
%   lengths of the details at levels LEVDEC, LEVDEC-1, ..., 1.
%
%   [C,L] = WDEC2CL(DEC,TYPE,LEV,IDXSIG) returns the coefficients 
%   and the lengths for the signals which indices are given by
%   the vector IDXSIG.
%
%   See also MDWTDEC, MDWTREC, WAVEDEC, WAVEREC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jan-2005.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

if nargin<2
    type = 'cfs';
elseif isnumeric(type)
    varargin{1} = type;
    type = 'cfs';
end

[longs,dirCAT] = mswdecfunc('longs',dec);
switch type
    case 'ca'
        longs = longs(1);
        coefs = dec.ca;
        next = 1;
    
    case 'cd'
        if nargin<3 , lev = 'all'; else lev = varargin{1}; end
        if isnumeric(lev) && (lev<=dec.level)
            coefs = dec.cd{lev};
            longs = longs(end-lev);
        else
            coefs = cat(dirCAT,dec.cd{end:-1:1});
            longs = longs(2:end-1);
        end
        next = 2;

    case {'cfs','all'}
        coefs = cat(dirCAT,dec.ca,cat(dirCAT,dec.cd{end:-1:1}));
        if nargin<2 , return; end
        next = 1;
        
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end

flagSIG = length(varargin)>=next;
if flagSIG
    idxSIG = varargin{next};
    if ~ischar(idxSIG)
        switch dec.dirDec;
            case 'r' , coefs = coefs(idxSIG,:);
            case 'c' , coefs = coefs(:,idxSIG);
        end
    end
end
