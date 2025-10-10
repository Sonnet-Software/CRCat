function [ theA,theB,theReturnCode ] = CRFitAuto( theY,theFreq,theVerbose,theMaxError )
% [ A,B,ReturnCode ] = CRFitAuto( Y,Freq,Verbose,MaxError )
% Take the complex data in Y and use CRFit to fit a rational polynomial.
% The required precision and the required polynomial size is automatically
% selected so as to yeild a good fit with RMS error of less than MaxError,
% or less than 1e-5 if MaxError not specified. Default is to run silently
% unless Verbose is passed as something other than 0. Setting Verbose to 1
% is recommended for large problems. jcr23Sep2025
% CRCat and associated software is licensed under the MIT open software
% license. See the file LICENSE.TXT in the main directory.

    if nargin < 2
        error('At least two arguments needed, %d passed.\n',nargin);
    end

    aNumFreq = numel(theFreq);
    if numel(theY) ~= aNumFreq
        error('The number of complex data, %d, does not equal the number of frequencies, %d.',numel(theY),aNumFreq);
    end % if numel

    if aNumFreq < 10
        error('The number of complex data, %d, must be at least 10 for an auto-fit.',aNumFreq);
    end % if numel

    if nargin <= 2
        aVerbose = 0;
    else
        aVerbose = theVerbose;
    end % if nargin

    if nargin <= 3
        aMaxError = 1e-5;
    else
        aMaxError = theMaxError;
        if aMaxError < 1e-10 || aMaxError > 1e-1
            warning('Max error must be between 1e-10 and 1e-1, not %d. Setting MaxError to 1e-5.',aMaxError)
            aMaxError = 1e-5;
        end % if aMaxError
    end % if nargin
    
    aError1 = 2*aMaxError; % Get loop started.
    aNumTries = 0;
    aNumTryLimit = 10; % Quit if more tries required to fit the data.
    aNumTermsMax = floor(0.5*aNumFreq);
    while ( aError1 > aMaxError && aNumTries < aNumTryLimit)
        % If first time through, take a guess at how many terms and how
        % many digits precision based on number of zero crossings of
        % the imaginary part of the data. There are probably better guesses than these.
        if aNumTries == 0
            % To reduce effect of noise, split theY into rows of a matrix and sum each row.
            aBinSize = 10;
            if aNumFreq < 10*aBinSize
                aBinSize = round(0.1 * aNumFreq);
            end % if numel
            aSize = aNumFreq - mod(aNumFreq,aBinSize);
            aYSummed = sum( imag(reshape(theY(1:aSize),aBinSize,[],1 ) ) );
            aYDiffed = diff(aYSummed); % Estimates slope of data.
            aYNumSignChanges = sum( abs( diff( aYDiffed > 0 ) ) );
            aNumDigits = 32 + 5 * aYNumSignChanges;
            aNumTerms = round(0.3*aNumDigits); % # terms in numerator, and also in the denominator.
        elseif aError2 > aMaxError % Need more precision.
            aNumDigits = round( 1.3 * aNumDigits );
        else % Need more polynomial terms;
            aNumTerms = round( 1.3 * aNumTerms );
        end % if aNumDigits

        if aNumTerms > aNumTermsMax % Not enough frequenies to solve for required number of polynomial terms.
            aNumTerms = aNumTermsMax; % Maximum number of terms given the number of frequencies.
            aNumTries = aNumTryLimit-1; % Allow one more try.
        end % if numel
        digits(aNumDigits); % Set numerical precision.

        if aVerbose
            fprintf('\n   Using %d digits precsion and %d polynomial terms.\n',aNumDigits,2*aNumTerms);
            fprintf('       Fit 1 starting...')
        end % if aVerbose

        % Fit a rational polynomial to the data.
        [ aA1,aB1,aReturnCode1 ] = CRFit( theY,theFreq,ones(1,aNumTerms),ones(1,aNumTerms) );
        if aReturnCode1 == 1 % Evaluate at the fitted frequencies and see what the error is.
            aFit1 = double( CREval(aA1,aB1,theFreq) );
            aError1 = rmse(theY,aFit1); % See if the CRFit result gives us pretty much the original data.
            if aVerbose
                fprintf('Complete, RMS error = %d.\n',aError1)
            end % if aVerbose
        else
            aNumTerms = round( 1.3 * aNumTerms ); % Try again with more polynomial terms...
            aError2 = 2*aMaxError; % and force more precision.
            if aVerbose
                fprintf('Fit failed, Return Code = %d.\n',aReturnCode1)
            end % if aVerbose
        end % if aReturnCode1

        % If needed, do a second fit to see if more precision needed.
        if aReturnCode1 == 1 && aError1 > aMaxError
            if aVerbose
                fprintf('       Fit 2 starting...')
            end % if aVerbose
            [ aA2,aB2,aReturnCode2 ] = CRFit( aFit1,theFreq,ones(1,aNumTerms),ones(1,aNumTerms) );
            if aReturnCode2 == 1
                aFit2 = double( CREval(aA2,aB2,theFreq) );
                aError2 = rmse(aFit1,aFit2); % If enough precision, aFit2 should be the same as aFit1.
                if aVerbose
                    fprintf('Complete, RMS error = %d.\n',aError2)
                end % if aVerbose
            else
                aError2 = 2*aMaxError; % Force more precision.
                if aVerbose
                    fprintf('Fit failed, Return Code = %d.\n',aReturnCode2)
                end % if aVerbose
            end % if aReturnCode2
        end % if aReturnCode1
        aNumTries = aNumTries + 1;
    end % while

    digits(32); % Return to default value.

    if aReturnCode1 == 1 && aError1 < aMaxError
        theA = aA1;
        theB = aB1;
    else
        theA = [];
        theB = [];
        if aNumTerms >= aNumTermsMax
            aReturnCode1 = -2;
            warning('Not enough data for required number of terms.')
        end % if aaNumTerms
    end % aReturnCode1
    theReturnCode = aReturnCode1;
    
end % CRFitAuto