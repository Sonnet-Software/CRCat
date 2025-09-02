function [theResult,theNum,theDen] = CREval2(theNumCoef,theDenCoef,theFreq)
    % Evaluate a rational complex polynomial. Result is vpa. jcr10mar2017
    % [Result,Num,Den] = CREval(NumCoef,DenCoef,Freq);
    % Result = sum n over 1..N ( NumCoef(n)*(i*2pi*Freq)^(N-n) ) /
    %          sum m over 1..M ( DenCoef(m)*(i*2pi*Freq)^(M-m) )
    % where i = sqrt(-1).
    % NumCoef and DenCoef are usually passed as vpa.
    % Result, Num and Den returned as vpa. Would be a good idea to convert
    % Result to double if making extensive use of it.
    % The may be imaginary frequency or pure real, both OK.
    % Num and Den are returned for error metric evaluation, if desired.
    % JCR23Feb2023
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    if length(theFreq) < 1 || (length(theNumCoef) < 1 && length(theDenCoef) < 1)
        theResult = []; % No data to work with.
        theNum = 0.0;
        theDen = 0.0;
        return;
    end

    if length(theNumCoef) < 1
        theResult = zeros(1,length(theFreq)); % No numerator, open circuit.
        theNum = 0.0;
        theDen = 1.0;
        return;
    end

    if  length(theDenCoef) < 1
        theResult = inf(1,length(theFreq)); % No denominator, short circuit.
        theNum = 1.0;
        theDen = 0.0;
        return;
    end

    % Make sure aFreqjw is imaginary radian frequency with zero real part
    % no matter if it was passed as pure real or pure imaginary.
    if max( real(theFreq) ) < 1e-30
        aFreqjw = 2*pi*theFreq;
    elseif max( imag(theFreq) ) < 1e-30
        aFreqjw = 2*pi*1j*theFreq;
    else
        error('Freq must be pure real or pure imaginary.')
    end % if max
    
    % theNumOld = polyval(theNumCoef,aCFreqList);
    % polyval will not take vpa data. So implimenting it with a loop.
    aNum = theNumCoef(1) * vpa( ones( 1,length(aFreqjw) ) );
    for iIndex = 2 : length(theNumCoef)
        aNum = aNum .* aFreqjw;
        aNum = theNumCoef(iIndex) + aNum;
    end
    
    % theDenOld = polyval(theDenCoef,aCFreqList);
    % polyval will not take vpa data. So implimenting it with a loop.
    aDen = theDenCoef(1) * vpa( ones( 1,length(aFreqjw) ) );
    for iIndex = 2 : length(theDenCoef)
        aDen = aDen .* aFreqjw;
        aDen = theDenCoef(iIndex) + aDen;
    end
    
    theNum = double(aNum);
    theDen = double(aDen);
    theResult = double( aNum ./ aDen );

end % CREval2