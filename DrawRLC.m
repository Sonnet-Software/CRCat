function DrawRLC( theLabel,theEnds,theSize,thePlotOption )
    % DrawRLC( Label,Ends,Size,PlotOption ): Draw the RLC indicated by
    % the first letter of the string Label on the current plot.
    %
    % Label first letter:
    % 'P': A port is drawn at first Ends, any additional letters label the port.
    % 'W': A wire is drawn between the Ends, no additional letters allowed.
    % 'G': A ground symbol is drawn at second Ends, any additional letters label the ground.
    % 'R', 'L', or 'C': Draw an R, L, or C between the Ends. Ends required.
    % Extra letters OK. Element labeled with entire Label.
    %
    % Ends are the [x1,y1,x2,y2] of each end of the element leads.
    %
    % Size = [Rlen LineWidth FontSize], all optional.
    % RLen is the length of an R or L before adding leads, as a fraction of
    % the length of the X-axis, default is 1/10th of the X-axis length.
    % Capacitors are set to a fraction of an R or L. Note that if the
    % X-axis changes length between calls to this routine, the size of the
    % next drawing changes also. If the Ends are too
    % close together, an error is thrown. LineWidth and FontSize are
    % measured in points, default is 1 and 10. If a set of
    % axes do not exist, one is created. If the DataAspectRatioMode is not
    % 'manual', then it is set to 'manual' and a warning displayed.
    %
    % PlotOption must be a string and is passed to plot, default is '-k'.
    %
    % Use CRCat.Draw to draw components.
    % Use CRComp.Label to add element value list. 28Nov2021jcr
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    aPlotOption = '-k'; % Default
    aTextColor = 'k';   % Default
    if nargin < 2
        error('Missing argument.\n');
    elseif nargin == 4
        if ischar( thePlotOption )
            aPlotOption = thePlotOption;
            aAlpha = aPlotOption( isstrprop( aPlotOption,'alpha' ) );
            aTextColor = aAlpha(1);
            if ~ismember( aTextColor,['r' 'g' 'b' 'c' 'm' 'y' 'k' 'w'])
                aTextColor = 'k'; % Default for text.
            end % if ~ismember
        else
            error('Unrecognized plot option.');
        end % isstring
    elseif nargin > 4
        error('Too many arguments.')
    end % if nargin
    
    % If no axes present, create a default set.
    aFig = gcf;
    if isempty( aFig.CurrentAxes )
        figure('Name','DrawRLC Default Figure');
        xlim( [0 7] );
        ylim( [0 7] );
        daspect( [1 1 1] );
        set( gca,'DataAspectRatioMode','manual' );
        pbaspect( [1 1 1] );
        set(gca,'PlotBoxAspectRatioMode','manual' );
        set(gca,'Units','inches' );
    end % if isempty
    
    % Get the data aspect ratio of the current set of axes.
    aDataAspectRatio = get( gca,'DataAspectRatio' );
    aAspectRatio = aDataAspectRatio(1) / aDataAspectRatio(2);
    
    if ~strcmp( get(gca,'DataAspectRatioMode'),'manual' ) 
                warning('Plot daspect([ %.4g %.4g %.4g ]) now being held constant to maintain correct RLC display.',aDataAspectRatio(1),aDataAspectRatio(2),aDataAspectRatio(3) );
        daspect( aDataAspectRatio );
        set( gca,'DataAspectRatioMode','manual' );
    end % if ~strcmp
    
    if ~strcmp( get(gca,'PlotBoxAspectRatioMode'),'manual' )
                aPlotBoxAspectRatio = get( gca,'PlotBoxAspectRatio' );
                warning('Plot pbaspect([ %.4g %.4g %.4g ]) now being held constant to maintain correct RLC display.',aPlotBoxAspectRatio(1),aPlotBoxAspectRatio(2),aPlotBoxAspectRatio(3) );
                daspect( aPlotBoxAspectRatio );
                set(gca,'PlotBoxAspectRatioMode','manual' );
    end % if ~strcmp
    
    aRLen = 0.1; % Default resistor length as a fraction of the x-axis length.
    aLineWidth = 1; % Default line width in points.
    aFontSize = 10; % Default text size in points.
    if nargin > 2
        if length(theSize) > 2
            aFontSize = theSize(3);
        end % if length
        if length(theSize) > 1
            aLineWidth = theSize(2);
        end % if length
        if ~isempty(theSize)
            aRLen = theSize(1);
        end % if length
    end % nargin
    aXLim = get(gca,'XLim');
    aRLength = aRLen * abs( aXLim(2) - aXLim(1) ); % Length of a resistor in X-Axis units.
    
    % Total length and rotation angle.
    aTotalLength = hypot( theEnds(3)-theEnds(1), aAspectRatio * (theEnds(4)-theEnds(2)) );
    aAngle = atan2( theEnds(4)-theEnds(2),(theEnds(3)-theEnds(1))/aAspectRatio );
    
    if aAngle < -0.9*pi % Set text justification.
        aHorz = 'center';
        aVert = 'bottom';
    elseif aAngle < -0.6*pi
        aHorz = 'right';
        aVert = 'bottom';
    elseif aAngle < -0.4*pi
        aHorz = 'right';
        aVert = 'middle';
    elseif aAngle < -0.1*pi
        aHorz = 'right';
        aVert = 'top';
    elseif aAngle < 0.1*pi
        aHorz = 'center';
        aVert = 'top';
    elseif aAngle < 0.4*pi
        aHorz = 'left';
        aVert = 'top';
    elseif aAngle < 0.6*pi
        aHorz = 'left';
        aVert = 'middle';
    elseif aAngle < 0.9 * pi
        aHorz = 'left';
        aVert = 'bottom';
    else
        aHorz = 'center';
        aVert = 'bottom';
    end % if aAngle
    
    hold on;
    
    aLabel = char( theLabel ); % So we can be sure to get the first char.
    switch upper( aLabel(1) )
        
        case 'R' % We have a resistor.
    
            if aRLength > aTotalLength % If element length too long, throw an error.
                error('Resistor %s is too long to fit between the end points.',aLabel);
            end % if aRLength
            aLeadLength = 0.5 * ( aTotalLength-aRLength )/aRLength; % Lead length before scaling.

            aX = aLeadLength + [ -aLeadLength 0.0 0.1/1.2  0.3/1.2 0.5/1.2  0.7/1.2 0.9/1.2  1.1/1.2 1.0 1.0+aLeadLength ];
            aY =               [  0.0         0.0 0.2/1.2 -0.2/1.2 0.2/1.2 -0.2/1.2 0.2/1.2 -0.2/1.2 0.0 0.0 ];

            % Scale, translate, rotate, and plot..
            aXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
            aYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );

            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth );

            aTextX = 0.5 * aX(end); % Put text just down from center of element.
            aTextY = 1.25 * min(aY);
            % Scale, translate, rotate, and plot.
            aTextXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aTextX - sin(aAngle) * aTextY );
            aTextYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aTextX + cos(aAngle) * aTextY );
            text( aTextXFinal,aTextYFinal,aLabel,'Color',aTextColor,'HorizontalAlignment',aHorz,'VerticalAlignment',aVert,'FontSize',aFontSize);
        
        case 'L' % We have an inductor.
    
            if aRLength > aTotalLength % If element length too long, throw an error.
                error('Inductor %s is too long to fit between the end points.',aLabel);
            end % if aRLength
            aLeadLength = 0.5 * ( aTotalLength-aRLength )/aRLength; % Lead length before scaling. 

            aN = 10; % Number of points for each loop of the inductor.
            aX = zeros( 4*aN-1 , 1 ); % Allocate space for four loops plus two leads.
            aY = zeros( 4*aN-1 , 1 ); % Note that each loop shares end points with it neighbor.

            aTh = linspace( pi,0,aN );
            % If aN==10, 1st loop is 2:11, 2nd loop is 11:20, 3rd is 20-29, 4th is 29-38. End point is 39.
            aX( 2      : aN+1   ) = 0.125 + 0.125*cos( aTh ); % First loop, 0 to 0.25, center at 0.125.
            aX( aN+2   : 2*aN   ) = 0.25 + aX(3:aN+1); % Second loop, 0.25 to 0.5, center at 0.375.
            aX( 2*aN+1 : 3*aN-1 ) = 0.50 + aX(3:aN+1); % Third loop, 0.5 to 0.75, center at 0.625.
            aX( 3*aN   : 4*aN-2 ) = 0.75 + aX(3:aN+1); % Fourth loop, 0.75 to 1.0, center at 0.875.
            aX(2:end-1) = aLeadLength + aX(2:end-1); % Add in the lead length.
            aX(end) = 1.0 + 2.0 * aLeadLength;

            aY( 2      : aN+1   ) = 0.125*sin( aTh ); % First loop;
            aY( 3      : aN     ) = 0.05 + aY(3:aN); % Move the body of the loop up a short distance.
            aY( aN+2   : 2*aN-1 ) = aY(3:aN); % Second loop, 0.25 to 0.5, center at 0.375.
            aY( 2*aN+1 : 3*aN-2 ) = aY(3:aN); % Third loop, 0.5 to 0.75, center at 0.625.
            aY( 3*aN   : 4*aN-3 ) = aY(3:aN); % Fourth loop, 0.75 to 1.0, center at 0.875.

            % Scale, translate, rotate, and plot.
            aXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
            aYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );
            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth );

            aTextX = 0.5 * aX(end); % Put text just down from center of element.
            aTextY = -0.1;
            % Scale, translate, rotate, and plot.
            aTextXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aTextX - sin(aAngle) * aTextY );
            aTextYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aTextX + cos(aAngle) * aTextY );
            text( aTextXFinal,aTextYFinal,aLabel,'Color',aTextColor,'HorizontalAlignment',aHorz,'VerticalAlignment',aVert,'FontSize',aFontSize);
        
        case 'C' % We have a capacitor.
    
            aCapLength = 0.15; % Body length of a capacitor before scaling.
            if aCapLength*aRLength > aTotalLength % If element length too long, throw an error.
                error('Capacitor %s is too long to fit between the end points.',aLabel);
            end % if aCapLength

            aCapHalfWidth  = 2.0 * aCapLength; % Body width of a capacitor before scaling.
            aLeadLength = 0.5 * ( aTotalLength/aRLength-aCapLength ); % Lead length before scaling.
            aCapOutPlate = aLeadLength + aCapLength; % x-coord of output plate before scaling.

            aX = [ 0.0 aLeadLength NaN aLeadLength    aLeadLength   NaN aCapOutPlate   aCapOutPlate  NaN aCapOutPlate aCapOutPlate+aLeadLength];
            aY = [ 0.0 0.0         NaN aCapHalfWidth -aCapHalfWidth NaN aCapHalfWidth -aCapHalfWidth NaN 0.0          0.0];

            % Scale, translate, rotate, and plot.
            aXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
            aYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );
            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth );

            aTextX = 0.5 * aX(end); % Put text just down from center of element.
            aTextY = 1.1 * min(aY);
            % Scale, translate, rotate, and plot.
            aTextXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aTextX - sin(aAngle) * aTextY );
            aTextYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aTextX + cos(aAngle) * aTextY );
            text( aTextXFinal,aTextYFinal,aLabel,'Color',aTextColor,'HorizontalAlignment',aHorz,'VerticalAlignment',aVert,'FontSize',aFontSize);
        
        case 'P' % We have a port.
        
            aN = 20; % Number of points for each loop of the inductor.
            aX = zeros( aN,1 ); % Allocate space for a small circle.
            aY = zeros( aN,1 );
            aRadius = 0.1;

            aTh = linspace( 0,2*pi,aN );
            aX( 1:aN ) = aRadius*cos( aTh ) - aRadius; % Small circle tangent to x=0.
            aY( 1:aN ) = aRadius*sin( aTh );

            % Scale, translate, rotate, and plot.
            aXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
            aYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );
            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth );

            if length( aLabel ) > 1
                aTextX = -1.5*aRadius; % Put text just down from center of port circle.
                aTextY = -1.5*aRadius;
                if aAngle < -0.9*pi || aAngle > 0.9*pi % Flip the port number to the other side.
                    aTextY = 1.5*aRadius;
                    aVert = 'top';
                end % if aAngle
                % Scale, translate, rotate, and plot.
                aTextXFinal = theEnds(1) + aRLength * ( cos(aAngle) * aTextX - sin(aAngle) * aTextY );
                aTextYFinal = theEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aTextX + cos(aAngle) * aTextY );
                text( aTextXFinal,aTextYFinal,aLabel(2:end),'Color',aTextColor,...
                                                            'HorizontalAlignment',aHorz,...
                                                            'VerticalAlignment',aVert,...
                                                            'FontSize',aFontSize);
            end % if length
        
        case 'W' % We have a line segment in theEnds.
        
            aXFinal = [ theEnds(1) theEnds(3) ];
            aYFinal = [ theEnds(2) theEnds(4) ]; % Marker on ends of wire make the ends rounded.
            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth,'Marker','.','MarkerSize',3*aLineWidth );
            
        case 'G' % We have a Ground symbol.
    
            aGndLength = 0.3; % Body length of a capacitor before scaling.
            if aGndLength*aRLength > aTotalLength % If element length too long, throw error.
                error('Ground symbol at is too long to fit between the end points.');
            end % if aGndLength
            
            aX = [ 0.0  0.0 NaN 0.11  0.11 NaN 0.22  0.22 NaN 0.33  0.33 ];
            aY = [ 0.4 -0.4 NaN 0.30 -0.30 NaN 0.20 -0.20 NaN 0.10 -0.10 ];
        
            % Scale, translate, rotate, and plot.
            aXFinal = theEnds(3) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
            aYFinal = theEnds(4) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );
            plot( aXFinal,aYFinal,aPlotOption,'LineWidth',aLineWidth );

            if length( aLabel ) > 1
                aTextX = 0.5*aX(end); % Put text just below the center of the ground symbol.
                aTextY = 1.2*aY(5);
                % Scale, translate, rotate, and plot.
                aTextXFinal = theEnds(3) + aRLength * ( cos(aAngle) * aTextX - sin(aAngle) * aTextY );
                aTextYFinal = theEnds(4) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aTextX + cos(aAngle) * aTextY );
                text( aTextXFinal,aTextYFinal,aLabel(2:end),'Color',aTextColor,...
                                                            'HorizontalAlignment',aHorz,...
                                                            'VerticalAlignment',aVert,...
                                                            'FontSize',aFontSize);
            end % if length
        
    end % switch
    
    hold off;
    
end % DrawRLC

    





