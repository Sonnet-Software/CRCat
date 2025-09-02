function theClean = CRFitClean(theCoef,theVerbose)
    % Clean = CRFitClean(Coef,Epsilon,Verbose) Extract all the zeros from the
    % polynomial coefficients Coef and set any positive real parts to zero.
    % This will take a long time if more than a few dozen coefficients. For
    % more than a half dozen coefficients, they should be extracted and
    % passed in vpa with sufficient digits for the size of the polynomial.
    % To check to see if there is any significant change, do a CREval
    % before and after and check the difference over your desired range of
    % frequencies. Pass the optional Verbose as anything but 0 and number
    % of positive real parts found will be displayed. jcr02mar2023

    if nargin >= 2 && ~strcmp("0",string(theVerbose)) 
        aVerbose = 1;
    else
        aVerbose = 0;
    end % if nargin

    aZeros = roots(theCoef);
    aPosRealRootIndices = find( real(aZeros)>0 );
    
    if aVerbose
        aNumPosRealParts = length( aPosRealRootIndices );
        fprintf('Number of zeros with positive real parts set to zero = %d.\n',aNumPosRealParts);
    end % if aVerbose

    aZeros( aPosRealRootIndices ) = 1i * imag( aZeros(aPosRealRootIndices) );

    % Convert back to a polynomial. Have to go this round-about route
    % because poly does not work with vpa at this time.
    theClean = charpoly( diag(aZeros) );
    theClean = real(theClean);

    % The result form charpoly normalizes the highest order coefficient,
    % i.e., the first one in the array, to one. Renormalize to same as was
    % passed in theCoef.
    aRenorm = theCoef(1) / theClean(1);
    theClean = aRenorm * theClean;

end % CRFitClean

    