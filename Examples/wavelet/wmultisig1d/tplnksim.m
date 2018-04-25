function varargout = tplnksim(option,P1,P2,flagPLOT)
%TPLNKSIM Two partitions links and similarity indices.
%
%   OUT = TPLNKSIM(OPTION,P1,P2) returns similarity 
%   indices values between the partitions P1 and P2.
%
%   OUT depends on OPTION value. The valid choices for 
%   OPTION are: 
%      'All'  (all similarity indices are returned) or 
%      'Rand' , 'Jaccard' , 'HubAra' , 'Wallace' , 'ICL' , 'ILN'
%      'MacNemar' , 'RandAsym' , 'FolkMal'.
%    If OPTION is 'All', OUT is an array which contains all the
%    similarity indices else OUT is the value of corresponding
%    index.
%
%    [OUT,LNKNUM] = TPLNKSIM(OPTION,P1,P2) returns a four 
%    numbers array LNKNUM = [R,S,U,V] such that: 
%      R is the number of pairs simultaneously joined in P1 and P2.
%      S is the number of pairs simultaneously separated in P1 and P2.
%      U is the number of pairs joined in P1 and separated P2.
%      V is the number of pairs separated in P1 and joined P2.
%
%    [OUT,LNKNUM,P1_and_P2,notP1_and_notP2,...
%        P1_and_notP2,notP1_and_P2] = TPLNKSIM(OPTION,P1,P2)
%    returns four arrays such that:
%      - P1_and_P2(i,j) = 1 if (i,j) simultaneously joined 
%        in P1 and P2 and 0 otherwise.
%      - notP1_and_notP2(i,j) = 1 if (i,j) simultaneously 
%        separated in P1 and P2 and 0 otherwise.
%      - P1_and_notP2(i,j) = 1 if (i,j) joined in P1 and
%        separated in P2 and 0 otherwise.
%      - notP1_and_P2(i,j) = 1 if (i,j) separated in P1 and 
%        joined in P2 and 0 otherwise.
%
%   ... = TPLNKSIM(...,flagPLOT) plots the previous array 
%   with the SPY function.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2015 The MathWorks, Inc.

% Similarity indices.
%--------------------
idx_Attrb = ...
    {'Rand' ,     'R' ;  ...
     'Jaccard' ,  'J' ;  ...
     'HubAra' ,   'HA';  ...
     'Wallace' ,  'W' ;  ...
     'MacNemar',  'MN';  ...
     'ILN',       'ILN'; ...     
     'ICL' ,      'ICL'; ...
     'RandAsym' , 'RA';  ...
     'FolkMal',   'FM'   ...
     };

%----------------------------------------------------------
% Rem: We introduce Rand Asymmetric IDX in a next version.
% Rem: It seems that Wallace IDX == Folkes Mallow IDX.
% idx_Attrb(end-1:end,:) = [];
idx_Attrb(end,:) = [];
%----------------------------------------------------------
if nargin<1 
    varargout{1} = idx_Attrb;
    return
end

% Check input arguments.
narginchk(3,4)
option = lower(option);
if ~isequal(option,'all')
    idx = find(strcmpi(idx_Attrb(:,1),option),1);
    if isempty(idx)
        idx = find(strcmpi(idx_Attrb(:,2),option),1);
        if isempty(idx)
             error(message('Wavelet:FunctionArgVal:Invalid_ParVal', option));
        end
    end
    option = idx_Attrb{idx,2};
end
if nargin<4 , flagPLOT = false; end
    
% Computation of Links.
nbSIG = size(P1.IdxCLU,1);
nbPAIRES = nbSIG*(nbSIG-1)/2;
[link_P1,pi_P1,VP1] = part_LINKS(P1);
[link_P2,pi_P2,VP2] = part_LINKS(P2);
[R,S,U,V,P1_and_P2,notP1_and_notP2,P1_and_notP2,notP1_and_P2] = ...
    two_part_LINKS(link_P1,link_P2);

% Test error of computation.
total = R + S + U + V;
notOK = abs(nbPAIRES-total);
if notOK
    error(message('Wavelet:FunctionToVerify:PartLinks'));
end

% Rand Index.
Rand_IDX = (R+S)/nbPAIRES;

% Rand Asym. Index.
Rand_ASYM_IDX = (2*(R+S+U)+nbSIG)/(nbSIG*nbSIG);

% Jaccard Index.
Jaccard_IDX = R/(R+U+V);

% Folkes and Mallows
FM_IDX = R/sqrt((R+U)*(R+V));

% Hubert & Arabie Index.
[ER,VR,MR] = exp_AND_var(nbSIG,nbPAIRES,pi_P1,VP1,pi_P2,VP2);
HubAra_IDX = (R-ER)/(MR-ER);

% Wallace Index.
Wallace_IDX = R/sqrt(pi_P1*pi_P2);

% Lerman Index.
ICL_IDX = ICL_IDX_Fun(R,ER,VR);

% Normalized Lerman Index.
[ER,VR] = exp_AND_var(nbSIG,nbPAIRES,pi_P1,VP1);
ICL_IDX_1 = (pi_P1-ER)/sqrt(VR);
[ER,VR]   = exp_AND_var(nbSIG,nbPAIRES,pi_P2,VP2);
ICL_IDX_2 = ICL_IDX_Fun(pi_P2,ER,VR);
ILN_IDX   = ICL_IDX/sqrt(ICL_IDX_1*ICL_IDX_2);

% MacNemar Index.
if isequal(abs(U+V),0)
    MacNemar_IDX = 1;
else
    MacNemar_IDX = abs(U-V)/(U+V);
end

switch option
    case 'all' , varargout{1} = ...
       [Rand_IDX,Jaccard_IDX,HubAra_IDX,Wallace_IDX, ...
        MacNemar_IDX,ILN_IDX,ICL_IDX,Rand_ASYM_IDX,FM_IDX];
    case 'R'   , varargout{1} = Rand_IDX;
    case 'J'   , varargout{1} = Jaccard_IDX;
    case 'HA'  , varargout{1} = HubAra_IDX;
    case 'W'   , varargout{1} = Wallace_IDX;      
    case 'ICL' , varargout{1} = ICL_IDX;        
    case 'ILN' , varargout{1} = ILN_IDX;
    case 'MN'  , varargout{1} = MacNemar_IDX;
    case 'RA'  , varargout{1} = Rand_ASYM_IDX;
    case 'FM'  , varargout{1} = FM_IDX;
end
if nargout>1
    varargout = {varargout{1} , [R,S,U,V]};
    if nargout>2
        varargout = [varargout , ...
            P1_and_P2,notP1_and_notP2,P1_and_notP2,notP1_and_P2];
    end
end
if flagPLOT
    figure;
    subplot(2,2,1); spy(P1_and_P2);       title('P1 and P2');
    subplot(2,2,2); spy(notP1_and_notP2); title('notP1 and notP2');
    subplot(2,2,3); spy(P1_and_notP2);    title('P1 and notP2');
    subplot(2,2,4); spy(notP1_and_P2);    title('notP1 and P2');
end
%--------------------------------------------------------------------------
function ICL_IDX = ICL_IDX_Fun(R,ER,VR)
if isequal(VR,0)
    ICL_IDX = sign((R-ER))*Inf;
else
    ICL_IDX = (R-ER)/sqrt(VR);
end
%--------------------------------------------------------------------------
function [link_P,pi_P,VP] = part_LINKS(P)

nbSIG = size(P.IdxCLU,1);
link_P = zeros(nbSIG,nbSIG,'uint8');
for k = 1:nbSIG
    numCLU = P.IdxCLU(k);
    link_P(k,P.IdxInCLU{numCLU}) = 1;
end
pi_P = (nnz(link_P)-nbSIG)/2;
VP = zeros(1,3);
N = P.NbInCLU;
VP(1) = sum(N.*(N-1));
VP(2) = sum(N.*(N-1).*(N-2));
VP(3) = VP(1)*VP(1) - 2*sum(N.*(N-1).*(2*N-3));
%--------------------------------------------------------------------------
function [R,S,U,V,P1_and_P2,notP1_and_notP2,P1_and_notP2,notP1_and_P2] = ...
    two_part_LINKS(link_P1,link_P2)

if nargin<2 , link_P2 = link_P1; end
nbSIG = size(link_P1,1);
P1_and_P2 = link_P1 & link_P2;
R = (nnz(P1_and_P2)-nbSIG)/2;
notP1_and_notP2 = ~link_P1 & ~link_P2;
S =  nnz(notP1_and_notP2)/2;
P1_and_notP2 = link_P1 & ~link_P2;
U = nnz(P1_and_notP2)/2;
notP1_and_P2 = ~link_P1 & link_P2;
V = nnz(notP1_and_P2)/2;
%--------------------------------------------------------------------------
function [ER,VR,MR] = exp_AND_var(nbSIG,nbPAIRES,pi_P1,VP1,pi_P2,VP2)

if nargin==4 , pi_P2 = pi_P1; VP2 = VP1; end
MR = (pi_P1+pi_P2)/2;
ER = (pi_P1+pi_P2)/nbPAIRES;
VR = ...
    VP1(1)*VP2(1)/(2*nbSIG*(nbSIG-1)) + ...
    VP1(2)*VP2(2)/(nbSIG*(nbSIG-1)*(nbSIG-2)) + ...
    VP1(3)*VP2(3)/(4*nbSIG*(nbSIG-1)*(nbSIG-2)*(nbSIG-3)) - ...
    (VP1(1)*VP2(1)/(2*nbSIG*(nbSIG-1)))^2;
%--------------------------------------------------------------------------
