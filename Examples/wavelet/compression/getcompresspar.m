function varargout = ...
    getcompresspar(MethodCOMP,nb_Cfs,nbPlan,typeARG,valARG,varargin)
%GETCOMPRESSPAR Returns various parameters for compression methods.
%   This function is used by GUI functions and and by the command
%   line function WCOMPRESS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Mar-2008.
%   Last Revision: 06-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

% Check inputs.
%--------------
switch MethodCOMP
    case 'gbl_mmc_h' , fileCompRat = 'exp_compRat_gbl_h';
    case 'gbl_mmc_f' , fileCompRat = 'exp_compRat_gbl_f';
    case 'lvl_mmc'   , fileCompRat = 'exp_compRat_lvl';       
end
if nargin==1
    S = load(fileCompRat); xval = S.xi; yval = S.yi;
    varargout = {xval , yval};
    return
end
nbIN = length(varargin);
if nbIN>0 , C = varargin{1}; else end

% Control of Compression Parameter.
%----------------------------------
varargout = {[],[],[],[],[]};
OK = 1;
switch typeARG
    case 'thr'
        OK = ~isnan(valARG) && ~(valARG<0);
    case 'nbcfs'
        OK = ~isnan(valARG) && ~(valARG<0) && (valARG<=nb_Cfs)&& ...
            (isequal(valARG,fix(valARG)));
    case 'percfs'
        OK = ~isnan(valARG) && ~(valARG<0) && (valARG<=100);
    case 'bpp'
        OK = ~isnan(valARG) && ~(valARG<0);
    case 'comprat'
        OK = ~isnan(valARG) && ~(valARG<0) && (valARG<=100);
    case 'loop' ,
        OK = ~isnan(valARG) && ~(valARG<1) && ...
            (isequal(valARG,fix(valARG)));
end

if OK
    % Load Estimated Compression Ratio.
    %----------------------------------
    switch MethodCOMP
        case {'gbl_mmc_h', 'gbl_mmc_f' , 'lvl_mmc'}
            S = load(fileCompRat);
            xval = S.xi;
            yval = S.yi;           
            switch typeARG
                case {'nbcfs','percfs','thr'}
                    if isequal(typeARG,'nbcfs')
                        nb_Kept_Cfs = valARG;
                    elseif isequal(typeARG,'percfs')
                        Per_Kept_Cfs = valARG;
                        nb_Kept_Cfs  = round((Per_Kept_Cfs*nb_Cfs)/100);
                    else
                        threshold = valARG;
                        nb_Kept_Cfs = sum((abs(C)>threshold));
                    end
                    [mini,idx] = min(abs(xval-nb_Kept_Cfs/nb_Cfs));
                    Per_Kept_Cfs = 100*nb_Kept_Cfs/nb_Cfs;
                    comprat = yval(idx);
                    bpp = (8*nbPlan*comprat)/100;

                case {'bpp','comprat'};
                    if isequal(typeARG,'comprat')
                        comprat = valARG;
                        bpp = (8*nbPlan*comprat)/100;
                    else
                        bpp = valARG;
                        comprat = 100*bpp/(8*nbPlan);
                    end
                    [mini,idx] = min(abs(yval-comprat));
                    nb_Kept_Cfs = round(xval(idx)*nb_Cfs);
                    Per_Kept_Cfs = 100*nb_Kept_Cfs/nb_Cfs;
            end
            switch MethodCOMP
                case {'gbl_mmc_f','gbl_mmc_h'}
                    imin = nb_Cfs-nb_Kept_Cfs;
                    if nbIN>0 && imin>0
                        D = sort(abs(C));
                        threshold = abs(D(imin));
                    else
                        threshold = 0;
                    end

                case {'lvl_mmc'}
                    threshold = 0; % Not used
            end            
            varargout = {nb_Kept_Cfs,Per_Kept_Cfs,bpp,comprat,threshold};
            
        case {'ezw','spiht','stw','wdr','aswdr','spiht_3d'}
            switch nbPlan
                case 1 , strCOL = 'BW';
                case 3 , strCOL = 'COL';
            end
            fileCompRat = ['exp_compRat_' MethodCOMP '_' strCOL];
            [dummy,idxRES] = min(abs([128*128 256*256 512*512] - nb_Cfs/nbPlan));
            switch idxRES
                case 1 , strRES = '128';
                case 2 , strRES = '256';
                case 3  ,strRES = '512';
            end
            VarName = ['comprat_EST_' strRES];
            S = load(fileCompRat);
            comprat_EST = S.(VarName);
            switch typeARG
                case {'bpp','comprat'}
                    if isequal(typeARG,'bpp')
                        bpp =  valARG;
                        comprat = 100*bpp/(8*nbPlan);
                    else
                        comprat = valARG;
                    end
                    [mini,loop] = min(abs(comprat_EST-comprat));
                    bpp = (8*nbPlan*comprat)/100;

                case 'loop'
                    loop = valARG;
                    comprat = comprat_EST(loop);
                    bpp = (8*nbPlan*comprat)/100;
            end
            varargout = {loop,bpp,comprat};
            
    end
end
varargout = {OK , varargout{:}};
