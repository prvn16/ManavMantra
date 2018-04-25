function varargout = wmspca(varargin)
%WMSPCA Multiscale Principal Component Analysis.
%   [X_SIM,QUAL,NPC,DEC_SIM,PCA_Params] = WMSPCA(X,LEVEL,WNAME,NPC) 
%   or [...] = WMSPCA(X,LEVEL,WNAME,'mode',EXTMODE,NPC)
%   returns a simplified version X_SIM of the input matrix X
%   obtained from the wavelet based multiscale PCA.
%
%   Input matrix X contains P signals of length N stored
%   columnwise where N > P.
%
%   Wavelet Decomposition Parameters.
%   ---------------------------------
%   The Wavelet decomposition is performed using the 
%   decomposition level LEVEL and the wavelet WNAME. 
%   EXTMODE is the extended mode for the DWT (default is
%   returned by DWTMODE).
%
%   If a decomposition DEC obtained using MDWTDEC is available, 
%   then you can use [...] = WMSPCA(DEC,NPC) instead of
%   [...] = WMSPCA(X,LEVEL,WNAME,'mode',EXTMODE,NPC).
%
%   Principal Components Parameter NPC.
%   -----------------------------------
%   If NPC is a vector, it must be of length LEVEL+2. It contains the   
%   number of retained principal components for each PCA performed:
%      - NPC(d) is the number of retained non-centered principal 
%	     components for details at level d, for 1 <= d <= LEVEL,
%      - NPC(LEVEL+1) is the number of retained non-centered
%        principal components for approximations at level LEVEL, 
%      - NPC(LEVEL+2) is the number of retained principal components
%        for final PCA after wavelet reconstruction, 
%      NPC must be such that 0 <= NPC(d) <= P for 1 <= d <= LEVEL+2.
%
%   If NPC = 'kais' (respectively 'heur'), the numbers of retained 
%   principal components are selected automatically using the  
%   Kaiser's rule (respectively the heuristic rule).
%      - Kaiser's rule keeps the components associated with 
%        eigenvalues exceeding the mean of all eigenvalues.
%      - heuristic rule keeps the components associated with 
%        eigenvalues exceeding 0.05 times the sum of all 
%        eigenvalues.
%   If NPC = 'nodet', the details are "killed" and all the
%   approximations are retained.
%
%   Outputs.
%   --------
%   X_SIM is a simplified version of the matrix X.
%   QUAL is a vector of length P containing the quality of
%   column reconstructions given by the relative mean square   
%   errors in percent.
%   NPC is the vector of selected numbers of retained 
%   principal components.
%   DEC_SIM is the wavelet decomposition of X_SIM. See MDWTDEC
%   for more information on the decomposition structure. 
%   PCA_Params is a structure array of length LEVEL+2 such that:
%     PCA_Params(d).pc = PC where:
%        PC is a P-by-P matrix of principal components.
%        The columns are stored according to the descending    
%        order of the variances. 
%     PCA_Params(d).variances = VAR where: 
%        VAR is the principal component variances vector.   
%     PCA_Params(d).npc = NPC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jan-2005.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2011 The MathWorks, Inc.

% Check input arguments.
nextARG = 1;
if ischar(varargin{1})
    switch lower(varargin{1}(1:3))
        case 'est'  , option = 'estimate'; nextARG = 2;
        case 'exe'  , option = 'execute';  nextARG = 2;
        otherwise   , option = 'compute';
    end
else
    option = 'compute';
end
if isstruct(varargin{nextARG})
    flagDEC = true;
    dec = varargin{nextARG};
    nextARG = nextARG+1;
    n = dec.dataSize(1);
    p = dec.dataSize(2);
    level = dec.level;
    if nargout>3 , x = mdwtrec(dec); end
else
    flagDEC = false;
    [x,level,wname] = deal(varargin{nextARG:2+nextARG});
    nextARG = nextARG+3;
    [n,p] = size(x);
end
if n<=p
    error(message('Wavelet:FunctionArgVal:Invalid_SizMat'))
end 
if ~flagDEC % Wavelet decomposition.
    if isequal(varargin{nextARG},'mode')
        extMode = varargin{nextARG+1};
        nextARG = nextARG+2;
    else
        extMode = dwtmode('status','nodisp');
    end
    dec = mdwtdec('col',x,level,wname,'mode',extMode);
end
npcPAR = varargin{nextARG};
Lplus2 = level+2;
npc = zeros(1,Lplus2);
if ischar(npcPAR)
	switch lower(npcPAR)
		case {'kais'   ,'heur'}
        case 'none'    , npc(:) = p;
        case 'nodet'   , npc = [zeros(1,level) p p];
        otherwise
            error(message('Wavelet:FunctionArgVal:Invalid_SelMeth'))
	end
else
	npc = npcPAR;
	if ((max(npc)>p) || (min(npc)<0) || ~isequal(length(npc),Lplus2))
		error(message('Wavelet:FunctionArgVal:Invalid_SelVect'))
	end
	npcPAR = 'manu';
end
PCA_Params(Lplus2) = struct('pc',[],'variances',[],'npc',[]);
if isequal(option, 'estimate') , dec_ORI = dec; end

% PCA level by level for details (d=1:level) and approximations (d=level+1)
flagCENTER = false;
for d=1:level+1
    % Set coefficients matrix.
    if d<level+1 , coefs = dec.cd{d}; else coefs = dec.ca; end

    % Perform PCA.
    [pc,newdata,variances] = wpca(coefs,flagCENTER);
    % we have: coefs*pc = newdata , pc*pc' = Id and coefs = newdata*pc'
    
    % Components selection. 
    switch npcPAR
    	case 'kais' , npc(d) = sum(variances>mean(variances));    		
    	case 'heur' , npc(d) = sum(variances>0.05*sum(variances));
    end
 
    % Store PCA parameters.
    PCA_Params(d) = struct('pc',pc,'variances',variances,'npc',npc(d));
        
    % The last columns of are replaced by zeros.
    if npc(d)<p, pc(:,npc(d)+1:p) = 0; end
    
    % Reconstruction of new coefficients for details and approximations
    if d<level+1 , dec.cd{d} = newdata*pc'; else dec.ca = newdata*pc'; end
end

% Wavelet reconstruction of columns of x_rec.
x_rec = mdwtrec(dec);

% Final PCA (d = level+2).
%-------------------------
flagCENTER = true;
if flagCENTER
    % Center the columns.
    avg = mean(x_rec);
    sizeXREC = size(x_rec,1);
    x_rec = (x_rec - avg(ones(sizeXREC,1),:));
end

% Perform last PCA.
[pc,newdata,variances] = wpca(x_rec,flagCENTER);

% Components selection.
switch npcPAR
    case 'kais' , npc(Lplus2) = sum(variances>mean(variances));
    case 'heur' , npc(Lplus2) = sum(variances>0.05*sum(variances));
end

% The last columns of are replaced by zeros.
if npc(Lplus2)<p, pc(:,npc(Lplus2)+1:p) = zeros(p,p-npc(Lplus2)); end

% Reconstruction of new coefficients.
x_rec = newdata*pc';
if flagCENTER
    x_rec = x_rec + avg(ones(sizeXREC,1),:);
end
    
% Store PCA parameters.
PCA_Params(Lplus2) = struct('pc',pc,'variances',variances,'npc',npc(Lplus2));

% quality of columns reconstructions given by the relative 
% mean square errors in percent. 
qual = 100*(1-(sum((x_rec - x).^2)./sum((x).^2)));

switch option
    case 'estimate',
        varargout = {dec_ORI,npc,PCA_Params,x_rec,qual,dec};
    otherwise
        varargout = {x_rec,qual,npc,dec,PCA_Params};
end
