function CRFitAutoTest()
    % CRFitAutoTest. Test CRFitAuto and CRFitInterp. jcr29Sep2025
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    % Full test run 11Oct2025jcr All passed.

    aErrorLim = 1e-5; % Ingore error less than this.
    aTestDataDir = 'CRCatTestData'; % All data files are in this directory.

    % Test 1 uses a previously saved custom catalog.
    aCatFileName = strcat(aTestDataDir,'/ACustomCatalogForTest.mat');
    if exist(aCatFileName, 'file') ~= 2
        error('Saved catalog not found: %s.\n', aCatFileName);
    end % if exist
    aCatStruct = load(aCatFileName);
    aCat = aCatStruct.theCat;
    fprintf('\nTest catalog loaded.\n\n');

    fprintf('Verbose mode turned on for all tests.\n')

    fprintf('\nTest 1: Fitting data from a simple component...')

    % Test 1, simple fit to data from a standard component.
    aComp = CRComp(1,aCat); % No fixed element values.
    aFreq = 1:40;
    aY = aComp.Eval(aFreq);
    [aAFit,aBFit,aReturnCode] = CRFitAuto(aY,aFreq,1);
    if aReturnCode == 1
        aYFit = CREval(aAFit,aBFit,aFreq);
        aFitError = rmse(aYFit,aY);
        if aFitError < aErrorLim
            fprintf('Test 1 passed with error = %d\n',aFitError)
        else
            fprintf('***Test 1 FAILED with error = %d\n',aFitError)
        end % if aFitError
    else
        fprintf('***Test 1 FAILED, unable to fit, CRFit return code = %d\n',aReturnCode)
    end % if aReturnCode


    % Test 2
    fprintf('\nTest 2: Fit a band-pass filter using data from the passband only.\n');
    aDataFileName = strcat(aTestDataDir,'/hairpin_InBand_Nf251.s2p');
    aData = SnP(aDataFileName);
    fprintf('Test 2 data loaded. Fitting data next...');
    % Fit S21.
    aS = aData.Pull('S21');
    [aAFitTest2,aBFitTest2,aReturnCode] = CRFitAuto(aS,aData.freq,1); % Verbose mode.
    if aReturnCode == 1
        aSFit = CREval(aAFitTest2,aBFitTest2,aData.freq);
        aFitError = rmse(aSFit,aS);
        if aFitError < aErrorLim
            fprintf('Test 2 passed with error = %d\n',aFitError)
        else
            fprintf('***Test 2 FAILED with error = %d\n',aFitError)
        end % if aFitError
    else
        fprintf('***Test 2 FAILED, unable to fit, CRFit return code = %d\n',aReturnCode)
    end % if aReturnCode


    fprintf('\nTest 3: Fit data from the band pass, extrapolate, and compare to the full EM result.\n');
    aDataFileName = strcat(aTestDataDir,'/hairpin_BroadBand_Nf991.s2p');
    aDataFull = SnP(aDataFileName);
    % Pull out the full, broadband S21 data.
    aSFull = aDataFull.Pull('S21');
    fprintf('Test 3 data loaded. Fitting S21 data from only the pass-band.');
    % Not using results from Test 2 because the EM analysis used a slightly
    % different meshing, and that gives slightly different pass-band results.
    % Limiting fit to just the pass band...
    [aAFit,aBFit,aReturnCode] = CRFitAuto(aSFull(376:421),aDataFull.freq(376:421),1); % Verbose mode.
    if aReturnCode ~= 1
        fprintf('***Test 3 FAILED band-pass fit, CRFit return code = %d\n',aReturnCode)
    else
        % Extrapolate above rational polynomial model to the full frequency list.
        aSExtrapolated = CREval(aAFit,aBFit,aDataFull.freq);
        % The aSFull data above 6 GHz is into the second order response, so no rmse above 6 GHz.
        aFitError = rmse(aSExtrapolated(1:592),aSFull(1:592));
        if aFitError < aErrorLim
            fprintf('Test 3 passed with error = %d\n',aFitError)
        else
            fprintf('***Test 3 FAILED with error = %d\n',aFitError)
        end % if aFitError
    end % if aReturnCode


    % Test 4 forms an SnP with a subset of aDataFull (same as in Test 3) of the
    % bandpass region to extrapolate to 0-6 GHz. Each of the four S-parameters are
    % extrapolated by CRInterp and checked for error against a 0-6 GHz subset of aSFull.
    aDataFileName = strcat(aTestDataDir,'/hairpin_BroadBand_Nf991.s2p');
    aDataFull = SnP(aDataFileName);
    aDataPassBand = aDataFull.Shorten(376:421);
    aData0to6 = aDataFull.Shorten(1:592);
    fprintf('\nTest 4 data loaded. Extrapolating full band from pass-band data for all four S-parameters.');
    aResultSnP = CRInterp(aDataPassBand,aData0to6.freq,1); % Verbose mode.

    % Check result error by comparing interpolated result with aData0to6
    fprintf('\n')
    for iRow=1:aResultSnP.nPort
        for iCol=1:aResultSnP.nPort
            aError1 = rmse( aResultSnP.mat(iRow,iCol,:), aData0to6.mat(iRow,iCol,:) );
            if aError1 < 1e-3 % Error limit is higher than aErrorLim because is for full band.
                fprintf('Test 4 S%d%d passed, full band error is %d.\n',iRow,iCol,aError1);
            else
                fprintf('***Test 4 S%d%d FAILED, full band error is %d.\n',iRow,iCol,aError1);
            end % if aError1
        end % for iCol
    end % for iRow

    fprintf('\nCRFitAutoTest complete.\n')

end % CRFitAutoTest