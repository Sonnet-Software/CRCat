function CRFitTest()
    % Test complex rational function fitting routines jcr16feb2015,20feb2015
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    % Full test run 04Jul2025jcr All passed.

    clear; % Make sure no other set variables coming into this.
    aErrorLim = 1e-5; % Ingore error less than this.
    
    % **********************************************************
    aName = 'Test  1: '; % Simple, 2 terms in both numerator and denominator.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [2 1]; % Numerator coef.
    aAGood = aA;
    aB = [5 1]; % Denominator coef.
    aBGood = aB;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  2: '; % Lots of terms in denominator. Norms to highest denom term.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [5 600]; % Numerator coef.
    aAGood = 1e3*aA;
    aB = [1e-3 1e-2 1e-1 1 10 100 1]; % Denominator coef.
    aBGood = 1e3*aB;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  3: '; % Leading term in numerator is set to zero, must be removed in solution.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [0 2 1]; % Numerator coef.
    aAGood = [2 1];
    aB = [5 1]; % Denominator coef.
    aBGood = aB;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  4: '; % Leading term in denominator is set to zero, must be removed in solution.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [5 2 1]; % Numerator coef.
    aAGood = aA;
    aB = [0 1]; % Denominator coef.
    aBGood = 1;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  5: '; % Result normalized to DC term in denominator.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [5 10 15]; % Numerator coef.
    aAGood = [0.25 0.5 0.75];
    aB = [20 5]; % Denominator coef.
    aBGood = [1 0.25];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    fprintf('\n');

    % **********************************************************
    aName = 'Test  6: '; % Lots of terms in denominator.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [3 2 50]; % Numerator coef.
    aAGood = [0.6 0.4 10];
    aB = [5 4 3 2 1]; % Denominator coef.
    aBGood = [1 0.8 0.6 0.4 0.2];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  7: '; % Almost perfectly singular matrix, but successfully norms to linear term in denom.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [3 2 1]; % Numerator coef.
    aAGood = 0.5*aA;
    aB = [5 4 3 2 1]; % Denominator coef.
    aBGood = 0.5*aB;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  8: '; % DC term in both numerator and denominator zero, must be removed in result.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [6 4 0]; % Numerator coef.
    aAGood = [0.3 0.2];
    aB = [20 2 0]; % Denominator coef.
    aBGood = [1 0.1];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test  9: '; % DC denominator term very tiny, so result normalized to linear term. cond warmings OK.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [15 10 5]; % Numerator coef.
    aAGood = [3 2 1];
    aB = [5 1e-10]; % Denominator coef.
    aBGood = [1 0];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 10: '; % Numerator is one DC term.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = 1; % Numerator coef.
    aAGood = 1;
    aB = [5 1]; % Denominator coef.
    aBGood = aB;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    fprintf('\n');

    % **********************************************************
    aName = 'Test 11: '; % One term (DC) in denominator.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [6 4 2]; % Numerator coef.
    aAGood = [3 2 1];
    aB = 2; % Denominator coef.
    aBGood = 1;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 12: '; % No terms in numerator. NULL return and error code.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = []; % Numerator coef.
    aAGood = [];
    aB = [3 2 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -2; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 13: '; % No terms in denominator. NULL return and error code.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = []; % Numerator coef.
    aAGood = [];
    aB = [3 2 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -2; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 14: '; % No terms in numerator and denominator. NULL return and error code.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = []; % Numerator coef.
    aAGood = [];
    aB = []; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 15: '; % One term in numerator and denominator.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = 6; % Numerator coef.
    aAGood = 3;
    aB = 2; % Denominator coef.
    aBGood = 1;
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    fprintf('\n');

    % **********************************************************
    aName = 'Test 16: '; % Not enough freqs. NULL return and error code.
    aF = linspace( 1,20,5 ); % Generate freq list: start, stop, # of points.
    aA = [1 2 3 4 50]; % Numerator coef.
    aAGood = [];
    aB = [3 2 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -2; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 17: '; % Lots of terms in numerator, lots of freqs.
    aF = linspace( 1,20,201 ); % Generate freq list: start, stop, # of points.
    aA = [1 2 10 4 50]; % Numerator coef.
    aAGood = [0.5 1 5 2 25];
    aB = [1 2 3]; % Denominator coef.
    aBGood = [0.5 1 1.5];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 18: '; % Numerator and denominator are the same. NULL result. Warnings from cond.
    aF = linspace( 1,20,201 ); % Generate freq list: start, stop, # of points.
    aA = [1 2 3]; % Numerator coef.
    aAGood = [];
    aB = [1 2 3]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -3; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 19: '; % Testing A and B Flags with float instead of logical.
    aF = linspace( 1,20,201 ); % Generate freq list: start, stop, # of points.
    aA = [1 0 3]; % Numerator coef.
    aAGood = [1/3 0 1];
    aB = [3 0 1]; % Denominator coef.
    aBGood = [1 0 1/3];
    aAFlag = [1.0 0.0 3.0];  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = [-3.0 0.000001 -5.1];
    aFlagGood = 1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 20: '; % aW and aZ not the same size.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [2 1]; % Numerator coef.
    aAGood = [];
    aB = [5 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF(1:end-1),aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);
    
    fprintf('\n');

    % **********************************************************
    aName = 'Test 21: '; % aW and aZ not the same size.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [2 1]; % Numerator coef.
    aAGood = [];
    aB = [5 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    TestBody(aName,aF,aZ(1:end-1),aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 22: '; % aW and aZ not the same size.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [2 1]; % Numerator coef.
    aAGood = [];
    aB = [5 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -1; % Expected error flag return.
    aZ = CREval(aA,aB,aF); % Calculate impedance to be fit.
    aF = ones(2,length(aZ));
    TestBody(aName,aF(1:end-1),aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);

    % **********************************************************
    aName = 'Test 23: '; % aW and aZ not the same size.
    aF = linspace( 1,20,21 ); % Generate freq list: start, stop, # of points.
    aA = [2 1]; % Numerator coef.
    aAGood = [];
    aB = [5 1]; % Denominator coef.
    aBGood = [];
    aAFlag = (aA~=0);  % If a coef of the aZ poly, above, is zero, do not solve for it.
    aBFlag = (aB~=0);
    aFlagGood = -1; % Expected error flag return.
    % aZ = CREval(aA,aB,aW); % Calculate impedance to be fit.
    aZ = ones(2,length(aF));
    TestBody(aName,aF(1:end-1),aZ,aAGood,aBGood,aAFlag,aBFlag,aFlagGood,aErrorLim);
    
    fprintf('\n');

end




%********************************************
%********************************************
function TestBody(theName,theF,theZ,theAGood,theBGood,theAFlag,theBFlag,theFlagGood,theErrorLim)
% Pass parameters to test CRFit. jcr20feb2015
    [aA2,aB2,aFlag] = CRFit(theZ,theF,theAFlag,theBFlag);
    if isempty(theAGood) && isempty(aA2) && isempty(theBGood) && isempty(aB2)
        aError = 0;
    elseif length(theAGood) == length(aA2) && length(theBGood) == length(aB2)
        aError = norm( theAGood - aA2 ) + norm( theBGood - aB2 );
    else
        aError = inf;
    end
    if ( aError < theErrorLim && aFlag == theFlagGood )
        fprintf('%sOK   ',theName);
    else
        fprintf('\n\n%s FAILED, Error = %f, Error Flag = %d.\n\n',theName,aError,aFlag);
    end
end

