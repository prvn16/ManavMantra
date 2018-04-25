function varargout = viewclust(varargin)
%VIEWCLUST View clusters in partitions.
%	VIEWCLUST computes and shows partitions clusters

%   Copyright 2006-2015 The MathWorks, Inc.

%   VIEWCLUST('clusters',FILECLUNAME,FILEDATANAME) or
%   VIEWCLUST('clusters',FILECLUNAME,FILEDATANAME,DIRDEC)
%   The FILECLUNAME must contain variable "tab_IdxCLU" which an 
%   array of size (nbSIG x nbPART) such that tab_IdxCLU(j,k) is
%   the number of cluster for the jth signal in the partition Pk.
%   Examples:
%       viewclust('clusters','ex1_TAB_PART','s3p3_30','r')
%
%   VIEWCLUST('compute',FILEDATANAME) or
%   VIEWCLUST('compute',FILEDATANAME,DIRDEC)
%   Examples:
%       viewclust('compute','s3p3_30','r');
%       viewclust(1); % is equivalent to the previous example.
%
%   The clusters are computed using MDWTCLUSTER with the default
%   values (see below) except 'linkage' which is set to 'ward'.
%   Default value for DIRDEC is 'r'.
%
%   VIEWCLUST('compute',FILEDATANAME,{'MDWTCLUSTER Params'})
%   (see MDWTCLUSTER).
%   The file FILEDATANAME must contain the variable "signals" or "X".
%   
%   Example:
%     PROP_1 = {'dirDec','r','level',4,'linkage','ward'};
%     PROP_2 = {'lst2clu',{'s','a1','a2'}};
%     PROP   = {PROP_1{:} , PROP_2{:}};
%     viewclust('compute','s3p3_30',PROP{:})
%
%    Partitions = VIEWCLUST(...)
%    [Partitions,tab_IdxCLU = VIEWCLUST(...)
%    Example:
%       [Partitions,tab_IdxCLU] = viewclust(3);
%
%   Instead of FILEDATANAME, the matrix of data DATAVAL
%   may be used. [...] = VIEWCLUST('compute',DATAVAL,...)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jan-2005.
%   Last Revision: 07-May-2008.

nbIN = length(varargin);
nextARG = 0;
if nbIN>0
    nextARG = 1;
    if isequal(lower(varargin{1}),'nodisp')
        nextARG = 2;
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
    case 1
        filedataname = 's3p3_30.mat';
        filepartname = 'exSave_TAB_PART.mat';
        
    case {2,3}
        filedataname = 's3p3_30.mat';
        
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
    if isequal(numEX,2) , save exSave_TAB_PART tab_IdxCLU; end
else
    load(filepartname);
end

if nargout>0
    Partitions = tab2part(tab_IdxCLU);
    varargout = {Partitions,tab_IdxCLU};
end
showclusters(filedataname,tab_IdxCLU,dirDec);

    
