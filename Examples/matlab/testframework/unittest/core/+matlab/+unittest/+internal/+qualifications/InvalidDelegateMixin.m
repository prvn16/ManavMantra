classdef InvalidDelegateMixin < matlab.unittest.internal.qualifications.QualificationDelegate
    methods(Sealed)
        function qualifyThat(varargin)
            throwAsCaller(MException(message('MATLAB:unittest:Fixture:QualificationMethodMustBeCalledFromSetupOrTeardown')));
        end
    end
end

