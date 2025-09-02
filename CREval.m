function theResult = CREval(theNumCoef,theDenCoef,theFreqList)
    % Evaluate a rational complex polynomial. Result is vpa. jcr10mar2017
    % [Result,Num,Den] = CREval(NumCoef,DenCoef,FreqList);
    % Result = sum n over 1..N ( NumCoef(n)*(i*FreqList)^(N-n) ) /
    %          sum m over 1..M ( DenCoef(m)*(i*FreqList)^(M-m) )
    % where i = sqrt(-1).
    % NumCoef and DenCoef are usually passed as vpa.
    % Result, Num and Den returned as vpa. Would be a good idea to convert
    % result to double if making extensive use of it.
    % The FreqList may be real or imaginary.
    % JCR23Feb2022
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    [theResult,~,~] = CREval2(theNumCoef,theDenCoef,theFreqList);

end % CREval