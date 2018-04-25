function lines = createLinesForQuiverStruct (hQuiver)

%   Copyright 2013-2017 The MathWorks, Inc.

    is3D = ~isempty(hQuiver.ZData);
  
    % Arrow head parameters
    alpha = .33;  % Size of arrow head relative to the length of the vector
    beta = .25;  % Width of the base of the arrow head relative to the length

    autoscale = strcmp(hQuiver.AutoScale,'on');
  
    if is3D
        [~,x,y,z] = xyzchk(hQuiver.XData, hQuiver.YData, hQuiver.ZData);
        u = hQuiver.UData;
        v = hQuiver.VData;
        w = hQuiver.WData;
    else
        [~,x,y,u,v] = xyzchk(hQuiver.XData,hQuiver.YData,hQuiver.UData,hQuiver.VData);
        
        % expand x and y data to be same size as u
        [m,n] = size(u);
        if ~isequal(size(x),size(hQuiver.UData))
            x = x(:).';
            x = x(ones(m,1),:);
        end
        if ~isequal(size(y),size(hQuiver.UData))
            y = y(:);
            y = y(:,ones(n,1));
        end
        
        z = 0; 
        w = 0;
    end
  
    % reshape and expand data
    if isscalar(u), u = u(ones(size(x))); end
    if isscalar(v), v = v(ones(size(x))); end
    if is3D && isscalar(w)
        w = w(ones(size(x))); 
    end
    
    if autoscale
        
        % Base autoscale value on average spacing in the x, y and z
        % directions.  Estimate number of points in each direction as
        % either the size of the input arrays or the effective square
        % spacing if x and y are vectors.
        if min(size(x))==1
            n=sqrt(numel(x)); 
            m=n; 
        else 
            [m,n]=size(x);
        end
        delx = diff([min(x(:)) max(x(:))])/n;
        dely = diff([min(y(:)) max(y(:))])/m;
        if is3D
            delz = diff([min(z(:)) max(z(:))])/max(m,n);
            del = delx.^2 + dely.^2 + delz.^2;
        else
            del = delx.^2 + dely.^2;
        end
        
        if del>0
            if is3D
                len = sqrt((u.^2 + v.^2 + w.^2)/del);
            else
                len = sqrt((u.^2 + v.^2)/del);
            end
            maxlen = max(len(:));
        else
            maxlen = 0;
        end
        
        if maxlen>0
            autoscale = autoscale*hQuiver.AutoScaleFactor / maxlen;
        else
            autoscale = autoscale*hQuiver.AutoScaleFactor;
        end
        
        u = u*autoscale; v = v*autoscale;
        if is3D, w = w*autoscale; end
      
    end

    % Make velocity vectors
    x = x(:).'; y = y(:).'; 
    u = u(:).'; v = v(:).';
    if is3D
       z = z(:).';
       w = w(:).';
    end
    
    uu = [x;x+u;NaN(size(u))];
    vv = [y;y+v;NaN(size(u))];
    if is3D
       ww = [z;z+w;NaN(size(u))];
    end
    
    ch(1) = matlab.graphics.primitive.Line('HitTest','off','Color',hQuiver.Color);
    ch(2) = matlab.graphics.primitive.Line('HitTest','off','Color',hQuiver.Color);
    ch(3) = matlab.graphics.primitive.Line('HitTest','off','Color',hQuiver.Color,'LineStyle','none');

    hu = x; hv = y;
    
    if is3D
        hw = z;
        set(ch(3),'xdata',hu(:),'ydata',hv(:),'zdata',hw(:));
    else
        set(ch(3),'xdata',hu(:),'ydata',hv(:));
    end
    
    uu = uu(:);
    vv = vv(:);
    if is3D, ww = ww(:); end
    
    if is3D
        set(ch(1),'xdata',uu,'ydata',vv,'zdata',ww);      
    else
        set(ch(1),'xdata',uu,'ydata',vv);
    end
    
    % Draw arrow head
    if strcmp(hQuiver.ShowArrowHead,'on')
        if is3D
            norm = sqrt(u.*u + v.*v + w.*w);
        else
            norm = sqrt(u.*u + v.*v);    
        end
        normxy = sqrt(u.*u + v.*v)+eps;
        allx = [x(:); x(:)+u(:)];
        spanx = max(allx) - min(allx);
        ally = [y(:); y(:)+v(:)];
        spany = max(ally) - min(ally);
        
        if is3D
            allz = [z(:); z(:)+w(:)];
            spanz = max(allz) - min(allz);
        end
        
        if is3D
            cutoff = hQuiver.MaxHeadSize * max(spanx,max(spany,spanz));
        else
            cutoff = hQuiver.MaxHeadSize * max(spanx,spany);
        end
        
        beta = beta .* norm ./ normxy;
        norm2 = norm;
        norm2(norm < cutoff) = 1;
        norm2(norm > cutoff) = norm(norm > cutoff)./cutoff;
        alpha = alpha ./ norm2;
        
        % Make arrow heads and plot them
        hu = [x+u-alpha.*(u+beta.*(v+eps));x+u; ...
              x+u-alpha.*(u-beta.*(v+eps));NaN(size(u))];
        hv = [y+v-alpha.*(v-beta.*(u+eps));y+v; ...
              y+v-alpha.*(v+beta.*(u+eps));NaN(size(v))];
        
        if is3D
            hw = [z+w-alpha.*w;z+w; ...
                  z+w-alpha.*w;NaN(size(w))];
        else
            hw = [];  
        end
        
        set(ch(2),'xdata',hu(:),'ydata',hv(:),'zdata',hw(:),...
                  'visible',hQuiver.Visible);
    else
        set(ch(2),'visible','off');
    end
    lines = ch;
end
