classdef SuiteCreationLiaison < handle
    % This class is undocumented and will change in a future release.
    
    % SuiteCreationLiaison - Class to handle communication between SuiteCreationServices.
    %
    % See Also: SuiteCreationService, Service, ServiceLocator, ServiceFactory, TestSuiteFactory
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % ParentName - Name of the test content, including any packages.
        ParentName;
    end
    
    properties (Dependent)
        % Factory - TestSuiteFactory for creating suites.
        %   A SuiteCreationService can set the factory if it is able to determine
        %   through static analysis what kind of factory to create.
        Factory;
    end
    
    properties (Dependent, SetAccess=private)
        % UsingDefaultFactory - Boolean indicating whether a SuiteCreationService
        %   has set the Factory.
        UsingDefaultFactory = true;
        
        % ParentNameMeetsNamingConvention - Boolean indicating whether the parent
        %   name meets a naming convention.
        ParentNameMeetsNamingConvention;
        
        % NamingConventionServices - Array of naming convention services.
        NamingConventionServices;
        
        % SimpleParentName - Name of the test content without any package prefixes.
        SimpleParentName;
        
        % Filename - Full path to file.
        %   If the parent name cannot be resolved to a file, this property is empty.
        Filename;
        
        % ParseTree - An mtree representation of file contents.
        ParseTree;
    end
    
    properties(Hidden)
        SkipMCheck (1,1) logical = false; % May be removed in the near future
    end
    
    properties (Access=private)
        InternalFactory = UNINITIALIZED;
        InternalParentNameMeetsNamingConvention = UNINITIALIZED;
        InternalNamingConventionServices = UNINITIALIZED;
        InternalSimpleParentName = UNINITIALIZED;
        InternalFilename = UNINITIALIZED;
        InternalParseTree = UNINITIALIZED;
    end
    
    methods
        function set.Factory(liaison, factory)
            liaison.InternalFactory = factory;
        end
        
        function factory = get.Factory(liaison)
            import matlab.unittest.internal.NonTestFactory;
            
            if liaison.UsingDefaultFactory
                exception = MException(message('MATLAB:unittest:TestSuite:NonTestFile', liaison.ParentName));
                factory = NonTestFactory(exception);
                return;
            end
            
            factory = liaison.InternalFactory;
        end
        
        function bool = get.UsingDefaultFactory(liaison)
            bool = isUninitialized(liaison.InternalFactory);
        end
        
        function bool = get.ParentNameMeetsNamingConvention(liaison)
            import matlab.unittest.internal.services.namingconvention.NamingConventionLiaison;
            
            if isUninitialized(liaison.InternalParentNameMeetsNamingConvention)
                services = liaison.NamingConventionServices;
                namingConventionLiaison = NamingConventionLiaison(liaison.SimpleParentName);
                fulfill(services, namingConventionLiaison);
                liaison.InternalParentNameMeetsNamingConvention = namingConventionLiaison.MeetsConvention;
            end
            bool = liaison.InternalParentNameMeetsNamingConvention;
        end
        
        function set.NamingConventionServices(liaison, services)
            liaison.InternalNamingConventionServices = services;
        end
        
        function services = get.NamingConventionServices(liaison)
            import matlab.unittest.internal.services.ServiceLocator;
            import matlab.unittest.internal.services.ServiceFactory;
            
            % If not passed in via the constructor, use the service locator
            % to locate the naming convention services to use.
            if isUninitialized(liaison.InternalNamingConventionServices)
                liaison.InternalNamingConventionServices = locateNamingConventionServices;
            end
            services = liaison.InternalNamingConventionServices;
        end
        
        function name = get.SimpleParentName(liaison)
            import matlab.unittest.internal.getSimpleParentName;
            
            if isUninitialized(liaison.InternalSimpleParentName)
                liaison.InternalSimpleParentName = getSimpleParentName(liaison.ParentName);
            end
            name = liaison.InternalSimpleParentName;
        end
        
        function filename = get.Filename(liaison)
            if isUninitialized(liaison.InternalFilename)
                liaison.InternalFilename = liaison.resolveFilename;
            end
            filename = liaison.InternalFilename;
        end
        
        function tree = get.ParseTree(liaison)
            if isUninitialized(liaison.InternalParseTree)
                liaison.InternalParseTree = mtree(liaison.Filename, '-file');
            end
            tree = liaison.InternalParseTree;
        end
    end
    
    methods(Static)
        function liaison = fromParentName(parentName, namingConventionServices)
            import matlab.unittest.internal.services.suitecreation.SuiteCreationLiaison;
            if nargin < 2
                namingConventionServices = UNINITIALIZED;
            end
            liaison = SuiteCreationLiaison(parentName,UNINITIALIZED,UNINITIALIZED,namingConventionServices);
        end
        
        function liaison = fromFilename(filename, parseTree, namingConventionServices)
            import matlab.unittest.internal.services.suitecreation.SuiteCreationLiaison;
            import matlab.unittest.internal.getParentNameFromFilename;
            parentName = getParentNameFromFilename(filename);
            liaison = SuiteCreationLiaison(parentName,filename,parseTree,namingConventionServices);
        end
    end
    
    methods (Access=private)
        function liaison = SuiteCreationLiaison(parentName, fileName, parseTree, namingConventionServices)
            liaison.ParentName = parentName;
            liaison.InternalFilename = fileName;
            liaison.InternalParseTree = parseTree;
            liaison.NamingConventionServices = namingConventionServices;
        end
        
        function filename = resolveFilename(liaison)
            % resolveFilename - Determine filename from the parent name.
            %   resolveFilename returns the full path to the file specified by parent
            %   name. If no such file exists, filename is empty.
            
            import matlab.unittest.internal.getFilenameFromParentName;
            import matlab.unittest.internal.whichFile;
            
            if exist(getFilenameFromParentName(liaison.ParentName)) %#ok<EXIST>
                filename = whichFile(liaison.ParentName);
            else
                filename = '';
            end
        end
    end
end

function services = locateNamingConventionServices
import matlab.unittest.internal.services.ServiceLocator;
import matlab.unittest.internal.services.ServiceFactory;

package = 'matlab.unittest.internal.services.namingconvention.located';
locator = ServiceLocator.forPackage(meta.package.fromName(package));
cls = ?matlab.unittest.internal.services.namingconvention.NamingConventionService;
serviceClasses = locator.locate(cls);
services = ServiceFactory.create(serviceClasses);
end

function bool = isUninitialized(value)
bool = isequal(value, UNINITIALIZED);
end

function out = UNINITIALIZED
% Simple marker for a value that has not yet been computed. This value is
% never equal to any valid value for a property of this class.
out = {};
end

% LocalWords:  namingconvention cls
