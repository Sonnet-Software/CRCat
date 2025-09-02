 classdef CRComp < handle
    % CRComp Specifies a component, a specific connection of RLC's between two nodes. jcr05Mar2015
    % Modified to be able to evaluate components without reference to a
    % component catalog. jcr18jan2022
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    properties (SetAccess = protected)
        symY;  % Symbolic equation for entire rational polynomial in terms of element values.
        symC;  % Symbolic CR Poly coefficients, Ai and Bi.
        symVn; % Symbolic symbols for RLC lumped elements.
        symEL; % Symbolic equations to go from fitted A,B coefficients to lumped element values.
        valEL; % Values of the RLCs. If empty, ignore this component during Eval.
        flagA; % Numerator signature.
        flagB; % Denominator signature.
        name;  % Name of component (use Cat.Name2Id to get index in CRCat catalog).
        node1; % First node between which component will be connected.
        node2; % Second node between which component will be connected.
    end
    
    methods
        function theComp = CRComp(theName,theCat,theValEL)
            % Comp = CRComp(Name,Cat,ValEL): Construct CRComp object(s) using
            % the Name(s) supplied. Name can be a scalar, or an array of
            % integers for Cat id's (i.e., index into Cat.list) or a string/char
            % or string/char array (double or single quotes). Comp is returned
            % with the same number of elements as Name. If called with no arguments
            % or empty Name, returns an empty scalar CRComp object. jcr09May2015
            %
            % Modified to be able to Eval components without reference
            % to a component catalog. Needs Cat, the component catalog,
            % passed to initially set up a component. jcr18jan2022
            % 
            % ValEL is an optional list of element values to set in the returned
            % Comp. If present, must have the right number of elements
            % for the returned Comp, and there can be only one Comp. If ValEL
            % not passed, element values are set to the Cat test values. jcr21July2025

            if nargin ~= 0

                if nargin < 2
                    error('At least two parameters, Name and Cat, must be passed.')
                end % if nargin
                
                if ischar( theName )
                    aName = string(theName);
                else
                    aName = theName;
                end

                sizeComp = size(aName);
                nComp = numel(aName);
                if nComp==0
                    theComp.valEL = []; % Signal to ignore this component.
                    return % Nothing to do.
                end % if nComp
                
                theComp( sizeComp(1),sizeComp(2)  ) = CRComp; % Allocating the last one allocates the entire array.
                nCat = numel(theCat.list);
            
                for iC = 1:nComp % Initialize each individual CRComp structure.
                    
                    if ~isnumeric( aName(iC) )
                        aId = theCat.Name2Id( string( aName(iC) ) );
                        if aId == 0
                            warning('Component name %s not found in the catalog. Allocating empty component.',aName(iC));
                        end % if aId
                    else
                        aId = aName(iC);
                    end % if ~isnumeric
                    
                    if aId>0 && aId<=nCat
                        aCatItem = theCat.list( aId );
                        theComp(iC).symY = aCatItem.symA / aCatItem.symB; % Symbolic equation for admittance in terms of RLC values.
                        theComp(iC).symC = aCatItem.symC; % Symbolic CR poly coefficients, Ai and Bi.
                        theComp(iC).symEL = aCatItem.symEL; % Symbolic equations to go from CRPoly coeff to RLC values.
                        if ~isempty(aCatItem.symVn)
                            theComp(iC).symVn = aCatItem.symVn;
                        else
                            theComp(iC).symVn = aCatItem.symV;
                        end % if ~isempty
                        [ theComp(iC).flagA,theComp(iC).flagB ] = theCat.Sig2Flags( aCatItem.flagSig );
                        if nargin == 2
                            theComp(iC).valEL = aCatItem.testEL; % Set RLCs to default testing values.
                        elseif numel(theValEL) == numel(aCatItem.symVn)
                            if nComp == 1
                                theComp(iC).valEL = theValEL; % Set RLCs to passed values.
                            else
                                error('Only one component can be created when specifying custom element values.')
                            end % if nComp
                        elseif isempty(theValEL)
                            theComp(iC).valEL = [];
                        else
                            error('Network Id %d requires %d element values but %d were passed.',aId,numel(aCatItem.symVn),numel(theValEL))
                        end % if nargin == 2
                        theComp(iC).name = string( aCatItem.name );
                        theComp(iC).node1 = uint32(0);
                        theComp(iC).node2 = uint32(0);
                    else
                        if aId ~= 0
                            warning('CRComp: Index=%d, id=%d is not within the CRCat range. Allocating empty component.',iC,aId );
                        end % if theId
                    end
                end % for iC ... initializing all components in array.
            end % if nargin
            
        end % CRComp constructor.
        
         
        function theRSSError = Fit(theComp,theY,theFreq,theValVnFixed)
            % RSSError = Fit(Comp,Y,Freq,ValVnFixed): Fit Comp to
            % admittance function Y ats frequencies Freq. Y, which
            % is complex, and Freq must have the same number of elements.
            % If there are fixed elements, i.e., those elements for which
            % there are no synthesis equations, values must be specified
            % in ValVnFixed, which is otherwise optional. If ValVnFixed
            % has more than one row, do a fit for each row (i.e., case)
            % of ValVnFixed, all based on the same least squares fit.
            % If ValVnFixed is needed but not provided, return empty.
            % Freq and component values can be in any consistent units,
            % for exmaple, Hz H,F,Ohms; or GHz/sec,nH,nF,Ohms.
            % The best fit values of the RLCs are stored in Comp.valEL, one
            % solution per row (there can be several solutions for 4 or
            % more RLCs) and one set of solutions per ValVnFixed case. If
            % unable to fit a component, valEL is returned empty and a
            % warning is printed. Returns RSSError. Returned empty if no
            % synthesis equations. If more than one component, does only
            % first one, no warning. Complex element values allowed.
            % Turns out to be needed for some equivalences. -- 19May2025jcr

            if nargin < 3
                error('At least three arguments needed.')
            end % nargin

            aFreq = theFreq;

            if isempty( theComp )
                theRSSError = [];
                return;
            end % if isempty
            
            % Check the number of frequencies and number of admittances to be fitted are consistent.
            aNumY = numel(theY);
            if aNumY ~= numel(aFreq)
                error('Number frequencies at which admittance data was provided, %d, and number of frequencies provided, %d, do not match.', ...
                    aNumY,numel(aFreq) );
            end % if aNumY

            % How many solutions? How many elements can be sythesized from the fitted rational polynomial??
            [ aNumSolutions,aNumV ] = size( theComp(1).symEL ); % aNumV is number of elements that can be synthisized.
            if aNumSolutions == 0 || aNumV == 0 || aNumY == 0
                theComp(1).valEL = [];
                theRSSError = [];
                return
            end % if aNumSolutions
            % aNumVn is total number of elements in the component, including fixed elements not solved for in symEL.
            aNumVn = numel( theComp(1).symVn );
            if aNumVn > aNumV % Store the sybolic names and values of the RLCs that are not synthesized.
                aSymVnFixed = theComp(1).symVn(aNumV+1:aNumVn);
                % Make sure we have values for these elements.
                if nargin ~= 4 || isempty(theValVnFixed)
                    theComp(1).valEL = [];
                    theRSSError = [];
                    return
                end % if nargin
                [ aNumCases,aNumValues ] = size( theValVnFixed );
                if aNumValues ~= aNumVn - aNumV
                    error('Need %d fixed element values for %s, but %d were passed.',aNumVn-aNumV,theComp(1).name,aNumValues)
                end % if aNumValues
            elseif aNumV == aNumVn && nargin == 4 && numel(theValVnFixed) ~= 0
                [ ~,aNumValues ] = size( theValVnFixed );
                error('No fixed element values needed for %s, but %d were passed.',theComp(1).name,aNumValues)
            else
                aSymVnFixed = [];
                aNumCases = 1;
            end % if aNumVn
            
            try % Get the coefficients for the rational polynomial that best fits the Y.
                [ aA,aB,aResultFlag ] = CRFit( theY,aFreq,theComp(1).flagA,theComp(1).flagB ); % Do the fit.
            catch
                aA = []; % No fit. Keep going to try other solutions, if any.
                aB = [];
                aResultFlag = -4; % CRFit had an error, probably divide by zero.
            end

            if aResultFlag < 0
                warning('Component name = %s: Unable to fit, CRFit error code = %d. Component ignored.', ...
                    theComp(1).name,aResultFlag);
                theComp(1).valEL = [];
                theRSSError = [];
                return;
            end % if aResultFlag

            theComp.valEL = zeros( aNumSolutions*aNumCases,aNumVn ); % Allocate memory for element values.
            % Calc element values. If throws an error, something wrong with the catalog symEL or symC.
            aTmp = [ aA aB ]; % All the fitted coefficients, inlcuding zero terms, returned by CRFit.
            aFittedCoef = aTmp( [ theComp(1).flagA theComp(1).flagB ] ); % Just the coef returned by coeffs for symC.
            iValRow = 1; % Start row for storing element value solutions.
            for iCase = 1:aNumCases
                try
                    aSymEL = subs( theComp(1).symEL, theComp(1).symC, aFittedCoef );
                    if aNumVn > aNumV % We have some fixed element values to substitute in too.
                        aSymEL = subs( aSymEL, aSymVnFixed, theValVnFixed(iCase,:) );
                        % Put the fixed element values into the component element value array.
                        theComp(1).valEL( iValRow:iValRow+aNumSolutions-1,aNumV+1:aNumVn ) = ...
                            repmat( theValVnFixed(iCase,:),aNumSolutions,1 );
                    end % if aNumVn
                    % Sometimes sym pi appears after the above substitution and makes double take forever.
                    aSymEL = subs( aSymEL, pi, 3.141592653590 );
                    theComp(1).valEL( iValRow:iValRow+aNumSolutions-1,1:aNumV ) = double( aSymEL );
                    iValRow = iValRow + aNumSolutions;
                catch
                    warning('Component name = %s, Case %d: Unable to solve for RLC values. Element values set to zero.', ...
                        theComp(1).name,iCase);
                end % try
            end % for iCase

            % rmse = root mean squared error, MATLAB 2022b and higher.
            theRSSError = rmse( theY',theComp(1).Eval( theFreq )' ); 
        
        end % CRComp.Fit

        
        function [ theY ] = Eval( theComp,theFreq )
            % Y = Eval( Comp,Freq ): Calculate the admittance of Comp
            % at freqs Freq by symY (from symA/symB, num/den, in Cat)
            % to get the admittance. jcr13Mar2015
            % Modified to do Eval with only internal data, no need
            % to reference theCat. jcr18jan2022 Freq can be passed as
            % either real or complex with zero real part. 1apr2023jcr
            % Freq and component values can be in any consistent units,
            % for example, Hz,H,F,Ohms; or GHz,nH,nF,Ohms. jcr12June2023
            % Provides one row of theY for each set of values in
            % theComp.valEL and solve only for the first Comp 4Feb2025jcr 
            
            if nargin < 2
                error('Wrong number of parameters passed.');
            end % nargin < 2

            if isempty(theComp(1)) || isempty(theComp(1).name) || isempty(theComp(1).valEL) || isempty(theFreq)
                theY = zeros( 1,numel(theFreq) );
                return; % Ignore component.
            end % if isempty

            % Make sure aFreqjw is imaginary radian frequency with zero real part
            % no matter if it was passed as pure real or pure imaginary.
            if max( real(theFreq) ) < 1e-30
                aFreqjw = 2*pi*theFreq;
            elseif max( imag(theFreq) ) < 1e-30
                aFreqjw = 2*pi*1j*theFreq;
            else
                error('Freq must be pure real or pure imaginary.')
            end % if max

             % Number of value sets to eval the component for, and the number of variables for which values are needed.
            [ aNumCases,nVPassed ] = size( theComp(1).valEL );
            theY = complex( zeros(aNumCases,numel(aFreqjw)) ); % Allocate the return variable.
            nVNeeded = numel( theComp(1).symVn ); % Number of RLCs we need.
            syms s;
            if nVPassed ~= nVNeeded
                error('Component %s has %d RLCs, but %d RLC values passed.',theComp(1).name,nVNeeded,nVPassed)
            end % if nVPassed

            for iCase = 1:aNumCases
                try
                    aSymYs = subs( theComp(1).symY, theComp(1).symVn, theComp(1).valEL(iCase,:) ); % aSymYs is a function only of s (=jw).
                catch
                    aSymYs = sym(0);
                end
    
                try
                    theY(iCase,:) = double( subs(aSymYs, s, aFreqjw) ); % A row vector is expected.
                catch
                    theY(iCase,:) = []; % Solution is no good, keep on going and find others.
                end % try
            end % iCase
                
        end % CRComp.Eval

        
        function [ theY ] = Nodal( theComp,theFreq,theCat )
            % [ Y } = Nodal( Comp,Freq,Cat ): Calculate the admittance of first Comp (only) at freqs Freq by nodal
            % analysis. This is typically used only to verify that the CRComp netlist corresponds
            % to the admittance obtained by evaluating symA/symB (CRComp.Eval).
            % If there are multiple EL solutions, one returned in each row. Solutions should be identical
            % if they all came from CRComp.Fit. This routine does numercially what
            % CRComp.Eval does symbolically using SymA and SymB. jcr13Mar2015
            % Freq and component values can be in any consistent units,
            % for exmaple, Hz,H,F,Ohms; or GHz,nH,nF,Ohms. jcr12June2023
            
            if isempty( theComp ) || isempty( theComp(1).valEL )
                theY = zeros( 1,numel(theFreq) );
                return; % Ignore component.
            end

            if nargin < 3
                error('Three arguments needed.')
            end % if nargin

            % Make sure aFreqjw is imaginary radian frequency with zero real part
            % no matter if it was passed as pure real or pure imaginary.
            if max( real(theFreq) ) < 1e-30
                aFreqjw = 2*pi*theFreq;
            elseif max( imag(theFreq) ) < 1e-30
                aFreqjw = 2*pi*1j*theFreq;
            else
                error('Freq must be pure real or pure imaginary.')
            end % if max
            
            aComp = theComp(1);
            aId = theCat.Name2Id(aComp.name);
            
            [ nSolutions,~ ] = size(aComp.valEL);
            theY = complex( zeros(nSolutions,numel(aFreqjw)) );
            
            if isempty( aComp.valEL )
                return; % Return open circuit admittance.
            end

            aNodeListTmp = theCat.list(aId).nodes; % The largest node number is the size of the nodal matrix.
            % Make all node numbers sequential, otherwise the nodal matrix
            % will have rows and columns with all zeros.
            aMaxLimit = 1 + max( aNodeListTmp ); % Value used to indicate node list value has been mapped.
            aNewNodeNum = 0;
            aMin = min( aNodeListTmp );
            aNodeList = aNodeListTmp; % Initializes aNodeList to correct size.
            while aMin < aMaxLimit
                aBinary = ( aNodeListTmp == aMin ); % Binary, locations of minimum valued node numbers.
                aNodeList( aBinary ) = aNewNodeNum;
                aNodeListTmp( aBinary ) = aMaxLimit; % The old node number has been mapped to a new node number.
                aNewNodeNum = aNewNodeNum + 1;
                aMin = min( aNodeListTmp );
            end % while min
            
            aB = zeros( max(aNodeList) , 1 ); % Right hand side for solving nodal equations.
            aB(1) = 1.0;
            
            for iSolution = (1:nSolutions) % Go through each EL solution (possible if 4 or more RLCs).
                aELVal = aComp.valEL(iSolution,:); % Get element values for nodal analysis.
                for iFreq = 1:numel(aFreqjw)
                    aN = complex( zeros( length(aB) ) ); % Allocate and clear the nodal matrix.
                    for iV = 1:length(aComp.symVn) % Go thru each variable (e.g., R, L, and C).
                        aELName = char(aComp.symVn(iV)); % All symbolic variable names for elements have an R, L, or C.
                        switch aELName( find( aELName=='R' | aELName=='L' | aELName=='C',1 ) )
                            case 'R'
                                aAdmittance = 1.0/aELVal(iV);
                            case 'L'
                                aAdmittance = 1 / (aFreqjw(iFreq) * aELVal(iV));
                            case 'C'
                                aAdmittance = aFreqjw(iFreq) * aELVal(iV);
                            otherwise
                                error('Unrecognized element: %s. Element name must begin with R, L, or C.',aELName);
                        end

                        % Put the admittance into the nodal matrix.
                        index1 = aNodeList( 2*iV-1 );
                        index2 = aNodeList( 2*iV );
                        if ( index1>0 )
                            aN( index1,index1 ) = aN( index1,index1 ) + aAdmittance;
                            if ( index2 > 0 )
                                aN( index1,index2 ) = aN( index1,index2 ) - aAdmittance;
                                aN( index2,index1 ) = aN( index2,index1 ) - aAdmittance;
                            end
                        end
                        if ( index2>0 )
                            aN( index2,index2 ) = aN( index2,index2 ) + aAdmittance;
                        end
                    end % for iV

                    aResult = aN\aB;
                    theY( iSolution,iFreq ) = 1.0/aResult(1);

                end % for iFreq
            end % for iSolution
            
        end % CRComp.Nodal


        function theToComp = Transform( theFromComp,theToId,theCat )
            % theToComp = Transform( theFromComp,theToId,theCat ): Convert the
            % RLC values in FromComp to the equivalent RLC values in a comp
            % of ToId. If no way to convert, return empty. Only one ToId to be
            % passed. Name or integer may be passed in ToId. -- 25Mar2025jcr 
            
            if nargin < 2
                error('Missing the ToId.');
            end % nargin < 2

            if nargin < 3
                error('Missing the Cat.');
            end % nargin < 3

            if ~isnumeric( theToId )
                aToId = theCat.Name2Id( theToId );
                if aToId == 0
                    error('Component name %s not found in the catalog.',theToId);
                end % if aToId
            else
                if numel(theToId) > 1
                    error('ToId must be a scalar.')
                end % numel
                aToId = theToId;
            end % if ~isnumeric

            if isempty(theFromComp) || isempty(theFromComp.name) || isempty(theFromComp.valEL)
                theToComp = [];
                return
            end % if isempty

            aFromId = theCat.Name2Id( theFromComp.name );

            % Get the transformation equations, if they exisit.
            aXfrm = theCat.Transformation( aFromId,aToId );

            if ~isa( aXfrm.eqn,'sym' )
                theToComp = []; % There is no transform.
                return;
            end % if isempty

            theToComp = CRComp( aToId,theCat );
            [numRows,~] = size(theFromComp.valEL);
            for iRow = numRows : -1 : 1
                theToComp.valEL(iRow,:) = double( subs( aXfrm.eqn, aXfrm.fromVar, theFromComp.valEL(iRow,:) ) );
            end % for iRow
            return;
        end % Transform
        
        
        function SetEL( theComp,theEL )
            % CRComp.SetEL( Comp, EL ): Set the element values to be evaluated. Must be the right
            % number of elements (i.e., right number of columns). Can be any number of rows.
            % Only first Comp done. If EL not passed, sets the valEL field to empty, which
            % means CRComp.Eval will ignore the component. jcr18Mar2015
            
            if nargin ~= 2
                theComp.valEL = [];
                return
            end % if nargin
            
            if isempty( theComp )
                return; % Nothing to do.
            end

            if isempty( theEL )
                theComp(1).valEL = [];
                return; % Clear out valEL values.
            end

            if ~isa( theEL,'float' )
                error('EL must be a float.');
            end % if nargin
            
            [ ~,nV ]  = size( theComp(1).symVn ); % Number of RLCs.
            [ ~,nVpassed ] = size( theEL );
            if nV ~= nVpassed
                error('Attempt to set %d element values for component: %s, but expecting %d values.',nVpassed,theComp(1).name,nV);
            end
            
            aELClass = class( theEL(1) );
            aMinEL = 1000000.0 * realmin( aELClass );
            aMaxEL = 1.0e-6 * realmax( aELClass );
            % We do not want any zero valued elements in the nodal net list. Change to minEL.
            % Zero valued resistors and inductors can make the nodal analysis and Y-parameters blow up.
            % Zero valued capacitors can make Z-parameters (inverse of Y-parameters) blow up.
            % For the same reasons, limit max value of all elements.
            aEL = theEL;
            aEL( abs( theEL )<aMinEL ) = aMinEL;
            aEL( abs( theEL )>aMaxEL ) = aMaxEL;
            
            theComp(1).valEL = aEL;
            
        end % CRComp.SetEL
        
        
        function SetSymEL( theComp,theSymEL )
            % CRComp.SetSymEL( Comp, SymEL ): Set the symbolic equations
            % used to synthesize element values from rational polynomial
            % coefficients. SymEL must be the right number of elements (i.e.,
            % right number of columns). Can be any number of rows, one for
            % each valid solution. Only first Comp done. jcr15Feb2025
            
            if nargin ~= 2
                error('Two arguments are required.');
            end % if nargin
            
            if isempty( theComp )
                return; % Nothing to do.
            end

            if isempty( theSymEL )
                theComp(1).symEL = [];
                return; % Clear out symEL values.
            end

            if ~isa( theSymEL,'sym' )
                error('SymEL must be symbolic.');
            end % if nargin
            
            [ ~,nV ]  = size( theComp(1).symVn ); % Number of RLCs.
            [ ~,nVpassed ] = size( theSymEL );
            if nV < nVpassed
                error('Attempt to set %d synthesis equations for component: %s, but cannot set more than %d eqautions.',nVpassed,theComp(1).name,nV);
            end
            
            theComp(1).symEL = theSymEL;
            
        end % CRComp.SetSymEL
        
        
        function theZeros = IsGain( theComp,theSolution )
            % CRComp.Gain( Solution ): Solution is an integer that specifies
            % which (of one or more solutions that could exist) should be
            % evaluated for gain when using the Comp.valEL RLC valus.
            % Default is the first solution. Form a symbolic equation
            % for the real part of the admittance (by multiplying
            % the numerator by the complex conjugate of the denominator and
            % then substitute in the Comp.valEL(Solution,:) values to give
            % a function of frequency only and check for zeros. Only one
            % solution done at a time. If more than one Comp, only
            % first Comp is done. If any real zeros, then the component
            % has a negative real part. Return an array of radian frequencies
            % of where the real part changes sign. In addition, both the
            % numerator and denominator must be the same sign or a zero at
            % zero frequency is returned. If real part is always positive,
            % an empty array is returned. 30Nov202 jcrModified to remove
            % need to reference theCat. jcr18jan2022
            
            syms w s;

            aComp = theComp(1); % If more than one, do only the first one.
            
            if isempty( aComp.valEL ) || isempty( aComp.symY )
                theZeros = [];
                return; % Do nothing if no valEL or symY specified.
            end
            
            aSolution = 1; % Default
            if nargin == 2
                aSolution = theSolution(1);
            end % if nargin
            
            [nRow,~] = size(theComp.valEL);
            if aSolution < 1 || aSolution > nRow
                error('No solution number %d in component name %s.',aSolution,aComp.name);
            end
            
            % Pull out the numerator and denominator, evaluate numerator
            % at jw and denominator at -jw (to get complex conjugate) and
            % multiply. Make sure all terms expanded out, or taking the
            % real part might give bad results.
            [ aNum,aDen ] = numden( aComp.symY ); % Get the numerator and denominator.
            aNumDenConj = expand( subs( aNum, s, 1i*w ) * subs( aDen, s, -1i*w ) );
            aRealPart = subs( aNumDenConj, 1i, 0 );

            % Substitute in the values for the RLCs.
            aRealPart = subs( aRealPart, aComp.symVn, aComp.valEL(aSolution,:) );

            % Evaluate the derivative of the real part with respect to
            % frequency.
            aDerivative = diff( aRealPart, w );
            
            % Make sure the result has w in it, i.e., it is not constant,
            % otherwise vpasolve throws an error.
            if has( aRealPart, w )
                aZeros = double( vpasolve( aRealPart ) );
            elseif double(aRealPart) >= 0.0
                aZeros = [];
            else
                aZeros = 0.0;
            end % if has
            
            % Remove all zeros that have an imaginary part.
            aZerosReal = real( aZeros( abs(aZeros) == abs(real(aZeros)) ) );
            
            % Remove all zeros that are at zero frequency.
            aZerosReal = aZerosReal( abs(aZerosReal) > 1.0e-20 );

            % Remove all zeros that have zero derivative with respect to
            % frequency (i.e., the real part is tangent to the horizontal
            % axis.
            aZerosReal = aZerosReal( abs(subs( aDerivative, w, aZerosReal )) > 1.0e-20 );
            
            % If it still looks passive, i.e., no real non-zero zeros, then
            % it is the same sign everywhere, check to make sure it is positive.
            if isempty( aZerosReal )
                aCoeff = coeffs( aRealPart );
                if ~isempty(aCoeff) && aCoeff(end) < 0.0
                    theZeros = 0; % Real part is negative, not passive.
                else % The real part is positive at very high frequency, 
                    theZeros = [];
                end % if aZerosReal
            else
                theZeros = aZeros; % Return all zeros found. It is not passive.
            end % if is empty
            
        end % CRComp.IsGain
        
        
        function theELValStr = ELVal2Str( theComp,theFormat,theSolution )
            % ELValStr = CRComp.ELVal2Str(Format,Solution): Generates an
            % array using CRComp.ElementValues and returns an array of
            % strings ready to print, including complex element values and
            % units. Print easily using fprint(' %s%s',ELValStr{:} ). Format
            % is the number of digits for each number. If not passed, 4 is
            % assumed. If Solution not passed, assumes you want the first
            % solution. -- jcr28Mar2025.

            if nargin < 2
                aFormat = 4; % Default
            else
                aFormat = theFormat;
            end % if nargin

            if nargin < 3
                aSolution = 1; 
            else
                aSolution = theSolution; 
            end % if nargin

            aELVals = theComp.ElementValues( aSolution );

            if aFormat < 1
                error('Format must be greater than 1.')
            end % if aFormat
   
            nVar = numel(theComp.symVn);
            theELValStr = cell(2,nVar); % Allocate empty cell array.

            for iEL = 1:nVar
                theELValStr{1,iEL} = num2str(aELVals{1,iEL},aFormat);
                theELValStr{2,iEL} = aELVals{2,iEL};
            end % for iEL

        end % CRComp.ELVal2str
        
        
        function theELVals = ElementValues( theComp,theSol )
            % ELVals = CRComp.ElementValues: For a Comp with nVar
            % variables, return a cell array with nVar cols and two rows.
            % The first row is the value of each of the nVar variables
            % and the second row is a string with the unit name,
            % determined by formating a nice number for the RLCs.
            % Only first Comp is done. Use values from solution Sol. Default
            % is Sol = 1. If no solutions exist, return zeros. To print
            % everything out easily if it is all real, use
            % CRComp.ELVal2Str. -- jcr29Apr2023
            % Sets the imaginary part of an element value to zero if it is
            % much less than the real part. Different fprintf needed if any 
            % elements have complex values. Recommend using ELVal2Str to
            % generate format for printing. -- jcr28Mar2025
   
            nVar = numel(theComp.symVn);
            theELVals = cell(2,nVar); % Allocate empty cell array.

            aSol = 1;
            if ( nargin == 2 )
                aSol = theSol;
            end % if nargin

            if ~isempty( theComp.valEL )
                for iEL = 1:nVar

                    if length(theComp.valEL) <= nVar * aSol
                        aValFundamental = theComp.valEL(aSol,iEL); % Units are Ohms, Farads, or Henries.
                    else
                        aValFundamental = 0;
                    end % length

                    if ( aValFundamental == 0 )
                        aVal = 0;
                        aScaleCharacter = ''; % No scale character if zero valued element.
                    elseif ( abs(aValFundamental) < 1e-12 )
                        aVal = aValFundamental * 1e15;
                        aScaleCharacter = 'f'; % Femto
                    elseif ( abs(aValFundamental) < 1e-9 )
                        aVal = aValFundamental * 1e12;
                        aScaleCharacter = 'p'; % pico
                    elseif ( abs(aValFundamental) < 1e-6 )
                        aVal = aValFundamental * 1e9;
                        aScaleCharacter = 'n'; % Nano
                    elseif ( abs(aValFundamental) < 1e-3 )
                        aVal = aValFundamental * 1e6;
                        aScaleCharacter = char(956); % micro, greek letter mu.
                    elseif ( abs(aValFundamental) < 1 )
                        aVal = aValFundamental * 1e3;
                        aScaleCharacter = 'm'; % milli
                    elseif ( abs(aValFundamental) < 1e3 )
                        aVal = aValFundamental;
                        aScaleCharacter = ''; % No scale character.
                    elseif ( abs(aValFundamental) < 1e6 )
                        aVal = aValFundamental * 1e-3;
                        aScaleCharacter = 'k'; % kilo
                    else
                        aVal = aValFundamental * 1e-6;
                        aScaleCharacter = 'M'; % Mega
                    end % if abs

                    % If element value is complex with an imaginary part
                    % much less than the real part, make it real.
                    if abs(aVal) > 1e5*abs(imag(aVal))
                        aVal = real(aVal);
                    end % if abs(aVal)
                    theELVals{1,iEL} = aVal; % Value of the component.

                    aStr = char( theComp.symVn(iEL) );
                    switch aStr(1)
                        case 'R'
                            theELVals{2,iEL} = string( strcat( aScaleCharacter,char(937) ) ); % Greek letter Ohm.
                        case 'L'
                            theELVals{2,iEL} = string( strcat( aScaleCharacter,'H' ) );
                        case 'C'
                            theELVals{2,iEL} = string( strcat( aScaleCharacter,'F' ) );
                    end % switch aStr

                end % for iEL
            else
                theELVals{1,1} = 0;
                theELVals{1,2} = 'No element values.';
            end % if ~isempty

        end % CRComp.ElementValues
        
        
        function Label( theComp,theXY,theSol )
            % CRComp.Label( XY,Sol ): Label a plot with
            % the values of the Comp. Top left corner is at XY. Sol is the
            % solution number. Sol default=all solutions. jcr15Dec2021
            
            if nargin < 2
                error('Missing argument.\n');
            elseif nargin > 3
                error('Too many arguments.')
            end % if nargin
            
            aComp = theComp(1);
            
            [nSol,nEL] = size( aComp.valEL );
            aSolStart = 1; % Default start and stop.
            aSolStop = nSol;
            if nargin==3 && theSol > 0
                aSolStart = theSol;
                aSolStop  = theSol;
            end % if nargin
            if aSolStop > nSol
                error('There are only %d solutions, there is no solution %d.',nSol,aSolStop);
            end % if aSolStop

            % Initialize the aPlotLabel array with info on each element for
            % the first solution.
            aElVals = aComp.ELVal2Str(4,1);
            for iEL = nEL : -1 : 1 % Go through each element in the first solution.
                aPlotLabel{iEL} = strcat( string(theComp.symVn(iEL)),"=",aElVals{1,iEL},aElVals{2,iEL} );
            end % for iEL
                
            for iSol = aSolStart+1 : aSolStop % Go through each remaining solution, if any.
                aElVals = aComp.ELVal2Str(4,iSol);
                for iEL = 1 : nEL % Go through each element.
                    aPlotLabel{iEL} = strcat( aPlotLabel{iEL},", ",aElVals{1,iEL},aElVals{2,iEL} );
                end % iEL
            end % for iSol
            
            if nEL > 0
                text( theXY(1),theXY(2),aPlotLabel,'VerticalAlignment','Top' );
            end % if nEL
            
        end % CRComp.Label
        
        
    end % CRComp methods
end % CRComp

