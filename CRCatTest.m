
function CRCatTest(theOptionStr)
    % Test complex rational function classdef
    % CRCatTest('update') % refreshes the 'correct answer' files for all tests.
    % Called with no options, runs tests. jcr15mar2017
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    % All data files updated and all tests passed. jcr04jul2025

    aTestDataDir = 'CRCatTestData'; % All data files in this directory.

    % Many tests use a previously saved base catalog (aBigCat) to test
    % functions. This file is updated or loaded here. Takes a few minutes.
    aDataFileName = strcat(aTestDataDir,'/BigCat.mat');
    aUpDate = ( nargin == 1 && strcmp(theOptionStr,'update') );
    if ~aUpDate && exist(aDataFileName, 'file') ~= 2
        fprintf('BigCat file not found: %s. Recreating it.\n', aDataFileName);
        aUpDate = true;
    end % if ~aUpDate

    if aUpDate 
        fprintf('BigCat Data file being updated.\n');
        aBigCat = CRCat('base');
        save(aDataFileName,'aBigCat'); % Saving updated BigCat catalog.
        fprintf('BigCat Data File updated.\n');
    else
        fprintf('BigCat Data file being loaded, takes a while ... ');
        aBigCatStruct = load(aDataFileName);
        aBigCat = aBigCatStruct.aBigCat;
        fprintf('BigCat Data File loaded.\n');
    end % if aUpDate


    % Make sure Units gives same result.
    aTestName = 'Test 01: ';
    aCompFileName = strcat(aTestDataDir,'/unitsTest.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aCat = CRCat('empty');
        aCat.Units('hz');
        aCat2 = CRCat('empty');
        aCat2.Units('KHZ');
        aCat3 = CRCat('empty');
        aCat3.Units('mhz');
        aCat4 = CRCat('empty');
        aCat5 = CRCat('empty');
        aCat5.Units('ThZ');
        save(aCompFileName,'aCat','aCat2','aCat3','aCat4','aCat5');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aCat = CRCat('empty');
        aCat.Units('hz');
        aCat2 = CRCat('empty');
        aCat2.Units('KHZ');
        aCat3 = CRCat('empty');
        aCat3.Units('mhz');
        aCat4 = CRCat('empty'); % Units should be GHz.
        aCat5 = CRCat('empty');
        aCat5.Units('ThZ');
        aMatFile = load(aCompFileName);
        if ~isequal( aMatFile.aCat,aCat )
            fprintf('%sFAILED, Hz.\n',aTestName);
        elseif ~isequal( aMatFile.aCat2,aCat2 )
            fprintf('%sFAILED, kHz.\n',aTestName);
        elseif ~isequal( aMatFile.aCat3,aCat3 )
            fprintf('%sFAILED, MHz.\n',aTestName);
        elseif ~isequal( aMatFile.aCat4,aCat4 )
            fprintf('%sFAILED, GHz.\n',aTestName);
        elseif ~isequal( aMatFile.aCat5,aCat5 )
            fprintf('%sFAILED, THz.\n',aTestName);
        else
            fprintf('%sOK   \n',aTestName);
        end
    end % if aUpDate, Test 01


    % Make sure Id2Name gives same result.
    aTestName = 'Test 02: ';
    aCompFileName = strcat(aTestDataDir,'/names.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aCompNames = aBigCat.Id2Name(1:length(aBigCat.list));
        save(aCompFileName,'aCompNames');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aId = 1:length(aBigCat.list);
        aNames = aBigCat.Id2Name(aId);
        aMatFile = load(aCompFileName);
        aCompNames = aMatFile.aCompNames;
        if isequal( aNames,aCompNames )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED. Id''s of different comp names:\n',aTestName);
            for index = 1:length(aBigCat.list)
                if ~isequal( aNames(index),aCompNames{1}(index) )
                    fprintf( '%d ',index );
                end % if ~isequal
            end % for index
            fprintf('\n');
        end
    end % if aUpDate, Test 02


    % Make sure Name2Id gives same result.
    aTestName = 'Test 03: ';
    aCompFileName = strcat(aTestDataDir,'/names.mat');
    if ~aUpDate % names file was updated in previous test.
        fprintf('%sRunning ... ',aTestName);
        aId = 1:length(aBigCat.list);
        aMatFile = load(aCompFileName);
        aCompNames = aMatFile.aCompNames;
        aCompId = aBigCat.Name2Id( aCompNames );
        if isequal( aId,aCompId )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
            for index = 1:length(aBigCat.list)
                if ~isequal( aId(index),aCompId(index) )
                    fprintf( '%d ',index );
                end % if ~isequal
            end % for index
        end
    end % if aUpDate, Test 03


    % Make sure UniqueSigs gives same result.
    aTestName = 'Test 04: ';
    aCompFileName = strcat(aTestDataDir,'/uniqueSigsList.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aCompSigs = aBigCat.UniqueSigs;
        save(aCompFileName,'aCompSigs');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTestSigs = aBigCat.UniqueSigs;
        aMatFile = load(aCompFileName);
        aCompSigs = aMatFile.aCompSigs;
        if isequal( aTestSigs,aCompSigs )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
            for index = 1:length(aBigCat.list)
                if ~isequal( aTestSigs(index),aCompSigs(index) )
                    fprintf( '%d ',index )
                end % if ~isequal
                fprintf('\n')
            end % for index
        end
    end % if aUpDate, Test 04


    % Make sure NumRLC gives same result for a few select components.
    aTestName = 'Test 05: ';
    aCompFileName = strcat(aTestDataDir,'/numRLC.mat');
    aId = 1:2:20; % To test NumRLC returning subset of entire list.
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.NumRLC(aId);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.NumRLC(aId);
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aTest,aComp )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
            for index = 1:length(aTest)
                if ~isequal( aTest(index),aComp(index) )
                    fprintf( '%d ',aId(index) )
                end % if ~isequal
                fprintf('\n')
            end % for index
        end
    end % if aUpDate, Test 05


    % Make sure NumRLC gives same result for all components.
    aTestName = 'Test 06: ';
    aCompFileName = strcat(aTestDataDir,'/numRLC2.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.NumRLC;
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.NumRLC;
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aTest,aComp )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
            for index = 1:length(aTest)
                if ~isequal( aTest(index),aComp(index) )
                    fprintf( '%d ',index )
                end % if ~isequal
                fprintf('\n')
            end % for index
        end
    end % if aUpDate, Test 06


    % Make sure CheckId returns with no error message given valid ids.
    aTestName = 'Test 07: ';
    if ~aUpDate % Only needs bigCat data file, which is updated elsewhere.
        fprintf('%sRunning ... ',aTestName);
        aBigCat.CheckId( 1:length(aBigCat.list),1 ); % Routine terminates with error message if there is a bad id.
        fprintf('%sOK   \n',aTestName);
    end % if aUpDate, Test 07


    % Make sure SameSymConv gives same result.
    aTestName = 'Test 08: ';
    aCompFileName = strcat(aTestDataDir,'/sameSymConvTest.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.SameSymConv(100,39);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.SameSymConv(100,39); % 100 == XII-8, 39 == VII-4
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aTest,aComp )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 08


    % Make sure ELSens gives same result.
    aTestName = 'Test 09: ';
    aCompFileName = strcat(aTestDataDir,'/ELSensTest.mat');
    aTestEL = [1 .02 3 0.04];
    aTestFreq = [1.0 2.0]; % Element sensitivity will be averaged over these two frequencies.
    if aUpDate
        fprintf('%sData File being updated ... ',aTestName);
        aComp = aBigCat.ELSens(100,aTestEL,aTestFreq);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.ELSens(100,aTestEL,aTestFreq); % 100 == XII-8
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if max(max(abs(aComp-aTest))) < max(max(aComp)) * 1.0e-10
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 09


    % Make sure FindSensEL gives same result.
    aTestName = 'Test 10: ';
    aCompFileName = strcat(aTestDataDir,'/findSensELTest.mat');
    aTestEL = [2 .04 1 0.01];
    aTestFreq = [1.0 2.0]; % Element sensitivity will be averaged over these two frequencies.
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.FindSensEL(100,aTestEL,aTestFreq);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.FindSensEL(100,aTestEL,aTestFreq); % 100 == XII-8
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if max(max(abs(aComp-aTest))) < max(max(aComp)) * 1.0e-10
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 10

    
    % Make sure SetBestTestEL gives same result.
    aTestName = 'Test 11: ';
    aCompFileName = strcat(aTestDataDir,'/setBestTestELTest.mat');
    aTestFreq = 0.01; % The frequency used to originally set was 1.0. In order to test, we need a diff freq to get a diff testEL result.
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aBigCat.SetBestTestEL(100,aTestFreq);
        aComp = aBigCat.list(100).testEL;
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aBigCat.SetBestTestEL(100,aTestFreq);
        aTest = aBigCat.list(100).testEL;
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if max(max(abs(aComp-aTest))) < max(max(aComp)) * 1.0e-10
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%s FAILED.\n',aTestName);
        end
    end % if aUpDate, Test 11

    
    % Make sure FlagCensus gives same result.
    aTestName = 'Test 12: ';
    aCompFileName = strcat(aTestDataDir,'/flagCensusTest.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.FlagCensus;
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.FlagCensus;
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aComp,aTest )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 12

    
    % Make sure Sig2Flags gives same result.
    aTestName = 'Test 13: ';
    aCompFileName = strcat(aTestDataDir,'/sig2Flags.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aCat = CRCat('empty');
        [ aFlag1,aFlag2 ] = aCat.Sig2Flags( '110-111' );
        aComp = [ aFlag1 aFlag2 ];
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aCat = CRCat('empty');
        [ aFlag1,aFlag2 ] = aCat.Sig2Flags( '110-111' );
        aTest = [ aFlag1 aFlag2 ];
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aComp,aTest )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 13
 
    
    % Make sure char gives same result.
    aTestName = 'Test 14: ';
    aCompFileName = strcat(aTestDataDir,'/charTest.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = char(aBigCat);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = char(aBigCat);
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aComp,aTest )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 14
    
    
    % Make sure Transformation gives same result.
    aTestName = 'Test 15: ';
    aCompFileName = strcat(aTestDataDir,'/transformationTest.mat');
    if aUpDate
        fprintf('%sData file being updated ... ',aTestName);
        aComp = aBigCat.Transformation(100,39);
        save(aCompFileName,'aComp');
        fprintf('%sFile updated.\n',aTestName);
    else
        fprintf('%sRunning ... ',aTestName);
        aTest = aBigCat.Transformation(100,39);
        aMatFile = load(aCompFileName);
        aComp = aMatFile.aComp;
        if isequal( aComp,aTest )
            fprintf('%sOK   \n',aTestName);
        else
            fprintf('%sFAILED.\n',aTestName);
        end
    end % if aUpDate, Test 15

    
    fprintf('CRCatTest finished.\n');
    
    
end
    

