function [ theA,theB,theReturnCode ] = CRFit( theY,theFreq,theFlagA,theFlagB )
% [ A,B,ReturnCode ] = CRFit( Y,Freq,FlagA,FlagB )
% Y and Freq converted, below, to vpa (Variable Precision Arithmetic).
% A amd B returned in vpa too. To change precision, use digits(). jcr08mar2017
% Given admitance, Y, at frequencies Freq in units consistent with the desired
% units for element values. Can be pure real or pure imaginary. CRFit returns numerator and
% denominator coefficients for the complex Pade rational polynomial that is
% the least squares fit to Y over the Freq list. All coefficients are
% real and the rational polybnomial is a function of j*Freq:
%
% Yfit = ( An + A(n-1)*(jw) + A(n-2)*(jw)^2 + ... + A1*(jw)^(N-1) ) /
%        ( Bm + B(m-1)*(jw) + B(m-2)*(jw)^2 + ... + B1*(jw)^(M-1) )
%
% The Coefficients are ordered for use in the MATLAB polyval function.
% FlagA and FlagB are set to zero for coefficients that are not to be
% included in the fitted polynomial. The length of FlagA determines
% the max number of terms in the numerator, and the FlagB length determines
% the max number of terms in the denominator. If A and B are returned NULL, no
% fit was possible (singluar matrix inversion or not enough Freqs or not enough
% CR coef). For normalization, one B coef will be set to 1.
% ReturnCode = 1 if all OK, = -1 if FreqList is not a row vector the same length as Y
% (which probably means Freq and Y do not go together), = -2 if not enough
% frequencies (Freq) to fit the desired number of coefficients, and = -3 or -4 if
% the matrix solve is singular. jcr18Feb2015
% CRCat and associated software is licensed under the MIT open software
% license. See the file LICENSE.TXT in the main directory.

    if any(size(theFreq) ~= size(theY)) || ~isrow(theY)
        theA = [];
        theB = [];
        theReturnCode = -1;
        return; % Probably called in error with Freq data that does not match the Y data.
    end
    aFmax = length(theY);

    % Make sure A and B flags are logical variables.
    aFlagA = ( (theFlagA>0.0001) | (theFlagA<-0.0001) );
    aFlagB = ( (theFlagB>0.0001) | (theFlagB<-0.0001) );

    % Remove leading zeros from the flags (i.e., high order poly terms are zero).
    aIndex = find( aFlagA,1 );
    if ~isempty( aIndex )
        aTmp = aFlagA;
        aFlagA = aTmp( aIndex:end );
    else
        aFlagA = [];
    end
    
    aIndex = find( aFlagB,1 );
    if ~isempty( aIndex )
        aTmp = aFlagB;
        aFlagB = aTmp( aIndex:end );
    else
        aFlagB = [];
    end
    
    % Remove trailing zeros from the flags (i.e., DC terms are zero).
    % Do this only if both numerator and denominator DC terms are specified to be zero.
    while ~isempty(aFlagA) && ~isempty(aFlagB) && aFlagA(end) == 0 && aFlagB(end) == 0
        aFlagA = aFlagA( 1:end-1 );
        aFlagB = aFlagB( 1:end-1 );
    end

    aABFlag = [ aFlagA aFlagB ];  % The two flag logical vectors concatonated.
    aNmax = length( aFlagA );     % Number of terms in the numerator.
    aMmax = length( aFlagB );     % Number of terms in the denominator.

    if ( aFmax < aNmax + aMmax ) || (aNmax < 1) || (aMmax < 1)
        theA = [];
        theB = [];
        theReturnCode = -2;
        return; % Not enough data in theY to solve for CR coef or not enough CR coef.
    end
    
    % Set up the full matrix.
    aFull = FillMatrix( theY,theFreq,aNmax,aMmax );

    % One of the coefficients must be normalized, we normalize to 1.0.
    % However, if the correct solution for the normalized coefficient is
    % actually zero, then trying to normalize it to 1 forms a singular
    % matrix. Try to normalize each coef to 1 until we find one that works, usually
    % will be the first one. If needed, we check each term in the denominator only.
    % If 100 terms or more, just pick one coefficient to normalize.
    % Checking condition number takes too long.
    
    aBestNormIndex = length(aABFlag) - 2; % Go with the w^2 coefficient.
    aCountLimit = aNmax + aMmax; % This will limit the number of condition numbers checked.
    if aCountLimit < 100
        aCondOK = 1.0e10; % Keep searching for better soultions when condition number is above this value.
        aBestCond = Inf;
        aCount = 0; % Count the number of denominator coefficients checked for condition number.
        if ( aCountLimit > 10)
            aCountLimit = 3; % For a big matrix, cond function gets really slow. Limit number of terms checked.
        end
        aBestNormIndex = 0; % If left unchanged, we were unsuccesful in finding a solution.
        for iNormIndex = length(aABFlag):-1:aNmax+1 % Start with DC term in denominator.
            if ( aBestCond >= aCondOK && aABFlag(iNormIndex) && aCount < aCountLimit ) % Stop searching once Best is better than OK.
                aCount = aCount+1;
                aABFlag(iNormIndex) = false; % So will remove norm row,col from aWork matrix, to be used for RHS.
                aWork = aFull( aABFlag, aABFlag ); % Remove unneded rows and cols.
                aNewCond = cond( aWork ); % Very big condition number is bad.
                if ( aNewCond < aBestCond )
                    aBestNormIndex = iNormIndex;
                    aBestCond = aNewCond;
                end % if aNewCond
                aABFlag( iNormIndex ) = true; % Restore norm candidate Flag.
            end % if aBestCond
        end % for iNormIndex
    end % if aCountLimit
%aBestNormIndex = 1; % DISABLE FINDING BEST NORM INDEX, comment out this line and un-comment above section to enable.
        
    % Evaluate the solution.
    aSolution = vpa( zeros( 1,length(aABFlag) ) );
    aABFlag(aBestNormIndex) = false; % So will remove norm row,col from aWork matrix, to be used for RHS.
    aWork = aFull( aABFlag, aABFlag ); % Remove unneded rows and cols.
    aRHS = -aFull( aABFlag, aBestNormIndex ); % Make the RHS and solve for the coef.
    aSolution( aABFlag ) = aWork \ aRHS;

    if any( isnan(aSolution) )
        theReturnCode = -3; % No solution found, matrix to solve for ab coeff is singluar.
        return;
    end

    aSolution( aBestNormIndex ) = 1; % Set the RHS row,col variable (normalized to 1).
    theA = aSolution( 1:aNmax );
    theB = aSolution( aNmax+1:end );
    theReturnCode = 1;
    
end % CRFit 


function theFull = FillMatrix( theY,theFreq,theNmax,theMmax )
% Full = FillMatrix( Y,Freq,Nmax,Mmax )
% Returns a full matrix (vpa) for complex rational polynomial least squares fit.
% Fitted data is the complex impedance, Y at Freq freqs in units consistent
% with the desired element values. Can be pure real or pure imaginary.
% Nmax number of terms in the numerator, Mmax terms
% in the denominator. Error conditions are checked in CRFit before calling
% this routine. jcr18Feb2015.
% Modified so that jW can be passed as real or imaginary frequency. jcr06apr2023

    % Convert input data to vpa (Variable Precision Arithmetic).
    aY = vpa(theY);

    % This routine requires a real aW radian frequency.
    % Make sure aW is real with zero imag part and make it a radian freq.
    % no matter if theFreq was passed as pure real or pure imaginary.
    if max( imag(theFreq) ) < 1e-30
        aW = vpa( 2*pi*theFreq );
    elseif max( real(theFreq) ) < 1e-30
        aW = vpa( imag(2*pi*theFreq) );
    else
        error('Freq must be pure real or pure imaginary.')
    end % if max

    %Gather required statistics.
    aW2 = aW .* aW;    % Stores frequency squared.
    aYmag2 = aY .* conj(aY);

    aMax = max(theNmax,theMmax); %This is how manny of each statistic that we will need.

    aWSum = vpa( zeros(1,aMax) ); %This is where we will store the statistics.
    aGSum = vpa( zeros(1,aMax) );
    aBSum = vpa( zeros(1,aMax) );
    aYSum = vpa( zeros(1,aMax) );

    aWPwr = vpa( ones( 1,length(theFreq) ) );   % Intermediate storage for frequency to the nth power.
    for iIndex = (1:aMax) % Do the even power stats, pwr = 2*(iIndex - 1).
        aWSum(iIndex) = sum( aWPwr );
        aGSum(iIndex) = dot( real(aY), aWPwr );
        aYSum(iIndex) = dot( aYmag2, aWPwr );
        aWPwr = vpa( aWPwr .* aW2 );
    end

    aWPwr = aW;
    for iIndex = (1:aMax) % Do the odd power stats, pwr = 2*iIndex - 1.
        aBSum(iIndex) = dot( imag(theY) , aWPwr );
        aWPwr = aWPwr .* aW2;
    end

    % Stats are done. Fill the matrix.
    aNMmax = theMmax + theNmax;
    theFull = vpa( zeros( aNMmax, aNMmax ) );

    % We first fill the upper triangular part of the matrix and then make it symmetric.
    % NOTE: theFull matrix rows/cols are ordered so An is first row/col, then An-1,
    % etc. This is so that the A and B come out in the order used by MATLAB
    % polyval. This order is the reverse of that in my notes. The iRow.iCol indices below 
    % correspond to indexing in my notes. theFull matrix (reordered) indices are figured
    % out when each statistic is stored in theFull matrix. -- jcr.

    % Fill the upper left corner. Submatrix is square theNmax x theNmax.
    for iCol = ( 1:theNmax )
        iSrc = iCol;
        for iRow = ( iCol:2:theNmax )
            if mod( iRow-iCol, 4 ) == 2
                theFull( theNmax-iRow+1,theNmax-iCol+1 ) = -aWSum( iSrc );
            else
                theFull( theNmax-iRow+1,theNmax-iCol+1 ) = aWSum( iSrc );
            end
            iSrc = iSrc + 1;
        end
    end

    % Fill the lower right corner.  Submatrix is square theMmax x theMmax.
    for iCol = ( 1:theMmax )  % iRow,iCol are the indices within the submatrix.
        iSrc = iCol; % Index of where the desired statistic is stored.
        for iRow = ( iCol:2:theMmax )  % Row index within the submatrix.
            if mod( iRow-iCol, 4 ) == 2
                theFull( aNMmax-iRow+1,aNMmax-iCol+1 ) = -aYSum( iSrc );
            else
                theFull( aNMmax-iRow+1,aNMmax-iCol+1 ) = aYSum( iSrc );
            end
            iSrc = iSrc + 1;
        end
    end

    % Fill the aRSum data in the upper right corner.
    % iRow and iCol are the submatrix row,col as in my notes. The polyval order
    % for theFull matrix location is figured out when we put the desired
    % statistic in its place.
    for iCol = ( 1:aMax )  %Col index within the submatrix.
        iSrc = iCol; % Index of where the desired statistic is stored.
        for iRow = ( iCol:2:aMax )  % Row index within the submatrix.
            if mod( iRow-iCol, 4 ) == 2 % Set the sign on the statistic to be stored.
                aGtmp = aGSum( iSrc );
            else
                aGtmp = -aGSum( iSrc );
            end
            if iRow <= theNmax && iCol <= theMmax % This submatrix is theNmax x theMmax.
                 theFull( theNmax-iRow+1, aNMmax-iCol+1 ) = aGtmp;
            end
            if iCol <= theNmax && iRow <= theMmax % Reverse row and col. Submatrix is symmetrical.
                 theFull( theNmax-iCol+1, aNMmax-iRow+1 ) = aGtmp;
            end
            iSrc = iSrc + 1;
        end
    end

    % Fill the aXSum data in the upper right corner. See comments in above loop.
    for iCol = ( 1:aMax-1 )  %Col index within the submatrix.
        iSrc = iCol; % Index of where the desired statistic is stored.
        for iRow = ( iCol+1:2:aMax )  % Row index within the submatrix.
            if mod( iRow-iCol, 4 ) == 3 % Set the sign on the statistic to be stored.
                aGtmp = aBSum( iSrc );
            else
                aGtmp = -aBSum( iSrc );
            end
            if iRow <= theNmax && iCol <= theMmax % This submatrix is theNmax x theMmax.
                 theFull( theNmax-iRow+1, aNMmax-iCol+1 ) = aGtmp;
            end
            if iCol <= theNmax && iRow <= theMmax % Reverse row and col. Submatrix is symmetrical.
                 theFull( theNmax-iCol+1, aNMmax-iRow+1 ) = -aGtmp;
            end
            iSrc = iSrc + 1;
        end
    end

    % The upper triangle has been filled. Make the matrix symmetric.
    for iCol = ( 1:aNMmax-1 )  %Col index of destination.
        for iRow = ( iCol+1:aNMmax )  % Row index of destination.
            theFull( iRow, iCol ) = theFull( iCol, iRow );
        end
    end

end % CRFit > FillMatrix


