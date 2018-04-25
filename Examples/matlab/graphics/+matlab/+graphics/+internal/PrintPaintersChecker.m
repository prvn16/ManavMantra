classdef (Sealed) PrintPaintersChecker < handle
    % PrintPaintersChecker  - Helper class used by printing.
    %
    % This undocumented helper class is for internal use.
    
    %   Copyright 2014-2017 The MathWorks, Inc.
    
    properties 
        VertexLimit = 100000; % more than this and we won't auto-switch painters
        ObjectLimit = 1000; % more than this and we won't auto-switch to painters
        DebugMode = false; % true means print out some debugging info 
        
        LitSurfaceAndPatchLimit = 0; % more than this and we won't auto switch
        SurfaceTextureLimit = 2^24; % more than this and we won't auto switch 
    end
    
    properties (SetObservable)
        % classes we'll search for - observable because we need to rebuld the
        % query whenever it is set
        VertexPrimitiveList; 
    end
    
    properties (Access = private)
        VertexQuery = {}; % query for findobj 
    end
    
    methods (Access = private) 
        % private so only 1 instance can be created 
        function obj = PrintPaintersChecker()
            % setup listener to update query if vertex primitive list
            % changes
            addlistener(obj,'VertexPrimitiveList','PostSet',@obj.buildVertexQuery);            
            % initial set of classes we'll search for to find VertexData
            obj.VertexPrimitiveList = {'matlab.graphics.primitive.world.Line', ...
                             'matlab.graphics.primitive.world.LineStrip', ...
                             'matlab.graphics.primitive.world.Triangle', ...
                             'matlab.graphics.primitive.world.TriangleStrip', ...
                             'matlab.graphics.primitive.world.Quadrilateral', ...
                             'matlab.graphics.primitive.world.Marker', ...
                             'matlab.graphics.primitive.world.CompositeMarker', ...
                             'matlab.graphics.primitive.world.Point'};
        end
    end
    methods (Static) 
        function instance = getInstance()
            persistent theInstance;
            if isempty(theInstance) || ~isvalid(theInstance)
                theInstance = matlab.graphics.internal.PrintPaintersChecker;
            end
            instance = theInstance;
        end
    end
    
    methods (Access = public)
        
        % for given figure, check to see if the object and vertex counts are within
        % the limits. Returns true if either is above the set limit; and false
        % otherwise
        function exceeds = exceedsVertexLimits(obj, fig) 
            k = findobjinternal(fig, obj.VertexQuery);

            % return true if 
            % * number of found objects exceeds the object limit or 
            % * size of VertexData exceeds vertex limit
            
            if length(k) > obj.ObjectLimit
                % object count too high... 
                if obj.DebugMode
                   fprintf('PrintPaintersChecker: too many objects (%d)\n', length(k));
                end
                exceeds = true;
                return;
            else
                count = 0;
                for idx = 1:length(k) 
                    count = count + size(k(idx).VertexData, 2); 
                end
                exceeds = count > obj.VertexLimit;
                if obj.DebugMode
                   if exceeds
                       result = 'too many';
                   else
                       result = 'not too many';
                   end
                   fprintf('PrintPaintersChecker: found %d objects and %d vertices; %s\n', length(k), count, result);
                end
            end
        end

        % return query for findobj based on VertexPrimitiveList
        function query = getVertexQuery(obj)
            query = obj.VertexQuery;
            if obj.DebugMode 
                fprintf('query is: \n   ');
                for idx = 1:length(query) 
                    fprintf('%s ', query{idx});
                    if ~mod(idx, 3)
                        fprintf('\n   ');
                    end
                end
                fprintf('\n');
            end
            
        end
        function exceeds = exceedsLightingLimits(obj, fig)
            exceeds = false; % assume lighting won't be problem
            surfaceAndPatchCount = 0;
            lightCount = length(findobjinternal(fig, {'type', 'Light', '-and', 'visible', 'on'}));
            if lightCount > 0
                % visible surfaces and patches with lighting that could 
                % impact output
                surfaceAndPatchList = findobjinternal(fig, ...
                    'visible', 'on', '-and', ...
                    {'type', 'surface', '-or', 'type', 'patch'}, '-and', ...
                    '-not', 'facelighting', 'none');
                for idx = 1:length(surfaceAndPatchList)
                    surfaceAndPatchCount = surfaceAndPatchCount + ...
                        obj.countIfVisible(surfaceAndPatchList(idx));
                end
            end
            if surfaceAndPatchCount > obj.LitSurfaceAndPatchLimit
                exceeds = true;
            end
        end
        
        function exceeds = exceedsTextureLimits(obj, fig)
            % Check if given surface object with Facecolor
            % 'Texturemap', could produce large size output
            
            exceeds = false;
            currentTextureSize = 0;
            surfaces = findobjinternal(fig, 'visible', 'on', 'type', 'surface', '-and', 'FaceColor', 'Texturemap');
            if ~isempty(surfaces)
               for idx = 1:length(surfaces)
                   xLength = length(get(surfaces(idx), 'XData'));
                   yLength = length(get(surfaces(idx), 'YData'));
                   xCData = size(get(surfaces(idx), 'CData'), 1);
                   yCData = size(get(surfaces(idx), 'CData'), 2);
                   
                   totalTriangles = (xLength-1)*(yLength-1)*2;
                   currentTextureSize = currentTextureSize + ...
                       totalTriangles*xCData*yCData;
               end
            end
            
            if currentTextureSize>obj.SurfaceTextureLimit
                exceeds = true;
            end
        end
        
    end
    
    methods (Access = private) 
        % create query for findobj based on VertexPrimitiveList
        function buildVertexQuery(obj, ~, ~)
            
            query = [];
            for idx = 1:length(obj.VertexPrimitiveList)
                newEntry = {'-isa' obj.VertexPrimitiveList{idx}};
                if idx == 1
                    query = newEntry;
                else 
                    query = [query {'-or'} newEntry];
                end
                
            end
            
            obj.VertexQuery = [{'Visible'} {'on'} query];
           
        end
        
        % h is a visible surface or patch (h.Visible == 'on')
        function count = countIfVisible(~, h)
            count = 0;
            vis = true;
            % except for figure and axes, if the parents are all visible
            % then the object with 'visible' 'on' is visible too
            p = h.Parent;
            while vis == true 
                if isa(p, 'matlab.ui.Figure') || isa(p, 'matlab.ui.Root')
                    break;
                end
                % we ignore axes visibility because that doesn't impact the
                % visibility of the contained children
                if ~(isa(p, 'matlab.graphics.axis.Axes') || isa(p, 'matlab.ui.control.UIAxes'))
                    % ignore parents that don't have visible property
                    try 
                       vis = strcmp(p.Visible, 'on');
                    catch
                        % ignore ... might not have a Visible property
                    end
                end
                if ~vis
                    break;
                end
                p = p.Parent;
            end
            % if vis is true then the input object should be really
            % visible)
            if vis
                count = 1;
            end
        end
    end
end
