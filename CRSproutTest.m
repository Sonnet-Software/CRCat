 function CRSproutTest( theCat )
    % CRSproutTest(Cat): Test CRSprout. If theCat is not passed, will load
    % the base catalog (which can take a while). jcr12Mar2022
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    % Full test run jcr04Jul2025 All passed.
    
    
    %***********************************************
    fprintf('CRSprout Test starting.\n');
    if nargin < 1
        fprintf('Loading base CRCat. This could take a while.\n\n');
        theCat = CRCat('base');
    end % if nargin
    
    
    %***********************************************
    aTestName = 'CRSprout Test 01: '; % Test empty Sprout, no OriginalY.
    fprintf('%sRunning ... ',aTestName);
    aFreq = 1:10;
    aSprout(10) = CRComp; % Allocates 10 empty components.
    aCorrectY = zeros(1,length(aFreq));
    aY = CRSprout(aFreq,aSprout);
    if isequal( aY,aCorrectY )
        fprintf('%sOK\n',aTestName);
    else
        fprintf('%s FAILED.\n',aTestName);
    end % CRSprout Test 01
    
    
    %***********************************************
    aTestName = 'CRSprout Test 02: '; % Test empty Sprout, with OriginalY.
    fprintf('%sRunning ... ',aTestName);
    aFreq = 1:10;
    aSprout(10) = CRComp; % Allocates 10 empty components.
    aOriginalY = 11:20;
    aY = CRSprout(aFreq,aSprout,aOriginalY); % Should come back with aOriginalY unchanged.
    if isequal( aY,aOriginalY )
        fprintf('%sOK\n',aTestName);
    else
        fprintf('%s FAILED.\n',aTestName);
    end % CRSprout Test 02
    
    
    %***********************************************
    aTestName = 'CRSprout Test 03: '; % Test Sprout set to build XXIII-9.
    fprintf('%sRunning ... ',aTestName);
    aFreq = 1:10;
    % [        La,       Rb,       Lb,       Lc,       Cc ]
    aValEL = [ 1.0000    2.0000    0.3000    4.0000    0.0500 ];
    aName = 'XXIII-9'; % To see a schematic of this component: theCat.Draw(aName)
    aCompBase = CRComp( aName,theCat );
    aCompBase.SetEL( aValEL );
    aCorrectY = aCompBase.Eval( aFreq );
    
    % Set Sprout so it builds up an XXIII-9 from individual components.
    clear aSprout; % Clear out any previous data.

    % inductor La connected in parallel with entire rest of circuit, below.
    aSprout(4) = CRComp('L',theCat);
    aSprout(4).SetEL( aValEL( 1 ) );
    
    % parallel Lc Cc connected in series with parallel RL, below.
    aSprout(3) = CRComp('ParLC',theCat);
    aSprout(3).SetEL( aValEL( 4:5 ) );
    
    % resistor Rb conected in parallel with Lb, below.
    aSprout(2) = CRComp('R',theCat);
    aSprout(2).SetEL( aValEL( 2 ) );
    
    % inductor Lb;
    aSprout(1) = CRComp('L',theCat);
    aSprout(1).SetEL( aValEL( 3 ) );
    
    aY = CRSprout(aFreq,aSprout);
    aError = max( abs( aY - aCorrectY ) );
    if aError < 1e-10 && isequal( char( aCompBase.symVn ), '[La, Rb, Lb, Lc, Cc]' )
        fprintf('%sOK\n',aTestName);
    else
        fprintf('%s FAILED.\n',aTestName);
    end % CRSprout Test 03
    
    
    %***********************************************
    aTestName = 'CRSprout Test 04: '; % Test Sprout set to build XXIII-9 with some empty components inserted.
    fprintf('%sRunning ... ',aTestName);
    aFreq = 1:10;
    % [        La,       Rb,       Lb,       Lc,       Cc ]
    aValEL = [ 1.0000    2.0000    0.3000    4.0000    0.0500 ];
    aName = 'XXIII-9'; % To see a schematic of this component: theCat.Draw(aName)
    aCompBase = CRComp( aName,theCat );
    aCompBase.SetEL( aValEL );
    aCorrectY = aCompBase.Eval( aFreq );
    
    % Set Sprout so it builds up an XXIII-9 from individual components.
    clear aSprout; % Clear out any previous data.

    % inductor La connected in parallel with entire rest of circuit, below.
    aSprout(10) = CRComp('L',theCat);
    aSprout(10).SetEL( aValEL( 1 ) );
    
    % parallel Lc Cc connected in series with parallel RL, below.
    aSprout(9) = CRComp('ParLC',theCat);
    aSprout(9).SetEL( aValEL( 4:5 ) );
    
    % resistor Rb conected in parallel with Lb, below.
    aSprout(6) = CRComp('R',theCat);
    aSprout(6).SetEL( aValEL( 2 ) );
    
    % inductor Lb;
    aSprout(3) = CRComp('L',theCat);
    aSprout(3).SetEL( aValEL( 3 ) );
    
    aY = CRSprout(aFreq,aSprout);
    aError = max( abs( aY - aCorrectY ) );
    if aError < 1e-10 && isequal( char( aCompBase.symVn ), '[La, Rb, Lb, Lc, Cc]' )
        fprintf('%sOK\n',aTestName);
    else
        fprintf('%s FAILED.\n',aTestName);
    end % CRSprout Test 04
    
    
    %***********************************************
    aTestName = 'CRSprout Test 05: '; % Test Sprout being extracted from XXIII-9 as aOriginalY, piece by piece.
    fprintf('%sRunning ... ',aTestName);
    aFreq = 1:10;
    % [        La,       Rb,       Lb,       Lc,       Cc ]
    aValEL = [ 1.0000    2.0000    0.3000    4.0000    0.0500 ];
    aName = 'XXIII-9'; % To see a schematic of this component: theCat.Draw(aName)
    aCompBase = CRComp( aName,theCat );
    aCompBase.SetEL( aValEL );
    aOriginalY = aCompBase.Eval( aFreq );

    % Set Sprout so it sets up an XXIII-9 piece by piece.
    clear aSprout; % Clear out any previous data.

    % inductor La connected in parallel with entire rest of circuit, below.
    aSprout(4) = CRComp('L',theCat);
    aSprout(4).SetEL( aValEL( 1 ) );

    % parallel Lc Cc connected in series with parallel RL, below.
    aSprout(3) = CRComp('ParLC',theCat);
    aSprout(3).SetEL( aValEL( 4:5 ) );

    % resistor Rb conected in parallel with Lb, below.
    aSprout(2) = CRComp('R',theCat);
    aSprout(2).SetEL( aValEL( 2 ) );

    % inductor Lb;
    aSprout(1) = CRComp('L',theCat);
    aSprout(1).SetEL( aValEL( 3 ) );

    aSproutY = CRSprout(aFreq,aSprout);
    aError1 = rmse( aSproutY,aOriginalY );

    aModifiedY = CRSprout(aFreq,aSprout,aOriginalY);
    aError2 = max( abs( aModifiedY ) );
    if aError1 < 1e-10 && aError2 < 1e-10 && isequal( char( aCompBase.symVn ), '[La, Rb, Lb, Lc, Cc]' )
        fprintf('%sOK\n',aTestName);
    else
        fprintf('%s FAILED.\n\n',aTestName);
    end % CRSprout Test 05

    
    
    
   
    
    
    
    
    
    
end % CRSproutTest