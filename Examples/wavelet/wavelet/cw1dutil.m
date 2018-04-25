function varargout = cw1dutil(option,fig,varargin)
%CW1DUTIL Continuous wavelet 1-D utilities.
%   VARARGOUT = CW1DUTIL(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

switch option
    case 'plotSignal'
      axe = varargin{1};
      sig = varargin{2};
      hdlAXES = varargin{3};
      %-----------------------
      color = wtbutils('colors','cw1d','sig');
      vis   = get(axe,'Visible');
      xValMin = 1;
      xValMax = length(sig);
      ymin = min(sig)-eps;
      ymax = max(sig)+eps;
      plot(sig,'Color',color,'Parent',axe);
      set(axe,'XLim',[xValMin xValMax],'YLim',[ymin ymax],...
              'XGrid','Off','YGrid','Off');
      strTitle = getWavMSG('Wavelet:divGUIRF:AnalSig',xValMax);
      wtitle(strTitle,'Parent',axe,'Visible',vis);
      set(axe,'Visible',vis);        
      set(hdlAXES,'XLim',[xValMin xValMax]);

    case 'plotCfsLine'
      axe   = varargin{1};
      coefs = varargin{2};
      strTitle = varargin{3};
      %-------------------------
      color = wtbutils('colors','cw1d','lin');
      xlim  = get(axe,'XLim');
      vis   = get(axe,'Visible');
      plot(coefs,'Color',color,'Parent',axe,'Visible',vis);     
      wtitle(strTitle,'Parent',axe,'Visible',vis);
      set(axe,'Visible',vis,'XLim',xlim,'Box','On');

    case 'plotChainLine'
      axe      = varargin{1};
      scales   = varargin{2};
      coefs    = varargin{3};
      strTitle = varargin{4};
      %------------------------- 
      vis = get(axe,'Visible');
      [iRow,iCol] = find(coefs);
      if ~isempty(iRow)
          [nbRow,nbCol] = size(coefs);
          markersize = 2;
          marker     = 'o';
          linestyle  = 'none';
          color      = wtbutils('colors','cw1d','spy');
          x = 1:nbCol;
          xlim  = get(axe,'XLim');
          ylim = [min(scales) max(scales)]+sqrt(eps)*[-1 1];
          varargout{1} = ...
            plot(x(iCol),scales(iRow), ...
               'Visible',vis, ...
               'marker',marker, ...
               'MarkerSize',markersize, ...
               'MarkerEdgeColor',color, ...
               'MarkerFaceColor',color, ...
               'LineStyle',linestyle,   ...
               'Color',color, ...
               'Parent',axe   ...
               ); 
          step  = ceil(nbRow/20);
          ytics = scales(1:step:nbRow);
          ylabs = num2str(ytics(:));
          set(axe,...
              'Visible',vis, ...
              'XLim',xlim,'YLim',ylim,...
              'Box','On',...
              'YDir','normal','GridLineStyle','none',...
              'YTick',ytics,'YTickLabel',ylabs,...
              'clipping','on'...
              );
      end
      wtitle(strTitle,'Parent',axe,'Visible',vis);

    case 'computeChainLine'
      scales = varargin{1};
      coefs  = varargin{2};
      indBeg = varargin{3};
      %--------------------
      [~,I1] = sort(scales);
      [~,I2] = sort(I1);
      coefs = coefs(I2,:);
      coefs = localmax(coefs,indBeg);
      varargout{1} = coefs(I1,:);
      varargout{2} = getWavMSG('Wavelet:divGUIRF:LocMaxLine');

    case 'cfsLineTitle'
      toolATTR = wfigmngr('getValue',fig,'ToolSettings');
      toolMode = toolATTR.Mod;
      scale    = toolATTR.Sca;
      freq     = toolATTR.Frq;
      scaStr   = num2str(scale);
      frqStr   = sprintf('%7.3f',freq);
      switch toolMode
          case {'real','abs','arg'}
              switch toolMode
                  case 'real'
                      RealSTR = getWavMSG('Wavelet:divGUIRF:RealSTR',scaStr,frqStr);
                      varargout{1} = {RealSTR};
                  case {'abs','arg'}
                      ModuleSTR = getWavMSG('Wavelet:divGUIRF:ModuleSTR',scaStr,frqStr);
                      AngleSTR = getWavMSG('Wavelet:divGUIRF:AngleSTR',scaStr,frqStr);
                      varargout{1} = {ModuleSTR,AngleSTR};
              end
          case {'all'}
              ModuleSTR = getWavMSG('Wavelet:divGUIRF:ModuleSTR_2',scaStr,frqStr);
              AngleSTR = getWavMSG('Wavelet:divGUIRF:AngleSTR_2',scaStr,frqStr);
              varargout{1} = {ModuleSTR,AngleSTR};
      end
       
    case 'cfsColorTitle'
      toolMode = varargin{1};
      pop_ccm  = varargin{2};
      %----------------------
      strPopCM = get(pop_ccm,'String');
      strPopCM = strPopCM(get(pop_ccm,'Value'),:);
      switch toolMode
          case 'real'
              varargout{1} = ...
                  getWavMSG('Wavelet:divGUIRF:RealColSTR',strPopCM);
          case {'abs','arg'}
              varargout{1} = ...
                {getWavMSG('Wavelet:divGUIRF:ModulusColSTR',strPopCM);...
                 getWavMSG('Wavelet:divGUIRF:AngleColSTR',strPopCM)};              
          case 'all'
              varargout{1} = ...
                {getWavMSG('Wavelet:divGUIRF:ModuleSTR_3');...
                 getWavMSG('Wavelet:divGUIRF:AngleSTR_3')};              
      end

   case 'initPosAxes'
      toolMode = varargin{1};
      pos_Gra_Rem = varargin{2};
      %-------------------------------
      bdx = 0.045; bdy = 0.05; ecy = 0.06;
      h_col = 0.015;
      x_axe = pos_Gra_Rem(1)+bdx;
      w_axe = (pos_Gra_Rem(3)-2*bdx);
      w_col = pos_Gra_Rem(3)/3;
      x_col = pos_Gra_Rem(1)+w_col;
      h_rem = pos_Gra_Rem(4)-2*bdy;
      pos_axes = zeros(8,4,5);
      pos_axes(:,1,1:4) = x_axe;
      pos_axes(:,3,1:4) = w_axe;
      dummy = [x_col , 0 , w_col , h_col];
      pos_axes(:,:,5) = dummy(ones(1,8),:);
      pos_axes = permute(pos_axes,[3 2 1]);
 
      % Proportion.
      %-------------
      NB_Config = 8;
      prop = [...
        2 4 2 4 ;
        1 3 1 0 ;
        1 3 0 3 ;
        1 0 1 3 ;
        1 3 0 0 ;
        1 0 1 0 ;
        1 0 0 3 ;
        1 0 0 0 ;
        ];
      dummy = sum(prop,2);
      for k = 1:NB_Config , prop(k,:) = (12*prop(k,:))/dummy(k); end
      vis = (prop>0);
      for k = 1:NB_Config
        visFlg = vis(k,[1 2 3 4 2]);
        DY     = ecy*visFlg.*[1 1 1.125 1 0.250];
        h_ele = (h_rem-h_col*visFlg(5)-sum(DY(2:5)))/12;
        h_axe = max(prop(k,:)*h_ele,1.E-6);

        y_axe = pos_Gra_Rem(2)+pos_Gra_Rem(4)-bdy-h_axe(1);
        pos_axes(1,:,k) = [x_axe y_axe w_axe h_axe(1)];
        y_axe = pos_axes(1,2,k)-DY(2)-h_axe(2);
        pos_axes(2,:,k) = [x_axe y_axe w_axe h_axe(2)];
        y_col = pos_axes(2,2,k)-DY(5)-h_col*visFlg(5);
        pos_axes(5,:,k) = [x_col , y_col , w_col , h_col];
        y_axe = pos_axes(5,2,k)-DY(3)-h_axe(3);
        pos_axes(3,:,k) = [x_axe y_axe w_axe h_axe(3)];
        y_axe = pos_axes(3,2,k)-DY(4)-h_axe(4);
        pos_axes(4,:,k) = [x_axe y_axe w_axe h_axe(4)];
      end
      %-----------------------------------------------------------
      num = 1;
      toolATTR = struct( ...
          'Pos',pos_axes,'Vis',vis,'Num',num,'Mod',toolMode,...
          'Sca',[],'Frq',[]);
      wfigmngr('storeValue',fig,'ToolSettings',toolATTR);
      hdl_Re_AXES = zeros(5,1);
      for k = 1:5
          hdl_Re_AXES(k) = axes(...
              'Parent',fig,              ...
              'Units','normalized',      ...
              'Position',pos_axes(k,:,num),...
              'Visible','off',           ...
              'XTickLabelMode','manual', ...
              'YTickLabelMode','manual', ...
              'XTickLabel',[],           ...
              'YTickLabel',[],           ...
              'XTick',[],'YTick',[],     ...
              'Box','On'                 ...
              );
      end
      if ~isequal(toolMode,'real')
          hdl_Im_AXES = copyobj(hdl_Re_AXES,fig);
          varargout = {hdl_Re_AXES,hdl_Im_AXES};
      else
          varargout = {hdl_Re_AXES};        
      end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end
