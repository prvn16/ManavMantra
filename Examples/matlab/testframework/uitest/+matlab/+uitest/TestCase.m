classdef (Abstract) TestCase < matlab.unittest.TestCase
    %TESTCASE - TestCase for writing tests using the App Testing Framework
    %
    %   Use the matlab.uitest.TestCase class to write tests that exercise
    %   the functionality of MATLAB Apps and leverage the App Testing
    %   Framework. The matlab.uitest.TestCase class derives from the
    %   matlab.unittest.TestCase class.
    %
    %   To avoid user interference with the App under test, new uifigure
    %   instances are "locked" automatically. The contents of locked
    %   figures are unresponsive to human interactions but continue to
    %   react to the programmatic gestures of the TestCase.
    %
    %   matlab.uitest.TestCase methods:
    %     forInteractiveUse - Create a TestCase for interactive use
    %     press  - Press UI component within App
    %     choose - Choose UI component or option within App
    %     drag   - Drag UI component within App
    %     type   - Type in UI component within App
    %
    %   Example:
    %
    %     % Create a class-based MATLAB unit test that derives from
    %     % matlab.uitest.TestCase:
    %     classdef MyUITest < matlab.uitest.TestCase
    %         methods (Test)
    %             function testLampColorInteraction(testCase)
    %                 % Create an App and specify teardown routine
    %                 f = uifigure;
    %                 testCase.addTeardown(@delete, f);
    %
    %                 % Configure a red-colored lamp to change to green
    %                 % when a button is pressed
    %                 lamp = uilamp(f, 'Position', [50 100 20 20], 'Color', 'red');
    %                 button = uibutton(f, ...
    %                     'ButtonPushedFcn', @(o,e)set(lamp, 'Color', 'green'));
    %
    %                 % Exercise - press the button to invoke its ButtonPushedFcn
    %                 testCase.press(button);
    %
    %                 % Verify that the lamp color is green
    %                 testCase.verifyEqual(lamp.Color, [0 1 0], ...
    %                     'The lamp should be green');
    %             end
    %         end
    %     end
    %
    %     % Run the test
    %     >> runtests MyUITest
    %
    % See also matlab.unittest.TestCase.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = private, Constant)
        Driver = matlab.ui.internal.Driver;
    end
    
    methods (Sealed, TestClassSetup, Hidden)
        
        function lockNewFigures(testCase)
            
            L = event.listener(?matlab.ui.Figure, ...
                'InstanceCreated', @(o,e)testCase.lockfig(e.Instance));
            
            testCase.addTeardown(@delete, L);
        end
        
    end
    
    methods (Sealed)
        
        function press(testCase, H, varargin)
            %PRESS Press UI component in App
            %
            %   press(TESTCASE, H) performs a "press" gesture on the UI
            %   component H for components that support this gesture.
            %   Examples of components that support the "press" gesture
            %   include uibutton, uicheckbox, uiradiobutton, and uiswitch.
            % 
            %   press(TESTCASE, H, LOCATION) specifies the location to
            %   press within the component H. For example, H can be a
            %   uiaxes and LOCATION a 1x2 or 1x3 axes coordinate.
            %
            %   For more information on supported UI components and syntaxes,
            %   see the reference page for matlab.uitest.TestCase/press.
            %
            %   Examples:
            %   
            %     testCase = matlab.uitest.TestCase.forInteractiveUse;
            %
            %     button = uibutton;
            %     testCase.press(button);
            %
            %     ax = uiaxes;
            %     testCase.press(ax, [0.2 0.4]);
            %
            % See also matlab.uitest.TestCase/choose.
            
            narginchk(2, Inf);
            testCase.Driver.press(H, varargin{:});
        end
        function choose(testCase, H, varargin)
            %CHOOSE Choose UI component or option in App
            %
            %   choose(TESTCASE, H, OPTION) chooses the option OPTION
            %   within the UI component H for components that support this
            %   gesture. Examples of components that support the "choose"
            %   gesture include uicheckbox, uiswitch, and uilistbox. The
            %   data type of OPTION depends on the type of component under
            %   test.  For example, if H is a uiswitch, OPTION is a text or
            %   numeric value. But if H is a uicheckbox, OPTION is a
            %   logical value.
            %
            %   For more information on supported UI components and syntaxes,
            %   see the reference page for matlab.uitest.TestCase/choose.
            %
            %   Examples:
            %
            %     testCase = matlab.uitest.TestCase.forInteractiveUse;
            %
            %     % Choose an item on a discrete knob
            %     knob = uiknob('discrete');
            %     % choose by "Item"
            %     testCase.choose(knob, 'Medium');
            %     % choose by Item index
            %     testCase.choose(knob, 1);
            %
            %     % Choose multiple items in a listbox
            %     listbox = uilistbox('Multiselect', 'on');
            %     testCase.choose(listbox, 1:3);
            %
            %     % Choose a tab within a tabgroup
            %     fig = uifigure;
            %     group = uitabgroup(fig);
            %     tab1 = uitab(group, 'Title', 'Tab #1');
            %     tab2 = uitab(group, 'Title', 'Tab #2');
            %     % The following are equivalent:
            %     testCase.choose(group, "Tab #2");
            %     testCase.choose(group, 2);
            %     testCase.choose(tab2);
            %
            % See also matlab.uitest.TestCase/press.
            
            narginchk(2, Inf);
            testCase.Driver.choose(H, varargin{:});
        end
        function drag(testCase, H, start, stop, varargin)
            %DRAG Drag UI component within App
            %
            %  drag(TESTCASE, H, START, STOP) performs a "drag" gesture on
            %  the UI component H from the specified START value to STOP.
            %  This interaction is supported for the uislider and
            %  continuous uiknob components.
            %
            %  Examples:
            %   
            %    testCase = matlab.uitest.TestCase.forInteractiveUse;
            %
            %    knob = uiknob;
            %    testCase.drag(knob, 10, 90);
            %
            %    slider = uislider;
            %    testCase.drag(slider, 80, 23);
            
            narginchk(4, Inf);
            testCase.Driver.drag(H, start, stop, varargin{:});
        end
        function type(testCase, H, text, varargin)
            %TYPE Types in UI component within App
            %
            %   type(TESTCASE, H, VALUE) types VALUE into the UI component H
            %   for components that support this gesture. Examples of
            %   components that support the "type" gesture include
            %   uieditfield, and uitextarea. VALUE specified
            %   depends on the component H under test. For example, a
            %   standard uieditfield uses a text-based value, while a
            %   numeric editfield uses a numeric value.
            %
            %   For more information on supported UI components and syntaxes,
            %   see the reference page for matlab.uitest.TestCase/type.
            %
            %   Examples:
            %   
            %     testCase = matlab.uitest.TestCase.forInteractiveUse;
            %
            %     % Type in an editfield
            %     editfield = uieditfield;
            %     testCase.type(editfield, 'Hello World!');
            %
            %     % Type in a numeric editfield
            %     numedit = uieditfield('numeric');
            %     testCase.type(numedit, 126.88);
            %
            %     % Type in an editable dropdown
            %     dropdown = uidropdown('Editable', 'on');
            %     testCase.type(dropdown, 'Custom Item');
            
            narginchk(3, Inf);
            testCase.Driver.type(H, text, varargin{:});
        end
        
    end
    
    methods (Static)
        function testCase = forInteractiveUse
            %FORINTERACTIVEUSE - Create a TestCase to use interactively
            %
            %   TESTCASE = matlab.uitest.TestCase.forInteractiveUse creates
            %   a TestCase instance for experimentation at the MATLAB
            %   command prompt. TESTCASE is a matlab.uitest.TestCase
            %   instance that reacts to qualification failures and
            %   successes by printing messages to standard output (the
            %   screen).
            %
            %   Examples:
            %
            %     % Configure a red-colored lamp to change to green when a button is pressed
            %     f = uifigure;
            %     lamp = uilamp(f, 'Position', [50 100 20 20], 'Color', 'red');
            %     button = uibutton(f, ...
            %         'ButtonPushedFcn', @(o,e)set(lamp, 'Color', 'green'));
            %
            %     % Create a TestCase for interactive use at the MATLAB Command Prompt
            %     testCase = matlab.uitest.TestCase.forInteractiveUse;
            %
            %     % Exercise - press the button to invoke its ButtonPushedFcn
            %     testCase.press(button);
            %
            %     % Produce a failing verification
            %     testCase.verifyEqual(lamp.Color, 'green');
            %
            %     % Produce a passing verification
            %     testCase.verifyEqual(lamp.Color, [0 1 0]);
            
            import matlab.uitest.InteractiveTestCase;
            testCase = InteractiveTestCase;
        end
    end
    
    methods (Access = private)
        function lockfig(testCase, fig)
            import matlab.uiautomation.internal.FigureHelper;
            
            if FigureHelper.isWebFigure(fig)
                testCase.Driver.lock(fig);
            end
        end
    end
    
end
