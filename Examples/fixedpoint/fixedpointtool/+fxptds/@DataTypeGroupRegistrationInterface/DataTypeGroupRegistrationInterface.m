classdef (Abstract) DataTypeGroupRegistrationInterface
    % DataTypeGroupRegistrationInterface This class is the abstract parent of the common registration gateway
    % interface for the data type group registration process. Any class
    % that implements this interface needs to implement a public method of
    % "resister" that takes as first input an object of data type group and
    % second input a group member (AbstractResult)
	
    %   Copyright 2016 The MathWorks, Inc.
    methods (Abstract)
        register(this, dataTypeGroup, member)
    end
    
end