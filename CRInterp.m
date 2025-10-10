function [ theFinish ] = CRInterp( theStart,theNewFreqs,theVerbose,theMaxError )
% [ Finish ] = CRInterp( Start,NewFreqs,Verbose,MaxError )
% Take the S/Y/Z parameters in the SnP structure Start and fit a rational
% polynomial to each S/Y/Z-parameter using CRFitAuto, which automatically
% selects the numerical precision and number of polynomial terms needed
% for an accurate answer. This routine then evaluates the resulting
% rational polynomial at the NewFreqs and returns in the Finish SnP
% structure. There can be any number of NewFreqs. This routine can even
% be used for a limited degree of extrapolation.
% Run silently if Verbose is not present or is set to zero.
% Setting Verbose to 1 is recommended for large problems. If maxError
% not present, max interpolation error defaults to 1e-5. There must
% be data at enough frequencies to allow fitting of a rational polynomial
% with a sufficient number of terms. Interpolated result is guarenteed
% perfectly causal. jcr23Sep2025
% CRCat and associated software is licensed under the MIT open software
% license. See the file LICENSE.TXT in the main directory.

    if nargin < 2
        warning('At least two arguments needed, %d passed.\n',nargin);
        theFinish = [];
        return;
    end

    if nargin <= 2
        aVerbose = 0;
    else
        aVerbose = theVerbose;
        fprintf('\n')
    end % if nargin

    if nargin <= 3
        aMaxError = 1e-5;
    else
        aMaxError = theMaxError;
    end % if nargin

    aYResult = zeros( theStart.nPort,theStart.nPort,numel(theNewFreqs) );
    for iRow = 1:theStart.nPort
        for iCol = 1:theStart.nPort
            if aVerbose
                fprintf('\nInterpolating the (%d,%d) element.',iRow,iCol)
            end % if aVerbose
            % CRFit checks dimensions. Following required to make sure
            % aYFit and theStart.freq are same dimensions.
            aYFit(1,:) = theStart.mat(iRow,iCol,:);
            % Fit a rational polynomial to the data.
            [ aA,aB,aReturnCode ] = CRFitAuto( aYFit,theStart.freq,aVerbose,aMaxError );
            if aReturnCode == 1 % Do interpolation.
                aYResult(iRow,iCol,:) = double( CREval(aA,aB,theNewFreqs) );
            else 
                error('CRFitAuto returned error code %d for parameter (%d,%d).',aReturnCode,iRow,iCol);
            end % if aReturnCode
        end % for iCol
    end % for iRow

    digits(32); % Return to default value.

    % Open and init the result structure and fill with the interpolated data.
    theFinish = theStart.Copy;
    theFinish.Fill(aYResult,theNewFreqs);
    
end % CRInterp