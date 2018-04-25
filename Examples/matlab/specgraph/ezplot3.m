function hh = ezplot3(varargin)
%EZPLOT3   (NOT RECOMMENDED) Easy to use 3-d parametric curve plotter
%
% ===============================================
% EZPLOT3 is not recommended. Use FPLOT3 instead.
% ===============================================
%
%   EZPLOT3(FUNX,FUNY,FUNZ) plots the spatial curve FUNX(T), FUNY(T), and
%   FUNZ(T) over the default domain 0 < T < 2*PI.
%
%   EZPLOT3(FUNX,FUNY,FUNZ,[TMIN,TMAX]) plots the curve FUNX(T), FUNY(T),
%   and FUNZ(T) over TMIN < T < TMAX.
%
%   EZPLOT3(FUNX,FUNY,FUNZ,'animate') or
%   EZPLOT(FUNX,FUNY,FUNZ,[TMIN,TMAX],'animate') produces an animated trace
%   of the spatial curve.
%
%   EZPLOT3(AX,...) plots into AX instead of GCA.
%
%   H = EZPLOT3(...) returns handles to the plotted objects in H.
%
%   Examples:
%   The easiest way to express a function is via a string:
%      ezplot3('cos(t)','t*sin(t)','sqrt(t)')
%
%   One programming technique is to vectorize the string expression using
%   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
%   This makes the algorithm more efficient since it can perform multiple
%   function evaluations at once.
%      ezplot3('cos(t)','t.*sin(t)','sqrt(t)')
%
%   You may also use a function handle to an existing function or an
%   anonymous function. These are more powerful and efficient than string
%   expressions.
%      ezplot3(@cos,@(t)t.*sin(t),@sqrt)
%
%   If your function has additional parameters, for example k in myfuntk:
%      %-----------------------%
%      function s = myfuntk(t,k)
%      s = t.^k .* sin(t);
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%
%      ezplot3(@cos,@(t)myfuntk(t,1),@sqrt)
%
%   See also EZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT, EZPOLAR,
%            EZSURF, EZSURFC, PLOT, PLOT3, VECTORIZE, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

% Create plot 
cax = newplot(cax);
fig = ancestor(cax,'figure');

% Check each input function or expression
[x,x0,xargs] = ezfcnchk(args{1},0,'t');
[y,y0,yargs] = ezfcnchk(args{2},0,'t');
[z,z0,zargs] = ezfcnchk(args{3},0,'t');

allargs = union(xargs,union(yargs,zargs));
numargs = length(allargs);
if (ismember({''},allargs)), numargs = max(1, numargs-1); end
if (numargs == 2)
   error(message('MATLAB:ezplot3:ParameterizedSurface'))
elseif (numargs > 2)
   error(message('MATLAB:ezplot3:InvalidFunctions'));
end

Aflag = 0; % Animation option.

Npts = 300;

% Determine the domain in t:
switch nargs
   case 3
      T =  linspace(0,2*pi,Npts);
   case 4
      if isa(args{4},'double')   
         T = linspace(args{4}(1),args{4}(2),Npts);
      elseif isequal(args{4},'animate')
         Aflag = 1;
         T =  linspace(0,2*pi,Npts);
      else
         T =  linspace(0,2*pi,Npts);
      end
   case 5
      if isa(args{4},'double') && isequal(args{5},'animate') 
         T = linspace(args{4}(1),args{4}(2),Npts);
         Aflag = 1;
      elseif isequal(args{4},'animate') && isa(args{5},'double')
         T = linspace(args{5}(1),args{5}(2),Npts);
         Aflag = 1;
      else
         T = linspace(0,2*pi,Npts);
      end
end

H = findobj(fig,'Type','uicontrol','String','Repeat');
if ~isempty(H) && ~Aflag
   delete(H);
end

% Evaluate each of (X,Y,Z)
X = ezplotfeval(x,T);
if numel(X) == 1
   X = X*ones(size(T));
end
Y = ezplotfeval(y,T);
if numel(Y) == 1
   Y = Y*ones(size(T));
end
Z = ezplotfeval(z,T);
if numel(Z) == 1
   Z = Z*ones(size(T));
end

% Option to Return a handle.
h = plot3(X,Y,Z,'parent',cax);

xlabel(cax,'x'); ylabel(cax,'y'); zlabel(cax,'z');
title(cax,['x = ' texlabel(x0), ', y = ' texlabel(y0), ', z = ' texlabel(z0)]);
grid(cax,'on');

if Aflag
   hold(cax,'on');
   H = plot3(X(1),Y(1),Z(1),'r.','markersize',24,'parent',cax);

   dk = ceil(length(Y)/Npts);
   % run once with timing so that we see how fast this machine is
   tic
   set(H,'xdata',X(1),'ydata',Y(1),'zdata',Z(1));
   drawnow;
   tm = 0.00003/toc;
   for k = 2:dk:length(Y)
      set(H,'xdata',X(k),'ydata',Y(k),'zdata',Z(k));
      pause(tm);
      drawnow;
   end
   % Define the userdata for the callback.
   ud.x = X; ud.y = Y; ud.z = Z; ud.dk = dk; ud.h = H; ud.tm = tm; ud.cax = cax;
   set(fig,'userdata',ud);
   % Define the callback string.
   s = ['ud = get(gcbf,''userdata'');' ...
        'hold(ud.cax,''on'');' ...
        'tm = ud.tm;' ...
        'for k = 1:ud.dk:length(ud.y),' ...
           'set(ud.h,''xdata'',ud.x(k),''ydata'',ud.y(k),''zdata'',ud.z(k));' ...
           'pause(tm);' ...
           'drawnow;' ...
        'end,' ...
        'hold(ud.cax,''off'');'];
   uicontrol('Units','normal','Position',[.02 .01 .1 .06], ...
             'String','Repeat','CallBack',s,'parent',fig);

end

if nargout > 0
  hh = h;
end
  

