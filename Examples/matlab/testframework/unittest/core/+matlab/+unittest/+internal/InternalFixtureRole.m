classdef InternalFixtureRole < matlab.unittest.internal.FixtureRole
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant, Access=protected)
        IsSetUpByRunner logical = true;
        IsUserVisible logical = false;
    end
    
    methods (Sealed)
        function roles = InternalFixtureRole(fixtures)
            roles = roles@matlab.unittest.internal.FixtureRole(fixtures);
        end
        
        function role = constructFixture(role, ~, affectedIndices)
            role.AffectedIndices = affectedIndices;
            role.Instance = copy(role.Instance);
        end
        
        function setupFixture(role, ~)
            fixture = role.Instance;
            registerTeardown = onCleanup(@()fixture.addTeardown(@teardown, fixture));
            fixture.setup;
        end
        
        function teardownFixture(role, ~)
            executeAllTeardownFor(role.Instance);
        end
        
        function deleteFixture(role)
            delete(role.Instance);
        end
    end
end


function executeAllTeardownFor(teardownable)
% Execute all teardown content without invoking the teardownable's destructor.
teardownable.runAllTeardownThroughProcedure_( ...
    @(fcn,varargin)fcn(teardownable, varargin{:}));
end

% LocalWords:  teardownable teardownable's
