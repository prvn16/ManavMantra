classdef (Sealed) AnyArguments < matlab.mixin.internal.Scalar
    % AnyArguments - Match any arguments.
    %
    %   Use AnyArguments to match any number of arguments when specifying mock
    %   object behavior or qualifying mock object interactions. AnyArguments
    %   matches an unlimited number of arguments, including zero.
    %
    %   AnyArguments must always be specified as the last argument in the
    %   argument list.
    %
    %   Examples:
    %       import matlab.mock.AnyArguments;
    %       import matlab.mock.actions.ThrowException;
    %
    %       testCase = matlab.mock.TestCase.forInteractiveUse;
    %
    %       % Create a mock for a bank account class
    %       [saboteurAccount, behavior] = testCase.createMock("AddedMethods","deposit");
    %
    %       % Define behavior
    %       when(behavior.deposit(AnyArguments), ThrowException);
    %
    %       % All of the following interactions throw an exception:
    %       saboteurAccount.deposit;
    %       saboteurAccount.deposit(-10);
    %       saboteurAccount.deposit(10);
    %       saboteurAccount.deposit('a', 'b', 'c');
    %
    %   See also:
    %       matlab.mock.TestCase
    
    % Copyright 2016 The MathWorks, Inc.
    
end

