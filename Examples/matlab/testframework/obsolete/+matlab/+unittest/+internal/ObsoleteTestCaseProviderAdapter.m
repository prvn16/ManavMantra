classdef (Sealed) ObsoleteTestCaseProviderAdapter < matlab.unittest.internal.TestCaseProvider
   % ObsoleteTestCaseProviderAdapter - Provides a TestCaseProvider wrapper
   % for interacting with TestCaseProvider instances that were saved in a
   % release prior to R2017a. 
   
   % Copyright 2016 The MathWorks, Inc.
    
   properties (Dependent, SetAccess = immutable)
      TestClass
      TestParentName
      TestMethodName
      TestName
   end
   
   properties (SetAccess = private)
       SharedTestFixtures
       Parameterization
       Tags = cell.empty(1, 0);
   end   
   
   properties (Access = private)
      DeprecatedTestCaseProvider 
   end
   
   methods
       function provider = ObsoleteTestCaseProviderAdapter(prototype)                        
            provider.DeprecatedTestCaseProvider = prototype.TestCaseProvider;
            
            % Prior to R2016b, the following properties were set on the
            % Test instance, rather than the TestCaseProvider
            provider.Parameterization   = prototype.Parameterization;
            provider.SharedTestFixtures = prototype.SharedTestFixtures;
            provider.InternalSharedTestFixtures = prototype.InternalSharedTestFixtures;
            
            % Tags were not a Test or TestCaseProvider property in R2014b
            % and prior releases.
            if isfield(prototype, 'Tags')
                provider.Tags = prototype.Tags;
            end
       end
       
       function testCase = provideClassTestCase(provider)
           testCase = provider.DeprecatedTestCaseProvider.provideClassTestCase();
       end
       
       function testCase = createTestCaseFromClassPrototype(provider, classTestCase)
          testCase = provider.DeprecatedTestCaseProvider.createTestCaseFromClassPrototype(classTestCase);
       end    
       
       function testClass = get.TestClass(provider)
          testClass = provider.DeprecatedTestCaseProvider.TestClass; 
       end
       
       function testParentName = get.TestParentName(provider)
           testParentName = provider.DeprecatedTestCaseProvider.TestParentName;
       end
       
       function testMethodName = get.TestMethodName(provider)
          testMethodName = provider.DeprecatedTestCaseProvider.TestMethodName; 
       end
       
       function testName = get.TestName(provider)
          testName = provider.DeprecatedTestCaseProvider.TestName; 
       end

       function superClasses = getSuperclasses(provider)
            superClasses = provider.DeprecatedTestCaseProvider.getSuperclasses;
        end
   end
end