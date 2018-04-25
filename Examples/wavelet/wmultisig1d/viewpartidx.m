function varargout = viewpartidx(varargin)
%VIEWPARTIDX View partitions links and similarity indices.
%	VIEWPARTIDX computes and shows partitions links and 
%   similarity indices.

%   Copyright 2006-2015 The MathWorks, Inc.

%      VARARGOUT = VIEWPARTIDX(VARARGIN)
%      VARARGOUT = {Partitions,LNK_SIM_STRUCT,tab_IdxCLU};
%      For Partitions and LNK_SIM_STRUCT see PARTLNKANDSIM.
%      For tab_IdxCLU, see below.
%
%  Examples.
%  ---------
%   [...] = VIEWPARTIDX(NUMEX) shows examples.
%   [...] = VIEWPARTIDX is equivalent to [...] = VIEWPARTIDX(1). 
%   The valid values for NUMEX are 1, 2 and 3.
%   When NUMEX = 1 or 2, previously computed partitions are loaded.
%   For NUMEX = 2 the original FILEDATANAME is not known.
%   For NUMEX = 3, the original FILEDATANAME is 's3p3_30.mat' 
%   and the direction of analysis is 'col', SHOWPARTTOOL can 
%   display original signals.
%   For NUMEX = 3, full computation is done using MDWTCLUSTER 
%  (see below) and the result is saved in 'exSave_TAB_PART.mat'
%     Examples:
%         [Partitions,LNK_SIM_STRUCT,tab_IdxCLU] = viewpartidx(1);
%         viewpartidx(2)
%
%  Full Help.
%  ---------
%   [...] = VIEWPARTIDX('clusters',FILECLUNAME) or 
%   [...] = VIEWPARTIDX('clusters',FILECLUNAME,FILEDATANAME) or
%   [...] = VIEWPARTIDX('clusters',FILECLUNAME,FILEDATANAME,DIRDEC)
%   The FILECLUNAME must contain variable "tab_IdxCLU" which an 
%   array of size (nbSIG x nbPART) such that tab_IdxCLU(j,k) is
%   the number of cluster for the jth signal in the partition Pk.
%     Examples:
%         viewpartidx('clusters','ex1_TAB_PART')
%         viewpartidx('clusters','ex3_TAB_PART','s3p3_30','r')
%   -------------------------------------------------------------
%   [...] = VIEWPARTIDX('compute',FILEDATANAME) or
%   [...] = VIEWPARTIDX('compute',FILEDATANAME,DIRDEC)
%     Examples:
%         viewpartidx('compute','s3p3_30','r')
%         viewpartidx('compute','elecsig100.mat')
%   Default for DIRDEC is 'r' (row).
%   The clusters are computed using MDWTCLUSTER with the default
%   values (see below) except 'linkage' which is set to 'ward'.
%
%   [...] = VIEWPARTIDX('compute',FILEDATANAME,{'MDWTCLUSTER Params'})
%   (see below). The file FILEDATANAME must contain the variable
%   "signals".
%   Example:
%     PROP_1 = {'dirDec','r','level',4,'linkage','ward'};
%     PROP_2 = {'lst2clu',{'s','a1','a2'}};
%     PROP   = {PROP_1{:} , PROP_2{:}};
%     viewpartidx('compute','s3p3_30',PROP{:})
%
%   Instead of FILEDATANAME, the matrix of data DATAVAL
%    may be used. [...] = VIEWPARTIDX('compute',DATAVAL,...)
%------------------------------------------------------------------
% S = MDWTCLUSTER(X,'PropName1',PropVal1,'PropName2',PropVal2,,...)
% The valid choices for PropName are:
%   'dirDec'   - 'r' (row) or 'c' (column) - default 'r'.
%   'level'    - level of DWT decomposition.
%                default is: level = fix(log2(size(X,d))) (d = 1 or 2).
%   'wname'    - wavelet used for the DWT - default is 'haar'.
%   'dwtEXTM'  - see DWTMODE  - default is 'sym'.
%   'pdist'    - see PDIST    - default is 'euclidean'.
%   'linkage'  - see LINKAGE  - default is 'average'.
%   'maxclust' - number of clusters - default is 6.
%                The input may be a vector.
%   'lst2clu'  - Cell array which contains the list of data to classify.
%                If N is the level of decomposition, allowed values are:
%                   's'   (signal) , 'aj' (approximation at level j),
%                   'dj'  (detail at level j),
%                   'caj' (coefficients of approximation at level j),
%                   'cdj' (coefficients of detail at level j),
%                          with j = 1 , ... ,N
%                   The default is: lst = {'s' ; 'ca1' ; ... ; 'caN'}.
%
%    S.IdxCLU(:,j) containts the cluster numbers obtained from the
%------------------------------------------------------------------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jan-2005.
%   Last Revision: 07-May-2008.

noDISP = false;
nbIN = length(varargin);
nextARG = 0;
if nbIN>0
    nextARG = 1;
    if isequal(lower(varargin{1}),'nodisp')
        nextARG = 2; noDISP = true;
    end
    numEX = varargin{nextARG};
else
    numEX = 1;
end
nextARG = nextARG+1;

% Defaults
dirDec = 'r';
filepartname = ''; 
filedataname = ''; 
switch numEX
    case 1 , filedataname = 's3p3_30.mat';filepartname = 'ex1_TAB_PART.mat';
    case 2 , filepartname = 'ex1_TAB_PART.mat';
    case 3 , filedataname = 's3p3_30.mat';
    case 'clusters'
        if nbIN < nextARG
            error(message('MATLAB:narginchk:notEnoughInputs'));
        elseif nbIN > nextARG+2
            error(message('MATLAB:narginchk:tooManyInputs'));
        end
        filepartname = varargin{nextARG};
        nextARG = nextARG+1;
        if nbIN>=nextARG           
            filedataname = varargin{nextARG};
            nextARG = nextARG+1;
            if nbIN>=nextARG
                dirDec = varargin{nextARG};
                nextARG = nextARG+1;
            end
        end        
    case 'compute'
        if nbIN < nextARG
            error(message('MATLAB:narginchk:notEnoughInputs'));
        elseif nbIN > nextARG+16
            error(message('MATLAB:narginchk:tooManyInputs'));
        end
        if ~ischar(varargin{nextARG})
            signals = varargin{nextARG};
            filedataname = '';
        else
            filedataname = varargin{nextARG};
        end
        nextARG = nextARG+1;
        if nbIN==nextARG
            dirDec = varargin{nextARG}; 
            nextARG = nextARG+1;
        end
end
if isempty(filepartname)
    if ~isempty(filedataname)
        signals = msloadutl(filedataname);
    end
    switch nbIN
        case {nextARG-1,nextARG}
            S = mdwtcluster(signals,'linkage','ward','dirDec',dirDec);
        otherwise
            idx = find(strcmpi(varargin,'dirDec'));
            if ~isempty(idx) , dirDec = varargin{idx+1}; end
            S = mdwtcluster(signals,varargin{nextARG:end});
    end
    tab_IdxCLU = S.IdxCLU;
    clear S
    if isequal(numEX,3) , save exSave_TAB_PART tab_IdxCLU; end
else
    load(filepartname);
end
[Partitions,LNK_SIM_STRUCT,tab_IdxCLU] = partlnkandsim(tab_IdxCLU);
if nargout>0
    varargout = {Partitions,LNK_SIM_STRUCT,tab_IdxCLU};
end
if noDISP , return; end
showparttool(Partitions,LNK_SIM_STRUCT,filedataname,dirDec);

    
