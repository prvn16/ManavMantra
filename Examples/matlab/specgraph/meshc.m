function h = meshc(varargin)
    %MESHC  Combination mesh/contour plot.
    %   MESHC(...) is the same as MESH(...) except that a contour plot
    %   is drawn beneath the mesh.
    %
    %   Because CONTOUR does not handle irregularly spaced data, this
    %   routine only works for surfaces defined on a rectangular grid.
    %   The matrices or vectors X and Y define the axis limits only.
    %
    %   See also MESH, MESHZ.
    
    %   Clay M. Thompson 4-10-91
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    nargs = length(args);
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 4
        error(message('MATLAB:narginchk:tooManyInputs'));
    end
    
    if nargs == 1  % Generate x, y matrices for surface z.
        z = args{1};
        z = datachk(z,'numeric');
        [m, n] = size(z);
        [x, y] = meshgrid(1 : n, 1 : m);
    elseif nargs == 2
        z = args{1};
        c = args{2};
        z = datachk(z,'numeric');
        c = datachk(c,'numeric');
        [m, n] = size(z);
        [x, y] = meshgrid(1 : n, 1 : m);
    else
        [x, y, z] = deal(args{1 : 3});
        x = datachk(x,'numeric');
        y = datachk(y,'numeric');
        z = datachk(z,'numeric');
        if nargs == 4
            c = args{4};
            c = datachk(c,'numeric');
        end
    end
    
    if min(size(z)) == 1
        error(message('MATLAB:meshc:MatrixInput'));
    end
    
    % Determine state of system
    if isempty(cax)
        cax = gca;
    end
    nextPlot = cax.NextPlot;
    
    % Plot mesh.
    if nargs == 2 || nargs == 4
        hm = mesh(cax, x, y, z, c);
    else
        hm = mesh(cax, x, y, z);
    end
    
    % Set NextPlot to 'add' so that the contour object is added to the
    % existing axes. 'mesh' calls 'newplot', so the Figure's NextPlot
    % property will already be set to 'add' at this point.
    cax.NextPlot = 'add';
    
    a = get(cax, 'ZLim');
    
    % Always put contour below the plot.
    zpos = a(1);
    
    % Get the contour data
    [~, hh] = contour(cax, x, y, z, 'ContourZLevel', zpos);
    
    % Restore the original value for NextPlot.
    cax.NextPlot = nextPlot;
    
    if nargout > 0
        h = [hm; hh(:)];
    end
end
