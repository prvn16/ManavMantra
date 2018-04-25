classdef Tolerance
    % Tolerance - Abstract interface for tolerances
    %
    %   Tolerances define a notion of fuzzy equality for a set of data
    %   types and can be plugged in to the IsEqualTo constraint through the
    %   'Within' parameter.
    %
    %   Tolerance methods:
    %       supports         - Returns a boolean value indicating whether the tolerance supports a specified data type
    %       satisfiedBy      - Returns a boolean value indicating whether the tolerance was satisfied by two values
    %       getDiagnosticFor - Returns a diagnostic object containing information about the result of a comparison
    
    %  Copyright 2012-2016 The MathWorks, Inc.
    
    methods (Abstract)
        % supports - Returns a boolean value indicating whether the tolerance supports a specified data type
        %
        %   The supports method is meant to provide the tolerance the opportunity
        %   to specify support for data types. The method is meant to operate by
        %   examining the type of <value> to determine whether it is supported.
        bool = supports(tolerance, value);
        
        % satisfiedBy - Returns a boolean value indicating whether the tolerance was satisfied by two values
        %
        %   This method defines the tolerance's notion of equality. If a tolerance
        %   has been satisfied, it indicates that the tolerance considers the two
        %   values equivalent.
        bool = satisfiedBy(tolerance, actVal, expVal);
        
        % getDiagnosticFor - Returns a diagnostic object containing information about the result of a comparison
        %
        %   Analyzes the actual and expected values and produces a
        %   matlab.unittest.diagnostics.ConstraintDiagnostic object containing
        %   information about the comparison performed.
        %
        %   See also:
        %       matlab.unittest.diagnostics.ConstraintDiagnostic
        diag = getDiagnosticFor(tolerance, actVal, expVal);
    end
end