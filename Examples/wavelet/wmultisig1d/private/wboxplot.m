function hout = wboxplot(x,varargin)
%WBOXPLOT Display boxplots of a data sample.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Sep-2006.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2013/07/05 04:31:19 $ 

nbIN = nargin-1;
if isvector(x)
   x = x(:);
   n = 1;
else
   n = size(x,2);
end

% Set defaults
widths = []; % default is 0.5, smaller for three or fewer boxes
okargs = {'labels','widths'};
for k = 1:2:nbIN
    argName = varargin{k};
    argVal  = varargin{k+1};
    idx = find(strcmpi(okargs,argName),1);
    if ~isempty(idx)
        switch okargs{idx}
            case 'labels' , labels = argVal;
            case 'widths' , widths = argVal;
        end
    end
end
if ischar(labels)  , labels = cellstr(labels); end
if isempty(widths) , widths = min(0.15*n,0.5); end
wd2 = 0.5*widths;
wd4 = 0.25*widths;

% Xminmax , xlims , Yminmax , ylims
xlims = [0.5 , n + 0.5];
ymin = min(x(:));
ymax = max(x(:));
if ymax > ymin
   dy = (ymax-ymin)/20;
else
   dy = 0.5;  % no data range, just use a y axis range of 1
end
ylims = [(ymin-dy) (ymax+dy)];

% Scale axis for vertical or horizontal boxes.
newplot
oldstate = get(gca,'NextPlot');
set(gca,'NextPlot','add','Box','on');
if isempty(xlims) , xlims = [0 1]; end
if isempty(ylims) , ylims = [0 1]; end
axis([xlims ylims]);
set(gca,'XTick',1:n,'Units','normalized');
drawnow;
if nargout>0 , hout = []; end

notnans = ~isnan(x);
percent = [25 ; 50 ; 75];
for i=1:n
   thisgrp = find(notnans(:,i)) + (i-1)*size(x,1);
   y = x(thisgrp); 
   lb = i; 
   sz = size(y);
 
   % If X is empty, return all NaNs.
   if isempty(y)
       if isequal(y,[])
           pctiles = nan(3,1);
       else
           szout = sz; szout(1) = 3;
           pctiles = nan(szout);
       end
   else
       nrows = sz(1);
       ncols = prod(sz) ./ nrows;
       y = reshape(y,nrows,ncols);
       y = sort(y,1);
       nonnans = ~isnan(y);

       % If there are no NaNs, do all cols at once.
       if all(nonnans(:))
           n = sz(1);
           q = [0 100*(0.5:(n-0.5))./n 100]';
           xx = [y(1,:); y(1:n,:); y(n,:)];
           pctiles = zeros(3,ncols);
           pctiles(:,:) = interp1q(q,xx,percent(:));
           % If there are NaNs, work on each column separately.
       else
           % Get percentiles of the non-NaN values in each column.
           pctiles = nan(3,ncols);
           for j = 1:ncols %#ok<BDSCI>
               nj = find(nonnans(:,j),1,'last');
               if nj > 0
                   if isequal(percent,50) % make the median fast
                       if rem(nj,2)
                           pctiles(:,j) = y((nj+1)/2,j);
                       else
                           pctiles(:,j) = (y(nj/2,j) + y(nj/2+1,j))/2;
                       end
                   else
                       q = [0 100*(0.5:(nj-0.5))./nj 100]';
                       xx = [y(1,j); y(1:nj,j); y(nj,j)];
                       pctiles(:,j) = interp1q(q,xx,percent(:));
                   end
               end
           end
       end

       % Reshape Y to conform to X's original shape and size.
       szout = sz; szout(1) = 3;
       pctiles = reshape(pctiles,szout);
   end

   % If X is a vector, the shape of Y should follow that of P.
   if isvector(y) , pctiles = reshape(pctiles,3,1); end

   q1  = pctiles(1,:);
   med = pctiles(2,:);
   q3  = pctiles(3,:);

   % find the extreme values (to determine where whiskers appear)
   vhi = q3+1.5*(q3-q1);
   upadj = max(y(y<=vhi));
   if (isempty(upadj)), upadj = q3; end

   vlo = q1-1.5*(q3-q1);
   loadj = min(y(y>=vlo));
   if (isempty(loadj)), loadj = q1; end

   x1 = repmat(lb,1,2);
   x2 = x1 + [-wd4,wd4];
   outliers = y<loadj | y > upadj;
   yy = y(outliers);

   xx = repmat(lb,1,length(yy));
   lbp = lb + wd2;
   lbm = lb - wd2;
   upadj = max(upadj,q3);
   loadj = min(loadj,q1);

   % Set up (X,Y) data for notches.
   deltaMED = 1.57*(q3-q1)/sqrt(length(y));
   n1 = min([med + deltaMED q3]);
   n2 = max([med - deltaMED q1]);
   lnm = lb-wd4;
   lnp = lb+wd4;
   xx2 = [lnm lbm lbm lbp lbp lnp lbp lbp lbm lbm lnm];
   yy2 = [med n1 q3 q3 n1 med n2 q1 q1 n2 med];
   xx3 = [lnm lnp];
   yy3 = [med med];
   hh = plot(x1,[q3 upadj],'k--', x1,[loadj q1],'k--',...
       x2,[upadj upadj],'k-', x2,[loadj loadj],'k-', ...
       xx2,yy2,'b-', xx3,yy3,'r-', xx,yy,'r+');
   hh = double(hh);
   if length(hh)<7 , hh(7) = NaN; end
   if nargout>0 , hout = [hout, hh(:)]; end %#ok<AGROW>
   %--------------------------------
   % hh(1) - 'Upper Whisker'
   % hh(2) - 'Lower Whisker'
   % hh(3) - 'Upper Adjacent Value'
   % hh(4) - 'Lower Adjacent Value'
   % hh(5) - 'Box'
   % hh(6) - 'Median'
   % hh(7) - 'Outliers' (or NaN)
   %--------------------------------   
end
set(gca,'XTickLabel',labels);
set(gca,'NextPlot',oldstate);
