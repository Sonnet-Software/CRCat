 function theComp = CRSeedAddNoise( theSeed,theNoiseFloor,theCat,theFit,theId,theSprout )
    % Comp = CRSeedAddNoise( Seed,NoiseFloor,Cat,Fit,Id,Sprout ): Evaluate how
    % the CR fitting performs when noise is added to the Seed data being
    % fitted. Comments for NoiseFloor below. See CRSeed for other comments.
    % NoiseFloor is in dB, must be a negative number. No noise added if below -200 dB.
    % Seed is converted to S-parameters. Gausian noise is added to the real
    % and imaginary parts. Then converted to Y or Z parameters as indicated
    % by Fit. Skip all degenerate components. 18nov2021jcr
    % Some internal work is done with frequency in radians/sec for radian
    % frequency so that CRComp.Fit element units are H,F,Ohms. Units for
    % display of component element values are selected for compact display.
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    if nargin < 3
        error('Missing argument.\n');
    end % if nargin

    if nargin == 3
        aFit = 'y'; % Default.
    else
        aFit = char(theFit); % Make sure it is a character array.
    end % if nargin

    if isempty(theCat)
        error('Catalog passed to this routine is empty.')
    end % if isempty

    % If the first digit in aFit is numeric, aFit starts with the number of
    % frequencies from theSeed to be used for fitting, aFlim. Extract that number.
    aFlim = 0; % Signal that aFlim was not specified in theFit string.
    if isstrprop(aFit(1),'digit') % First character is numeric, get numbers out of the string.
        aNumberStrings = regexp(aFit,'\d*','match'); % Returns cell array with one number string per element.
        aFlim = str2double( aNumberStrings{1} );
    end % if isstrprop
    
    if ~isnumeric( theNoiseFloor ) || theNoiseFloor >= 0.0
        error('NoiseFloor must be negative dB.\n');
    end % if ~isnumeric
    
    if nargin < 5 || theId(1) == 0
        aIdVec = 1:length(theCat.list); % Default option, fit all the components.
    elseif ~isnumeric( theId )
        error('Component Ids must be numeric.\n');
    else
        aIdVec = theId;
    end % if nargin
    aNumComp = length( aIdVec );
    aErrorSto( 1:aNumComp ) = -1; % To inicate error not set for comps that have no solution; for sorting.
    aPassiveSto( 1:aNumComp ) = 0;
    aCompSto( 1:aNumComp ) = CRComp; % Sets aCompSto vector to empty comps.
    
    if isa(theSeed,'SnP')
        aSeed = theSeed;
    elseif isa(theSeed,'char') || isa(theSeed,'string')
        aSeed = SnP; % Allocate the structure that will hold the data from the file.
        aSeed.Get( theSeed ); % Get the data from the file.
    else
        error('Seed must be an SnP class variable or a file name of Touchstone formated data.')
    end % if isa

    % Set the limit for number of frequencies to fit. Can be a subset of
    % the entire frequency list.
    if ( aFlim > numel(aSeed.freq) || aFlim == 0 )
         aFlim = numel(aSeed.freq); % Fit entire aSeed data set.
    end % if aFlim
    
    % Change aSeed frequency units to coorrespond to the units used in theCat.
    aSeed.Units( theCat.fUnit );
    
    % Add noise to aSeed data to simulate noisy measured data, if desired.
    aSeedPlusNoise = aSeed;
    if theNoiseFloor > -199.9  % Skip adding noise if floor -200 dB or more down.
        aSeedPlusNoise.AddNoise( theNoiseFloor ); % S-parameter data comes back.
    end % if theNoiseFloor

    [aFitSeed,aFitDescription] = aSeed.Pull(aFit); % Pull out data for fitting.
    [aFitSeedPlusNoise,~] = aSeedPlusNoise.Pull(aFit); % Pull out data+noise for fitting.

    if aSeed.rNorm > 1e-20
        aYNorm = 1/aSeed.rNorm; % Normalizing admittance for S-parameters.
    else
        aYNorm = 0.02; % Normalize any needed S-parameters to 50 Ohms.
    end % if aSeed
    
    % Convert from what was pulled out of aSeed to admittance.
    aFirstNonDigitIndex = regexp(aFit,'\D');
    if upper(aFit( aFirstNonDigitIndex(1) )) == 'Z' % Convert from impedance to admittance.
        aFitSeed = 1./aFitSeed;
        aFitSeedPlusNoise = 1./aFitSeedPlusNoise;
    elseif upper(aFit( aFirstNonDigitIndex(1) )) == 'S' % Convert from S parameter to admittance.
        aFitSeed = aYNorm * (1-aFitSeed)./(1+aFitSeed);
        aFitSeedPlusNoise = aYNorm * (1-aFitSeedPlusNoise)./(1+aFitSeedPlusNoise);
    elseif upper(aFit( aFirstNonDigitIndex(1) )) ~= 'Y'
        error('Unrecognized Fit parameter %s.',aFit);
    end % if upper

    % For the first component in theSprout, subtract its impedance from the
    % impedance of aFitSeed. Then for the second component in theSprout,
    % subtract its admittance from the admittance of aFitSeed. Empty
    % components have no effect on aFitSeed. Proceed likewise treating all
    % odd index components as impedance to be subtracted and all even
    % indexed components as admittance to be subtracted. Then, whatever is
    % left over in aFitSeed is to be fit to the next component. User
    % selects which of the best components is desired to be added to
    % theSprout of the best fitting components. Do the same for aFitSeedPlusNoise.

    aFreqHz = aSeed.freq * aSeed.fMult;

    if nargin >= 6 % theSprout was passed. Take theSprout data out of the Seed data.
        aFitSeed = CRSprout(aFreqHz,theSprout,aFitSeed);
        aFitSeedPlusNoise = CRSprout(aFreqHz,theSprout,aFitSeedPlusNoise);
    end % if nargin
    
    % dB reflection coefficient corresonding to the admittance. For later plotting.
    adB_Seed          = 20.0*log10( abs( ( aYNorm - aFitSeed ) ./ ( aYNorm + aFitSeed ) ) );
    adB_SeedPlusNoise = 20.0*log10( abs( ( aYNorm - aFitSeedPlusNoise ) ./ ( aYNorm + aFitSeedPlusNoise ) ) );
    aPhi_Seed = atan2( imag(aFitSeed),real(aFitSeed) ) .* (180/pi) ;
    aPhi_SeedPlusNoise = atan2( imag(aFitSeedPlusNoise),real(aFitSeedPlusNoise) ) .* (180/pi) ;
    
    fprintf('\n****Fitting %s****\n',aFitDescription);
    if isa(theSeed,'char') || isa(theSeed,'string')
        fprintf('File name: %s\n\n',theSeed);
    end % if isa
    
%     % Find the best signatures for the desired admittance.
%     if nargin <=3 % theSig was not specified.
%         [ aSigReturn, aMinError ] = theCat.FindBestSignatures( aY,aData.freq );
%     else
%         [aFlagA,~] = theCat.Sig2Flags( theSig ); % Returns zero if bad theSig string.
%         if aFlagA == 0
%             error('Bad signature, %s.\n',theSig );
%         end % if aFlagA
%         aSigReturn{1} = theSig;
%         aMinError = -1;
%     end % isempty
%     aIdVec = theCat.Sig2Id( aSigReturn{1} );
%     fprintf('\n\nSignature %s has minimum error of %f.',aSigReturn{1},aMinError(1));
%     if length(aSigReturn) > 1
%         fprintf('\nOther signatures with similar minimum error:');
%         fprintf(' %s',aSigReturn{2:end});
%     end % if length
%     fprintf('\n\n');

    % Get a vector of aY magnitude to normalize the RSS error for each fit.
    % aYMag = abs( double(aFitSeedPlusNoise) );
    % % if aYMag too small, leave that term out of the RSS summation.
    % aYNotZero = aYMag > 1.0e-10; % Arbitrary small number, to avoid divide by zero.
    % aYMagOk = aYMag( aYNotZero );
    % aYNoiseOk = double( aFitSeedPlusNoise( aYNotZero ) );
    
    % Fit all components to the data and print out a summary, but skip degenerate components.
    for iComp = 1:aNumComp
        aId = aIdVec(iComp); % Component index in theCat.
        if isempty( theCat.list(aId).symEL )
            fprintf('Id = %d, Name = %s, No synthesis equations, likely degenerate network.', aId,theCat.Id2Name(aId) );
        else
            aCompSto(iComp) = CRComp( aId,theCat ); % Set up the component to be fitted to the data.
            % Do a fit and synthesize element values.
            aErrorTmp = aCompSto(iComp).Fit( aFitSeedPlusNoise(1:aFlim),aFreqHz(1:aFlim) ); % Fit Y with result in aCompSto.
            if isempty(aErrorTmp)
                aErrorTmp = -1; % this iComp to be ignored, could not fit.
            end % if isempty
            aErrorSto(iComp) = min( aErrorTmp );
            
            if isempty( aCompSto(iComp).valEL )
                aErrorSto(iComp) = -1.0; % Signal that component is to be ignored.
            end % if ~isempty
    
            aPassiveSto(iComp) = isempty( aCompSto(iComp).IsGain ); % Returns empty if aComp is passive.
    
            fprintf('Id = %d, Name = %s, ', aId,aCompSto(iComp).name);
            fprintf(' RSS(y) Error = %f\n',aErrorSto(iComp));
            fprintf('Component variables:    '); 
    
            if aErrorSto(iComp) < 0 || isreal( aCompSto(iComp).valEL(1) ) % Real numbers to print.
                fprintf('%s    ',aCompSto(iComp).symVn);
                fprintf('\nNodal connection list: ');
                fprintf('%d %d   ',theCat.list(aId).nodes);
            else % Imaginary numbers to print.
                fprintf('%s             ',aCompSto(iComp).symVn);
                fprintf('\nNodal connection list:  ');
                fprintf('%d %d            ',theCat.list(aId).nodes);
            end % if isreal
            for iSolution=1:size( aCompSto(iComp).symEL,1 )
                aElVals = aCompSto(iComp).ELVal2Str(4,iSolution);
                fprintf('\nFitted RLC Values:  ');
                fprintf( ' %s%s',aElVals{:} ); % Element values followed by units corresponding to theCat.fUnit.
            end % for iSolution


        end % if isempty
        fprintf('\n\n');
        
    end % for iComp

    aIdSolved = aIdVec( aErrorSto >= 0.0 ); % Remove all comps that have no solution.
    aPassiveSolved = aPassiveSto( aErrorSto >= 0.0 );
    aCompSolved = aCompSto( aErrorSto >= 0.0 );
    aErrorSolved = aErrorSto( aErrorSto >= 0.0 );

    if isempty( aIdSolved )
        theComp = []; % Return value.
        return;
    end % if aIdSolved
    
    % Print out a summary of the 100 smallest errors.
    fprintf('Up to the 100 Best Fits (ID-Solution, RSS(%s) Error)',aFitDescription );
    if theNoiseFloor > -199.9
        fprintf(' Noise Floor = %f dB',theNoiseFloor);
    end % if theNoiseFloor
    fprintf('\n');
    if isa(theSeed,'char') || isa(theSeed,'string')
        fprintf('File Name: %s\n',theSeed);
    end % if isa
    
    [ ~,aOrder ] = sort( aErrorSolved ); % Sort so lowest error comps come first. 
    aErrorSorted = aErrorSolved( aOrder );
    aIdSorted = aIdSolved( aOrder );
    aPassiveSorted = aPassiveSolved( aOrder );
    aCompSorted = aCompSolved( aOrder );
    
    aLim = min( length(aIdSorted),100 );
    for iComp=1:aLim
        if aPassiveSorted(iComp) % We have a passive component, indicate with * after the ID-Solution Number.
            fprintf(' (%d* %.3g)',aIdSorted(iComp),aErrorSorted(iComp));
        else
            fprintf(' (%d  %.3g)',aIdSorted(iComp),aErrorSorted(iComp));
        end % if any
        if rem(iComp,10) == 0
            fprintf('\n'); % Start a new line after every 10th item.
        end % if rem
    end % for iComp
    fprintf('\n');
    theCat.DrawArray( aCompSorted );
    set(gcf,'Name','Top 10 Models');
    
    % Print out a summary of the smallest passive model errors.
    fprintf('Up to the 20 Best Passive Fits (ID-Solution, RSS(%s) Error)',aFitDescription );
    if theNoiseFloor > -199.9
        fprintf(' Noise Floor = %f dB',theNoiseFloor);
    end % if theNoiseFloor
    fprintf('\n');
    if isa(theSeed,'char') || isa(theSeed,'string')
        fprintf('File Name: %s\n',theSeed);
    end % if isa
    aIdPassive = aIdSorted( aPassiveSorted==true );  % Include only passive solutions.
    aCompPassive = aCompSorted( aPassiveSorted==true );  % Include only passive solutions.
    aErrorPassive = aErrorSorted( aPassiveSorted==true );  % Include only passive solutions.
    aLim = min( length(aIdPassive),20 );
    for iComp=1:aLim
        fprintf(' (%d* %.3g)',aIdPassive(iComp),aErrorPassive(iComp));
        if rem(iComp,10) == 0
            fprintf('\n'); % Start a new line after every 10th item.
        end % if rem
    end % for iComp
    fprintf('\n\n');
    if ~isempty( aCompPassive )
        theCat.DrawArray( aCompPassive );
    end % if ~isempty
    aPlotHandle = gcf;
    set(aPlotHandle,'Name','Top 10 Passive Models');
    aPlotHandle.Position(1) = aPlotHandle.Position(1) + 0.25; % Move the plot a little bit so it
    aPlotHandle.Position(2) = aPlotHandle.Position(2) - 0.25; % does not exactly cover the previous plot.
    
    % Ask which components the user would like a plot of the resulting fit
    % and then plot it.
    aComp = []; % So we know if any component was plotted for return value.
    aId = input('Enter component id for plotting (return to end): ');
    while ~( isempty(aId) || aId <= 0 )
        
        % Allocate a component and do a fit and synthesize element values.
        aCatEntry = theCat.list( aId );
        aComp = CRComp( aId,theCat );
        aError = aComp.Fit(aFitSeedPlusNoise(1:aFlim),aFreqHz(1:aFlim)); % Fit y to aComp.

        aYFit = aComp.Eval( aFreqHz );
        adB_Fit = 20.0*log10( abs( ( aYNorm - aYFit ) ./ ( aYNorm + aYFit ) ) );
        aPhi_Fit = atan2( imag(aYFit),real(aYFit) ) .* (180/pi) ;
        
        [aPlotLabel{1:20}] = deal(''); % Unlikely to need more than this.
        aPlotLabel{1} = sprintf('%s, Id=%d',aCatEntry.name, aId );
        aPlotLabel{2} = strcat( "RSS(",aFitDescription,") ",sprintf(' %.3g',aError ) );
        if theNoiseFloor < -199.9
            aPlotLabel{3} = sprintf('N = %d, no added noise.',numel(aFreqHz));
        else
            aPlotLabel{3} = sprintf('N = %d, Noise Floor = %.3g dB',numel(aFreqHz),theNoiseFloor);
        end % if theNoisefloor

        % Plot the result
        aPlotHeight = 5.0;
        aPlotWidth = 7.0;
        aPlotHorzMargin = 1.1; % So labels are within the figure.
        aPlotVertMargin = 0.8; % Setting OuterPosition property leaves too much white space.
        aComponentWidth = 3.0;
        
        figure('Units','Inches','Position',[1 1 aPlotWidth+aComponentWidth aPlotHeight+0.75])
        
        ax1 = subplot(1,2,1); % The fitted results go in this subplot.
        ax1.Units = 'Inches';
        ax1.Position = [aPlotHorzMargin aPlotVertMargin aPlotWidth-aPlotHorzMargin aPlotHeight-aPlotVertMargin];
        
        hold on;
        if theNoiseFloor > -199.9 % Need to plot the noise added curve.
            yyaxis left
            plot(aSeedPlusNoise.freq,adB_Fit,'-b','LineWidth',6,'DisplayName','Fitted Mag');
            plot(aSeedPlusNoise.freq,adB_SeedPlusNoise,'-b','LineWidth',2,'DisplayName','Noise Added');
            plot(aSeed.freq,adB_Seed,'-k','LineWidth',1,'DisplayName','Base Mag');
            yyaxis right
            plot(aSeedPlusNoise.freq,aPhi_Fit,'-r','LineWidth',6,'DisplayName','Fitted Phase');
            plot(aSeedPlusNoise.freq,aPhi_SeedPlusNoise,'-r','LineWidth',2,'DisplayName','Noise Added');
            plot(aSeed.freq,aPhi_Seed,'-k','LineWidth',1,'DisplayName','Base Phase');
        else
            yyaxis left
            plot(aSeedPlusNoise.freq,adB_Fit,'-b','LineWidth',6,'DisplayName','Fitted Mag');
            plot(aSeed.freq,adB_Seed,'-k','LineWidth',2,'DisplayName','Base Mag');
            yyaxis right
            plot(aSeed.freq,aPhi_Fit,'-r','LineWidth',6,'DisplayName','Fitted Phase');
            plot(aSeed.freq,aPhi_Seed,'-k','LineWidth',2,'DisplayName','Base Phase');
        end % if theNoiseFloor

        set( gca,'FontSize',14 );
        aXlim = xlim;
        aYlim = ylim;
        aT = text( aXlim(1)+0.05*(aXlim(2)-aXlim(1)), aYlim(1)+0.3*(aYlim(2)-aYlim(1)),aPlotLabel );
        set( aT,'FontSize',14 );
        title( 'Measurement vs. Fitted Lumped Model' );
        xlabel( sprintf('Frequency (%s)',theCat.fUnit) );
        yyaxis left
        ylabel( 'Magnitude (dB)' );
        yyaxis right
        ylabel( 'Phase (Deg)' );
        legend;
        box;
        hold off;
        
        ax2 = subplot('position',[ 0.9 0.1 0.1 0.1 ] ); % Create the axes so sure not to overlapp the existing set of axes.
        daspect( [1 1 1] ); % Now fixed so all drawings at same scale.
        pbaspect( [aComponentWidth aPlotHeight 1] ); % Fix the physical dimensions of the component plot.
        xlim( [ 0 aComponentWidth ] );
        ylim( [ 0 aPlotHeight ] );
        set( ax2,'Units','inches','Position',[aPlotWidth 0 aComponentWidth aPlotHeight] );
        aEnds = [ 0.5*aComponentWidth 0.95*aPlotHeight 0.5*aComponentWidth 0.0 ]; % Ends for drawing component schematic.
        aSize = [ 0.12 1 12 ]; % Resistor length as a fraction of x-axis length, line point size, font point size.
        aFinalEnds = theCat.Draw(aId,aEnds,aSize); % Position schematic starting near the center top and going down.
        theCat.Draw('port',aEnds,aSize);
        aGndStr = sprintf('ground%s.%d',aComp.name,aId); % Label the ground with the component name and Id.
        theCat.Draw(aGndStr,aFinalEnds,aSize);
        aComp.Label( aFinalEnds(3:4) ); % Put on the fitted element values.
        axis off;
        
        set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
        
        aId = input('Enter component id for next plot (return to end): ');
        
    end % ~isempty
    
    % If nothing plotted, return lowest error fit.
    if isempty(aComp)
        if isempty(aCompSorted)
            aComp = [];
        else
            aComp = aCompSorted(1);
            aComp.Fit(aFitSeedPlusNoise,aSeedPlusNoise.freq); % Fit y to aComp.
        end % if isempty
    else
        aComp.Fit(aFitSeedPlusNoise,aSeedPlusNoise.freq); % Back to consistent units.
    end % if isempty(aComp)
    theComp = aComp; % Set return value.
    
end % CRSeedAddNoise
