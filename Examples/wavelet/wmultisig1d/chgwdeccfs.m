function dec = chgwdeccfs(dec,type,coefs,varargin)
%CHGWDECCFS Change multisignal 1-D decomposition coefficients.
%   DEC = CHGWDECCFS(DEC,'ca',COEFS) replaces the approximation 
%   coefficients at level DEC.level by those contained in the 
%   matrix COEFS. If COEFS is a single value V, all the
%   coefficients are replaced by V.
%    
%   DEC = CHGWDECCFS(DEC,'cd',COEFS,LEV) replaces the detail 
%   coefficients at level LEV by those contained in the 
%   matrix COEFS. If COEFS is a single value V, then LEV
%   can be a vector of levels and all the coefficients 
%   that belong to these levels are replaced by V.
%   LEV must be such that:    1 <= LEV <= DEC.level
%
%   DEC = CHGWDECCFS(DEC,'all',CA,CD) replaces all the
%   the approximation coefficients and all the detail
%   coefficients. CA must be a matrix and CD must be   
%   a cell array of length DEC.level.
%
%   DEC = CHGWDECCFS(...,IDXSIG) replaces the coefficients
%   for the signals which indices are given by the vector 
%   IDXSIG. If the initial data are stored rowwise (resp. 
%   columnwise) in a matrix X, then IDXSIG contains the 
%   row (resp. the column) indices of concerned data. 
%
%   If COEFS (or CA, or CD) is a single number, then it replaces  
%   all the concerned coefficients. Else, COEFS (or CA, or CD)  
%   must be a matrix of appropriate size.
%
%   For a real value V, DEC = CHGWDECCFS(DEC,'all',V) replaces  
%   all the coefficients by V.
%
%   See also MDWTDEC, MDWTREC.

%   Note:
%   -----
%   For compatibility with previous 1-D-1-Signal storage, 
%   DEC = CHGWDECCFS(DEC,'all_CL',C) let you replace all the  
%   coefficients by those contained in the matrix C using 
%   the (C,L) structure storage. (See WAVEDEC for more 
%   information on (C,L) structure).
%   DEC = CHGWDECCFS(DEC,'all_CL',C,IDXSIG) replaces the 
%   coefficients of the signals which indices are given by 
%   IDXSIG.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-May-2005.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
nbIN = nargin;
narginchk(3,5);
nbIN_More = length(varargin);

type  = lower(type);
dirDec = dec.dirDec;
if isequal(dirDec,'c')
    dec = mswdecfunc('transpose',dec);
    coefs = coefs';
end
nbSIG = dec.dataSize(1);
oneVAL = isequal(size(coefs),[1 1]);
switch type
    case {'all_cl','ca'} , next = 1;
    case 'all'
        next = 1;
        switch nbIN
            case 3 , 
                if ~oneVAL ,  
                    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal')); 
                end
            case 4 ,
                if iscell(varargin{1}) || ...
                   (oneVAL && isequal(size(varargin{1}),[1 1]))
                    next = 2;
                else
                    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
                end
            case 5  , next = 2;
        end
        
        if isequal(dirDec,'c')
        end
    case 'cd' , next = 2;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
flagSIG   = nbIN_More>=next;
if flagSIG ,idxSIG = varargin{next}; else idxSIG = (1:nbSIG); end

switch type
    case 'all_cl'
        if ~oneVAL
            longs = mswdecfunc('longs',dec);
            first = cumsum(longs)+1;
            first = first(end-2:-1:1);
            nbCFS = longs(end-1:-1:2);
            last  = first+nbCFS-1;
            dec.ca(idxSIG,:)  = coefs(:,1:longs(1));
            for k = 1:dec.level
                dec.cd{k}(idxSIG,:) = coefs(:,first(k):last(k));
            end
        else
            dec.ca(idxSIG,:)  = coefs;
            for k = 1:dec.level , dec.cd{k}(idxSIG,:) = coefs; end
        end
    
    case 'all'
        dec.ca(idxSIG,:) = coefs;
        switch nbIN
            case 3
                for k = 1:dec.level
                    dec.cd{k}(idxSIG,:) = coefs;
                end
            case {4,5} 
                if ~iscell(varargin{1})
                    for k = 1:dec.level
                        dec.cd{k}(idxSIG,:) = varargin{1};
                    end
                else
                    if isequal(dirDec,'c') ,
                        for k = 1:length(varargin{1})
                            varargin{1}{k} = varargin{1}{k}';
                        end
                    end
                    for k = 1:dec.level
                        dec.cd{k}(idxSIG,:) = varargin{1}{k};
                    end                    
                end
        end
                
    case 'cd'
        if nbIN_More>0
            lev = varargin{1};
            if any(lev<1) || any(lev>dec.level)
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
            end
        end
        if ~oneVAL
            if length(lev)>1
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal')); 
            end
            dec.cd{lev}(idxSIG,:) = coefs;
        else
            if nbIN_More==0 , lev = 1:dec.level; end
            for k=1:length(lev)
                dec.cd{lev(k)}(idxSIG,:) = coefs;
            end
        end
        
    case 'ca'
        dec.ca(idxSIG,:) = coefs;
        
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
if isequal(dirDec,'c') , dec = mswdecfunc('transpose',dec);  end
