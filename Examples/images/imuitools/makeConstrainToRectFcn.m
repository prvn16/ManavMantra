function fcn = makeConstrainToRectFcn(type,xlim,ylim)
%makeConstrainToRectFcn Create rectangularly bounded position constraint function.
%   fcn = makeConstrainToRectFcn(type,xlim,ylim) creates a position constraint
%   function for draggable tools of a given type, where type is one of the
%   following character arrays or strings:
%    
%   'imellipse'
%   'imfreehand' 
%   'imline'
%   'impoint'
%   'impoly'
%   'imrect'    
%     
%    The rectangular boundaries of the position constraint function are
%    described by the vectors xlim and ylim where xlim = [xmin xmax] and
%    ylim = [ymin ymax].
%
%   Example
%   -------
%   % Constrain drag of impoint within axis limits 
%   figure, plot(1:10);
%   h = impoint(gca,2,6);
%   api = iptgetapi(h);
%   fcn = makeConstrainToRectFcn('impoint',get(gca,'XLim'),get(gca,'YLim'));
%   api.setPositionConstraintFcn(fcn);
%
%   See also imdistline, imellipse, imfreehand, imline, impoint, impoly, imrect
  
%   Copyright 2005-2016 The MathWorks, Inc.

if nargin > 0
    type = convertStringsToChars(type);
end

validatestring(lower(type),...
            {'imline','imrect','impoint','imellipse','impoly','imfreehand'},...
            mfilename,'type',1);
        
validateattributes(xlim,{'numeric'},{'vector'},mfilename,'xlim',2);
validateattributes(ylim,{'numeric'},{'vector'},mfilename,'ylim',3);

if length(xlim) ~= 2
    error(message('images:makeConstrainToRectFcn:xLimSize'));
end

if length(ylim) ~= 2
    error(message('images:makeConstrainToRectFcn:yLimSize'));
end
            
switch lower(type)
    case 'imline'
        fcn = @constrainLineToRect;
    case {'imrect','imellipse'}
        fcn = @constrainRectToRect;
    case 'impoint'
        fcn = @constrainPointToRect;
    case {'impoly','imfreehand'}
        fcn = @constrainPolygonToRect;
end

%Store previous position matrix for use in constrainLineToRect.
line_pos_last = [];

%Store previous rectangle vertices for use in constrainRectToRect.
rect_pos_last = [];

% Store previous position matrix of polygon for use in
% constrainPolygonToRect
polygon_pos_last = [];

% Use threshold for deciding whether or not a drag is a resize event to
% avoid incorrect constraint from being applied due to numerical error
resize_threshold = 1000 * eps;


    %-----------------------------------------
    function new_pos = constrainLineToRect(pos)
                                
        previous_position_cached = ~isempty(line_pos_last);
        
        is_end_point_drag = previous_position_cached &&...
                            (any(pos(:,1) == line_pos_last(:,1)) &&...
                            any(pos(:,2) == line_pos_last(:,2)));
                                    
        if is_end_point_drag
            new_pos = [constrainPointToRect(pos(1,:));constrainPointToRect(pos(2,:))];
        else
            %Apply correction made to first end point to both end points
            constrained_p1 = constrainPointToRect(pos(1,:));
            v1 = constrained_p1 - pos(1,:);
            temp_pos = pos + [v1; v1];
            
            % Now reconstrain both end points according to correction made
            % to second endpoint of partially constrained line.
            constrained_p2 = constrainPointToRect(temp_pos(2,:));
            v2 = constrained_p2 - temp_pos(2,:);
            new_pos = temp_pos + [v2; v2];     
        end
        
        line_pos_last = new_pos;
    end

    %-----------------------------------------
    function new_pos = constrainRectToRect(pos)
       		
		previous_position_cached = ~isempty(rect_pos_last);
        
		is_resize_drag = previous_position_cached &&...
			any(abs(pos(3:4) - rect_pos_last(3:4)) > resize_threshold);
              
        if is_resize_drag
			
            vert = posRect2Vertices(pos);
            for i = 1:4
                vert(i,:) = constrainPointToRect(vert(i,:));
            end
            new_pos = vertices2PosRect(vert);

        else

            new_pos = constrainTranslatedRectToRect(pos);
 
        end            

        rect_pos_last = new_pos;

    end
    
     %------------------------------------------
    function new_pos = constrainPointToRect(pos)

        x_candidate = pos(1);
        y_candidate = pos(2);

        x_new = min( xlim(2), max(x_candidate, xlim(1) ) );
        y_new = min( ylim(2), max(y_candidate, ylim(1) ) );

        new_pos = [x_new y_new];

    end

    %----------------------------------------------------
    function new_pos = constrainTranslatedRectToRect(pos)
    
        x_min = min( xlim(2) - pos(3), max(pos(1), xlim(1)) );
        y_min = min( ylim(2) - pos(4), max(pos(2), ylim(1)) );
        new_pos = [x_min y_min pos(3) pos(4)];

    end
        
    %----------------------------------------------
    function new_pos = constrainPolygonToRect(pos)
        
        previous_position_cached = ~isempty(polygon_pos_last) &&...
                                   isequal(size(pos),size(polygon_pos_last));
        
        polygon_translated = previous_position_cached &&...
                             all( pos(:,1) ~= polygon_pos_last(:,1) |...
                                  pos(:,2) ~= polygon_pos_last(:,2));
                                                
        num_points = size(pos,1);
              
        new_pos = pos;
        if polygon_translated                 
        
			b_box = findBoundingBox(pos(:,1),pos(:,2));
			
            constrained_b_box = constrainTranslatedRectToRect(b_box);
		
			delta_pos = constrained_b_box(1:2) - b_box(1:2);
			delta_pos = repmat(delta_pos,num_points,1);
			new_pos = pos + delta_pos;

		else % Vertex dragged
            for i = 1:num_points
               new_pos(i,:) = constrainPointToRect(pos(i,:));
            end
        end
           
        polygon_pos_last = new_pos;
    end

end
