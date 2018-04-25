%IMELLIPSE Create draggable ellipse.
%   H = IMELLIPSE begins interactive placement of an ellipse on the
%   current axes. The function returns H, a handle to an imellipse object.
%
%   The ellipse has a context menu associated with it that allows you to
%   copy the current position to the clipboard and change the color used to
%   display the ellipse. Right-click on the ellipse to access this
%   context menu.
%
%   H = IMELLIPSE(HPARENT) begins interactive placement of an ellipse on
%   the object specified by HPARENT. HPARENT specifies the HG parent of the
%   ellipse graphics, which is typically an axes but can also be any other
%   object that can be the parent of an hggroup.
%
%   H = IMELLIPSE(HPARENT,POSITION) creates a draggable ellipse on the
%   object specified by HPARENT. POSITION is a four-element vector that
%   specifies the initial position of the ellipse. POSITION has the form
%   [XMIN YMIN WIDTH HEIGHT].
%
%   H = IMELLIPSE(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a draggable
%   ellipse, specifying parameters and corresponding values that control
%   the behavior of the ellipse. Parameter names can be abbreviated, and
%   case does not matter.
%
%   Parameters include:
%
%   'PositionConstraintFcn'        Function handle fcn that is called whenever 
%                                  the ellipse is dragged using the mouse. Type
%                                  "help imellipse/setPositionConstraintFcn"
%                                  for information on valid function
%                                  handles.
%
%   Methods
%   -------
%   Type "methods imellipse" to see a list of the methods.
%
%   For more information about a particular method, type 
%   "help imellipse/methodname" at the command line.
%
%   Remarks
%   -------
%   If you use IMELLIPSE with an axis that contains an image object, and do
%   not specify a position constraint function, users can drag the
%   ellipse outside the extent of the image and lose the ellipse.  When
%   used with an axis created by the PLOT function, the axis limits
%   automatically expand to accommodate the movement of the ellipse.
%
%   Example 1
%   ---------    
%   Display updated position in the title. Specify a position constraint
%   function using makeConstrainToRectFcn to keep the ellipse inside the
%   original xlim and ylim ranges.
%
%   figure, imshow('cameraman.tif');
%   h = imellipse(gca, [10 10 100 100]);
%   addNewPositionCallback(h,@(p) title(mat2str(p,3)));
%   fcn = makeConstrainToRectFcn('imellipse',get(gca,'XLim'),get(gca,'YLim'));
%   setPositionConstraintFcn(h,fcn);   
%
%   Example 2
%   ---------
%   Interactively place an ellipse by clicking and dragging. Use wait to block
%   the MATLAB command line. Double-click on the ellipse to resume execution
%   of the MATLAB command line.
%
%   figure, imshow('pout.tif');
%   h = imellipse;
%   vertices = wait(h);
%
%   See also IMROI, IMFREEHAND, IMLINE, IMPOINT, IMPOLY, IMRECT,
%   makeConstrainToRectFcn.

%   Copyright 2007-2009 The MathWorks, Inc.

classdef imellipse < imrect
    
    properties(GetAccess = 'private',SetAccess = 'private')
        
        h_ax;
        
    end
    
    methods
       
        function obj = imellipse(varargin)
            %imellipse  Constructor for imellipse.
           
            obj = obj@imrect(varargin{:},'DrawAPI',ellipseSymbol());
            if ~isempty(obj)
                obj.h_ax = ancestor(obj.h_group,'axes');
                set(obj, 'Tag', 'imellipse');
            end
            
            
            
        end
        
        function vert = getVertices(obj)
            %getVertices  Return vertices on perimeter of ellipse.
            %
            %   vert = getVertices(h) returns a set of vertices which
            %   lie along the perimeter of the ellipse h. vert is a N-by-2
            %   array.
            
            h_ax = ancestor(obj.h_group,'axes');
            vert = getEllipseVertices(h_ax,obj.getPosition());
            
        end
        
        function vert = wait(obj)
            %wait  Block MATLAB command line until ROI creation is
            %finished.
            %
            %   vert = wait(h) blocks execution of the MATLAB
            %   command line until you finish positioning the ROI object h.
            %   You indicate completion by double-clicking on the ROI
            %   object.  The returned vertices, vert, is of the
            %   form returned by the getVertices method.
           
            pos = wait@imroi(obj);
            vert = [];
            if ~isempty(pos)
                vert = getEllipseVertices(obj.h_ax,pos);
            end
              
        end
        
    end
    
    methods (Access = 'protected')
       
        function [roix,roiy,m,n] = getPixelPosition(obj,h_im)
            
            % Overriding base class. getPixelPosition wouldn't need to be
            % overridden if getVertices becomes a public method of all ROI
            % objects.
            
            [xdata,ydata,a] = getimage(h_im);
            m = size(a,1);
            n = size(a,2);
            
            vert = obj.getVertices();
            xi = vert(:,1);
            yi = vert(:,2);
            
            % Transform xi,yi into pixel coordinates.
            roix = axes2pix(n, xdata, xi);
            roiy = axes2pix(m, ydata, yi);
            
        end
        
    end
   
end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imrect
    
    
