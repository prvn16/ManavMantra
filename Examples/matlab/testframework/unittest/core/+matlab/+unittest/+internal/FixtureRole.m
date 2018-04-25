classdef FixtureRole < matlab.mixin.Heterogeneous
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=protected)
        Instance (1,1) matlab.unittest.fixtures.Fixture = matlab.unittest.fixtures.EmptyFixture;
        AffectedIndices (1,:) double;
    end
    
    properties (Abstract, Constant, Access=protected)
        IsSetUpByRunner logical;
        IsUserVisible logical;
    end
    
    methods (Abstract)
        role = constructFixture(role, callback, affectedIndices);
        setupFixture(role, callback);
        teardownFixture(role, callback);
        deleteFixture(role);
    end
    
    methods (Sealed)
        function roles = FixtureRole(fixtures)
            roles = repmat(roles, size(fixtures));
            fixturesCell = num2cell(fixtures);
            [roles.Instance] = fixturesCell{:};
        end
        
        function bool = hasFixtureToSetUp(roles, requiredFixtures)
            import matlab.unittest.fixtures.Fixture;
            
            if isempty(requiredFixtures)
                % Quick return if no fixtures are needed at all
                bool = false;
                return;
            end
            
            bool = ~isempty(getTestFixturesToSetUp(roles.getActiveFixtureInstances, requiredFixtures));
        end
        
        function roles = determineSharedFixturesToSetUp(roles, prebuiltFixtures, requiredInternalFixtures, requiredUserFixtures)
            import matlab.unittest.internal.UserFixtureRole;
            import matlab.unittest.internal.InternalFixtureRole;
            import matlab.unittest.internal.PrebuiltFixtureRole;
            
            if isempty(requiredInternalFixtures) && isempty(requiredUserFixtures)
                % Quick return if no fixtures are needed at all
                roles = roles(zeros(1,0));
                return;
            end
            
            prebuiltFixturesToUse = roles.determinePrebuiltFixturesToUse(prebuiltFixtures, requiredUserFixtures);
            existingFixtures = [prebuiltFixturesToUse, roles.Instance];
            
            internalFixturesToSetUp = getTestFixturesToSetUp(existingFixtures, requiredInternalFixtures);
            userFixturesToSetUp = getTestFixturesToSetUp(existingFixtures, requiredUserFixtures);
            
            rolesToSetUp = [UserFixtureRole(userFixturesToSetUp), InternalFixtureRole(internalFixturesToSetUp)];
            rolesToSetUp = rolesToSetUp.orderAccordingToFolderScope;
            
            roles = [PrebuiltFixtureRole(prebuiltFixturesToUse), rolesToSetUp];
        end
        
        function idx = getIndicesOfFixturesToTearDown(roles, fixturesToKeep)
            mask = false(size(roles));
            for idx = 1:numel(roles)
                thisRole = roles(idx);
                if ~fixturesToKeep.containsEquivalentFixture(thisRole.Instance)
                    if thisRole.IsSetUpByRunner
                        mask(idx:end) = true;
                        break;
                    else
                        mask(idx) = true;
                    end
                end
            end
            
            idx = flip(find(mask));
        end
        
        function bool = hasFixtureSetUpByRunner(roles)
            bool = any([roles.IsSetUpByRunner]);
        end
        
        function bool = hasUserFixtureSetUpByRunner(roles)
            bool = any([roles.IsSetUpByRunner] & [roles.IsUserVisible]);
        end
        
        function fixtures = getUserVisibleFixtures(roles)
            roles = roles([roles.IsUserVisible]);
            fixtures = roles.getActiveFixtureInstances;
        end
        
        function tasks = getAdditionalFixtureOnFailureTasks(roles, fixture)
            for idx = 1:numel(roles)
                if roles(idx).Instance == fixture
                    % Don't consider the fixture itself nor any fixtures
                    % set up thereafter
                    roles(idx:end) = [];
                    break;
                end
            end
            tasks = roles.getAdditionalOnFailureTasks;
        end
        
        function tasks = getAdditionalOnFailureTasks(roles)
            import matlab.unittest.internal.Task;
            
            roles = roles([roles.IsUserVisible]);
            startIdx = find([roles.IsSetUpByRunner], 1, 'last');
            if isempty(startIdx)
                startIdx = 1;
            end
            
            fixtures = getActiveFixtureInstances(roles(startIdx:end));
            tasks = [Task.empty(1,0), fixtures.OnFailureTasks];
        end
    end
    
    methods (Sealed, Access=private)
        function fixtures = getActiveFixtureInstances(roles)
            import matlab.unittest.fixtures.Fixture;
            fixtures = [Fixture.empty(1,0), roles.Instance];
        end
        
        function prebuiltFixturesToUse = determinePrebuiltFixturesToUse(roles, prebuiltFixtures, requiredUserFixtures)
            import matlab.unittest.fixtures.Fixture;
            
            if isempty(prebuiltFixtures)
                % Quick return if no fixtures are needed
                prebuiltFixturesToUse = Fixture.empty(1,0);
                return;
            end
            
            existingFixtures = roles.getActiveFixtureInstances;
            newFixturesNeeded = getTestFixturesToSetUp(existingFixtures, requiredUserFixtures);
            
            prebuiltFixtureMask = false(size(prebuiltFixtures));
            for idx = 1:numel(prebuiltFixtures)
                prebuiltFixtureMask(idx) = containsEquivalentFixture(newFixturesNeeded, prebuiltFixtures(idx));
            end
            prebuiltFixturesToUse = prebuiltFixtures(prebuiltFixtureMask);
        end
        
        function roles = orderAccordingToFolderScope(roles)
            import matlab.unittest.internal.fixtures.FolderScope;
            import matlab.unittest.internal.whichFile;
            import matlab.unittest.internal.getParentNameFromFilename;
            
            fixtures = roles.getActiveFixtureInstances;
            scopes = [fixtures.FolderScope];
            
            for idx = 1:numel(fixtures)
                fixtureClassName = class(fixtures(idx));
                inferredFixtureClassName = getParentNameFromFilename(whichFile(fixtureClassName));
                
                if ~strcmp(fixtureClassName, inferredFixtureClassName)
                    % If the fixture isn't on the path, it's likely defined in the same
                    % folder as the test. Reduce its folder scope to be shared just
                    % within the folder where it's defined. The internal fixtures will
                    % place the fixture on the path before it is set up.
                    scopes(idx) = FolderScope.Within;
                end
            end
            
            [~, idx] = sort(scopes);
            roles = roles(idx);
        end
    end
end

function fixtures = getTestFixturesToSetUp(active, required)
fixtures = required(arrayfun(@(f)~active.containsEquivalentFixture(f), required));
end

% LocalWords:  prebuilt
