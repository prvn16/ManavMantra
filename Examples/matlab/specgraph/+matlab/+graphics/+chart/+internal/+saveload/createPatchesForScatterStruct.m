function p = createPatchesForScatterStruct(hScatter)
% construct the Patches that the older graphics system would construct for a scatter plot.    
% This is required to be able
% to create a .FIG file that is compatible with older versions of MATLAB.

%   Copyright 2013-2015 The MathWorks, Inc.

    is3D = ~isempty(hScatter.ZData_I);

    [x,y,s,c] = deal(hScatter.XData_I,hScatter.YData_I,...
                     hScatter.SizeData_I,hScatter.CData_I);
    if is3D
        z = hScatter.ZData_I;
    end
  
    if ~is3D && strcmp(hScatter.Jitter,'on')
        x = x + (rand(size(x))-0.5)*(2*hScatter.JitterAmount);
    end

    % check for scalar sizedata, cdata or colorspec
    if (length(s) == 1)
        s = repmat(s,length(x),1);
    end

    constantcolor = false;
    if size(c,1) == 1
        if size(c,2) ~= 3
            c = c(:);
        else
            constantcolor = true;
        end
    end
    if constantcolor, color = c; end

    if (length(s) == 1)
        s = s(1:length(x));
    end
    
    % strip out nan data
    nani = isnan(x(:)) | isnan(y(:)) | isnan(s(:));
    if is3D, nani = nani | isnan(z(:)); end
    nani = ~nani;
    x = x(nani);
    y = y(nani);
    s = s(nani);
    if is3D, z = z(nani); end
    if ~constantcolor, c = c(nani,:); end
    
    if length(x) > 100 && (constantcolor || size(c,2) == 1)

        % if there aren't a small number of points then group them
        % into a single patch according to marker size. This speeds
        % up rendering and shrinks the memory footprint. It means
        % however that the sizes are rounded to integers, which
        % might affect very high resolution rendering.
        
        sint = ceil(s); 
        
        % get list of distinct sizes
        uniquesizes = sint(1);
        count = 1;
        for k = 2:length(sint)
            ind = find(sint(k) == uniquesizes);
            if isempty(ind)
                uniquesizes = [uniquesizes sint(k)];
                count = [count 1];
            else
                count(ind) = count(ind)+1;
            end
        end
        
        % pre-allocate size lists
        xi = cell(1,length(uniquesizes));
        yi = xi;
        if is3D, zi = xi; end
        if ~constantcolor, ci = xi; end
        for k = 1:length(uniquesizes)
            xi{k} = zeros(count(k),1);
            yi{k} = zeros(count(k),1);
            if is3D
                zi{k} = zeros(count(k),1);
            end
            if ~constantcolor
                ci{k} = zeros(count(k),size(c,2));
            end
        end
        
        % fill each size list
        for k = 1:length(sint)
            ind = find(sint(k) == uniquesizes);
            xi{ind}(count(ind)) = x(k);
            yi{ind}(count(ind)) = y(k);
            if is3D
                zi{ind}(count(ind)) = z(k);    
            end 
            if ~constantcolor
                ci{ind}(count(ind),:) = c(k,:);
            end
            count(ind) = count(ind)-1;
        end
        
        str = struct('type',cell(1),'handle',cell(1),'properties',cell(1),'children',cell(1),'special',cell(1));
        p = repmat(str,length(xi),1);
        
        % make patches for each size
        for k = 1:length(xi)
            if ~constantcolor
                color = ci{k};
            end
            if is3D
                verts = [xi{k},yi{k},zi{k}];
            else
                verts = [xi{k},yi{k}];
            end
            p(k).type='patch';
            p(k).handle=[];
            
            props.HitTest='off';
            props.Vertices=verts;
            props.Faces=1:size(xi{k},1);
            props.FaceVertexCData=color;
            props.FaceColor='none';
            props.EdgeColor='none';
            props.LineWidth=hScatter.LineWidth;
            props.MarkerFaceColor=hScatter.MarkerFaceColor;
            props.MarkerEdgeColor=hScatter.MarkerEdgeColor;
            props.Marker=hScatter.Marker;
            props.MarkerSize=sqrt(uniquesizes(k));
            
            p(k).properties=props;
            p(k).children=[];
            p(k).special=[];
            
            % painters doesn't support RGB cdata
            if constantcolor
                if strcmp(hScatter.MarkerFaceColor,'flat')
                    p(k).properties.MarkerFaceColor = color;
                end
                if strcmp(hScatter.MarkerEdgeColor,'flat')
                    p(k).properties.MarkerEdgeColor = color;
                end
                p(k).properties.FaceVertexCData = [];
            end
        end
    else % use one patch per vertex
        str = struct('type',cell(1),'handle',cell(1),'properties',cell(1),'children',cell(1),'special',cell(1));
        p = repmat(str,length(x),1);

        for k = 1:length(x)
            if ~constantcolor
                color = c(k,:);
            end
            if is3D
                verts = [x(k),y(k),z(k)];
            else
                verts = [x(k),y(k)];
            end
            
            p(k).type='patch';
            p(k).handle=[];
            
            props.HitTest='off';
            props.Vertices=verts;
            props.Faces=1;
            props.FaceVertexCData=color;
            props.FaceColor='none';
            props.EdgeColor='none';
            props.LineWidth=hScatter.LineWidth;
            props.MarkerFaceColor=hScatter.MarkerFaceColor;
            props.MarkerEdgeColor=hScatter.MarkerEdgeColor;
            props.Marker=hScatter.Marker;
            props.MarkerSize=sqrt(s(k));
            
            p(k).properties=props;
            p(k).children=[];
            p(k).special=[];

            % painters doesn't support RGB cdata
            if constantcolor
                if strcmp(hScatter.MarkerFaceColor,'flat')
                    p(k).properties.MarkerFaceColor = color;
                end
                if strcmp(hScatter.MarkerEdgeColor,'flat')
                    p(k).properties.MarkerEdgeColor = color;
                end
                p(k).properties.FaceVertexCData = [];
            end
        end
    end
end
