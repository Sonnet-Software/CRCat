function PlotResult
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    aNBase = 'C:\Users\rautio\Desktop\AAA_jcr\papers\ComplexRationalSynthesis\CR_Paper\ChipResistor\chip_resistor_to10GHz.s2p';
    aBase = SnP; % Allocate the structure that will hold the data from the file.
    aBase.Get( aNBase ); % Get the data from the file.
    aBase.Spar; % Make sure it is S-parameters.
    
    aNmodel = 'C:\Users\rautio\Desktop\AAA_jcr\papers\ComplexRationalSynthesis\CR_Paper\ChipResistor\chip_resistor_model_to10GHz.s2p';
    aModeled = SnP; % Allocate the structure that will hold the data from the file.
    aModeled.Get( aNmodel ); % Get the data from the file.
    aModeled.Spar; % Make sure it is S-parameters.
    
    figure; % Open up a new figure.

    % Calc magnitude dB of the Base and Modeled result S-params.
    % If warning message that variables loaded below might not be used,
    % probably because where they are used are temporarily commented out.
    adBS11_Base = transpose( squeeze( 20.0*log10( abs( aBase.mat(1,1,:) ) ) ) );
    adBS11_Modeled = transpose( squeeze( 20.0*log10( abs( aModeled.mat(1,1,:) ) ) ) );
    adBS21_Base = transpose( squeeze( 20.0*log10( abs( aBase.mat(2,1,:) ) ) ) );
    adBS21_Modeled = transpose( squeeze( 20.0*log10( abs( aModeled.mat(2,1,:) ) ) ) );
    
    % Calc phase of the Base and Modeled result S-params.
    aRadToDeg = 180.0/pi;
    aAngS11_Base = transpose( squeeze( aRadToDeg*angle( aBase.mat(1,1,:) ) ) );
    aAngS11_Modeled = transpose( squeeze( aRadToDeg*angle( aModeled.mat(1,1,:) ) ) );
    aAngS21_Base = transpose( squeeze( aRadToDeg*angle( aBase.mat(2,1,:) ) ) );
    aAngS21_Modeled = transpose( squeeze( aRadToDeg*angle( aModeled.mat(2,1,:) ) ) );

    % Plot the result
%     hold on;
%     title( 'Modeled Chip Resistor versus EM Analysis' );
%     xlabel( sprintf('Frequency (%s)',aBase.fUnit) );
%     ylabel( 'S-Parameter Magnitude (dB)' );
%     set( gca,'FontSize',12 );
% %     aT = text( aXmin+0.05*(aXmax-aXmin), aYmin+0.3*(aYmax-aYmin),aPlotLabel );
% %     set( aT,'FontSize',12 );
%     f = gcf;
%     f.Units = 'inches';
%     f.Position = [1 1 8 5];
%     plot(aModeled.freq,adBS11_Modeled,':','LineWidth',8,'Color',[.7 .7 .7]);
%     plot(aModeled.freq,adBS21_Modeled,'-','LineWidth',8,'Color',[.7 .7 .7]);
%     plot(aBase.freq,adBS11_Base,':k','LineWidth',3);
%     plot(aBase.freq,adBS21_Base,'--k','LineWidth',2);
%     hold off;
%     set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
    
    hold on;
    title( 'Modeled Chip Resistor versus EM Analysis' );
    xlabel( sprintf('Frequency (%s)',aBase.fUnit) );
    ylabel( 'S-Parameter Phase (Degrees)' );
    set( gca,'FontSize',12 );
%     aT = text( aXmin+0.05*(aXmax-aXmin), aYmin+0.3*(aYmax-aYmin),aPlotLabel );
%     set( aT,'FontSize',12 );
    f = gcf;
    f.Units = 'inches';
    f.Position = [1 1 8 5];
    plot(aModeled.freq,aAngS11_Modeled,':','LineWidth',8,'Color',[.7 .7 .7]);
    plot(aModeled.freq,aAngS21_Modeled,'-','LineWidth',8,'Color',[.7 .7 .7]);
    plot(aBase.freq,aAngS11_Base,':k','LineWidth',3);
    plot(aBase.freq,aAngS21_Base,'--k','LineWidth',2);
    hold off;
    set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
    
end % PlotResult
