classdef (Abstract) ActionBehavior_IsFavorite < handle
    % Mixin class inherited by GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Hidden, Dependent, SetAccess = protected)
        % Property "IsFavorite": 
        %
        %   Whether the gallery item is a favorite.  It is a logical and
        %   the default value is false. It is a read-only property.
        %
        %   Example:
        %       popup = matlab.ui.internal.toolstrip.GalleryPopup();
        %       category = matlab.ui.internal.toolstrip.GalleryCategory('foo');
        %       item = matlab.ui.internal.toolstrip.GalleryItem('bar');
        %       popup.add(category);
        %       category.add(item);
        %       item.IsFavorite % returns false
        %       item.addToFavorite();
        %       item.IsFavorite % returns true
        %
        IsFavorite
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)        
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % IsFavorite
        function value = get.IsFavorite(this)
            % GET function
            action = this.getAction;
            value = action.IsFavorite;
        end
        
    end
    
end