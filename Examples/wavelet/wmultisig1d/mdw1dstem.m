function mdw1dstem(axe_IN,cfs_IN,longs,stem_ATTRB,txt_ATTRB)
%MDW1DSTEM Multi-Signal 1-D stem.
   
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jun-2005.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Defaults.
%----------
absmode = 1;
viewapp = 1;
colors  = 'wtbx';
flgZero = 1;
yscale  = 'eq';
flagTxtIN  = false;

% Nb. Plots.
%-----------
nb_AXE = length(axe_IN);

% Check inputs.
%--------------
if nargin>3
    % stem_ATTRB = ...
    %   {'mode',absMode,'viewapp',1,'colors','wtbx','yscale','eq'};
    absmode = stem_ATTRB{2};
    viewapp = stem_ATTRB{4};
    colors  = stem_ATTRB{6};
    yscale  = stem_ATTRB{8};
    flgZero = 1;
    if nargin>4
        flagTxtIN = true;
        % txt_ATTRB = {'l','on','bold',txt_LAB,idx_IN};
        txt_LAB = txt_ATTRB{4};
        idx_IN  = txt_ATTRB{5};
    end
end
%------------------------------------------------------------------
if size(longs,1)>size(longs,2) , cfs_IN = cfs_IN'; end
level = length(longs)-2;
nbStemLIN  = level + viewapp;
if isequal(upper(colors),'WTBX')
   dum = wtbutils('colors','app',level);
   dum = dum(1,:);
   colors = [wtbutils('colors','det',level) ; dum];
end
while size(colors,1)<nbStemLIN , colors = [colors;colors]; end
xAxeColor = get(axe_IN(1),'XColor');
lx = longs(end);
lf = 2*longs(end-1)-lx;
lf = lf+2-rem(lf,2);
%------------------------------------------------------------------

% Plot decomposition.
%--------------------
for k = 1:nb_AXE
    axe_Act = axe_IN(k);
    coefs   = cfs_IN(k,:);
    if flagTxtIN
        txtSTR = [txt_LAB int2str(idx_IN(k))];
    else
        txtSTR = '';
    end
    multi_plotstem;
end

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function hdl_lin = multi_plotstem
        axes(axe_Act);
        delete(get(axe_Act,'Children'));
        tag_axe = get(axe_Act,'Tag');
        next    = lower(get(axe_Act,'NextPlot'));
        set(axe_Act,'NextPlot','add','YLim',[0.5 nbStemLIN+0.5])
        mul = max([0.85 , 0.96*(nbStemLIN-1)/nbStemLIN]);

        hdl_lin = [];
        YtickLab = {};
        ybaseTAB = (1:nbStemLIN);
        if absmode , ybaseTAB = ybaseTAB-0.5; end
        
        maxCFS = max(abs(coefs(:)));
        % maxCFS = max(abs(coefs(1+longs(1):end)));
        for k=1:nbStemLIN
            appFlag = (k==(level+1));
            if appFlag
                lev = k-1;
                y = coefs(1:longs(1));
                YtickLab = {YtickLab{:},['A' int2str(lev)]};
            else
                lev = k;
                y = detcoef(coefs,longs,lev);
                YtickLab = {YtickLab{:},['D' int2str(lev)]};
            end
            y  = y(:)';
            if isequal(yscale,'eq')
                maxval = max(abs(y));
            else
                maxval = maxCFS;
            end
            ld = length(y);
            [xlow,xloc,xup] = coefsLOC((1:ld),lev,lf,lx);
            if absmode , y = abs(y); else y = y/2; end
            ybase = ybaseTAB(k);
            if maxval>0 , y = (mul*y)/maxval; end
            xlow = 1;
            xup = lx;
            color = colors(k,:);
            hh = plotstem;
            hdl_lin = [hdl_lin hh];
        end
        set(axe_Act,'YTick',(1:nbStemLIN),'YTickLabel',YtickLab,...
            'NextPlot',next,'Tag',tag_axe);
        if ~isempty(txtSTR)
            [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
            txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
        end
     %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
     function h = plotstem
        q =  [xlow xup];
        h = NaN*ones(1,4);
        h(1) = plot([q(1) q(2)],ybase+[0 0],'Parent',axe_Act,'Color',xAxeColor);

        indZ = find(abs(y)<eps);
        xZ   = xloc(indZ);
        yZ   = y(indZ);
        xloc(indZ) = [];
        y(indZ) = [];
        n = length(xloc);
        if n>0
            MSize = 2; Mtype = 'o';
            MarkerEdgeColor = color;
            MarkerFaceColor = color;
            xx = [xloc;xloc;nan*ones(size(xloc))];
            yy = [zeros(1,n);y;NaN*ones(size(y))];
            h(2) = plot(xx(:),ybase+yy(:),...
                'Parent',axe_Act,'LineStyle','-','Color',color);
            h(3) = plot(xloc,ybase+y,'Parent',axe_Act,...
                'Marker',Mtype, ...
                'MarkerEdgeColor',MarkerEdgeColor, ...
                'MarkerFaceColor',MarkerFaceColor, ...
                'MarkerSize',MSize, ...
                'LineStyle','none',...
                'Color',color);
        end
        if flgZero && (length(xZ)>0)
            MSize = 2; Mtype = 'o';
            h(4)  = plot(xZ,ybase+yZ,'Parent',axe_Act,...
                'Marker',Mtype, ...
                'MarkerEdgeColor',xAxeColor, ...
                'MarkerFaceColor',xAxeColor, ...
                'MarkerSize',MSize, ...
                'LineStyle','none',...
                'Color',xAxeColor);
        end
    end
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function [low,loc,up] = coefsLOC(idx,lev,lf,lx)
        %COEFSLOC coefficient location
        up  = idx;
        low = idx;
        for jj=1:lev
            low = 2*low+1-lf;
            up  = 2*up;
        end
        loc = max(1,min(lx,round((low+up)/2)));
    end
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function [ftnSize,txtPos] = get_TxtInAxe_Attrb(S)
        txtPos = 40;
        lenSTR = length(S);
        switch lenSTR
            case {1,2,3} , ftnSize = 12;
            case 4       , ftnSize = 11;
            case 5       , ftnSize = 10;
            otherwise    , ftnSize = 10;
        end
    end
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    end
end
