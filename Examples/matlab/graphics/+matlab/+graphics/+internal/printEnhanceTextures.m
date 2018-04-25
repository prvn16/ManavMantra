classdef (Sealed) printEnhanceTextures < handle
    %PRINTENHANCETEXTURES - Helper class used by printing.
    %
    % This undocumented helper class is for internal use.
    % It finds objects which are going to be drawn as a texturemap quad
    % (in postscript/metafile output)and texture size is under certain limits.
    % This utility is added as part of g1487425.
    
    properties
        fSurfLimit;
        fImageLimit;
    end
    
    methods (Access = private)
        
        % private to allow only one instance
        function obj = printEnhanceTextures()
            
            % Set default limits
            obj.fSurfLimit = 2^10;
            obj.fImageLimit = 10^5;
        end
    end
    
    methods (Static)
        function instance = getInstance()
            persistent theInstance;
            if isempty(theInstance) || ~isvalid(theInstance)
                theInstance = matlab.graphics.internal.printEnhanceTextures;
            end
            instance = theInstance;
        end
    end
    
    methods (Access = public)
        
        function result = needEnhanceOutput(obj, allContents)
            % Check for low resolution texture quad.
            % If present, then upsample texture output, otherwise output looks blurry in following cases: (g1487425)
            % a) View eps/epsc output using mac preview app
            % b) Import metafile output in word/ppt, then do ungroup
            %
            % Note: Currently, Image and Surface(Texturemap) objects are being drawn as texture primitive quad,
            % 		may need to update findall logic in future for new objects (with texture quad)
            
            result = false;
            
            % Find image object
            allImage = findall(allContents, '-depth', 0, 'Type', 'Image');
            % Find surface object with 'Texturemap' FaceColor
            allSurf = findall(allContents, '-depth', 0, 'Type', 'Surface', '-and',...
                'FaceColor', 'Texturemap');
            
            % Ouput looks blurry under 10^5 CData size for Image object, and
            % under 2^10 CData size for surface object
            if (~isempty(allImage) && obj.isTexturesUnderLimit(allImage, obj.fImageLimit)) ||...
                    (~isempty(allSurf) && obj.isTexturesUnderLimit(allSurf, obj.fSurfLimit))
                result = true;
            end
        end
    end
    
    methods (Access = private)
        function res = isTexturesUnderLimit(~, objects, limit)
            % Check whether texture size is under given limit
            
            cdata = get(objects, {'CData'});
            doEnhance = cellfun(@(x) size(x,1)*size(x,2) < limit, cdata, 'Uniform', true);
            res = any(doEnhance);
        end
    end
end

