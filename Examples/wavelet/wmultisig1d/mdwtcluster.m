function S = mdwtcluster(X,varargin)
%MDWTCLUSTER Multisignal 1-D hierarchical clustering.
%   S = MDWTCLUSTER(X) clusters data using hierarchical clustering.
%   cluster trees. The input X is a matrix which is decomposed in
%   row direction with the DWT, using Haar's wavelet and the maximum
%   allowed level (fix(log2(size(X,2))).
%
%   S = MDWTCLUSTER(X,'PropName1',PropVal1,'PropName2',PropVal2,,...)
%   The valid choices for PropName are:
%     'dirDec'   : 'r' (row) or 'c' (column).
%     'level'    : level of DWT decomposition.
%                  default is: level = fix(log2(size(X,d)))
%                  d = 1 or 2, depending on 'dirDec' value.
%     'wname'    : wavelet used for the DWT - default is 'haar'.
%     'dwtEXTM'  : DWT extension mode (see DWTMODE).
%     'pdist'    : see PDIST    - default is 'euclidean'.
%     'linkage'  : see LINKAGE  - default is 'ward'.
%     'maxclust' : number of clusters - default is 6.
%                  The input may be a vector.
%     'lst2clu'  : Cell array which contains the list of data to classify.
%          If N is the level of decomposition, allowed values are:
%             's'   (signal)
%             'aj'  (approximation at level j),
%             'dj'  (detail at level j),
%             'caj' (coefficients of approximation at level j),
%             'cdj' (coefficients of detail at level j),
%                    with j = 1 , ... ,N
%             The default is: {'s' ; 'ca1' ; ... ; 'caN'}.
%
%   The output S is a structure such that for each partition j:
%       S.IdxCLU(:,j) containts the cluster numbers obtained from the
%                     hierarchical cluster tree (See CLUSTER).
%            N.B.: If maxclustVal is a vector, IdxCLU is a multidimensional
%                  array such that IdxCLU(:,j,k) containts the cluster
%                  numbers obtained from the hierarchical cluster tree
%                  for k clusters.
%
%       S.Incons(:,j) containts the Inconsistent values of each non-leaf
%                     node in the hierarchical cluster tree
%                     (See INCONSISTENT).
%
%       S.Corr(j) containts the Cophenetic correlation coefficients of
%                 the partition (See COPHENET).
%   Example:
%       load elecsig10
%       lst2clu = {'s','ca1','ca3','ca6'};
%       S = mdwtcluster(signals,'maxclust',4,'lst2clu',lst2clu)
%       IdxCLU = S.IdxCLU;
%       plot(signals(IdxCLU(:,1)==1,:)','r');
%       hold on; plot(signals(IdxCLU(:,1)==3,:)','b')
%       equalPART = isequal(IdxCLU(:,1),IdxCLU(:,3))

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Oct-2005.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check input.
isstatsinstalled = ~isempty(ver('stats'));
tfstats = license('test', 'statistics_toolbox');
if (~isstatsinstalled || ~tfstats)
    error(message('Wavelet:mdw1dRF:StatsRequired'));
end
nbIN = length(varargin);
if isstruct(X)
    dec = X;
    decFLAG = true;
elseif isnumeric(X)
    decFLAG = false;
else
    error(message('Wavelet:FunctionArgVal:Invalid_ArgTyp'))
end

% Default values.
%----------------
% level_DEF = defined below
% Data_ToCLUST_DEF = defined below
dirDec_DEF = 'r';
wname_DEF  = 'haar';
distPAR_DEF = 'euclidean';
linkPAR_DEF = 'ward';
NbCLU_DEF   = 6;
%----------------------------------

% Initialize.
%------------
dirDec = '';
level = [];
wname = '';
distPAR = '';
linkPAR = '';
NbCLU   = [];
Data_ToCLUST = '';
dwtEXTM = 'sym';

% Check inputs.
%--------------
for k=1:2:nbIN
    argName = lower(varargin{k});
    argVAL  = varargin{k+1};
    switch argName
        case 'dirdec'   , dirDec  = lower(argVAL(1));
        case 'level'    , level   = argVAL;
        case 'wname'    , wname   = argVAL;
        case 'dwtextm'  , dwtEXTM = argVAL;
        case 'pdist'    , distPAR = argVAL;
        case 'linkage'  , linkPAR = argVAL;
        case 'maxclust' , NbCLU   = argVAL;
        case 'lst2clu'  , Data_ToCLUST = argVAL;
    end
end

% Initialize and Check inputs (finish).
%-------------------------------------
if isempty(distPAR) , distPAR = distPAR_DEF; end
if isempty(linkPAR) , linkPAR = linkPAR_DEF; end
if isempty(NbCLU) ,   NbCLU = NbCLU_DEF; end
if decFLAG
    dirDec = dec.dirDec;
    if isequal(dirDec,'c') , dec = mswdecfunc('transpose',dec); end
    wname = dec.wname;
    level = dec.level;
    nbSIG = dec.dataSize(1);
else
    if isempty(wname) ,  wname = wname_DEF; end
    if isempty(dirDec) , dirDec = lower(dirDec_DEF(1)); end
    if isequal(dirDec,'c') , X = X'; end
    [nbSIG,nbVAL] = size(X);
    if ~isequal(Data_ToCLUST,{'s'})
        level_DEF = fix(log2(nbVAL));
        if isempty(level) , level = level_DEF; end
    else
        level = 0;
    end
end
Data_ToCLUST_DEF = cell(1,level+1);
Data_ToCLUST_DEF(1) = {'s'};
for k=1:level
    Data_ToCLUST_DEF{k+1}= ['ca' int2str(k)];
end
if isempty(Data_ToCLUST) , Data_ToCLUST = Data_ToCLUST_DEF; end
nbPART = length(Data_ToCLUST);

if decFLAG
    if any(strcmp(Data_ToCLUST,'s')) , X = mdwtrec(dec); end
elseif level>0
    dec = mdwtdec('r',X,level,wname,'dwtEXTM',dwtEXTM);
end

nb_NbCLU = length(NbCLU);
IdxCLU = zeros(nbSIG,nbPART,nb_NbCLU);
InCONS = zeros(nbSIG-1,nbPART);
CophCORR = zeros(1,nbPART);
for j=1:nbPART
    partName = lower(Data_ToCLUST{j});
    switch partName(1)
        case 's'
            XtoCLU = X;
        case {'a','d'}
            num = str2double(partName(2:end));
            XtoCLU = mdwtrec(dec,partName(1),num);
        case 'c'
            num = str2double(partName(3:end));
            switch partName(2)
                case 'd' , XtoCLU = dec.cd{num};
                case 'a' , XtoCLU = mdwtrec(dec,'ca',num);
            end
    end
    Y = pdist(XtoCLU,distPAR);
    Z = linkage(Y,linkPAR);
    
    % Inconsistent values of a cluster tree.
    I = inconsistent(Z,2);
    InCONS(:,j) = I(:,4);
    
    % Cophenetic correlation coefficient
    [CophCORR(j),D] = cophenet(Z,Y); %#ok<NASGU>
    
    % Compute clusters.
    for k = 1:nb_NbCLU
        IdxCLU(:,j,k) = wtbxcluster(Z,NbCLU(k));
    end
end
S = struct('IdxCLU',IdxCLU,'Incons',InCONS,'Corr',CophCORR);
