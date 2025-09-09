function CRCompTest()
    % Test CRComp, Complex Rational Component methods. jcr08Sep2025
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    % Full test run 08Sep2025jcr All passed.

    aErrorLim = 1e-5; % Ingore error less than this.

    % Load test CR Catalog.
    aTestDataDir = 'CRCatTestData'; % All data files in this directory.
    % Many tests use a previously saved custom catalog (aBigCat) to test
    % functions. This file is updated or loaded here. Takes a few minutes.
    aDataFileName = strcat(aTestDataDir,'/ACustomCatalogForTest.mat');
    if exist(aDataFileName, 'file') ~= 2
        fprintf('Saved catalog not found: %s.\n', aDataFileName);
        quit(1);
    end % if exist
    aCatStruct = load(aDataFileName);
    aCat = aCatStruct.theCat;
    fprintf('Test catalog loaded.\n');

    % Set test components.
    aCompBase = CRComp(1,aCat); % No fixed element values.
    aCompBaseCopy = aCompBase;
    aCompFixed1 = CRComp(2,aCat); % Same as aCBase except last element is fixed,
                                % i.e., it is left out of symV member array.

    % Get base data from aCompBase.
    aF = 1:20;
    aY = aCompBase.Eval( aF );

    % Fit aCompBaseCopy to aY to see if we can recover the original element values.
    aCompBaseCopy.Fit(aY,aF);
    aRSSError = rmse(aCompBase.valEL,aCompBaseCopy.valEL);
    if aRSSError > aErrorLim
        fprintf('Test 1 failed. RSS Error = %d\n',aRSSError);
    else
        fprintf('Test 1 passed.\n');
    end % if aRSSError

    % Fit aCompFixed1 to aY to see if we can recover the original data.
    % The last element is fixed, so we must supply the correct value in
    % advance.
    aCompFixed1.Fit( aY,aF,aCompBase.valEL(5) );
    aRSSError = rmse(aCompBase.valEL,aCompFixed1.valEL);
    if aRSSError > aErrorLim
        fprintf('Test 2 failed. RSS Error = %d\n',aRSSError);
    else
        fprintf('Test 2 passed.\n');
    end % if aRSSError

    fprintf('CRCompTest complete.\n')

end % CRCompTest