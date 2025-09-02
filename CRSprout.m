 function theModifiedY = CRSprout( theFreq,theSprout,theOriginalY )
    % ModifiedY = CRSprout( Freq,Sprout,OriginalY )
    % If passed without OriginalY, the impedance of of odd indexed
    % components in theSprout, and the admittance of even indexed
    % components are evaluated. We then start with the 2nd component, for
    % which adittance was calcualted. We take the impedance of the
    % previous component, invert it and add it to the admittance of the
    % second component. This connects the second component in shunt with
    % the first and the result becomes the net adnittance of the circuit up
    % to that point. For the third component, we take that net admittance,
    % invert it and add it to the imp;edance of the third component. That
    % connects the third component in series. This process is repeated until
    % all components have been added into the circuit. This allows us to
    % build a network by combining components using a combination
    % of series and shunt connections. To connect a short circuit in series
    % or an open circuit in shunt, just make the component empty, as
    % in aComp=CRComp. The final resulting Y-parameters are returned.
    % 
    % If OriginalY is passed, then the above total admittance result is
    % subtracted from OriginalY. When Sprout exactly models OriginalY, then 
    % the returned ModifiedY wil be an open circuit (i.e., all zeros).
    % Otherwise, ModifiedY represents data that can be used with CRSeed to
    % find another CRComp to accurately model the left-over ModifiedY
    % admittance. If successful, you can add to Sprout array and that will
    % make the next CRSeed ModifiedY result even closer to zero, indicating 
    % an improved model of the original data. Element value units and Freq
    % units are any consistent set, such as Hz,F,H,Ohms, or GHz,nF,nH,Ohms.
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    if nargin < 2
        error('Too few arguments.');
    end % if nargin
    
    % Check matrix sizes.
    nFreq = numel(theFreq);
    if nargin >= 3 && length(theOriginalY) ~= nFreq
        error('OriginalY and Freq must have the same length.');
    end % if nargin

    % Evaluate the admittance of theSprout.
    theModifiedY = zeros(1,numel(theFreq)); % Default return is open circuit.
    aModifiedYStarted = 0; % The first valid component just goes right into theModifiedY.
    for iSprout=1:numel(theSprout)
        if ~isempty(theSprout(iSprout).name) && ~isempty(theSprout(iSprout).valEL)
            aYSprout = theSprout(iSprout).Eval( theFreq );
            if ~aModifiedYStarted
                theModifiedY = aYSprout; 
                aModifiedYStarted = 1;
            elseif mod(iSprout,2) % iSprout is odd, add impedance to theModifiedY.
                theModifiedY = 1 ./ ( (1./theModifiedY) + (1./aYSprout) );
            else % iSprout is even, add admittance to theModifiedY.
                theModifiedY = theModifiedY + aYSprout;
            end % if mod
        end % if theSprout
    end % for iSprout

    if nargin >= 3 % Subtract theSprout admittance from theOriginalY.
        theModifiedY = theOriginalY - theModifiedY;
    end % if nargin
    
end % CRSprout