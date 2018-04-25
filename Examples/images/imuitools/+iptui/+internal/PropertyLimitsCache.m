% Copyright 2014 The MathWorks, Inc.

classdef PropertyLimitsCache < handle
    
    properties (Access = private)
        
        cachedLimits
        
        app
        
        maskListener
        
    end
    
    properties (SetAccess = private, SetObservable = true)
        cacheUpdates = 0;
    end
    
    methods (Access = public)
        
        %------------------------------------------------------------------
        function self = PropertyLimitsCache(app_)

            % Set up and observer relationship with the main app.
            self.app = app_;
            self.maskListener = addlistener(self.app, 'maskFilledCleared', 'PostSet', @(hObj,evt) self.maskChanged(hObj, evt));
            
            % Populate limits in the cache.
            self.updateCache()
        end
        
        %------------------------------------------------------------------
        function limits = getPropLimits(self, propName)
            
            if isempty(self.cachedLimits)
                propsInCache = '';
            else
                propsInCache = fieldnames(self.cachedLimits);
            end
            
            switch (propName)
                case propsInCache
                    limits = self.cachedLimits.(propName);
                otherwise
                    self.addToCache(propName)
                    limits = self.cachedLimits.(propName);
            end
        end
        
    end
    
    methods (Access = private)
        
        %------------------------------------------------------------------
        function updateCache(self)
            propsToCache = self.app.interestingProps();
            if isempty(propsToCache)
                return
            end
            
            propsToGet = setdiff(propsToCache, ...
                {'eccentricity', 'extent', 'solidity', 'orientation'});
            propsUnfiltered = regionprops(self.app.maskFilledCleared, ...
                propsToGet);
            
            for idx = 1:numel(propsToCache)
                theProp = propsToCache{idx};
                switch (lower(theProp))
                    case {'eccentricity', 'extent', 'solidity'}
                        self.cachedLimits.(theProp) = [0 1];
                    case {'orientation'}
                        self.cachedLimits.(theProp) = [-90 90];
                    case {'eulernumber'}
                        if ~isempty(propsUnfiltered)
                            minLimit = min([propsUnfiltered.(theProp)]);
                            maxLimit = max([propsUnfiltered.(theProp)]);
                            self.cachedLimits.(theProp) = [floor(minLimit), ceil(maxLimit)];
                        else
                            self.cachedLimits.(theProp) = [0 0];
                        end
                    otherwise
                        if ~isempty(propsUnfiltered)
                            maxLimit = max([propsUnfiltered.(theProp)]);
                            self.cachedLimits.(theProp) = [0 ceil(maxLimit)];
                        else
                            self.cachedLimits.(theProp) = [0 0];
                        end
                end
            end
        end
        
        %------------------------------------------------------------------
        function addToCache(self, propName)
            switch (lower(propName))
                case {'eccentricity', 'extent', 'solidity'}
                    self.cachedLimits.(propName) = [0 1];
                case {'orientation'}
                    self.cachedLimits.(propName) = [-90 90];
                case {'eulernumber'}
                    props = regionprops(self.app.maskFilledCleared, propName);
                    if ~isempty(props)
                        minLimit = min([props.(theProp)]);
                        maxLimit = max([props.(theProp)]);
                        self.cachedLimits.(theProp) = [floor(minLimit), ceil(maxLimit)];
                    else
                        self.cachedLimits.(theProp) = [0 0];
                    end
                otherwise
                    props = regionprops(self.app.maskFilledCleared, propName);
                    if ~isempty(props)
                        maxLimit = max([props.(propName)]);
                        self.cachedLimits.(propName) = [0 ceil(maxLimit)];
                    else
                        self.cachedLimits.(propName) = [0 0];
                    end
            end
        end
        
        %------------------------------------------------------------------
        function maskChanged(self, ~, ~)
            self.updateCache()
            self.cacheUpdates = self.cacheUpdates + 1;
        end
        
    end
end