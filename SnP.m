classdef SnP < handle
    % SnP: Holds microwave n-port data at multiple frequencies.
    % 12Nov2021jcr
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    properties (SetAccess = protected)
        fUnit;  % Frequency unit text string.
        fMult;  % Multiplier to convert fUnit to Hz.
        freq;   % Vector of frequencies in fUnit units.
        nPort;  % Number of ports.
        pType;  % String indicating parameter type: 'S', 'Y', or 'Z'.
        dType;  % string indicating data type: real/imag ('RI') 
                % mag/angle(deg) ('MA') or db/angle(deg) ('DB'). This is
                % the data format in the file. In the SnP.mat member, it 
                % is always stored as complex numbers, real and imaginary.
        rNorm;  % R normalization impedance.
        xNorm;  % X normalization impedance, not yet supported.
        mat;    % Data in 3D matrix, first two indices are row and col of
                % n port data and third indiex is the frequency index.
    end % properties
    
    methods
        function theData = SnP( ~ )
            % Data = SnP( ~ ): Construct an empty structure to hold microwave
            % n-port data. 12nov2021jcr
            
            theData.fUnit  = '';
            theData.fMult  = 0.0;
            theData.pType  = '';
            theData.dType  = '';
            theData.rNorm  = 0.0;
            theData.xNorm  = 0.0; % X normalization impedance not yet supported.
            theData.freq   = [];
            theData.nPort  = 0;
            theData.mat    = [];
            
        end % SnP constructor
        
            
        function Init( theData,theLoadStr )
            % Init( Data,LoadStr): LoadStr is from the Touchstone file format, e.g.,
            % '# GHZ Y RI R 1.0' indcates GHz frequency unit, Y-parameters,
            % Real and imaginary and normalized to 1 Ohm. If LoadStr is not valid,
            % just return with no changes. Any items left out of LoadStr are set
            % to defaults: GHz, S, MA, 50. 12nov2021jcr
            
            aParsed = textscan( theLoadStr,'%s' );
            
            if ~isempty( aParsed )
                [aRows,~] = size( aParsed{1} );
            end % if ~isempty
            if aRows == 0
                return; % the parse of theLoadStr has nothing in it.
            end % aRows
            if ~strcmp(aParsed{1}{1},'#')
                return; % theLoadStr is not a Touchstone # file header.
            end % strcmp
            
            theData.fUnit  = 'GHz'; % Set defaults.
            theData.fMult  = 1.0e9;
            theData.pType  = 'S';
            theData.dType  = 'MA';
            theData.rNorm  = 50.0;
            theData.xNorm  = 0.0;
            theData.freq   = []; % Clear out pre-existing data, if any.
            theData.nPort  = 0;
            theData.mat    = [];
            
            if aRows >= 2
                theData.Units( aParsed{1}{2} )
            end % if aCols
            
            if aRows >= 3
                switch upper( aParsed{1}{3} )
                    case 'Y'
                        theData.pType = 'Y';
                    case 'S'
                        theData.pType = 'S';
                    case 'Z'
                        theData.pType = 'Z';
                    otherwise
                        error('Third item in the # line must be the parameter type, Y, S, or Z, not %s.\n',aParsed{1}{3});
                end % switch
            end % if aCols
            
            if aRows >= 4
                switch upper( aParsed{1}{4} )
                    case 'RI'
                        theData.dType = 'RI';
                    case 'MA'
                        theData.dType = 'MA';
                    case 'DB'
                        theData.dType = 'DB';
                    otherwise
                        error('Fourth item in the # line must be the data type, RI, MA, DB, not %s.\n',aParsed{1}{4});
                end % switch
            end % if aCols
            
            if aRows >= 5
                if ~strcmpi( aParsed{1}{5},'R' )
                    error('Fifth item in the # line must be R, not %d.\n',aParsed{1}{5});
                end % switch
            end % if aCols
            
            if aRows >= 6
                theData.rNorm = str2double( aParsed{1}{6} );
                if isempty( theData.rNorm )
                    error('Sixth item in the # line must be the normalizing resistance, not %d.\n',aParsed{1}{6});
                end % switch
            end % if aCols
            
        end % SnP.Init
            
            
        function Get( theData,theFileName )
            % Data = Get( Data,FileName ): Opens and reads an S-parameter file from Sonnet
            % in Touchstone format and puts it in Data. Before calling,
            % allocate Data using Data = SnP; You can use uigetfile and fullfile
            % to let the user browse for a FileName. Data is always stored in
            % the structure (Data.mat) in real/imaginary ('RI') format, no
            % matter what format it is in the file. 12Nov2021jcr

            % Make sure theFileName is a character, not a string variable.
            aFileName = char(theFileName);
            
            % Get the number of ports from the file name extension.
            % Find the postion of the last period in the file name.
            aIndex = strfind( aFileName,'.' );
            aLen = length(aIndex);
            if aLen == 0
                error('Data file name, %s, must end with an extension including the number of ports.\n',aFileName);
            end % if aLen
            nPorts = '';
            if aIndex(end)+2 <= length(aFileName)-1
                aNs = aFileName( aIndex(end)+2:end-1 ); % This substring should have the number of ports.
                nPorts = str2double( aNs ); % Try to convert the substring to a number.
                if isnan( nPorts )
                    error('Data file extension must include the number of ports.');
                end % if isnan
            end % if aIndex
            if isempty( nPorts )
                error('Data file name, %s, must end with an extension including the number of ports.\n',aFileName);
            end % if length
            
            aFId = fopen(aFileName); % Open the file and initialize theData from the # line in the file.
            theData.fUnit = '';
            if aFId == -1
                error('File %s not found.\n',aFileName);
            end % if aFId
            
            while ~feof(aFId) && isempty(theData.fUnit)
                theData.Init( fgetl(aFId) ); % Nothing changes until we get a good Touchstone # line.
            end % while ~feof
            fclose( aFId );
            if isempty(theData.fUnit)
                error('No # line in the file %s.\n',aFileName);
            end % if isemmpty
            
            aFId = fopen(aFileName); % re-open the file
            % Count the number of data numbers in the file so we can
            % figure out the number of frequencies in the file.
            nData = 0;
            while ~feof(aFId)
                aParsed = textscan( fgetl(aFId),'%f' ); % This quits scanning as soon as a non-number is encountered.
                nData = nData + length( aParsed{1} );
            end % while ~feof
            fclose(aFId); % Close the file.
            
            % Infer the number of frequencies from the number of data
            % numbers. There is 1 frequency number plus 2 * (number of ports
            % squared) numbers per frequency.
            nDataPerFreq = 1 + 2 * nPorts * nPorts;
            nFreq = floor( (nData+0.0001) / nDataPerFreq );
            nExtra = rem( nData,nDataPerFreq ); % Should be zero.
            if nExtra
                warning('The %d extra numeric entries in %s will be ignored. Reading data for %d frequencies assuming %d ports.\n',nExtra,aFileName,nFreq,nPorts);
            end % if nExtra
            
            % Allocate required memory in theData.
            theData.nPort = nPorts;
            theData.freq( nFreq )  = 0.0;
            theData.mat( nPorts,nPorts,nFreq ) = 0.0 + 0.0i;
            
            % Read all the data from the file into theData.freq and theData.mat.
            iFreq = 0; % Count how many frequencies have been read.
            iRow = theData.nPort + 1; % Indicates next data item is a frequency.
            aParsed = '';
            aFId = fopen(aFileName);
            while iFreq < nFreq || iRow <= theData.nPort
                while isempty( aParsed ) || length( aParsed{1} ) <= iPos
                    aParsed = textscan( fgetl(aFId),'%f' ); % This quits scanning as soon as a non-number is encountered.
                    iPos = 1;
                end % while
                if iRow > theData.nPort % Reset to read a new frequency.
                    iFreq = iFreq + 1;
                    theData.freq( iFreq ) = aParsed{1}(iPos);
                    iPos = iPos + 1;
                    iRow = 1;
                    iCol = 1;
                else
                    switch theData.dType
                        case 'RI'
                            aData = complex( aParsed{1}(iPos),aParsed{1}(iPos+1) );
                        case 'MA'
                            aData = aParsed{1}(iPos) * exp( aParsed{1}(iPos+1)*1i*pi/180.0 );
                        case 'DB'
                            aData = db2mag( aParsed{1}(iPos) ) * exp( aParsed{1}(iPos+1)*1i*pi/180.0 );
                    end % switch
                    theData.mat(iRow,iCol,iFreq) = aData;
                    iPos = iPos + 2;
                    iCol = iCol + 1;
                    if iCol > theData.nPort
                        iCol = 1;
                        iRow = iRow + 1;
                    end % if iCol
                end % if iRow
            end % while iFreq
            fclose(aFId); % Close the file.
            theData.dType = 'RI';

        end % SnP.Get


         function Fill( theData,theYRIdata,theFreq )
            % Data = Fill( Data,YRIdata,Freq ): Fills an SnP using
            % parameter data in Param specified at frequencies in Freq. The
            % YRIdata is always complex admittance in real and imaginary.
            % The frequency units are specified using Data.Init with Y and
            % RI in the LoadStr, which is done after using Data = SnP. YRIdata 
            % must be Nports x Nports x NFreq and complex. This routine can
            % be used directly to change the data in an SnP structure
            % provided the SnP is set for RI data and Y-parameters.
            % Example:
            %   aSeed = SnP;
            %   aSeed.Init( '# GHZ Y RI R 1.0' );
            %   aYRIdata(1,1,:) = aCorrectY;
            %   aSeed.Fill( aYRIdata,aFreq );
            % 10jun2023jcr

            % Get the number of ports and number of frequencies from the
            % size of the passed data. Check for consistency.
            [nPorts,aNumCol,aNumFreq] = size( theYRIdata );
            if nPorts ~= aNumCol
                error('Data for SnP data must be nPort x nPort x nFreq. First two dimensions are %d x %d.',nPorts,aNumCol);
            elseif aNumFreq ~= size(theFreq)
                error('Data for SnP data must be nPort x nPort x nFreq. nFreq is %d, but %d frequencies were passed.',aNumFreq,size(theFreq));
            elseif ~strcmp(theData.dType,'RI')
                error('The SnP structure must be set to RI data. It is set to %s.',theData.dType);
            elseif ~strcmp(theData.pType,'Y')
                error('The SnP structure must be set to Y-parameters. It is set to %s-parameters.',theData.pType);
            end % if aNumPorts
            
            % Allocate required memory in theData.
            theData.nPort = nPorts;
            theData.freq  = theFreq;
            theData.mat = theYRIdata;

        end % SnP.Fill
        
        
        function Units( theData,theUnitStr )
            % Units( Data,UnitString ) If frequency units are changing,
            % set according to UnitStr and change Data.freq values to
            % coorespond. 18nov2021jcr
            
            aOldFMult = theData.fMult;

            switch upper( theUnitStr )
                case 'HZ'
                    theData.fUnit = 'Hz';
                    theData.fMult = 1.0;
                case 'KHZ'
                    theData.fUnit = 'kHz';
                    theData.fMult = 1.0e3;
                case 'MHZ'
                    theData.fUnit = 'MHz';
                    theData.fMult = 1.0e6;
                case 'GHZ'
                    theData.fUnit = 'GHz';
                    theData.fMult = 1.0e9;
                case 'THZ'
                    theData.fUnit = 'THz';
                    theData.fMult = 1.0e12;
                otherwise
                    error('Second item in the # line must be the frequency unit, Hz to THz, not %s.\n',theUnitStr);
            end % switch

            % Change the frequency values to correspond to the new units.
            if ~isempty( theData.freq )
                theData.freq = theData.freq .* (aOldFMult / theData.fMult );
            end % if ~isempty
            
        end % SnP.Units

        
        function Inv( theData )
            % Inv( Data ) Invert Data.mat and put back in Data.mat.
            % 1x1 and 2x2 matrices are commnon so singular
            % matrices are checked for and tiny values substituted when
            % potential divide by zero. 15Nov2021
            
            switch theData.nPort
                case 1
                    aDet = theData.mat(1,1,:); % Extract the 1,1 data component.
                    aTiny = abs( aDet ) < 1.0e-20; % Logical array of all tiny elements.
                    aDet( aTiny ) = 1.0e-20; % Set all tiny elements to a minimum value.
                    theData.mat(1,1,:) = 1.0 ./ aDet;
                case 2
                    aDet = theData.mat(1,2,:) .* theData.mat(2,1,:) - theData.mat(1,1,:) .* theData.mat(2,2,:);
                    aTiny = abs( aDet ) < 1.0e-20; % Logical array of all tiny elements.
                    aDet( aTiny ) = 1.0e-20; % Set all tiny elements to a minimum value.
                    % Save a data column in a temp storage.
                    aData11 = theData.mat(1,1,:);
                    theData.mat(1,1,:) = -theData.mat(2,2,:) ./ aDet;
                    theData.mat(1,2,:) =  theData.mat(1,2,:) ./ aDet;
                    theData.mat(2,1,:) =  theData.mat(2,1,:) ./ aDet;
                    theData.mat(2,2,:) = -aData11 ./ aDet;
                otherwise
                    warning('off','MATLAB:singularMatrix');
                    warning('off','MATLAB:illConditionedMatrix');
                    for iFreq = 1:length(theData.freq)
                        theData.mat(:,:,iFreq) = inv( theData.mat(:,:,iFreq) );
                    end % for iFreq
                    warning('on','MATLAB:singularMatrix');
                    warning('on','MATLAB:illConditionedMatrix');
            end % switch theData.nPort
            
        end % SnP.Inv
        
        
        function Spar( theData,theZnorm )
            % Spar( Data,Znorm ) Convert Data.mat to S-parameters normalized
            % to Znorm and put back in Data.mat. If Znorm not specified,
            % 50 Ohms is used. Znorm must be real. Complex Znorm not yet
            % implemented. 17Nov2021jcr
            
            aZnorm = 50.0;
            if nargin >= 2
                aZnorm = theZnorm;
                if ~isreal(aZnorm)
                    error('Complex normalizing impedance, %f, not yet implemented.',aZnorm);
                elseif aZnorm < 1e-20
                    error('Zero and negative normalizing impedance, %f, not yet implemented.\n',aZnorm);
                end % if ~isreal
            end % if nargin
                
            aFactor = aZnorm / theData.rNorm; % Multiply Y parameters by this factor.
                    
            switch theData.pType
                
                case 'Y' % S = (1-Z0*Y) * (1+Z0*Y)^(-1)
                    theData.mat = aFactor * theData.mat;
                    aIm = eye(theData.nPort);
                    for iFreq = 1:length(theData.freq)
                        theData.mat(:,:,iFreq) = ( aIm - theData.mat(:,:,iFreq) ) / ( aIm + theData.mat(:,:,iFreq) );
                    end % for iFreq
                    theData.rNorm = aZnorm; % New normalizing Z0.
                    
                case 'Z' % S = (Z-Z0) * (Z+Z0)^(-1)
                    aZ0m = aFactor * eye( theData.nPort );
                    for iFreq = 1:length(theData.freq)
                        theData.mat(:,:,iFreq) = (theData.mat(:,:,iFreq) - aZ0m) / (theData.mat(:,:,iFreq) + aZ0m);
                    end % for iFreq
                    theData.rNorm = aZnorm; % New normalizing Z0.
                    
                case 'S' % Renormalize to the new Z0 if needed.
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, nothing to do.
                        theData.Ypar( 1.0 ); % Convert to Y-parameters normalized to 1 Ohm.
                        theData.Spar( aZnorm ); % One level of recursion.
                        theData.rNorm = aZnorm; % New normalizing Z0.
                    end % if abs
                    
                otherwise
                    error('Data structure has unrecognized pType value, %s',theData.pType);
                    
            end % switch theData.pType
            theData.pType = 'S';
            
        end % SnP.Spar
        
        
        function Ypar( theData,theZnorm )
            % Ypar( Data,Znorm )  Convert Data.mat to Y-parameters normalized
            % to Znorm and put back in Data.mat. If Znorm not specified,
            % use 1.0 Ohms. Znorm must be real. Complex Znorm not yet
            % implemented. 17Nov2021jcr
            
            aZnorm = 1.0; % Default.
            if nargin >= 2
                aZnorm = theZnorm;
                if ~isreal(aZnorm)
                    error('Complex normalizing impedance, %f, not yet implemented.',aZnorm);
                elseif aZnorm < 1e-20
                    error('Zero and negative normalizing impedance, %f, not yet implemented.\n',aZnorm);
                end % if ~isreal
            end % if nargin
                
            aFactor = aZnorm / theData.rNorm; % Multiply Y parameters by this factor.
                    
            switch theData.pType
                
                case 'Y' % Renormalize to a new Z0 if needed.
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, nothing to do.
                        theData.mat = aFactor * theData.mat;
                        theData.rNorm = aZnorm;
                    end % if abs
                    
                case 'Z' % Y = Z^(-1)
                    theData.Inv;
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, we are done.
                        theData.mat = aFactor * theData.mat;
                    end % if abs
                    theData.rNorm = aZnorm;
                    
                case 'S' %  Y = (1/Z0) * (1+S)^(-1) * (1-S)
                    aIm = eye(theData.nPort);
                    for iFreq = 1:length(theData.freq)
                        theData.mat(:,:,iFreq) = (aIm + theData.mat(:,:,iFreq)) \ (aIm - theData.mat(:,:,iFreq));
                    end % for iFreq
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, nothing to do.
                        theData.mat = aFactor * theData.mat;
                    end % if abs
                    theData.rNorm = aZnorm;
                    
                otherwise
                    error('Data structure has unrecognized pType value, %s',theData.pType);
                    
            end % switch theData.pType
            theData.pType = 'Y';
            
        end % SnP.Ypar
        
        
        function Zpar( theData,theZnorm )
            % Zpar( Data,Znorm )  Convert Data.mat to Z-parameters normalized
            % to Znorm and put back in Data.mat. If Znorm not specified,
            % use 1.0 Ohms. Znorm must be real. Complex Znorm not yet
            % implemented. 17Nov2021jcr
            
            aZnorm = 1.0; % Default.
            if nargin >= 2
                aZnorm = theZnorm;
                if ~isreal(aZnorm)
                    error('Complex normalizing impedance, %f, not yet implemented.',aZnorm);
                elseif aZnorm < 1e-20
                    error('Zero and negative normalizing impedance, %f, not yet implemented.\n',aZnorm);
                end % if ~isreal
            end % if nargin
                
            aFactor = theData.rNorm / aZnorm; % Multiply Z parameters by this factor.
                    
            switch theData.pType
                    
                case 'Y' % Z = Y^(-1)
                    theData.Inv;
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, we are done.
                        theData.mat = aFactor * theData.mat;
                    end % if abs
                    theData.rNorm = aZnorm;
                
                case 'Z' % Renormalize to a new Z0 if needed.
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, nothing to do.
                        theData.mat = aFactor * theData.mat;
                        theData.rNorm = aZnorm;
                    end % if abs
                    
                case 'S' %  Z = Z0 * (1-S)^(-1) * (1+S)
                    aIm = eye(theData.nPort);
                    for iFreq = 1:length(theData.freq)
                        theData.mat(:,:,iFreq) = (aIm - theData.mat(:,:,iFreq)) \ (aIm + theData.mat(:,:,iFreq));
                    end % for iFreq
                    if abs(aFactor-1.0) > 1e-20 % Normalizing Z0 must be changed, otherwise, nothing to do.
                        theData.mat = aFactor * theData.mat;
                    end % if abs
                    theData.rNorm = aZnorm;
                    
                otherwise
                    error('Data structure has unrecognized pType value, %s',theData.pType);
                    
            end % switch theData.pType
            theData.pType = 'Z';
            
        end % SnP.Zpar
        
        
        function AddNoise( theData,theNoiseFloor )
            % AddNoise( Data,NoiseFloor ) Convert Data to S-parameters, add
            % noise to realize the desired NoiseFloor in dB ( < 0 ).
            % Default is -40 dB if NoiseFloor is not specified. Data
            % is left in the form of S-parameters on return. 18Nov2021jcr
            
            aNoiseFloor = -40;
            if nargin > 1
                aNoiseFloor = theNoiseFloor;
            end % if nargin
            if aNoiseFloor > 0
                warning('Noise floor, %f dB, is usually negative, more negative means less noise.\n',aNoiseFloor);
            end % if aNoiseFloor
            
            theData.Spar; % Convert to S-parameters.
            
            % Subjective observation of the noise floor corresonponds to std dev
            % determined from theNoiseFloor minus 20 dB.
            aNoiseStdDev = 10^( (aNoiseFloor-20.0) / 20.0 );
            
            theData.mat  = theData.mat  + randn( size(theData.mat),'like',real(theData.mat) ) .* aNoiseStdDev...
                                   + 1j * randn( size(theData.mat),'like',imag(theData.mat) ) .* aNoiseStdDev;
            
        end % SnP.AddNoise
        
        
        function Shorten( theData,theNumFreq )
            % Shorten( Data,NumFreq ) Reduce the number of frequencies in
            % Data so that there are no more than NumFreq frequencies left.
            % If already <= NumFreq, do nothing. Default NumFreq is 10% of
            % the total. 02Jan2022
            
            aNumFreq = ceil( 0.1 * length(theData.freq) ); % Default
            if nargin > 1
                aNumFreq = theNumFreq;
            end % if nargin
            
            if aNumFreq < 0
                aNumFreq = 0;
            elseif aNumFreq > length(theData.freq)
                aNumFreq = length(theData.freq);
            end % if aNumFreq
            
            theData.freq( aNumFreq+1:end ) = [];
            theData.mat( :,:,aNumFreq+1:end ) = [];
            
        end % SnP.Shorten
        
        
        function [thePulled,theDescription] = Pull( theData,theType )
            % [Pulled,Description] = Pull( Data,Type ): Pull data to be fit
            % from SnP Data according to the string in Type and return in
            % complex array Pulled. A descriptive string on what has been
            % pulled is returned in Description. Examples of Type:
            % Type = 'ymn' (if m and n are one digit), or 'ym_n'. If m == n, return
            %        the sum of the mth column in Pulled. Corresponds to a Pi model
            %        for port m to ground. If either m or n are zero, change so
            %        both equal the non-zero value. If m ~= n return admittance
            %        for Pi model of port m to n, which is the negative of
            %        the corresponding Y-parameter.
            %      For 'z' replacing 'y', upper or lower case, use Z parameters
            %        instead of Y parameters. Lower case 'z' returns impedance fit
            %        data for a Tee-model.
            %      For upper case 'Y' or 'Z' or 'S', return the indicated Y-parameters or
            %        Z-parameters or S-parameters directly. Do not modify data for Pi or Tee model.
            %      Any numbers that preface the Type string are ignored.
            % 18Feb2023jcr
            
            if nargin > 2
                error('No more than two arguments.');
            end % if nargin
            
            if nargin == 2  % Process theType string.
                aType = char( theType ); % Make sure it is char, not string.

                % Ignore any leading numeric digits in aType.
                aTypeLogical = isstrprop(aType,'digit'); % Logical array == 1 if digit, == 0 otherwise.
                if aTypeLogical(1) % First character is numeric, strip leading numbers out of the string.
                    aFirstIndex = find(~aTypeLogical,1); % Index of first non-numeric character.
                    if ~isempty(aFirstIndex)
                        aType = aType( aFirstIndex:end );
                    else
                        aType = 'y11'; % aType is just a number, make aType the default.
                    end % if ~isempty
                end % if aTypeLogical

                if strlength(aType) == 1
                    aType = strcat(aType,'11'); % Default if numbers not specified.
                end % if strlength
            elseif nargin == 1
                aType = 'y11'; % Default if theType not specified.
            else
                error('At least one argument required.');
            end % if nargin
        
            if upper(aType(1)) ~= 'Z' && upper(aType(1)) ~= 'Y' && aType(1) ~= 'S'
                error('Unrecognized first letter in Type argument: %s',aType);
            end % if upper
            
            if strlength(aType) == 3 % Most common case.
                aFitRow = str2double( aType(2) );
                aFitCol = str2double( aType(3) );
            elseif length(aType) > 3 % Get the row and col numbers. Must be a '_' between the two numbers.
                aIndex = strfind( aType,'_' );
                if ~isempty(aIndex) && aIndex > 1 && aIndex < length(aType)
                    aFitRow = str2double( aType(2:aIndex-1) );
                    aFitCol = str2double( aType(aIndex+1:end) );
                else
                    error('When Type specifies multidigit ports, place a ''_'' between the port numbers: %s',aType);
                end % if ~isempty
            else
                error('Argument Type requires two port numbers: %s',aType);
            end % if strlength
            
            if aFitRow == 0 && aFitCol > 0
                aFitRow = aFitCol;
            elseif aFitRow > 0 && aFitCol == 0
                aFitCol = aFitRow;
            elseif aFitRow < 0 && aFitCol < 0
                error('Negative numbers not allowed for Type port numbers: %s',aType);
            elseif aFitRow == 0 && aFitCol == 0
                error('Both Type port numbers cannot be zero: %s',aType);
            end % aFitRow
        
            aDat = theData; % Work on a copy of what was passed.
        
            [nRow,nCol,nFreq] = size(aDat.mat); % Get the number of frequencies.
        
            if aFitRow > nRow
                error('There are only %d ports in DatMat, cannot pull port %d data.',nRow,aFitRow);
            elseif aFitCol > nCol
                error('There are only %d ports in DatMat, cannot pull port %d data.',nCol,aFitCol);
            end
        
            switch aType(1) % Get the desired data and work up a descriptive string.
                case 'y' % Pull the pi model admittance.
                    aDat.Ypar; % Make sure the data is Y-parameters, real and imaginary.
                    if aFitRow == aFitCol
                        for iFreq=nFreq:-1:1 % Sum the aFitCol at each frequency.
                            thePulled(1,iFreq) = sum( aDat.mat(:,aFitCol,iFreq) );
                        end % for iFreq
                        theDescription = sprintf( 'Pi admit port %d to gnd',aFitRow );
                    else % Pull the negative of the given Y-parameter.
                        thePulled = -transpose( squeeze( aDat.mat(aFitRow,aFitCol,:) ) );
                        theDescription = sprintf( 'Pi admit port %d to %d.',aFitCol,aFitRow );
                    end % aFitRow
                case 'Y' % Pull the the given Y-parameter without modification.
                    aDat.Ypar; % Make sure the data is in the form of Y-parameters, real and imaginary.
                    thePulled = -transpose( squeeze( aDat.mat(aFitRow,aFitCol,:) ) );
                    theDescription = sprintf( 'Y-Param port %d to %d',aFitCol,aFitRow );
                case 'z' % Pull tee model impedance.
                    aDat.Zpar; % Make sure the data is Z-parameters, real and imaginary.
                    if aFitRow == aFitCol
                        for iFreq=nFreq:-1:1            
                            thePulled(1,iFreq) = 2*aDat.mat(aFitRow,aFitCol,iFreq) - sum( aDat.mat(:,aFitCol,iFreq) );
                        end % for iFreq
                        theDescription = sprintf( 'Tee imped port %d to center',aFitRow );
                    else % Pull the the given Z-parameter, no further modification needed for the Tee model.
                        thePulled = transpose( squeeze( aDat.mat(aFitRow,aFitCol,:) ) );
                        theDescription = sprintf( 'Tee imped port %d and %d string to gnd',aFitCol,aFitRow );
                    end % aFitRow
                case 'Z' % Pull the the given Z-parameter without modification for the Tee model.
                    aDat.Zpar; % Make sure the data is in the form of Z-parameters, real and imaginary.
                    thePulled = transpose( squeeze( aDat.mat(aFitRow,aFitCol,:) ) );
                    theDescription = sprintf( 'Z-Param port %d to %d',aFitCol,aFitRow );
                case 'S' % Pull the the given S-parameter without modification.
                    aDat.Spar; % Make sure the data is in the form of S-parameters, real and imaginary.
                    thePulled = transpose( squeeze( aDat.mat(aFitRow,aFitCol,:) ) );
                    theDescription = sprintf( 'S-Param port %d to %d',aFitCol,aFitRow );
            end % switch aType
            
        end % SnP.Pull
        
        

    end % SnP public methods
    
    


    
end % classdef























