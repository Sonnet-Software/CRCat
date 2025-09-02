% Add components here to be included in the custom catalog.
% aCustomCat = CRCat('custom') creates, error checks and returns a catalog with the 
% custom components. If it error checks OK, the custom catalog is saved. Then
% run aCompleteCat = CRCat, with no arguments, and CRCat loads the default
% catalog and appends the custom catalog into aCompleteCat. Several example components 
% are implimented below. To enable a component, select the appropriate range of
% lines and press CTRL-T to un-comment the code. CTRL-R will re-comment the
% code. Then do CRCat('custom') to create the new custom catalog. 08Apr2015jcr
% CRCat and associated software is licensed under the MIT open software
% license. See the file LICENSE.TXT in the main directory.

function theLen = FillCat_Custom(theCat,theStartIndex)
    % Len = FillCat_Custom(Cat,StartIndex): Fill in catalog for all custom components.
    % If Cat.list is zero length, return only number of components that are set to be
    % loaded into theCat so that you can allocate theCat.list. 21Apr2015jcr

    aLen = length( theCat.list );
    index = theStartIndex;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  CUSTOM MODELS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     index = index + 1;
%     if aLen % Set up series LC.
%         
%         % Enter the variables (from the above syms line) that will be used
%         % in your circuit. If you declare new variables (using syms) be
%         % sure to make all resistors begin with R, inductors begin with L
%         % and capacitors begin with C. Do not declare a variable 'Re' as
%         % might treat it as a funciton that takes the real part of a
%         % number.
%         syms L C % Declare needed symbolic variables.
%         theCat.list(index).symV = [ L C ];
%         
%         % Set up a nodal net list. We are defining a component, which is a
%         % a combination of RLCs. We calculate the admittance between two
%         % terminals. The one terminal is always node 1. The other terminal
%         % is always node 0, also called ground. Note that above we set
%         % symV = [ L C ]. Thus the first element of this component is an
%         % inductor. We connect it between node 1 and node 2. Note the first and
%         % second numbers below. Node 2 is an internal node. You can pick any
%         % number other than 0 or 1 for internal nodes. The second element
%         % in our component (as listed in symV) is C, the capacitor. Since it
%         % is in series with the inductor, we connect one terminal of the
%         % capacitor to node 2 and the second terminal to node 0. Note the
%         % third and fourth numbers below. This completes the nodal
%         % description of our circuit.
%         theCat.list(index).nodes = uint32( [ 1 2 2 0 ] );
%         
%         % Pick a unique name for your component. CRCat checks to make sure
%         % all names in the complete catalog are unique. If not, you will get
%         % an error and the catalog will not be generated.
%         theCat.list(index).name = 'SerLC-Demo';
%     end
%            
%     index = index + 1;
%     if aLen  % L in series with (a C in parallel with a series RLC): XIX-6.
%         
%         % List the variables we are going to use in symV. Note that the
%         % nodal net list immediately follows and the variables are spaced
%         % so that each variable starts directly above the first of the two
%         % node numbers that connect that RLC into the component. Makes it
%         % easier to check. La connects to nodes 1 and 2. Cb to 2 and 0, etc.
%         syms La  Cb  Rc  Lc  Cc  % Declare needed symbolic variables.
%         theCat.list(index).symV =          [ La  Cb  Rc  Lc  Cc ];
%         theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
%         theCat.list(index).name = 'XIX-6_Demo';
%     end
%
%     More example custom circuits...

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel LC):  XXXII-39.
        syms La Lb Rc Ld Cd
        theCat.list(index).symV =          [ La  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-39_original';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel LC):  XXXII-39.
        % This example is identical to the above example except that we
        % have removed Cd from the symV array. This means that CRCat will
        % not solve for the Cd synthesis equations, but, because Cdd is in
        % the symVn array, Cdd will be included in the analysis of the
        % network. This is useful if MATLAB is unable to find synthesis
        % equations for all the elements of a network because it might be
        % able to find synthesis equations for some of the elements leaving
        % the remaining element values to be specified by the user when
        % snythesis results are needed. In this case, Cdd must be specified
        % by the user in order to perform a complete synthesis.
        syms La Lb Rc Ld Cdd
        theCat.list(index).symV =          [ La  Lb  Rc  Ld ];
        theCat.list(index).symVn =         [ La  Lb  Rc  Ld  Cdd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-39_FixedCdd';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel LC):  XXXII-39.
        syms La Lb Rc Ldd Cdd
        theCat.list(index).symV =          [ La  Lb  Rc  ];
        theCat.list(index).symVn =         [ La  Lb  Rc  Ldd  Cdd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0  3 0 ] );
        theCat.list(index).name =  'XXXII-39_FixedLdCdd';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel LC):  XXXII-39.
        syms La Lb Rcc Ldd Cdd
        theCat.list(index).symV =          [ La  Lb  ];
        theCat.list(index).symVn =         [ La  Lb  Rcc  Ldd  Cdd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3  3 0  3 0 ] );
        theCat.list(index).name =  'XXXII-39_FixedRcLdCdd';
    end

    index = index + 1;
    if aLen % Set up series RLC.
        syms R La Lb C
        theCat.list(index).symV = [La Lb R];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
        theCat.list(index).name = 'R-LC-Original';
    end
     
    index = index + 1;
    if aLen % Set up series RLC with the C fixed.
        syms R La Lb C
        theCat.list(index).symV  = [La Lb];
        theCat.list(index).symVn = [La Lb R];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
        theCat.list(index).name = 'R-LC-Cfixed';
    end
    
    index = index + 1;
    if aLen 
        syms Ra Ca Cb Ld Rd
        theCat.list(index).symV =  [ Ra Ca Cb Ld Rd ];
        theCat.list(index).symVn = [ Ra  Ca  Cb  Ld  Rd ];
        theCat.list(index).nodes = uint32( [ 2 0 2 0 1 2 1 3 3 0 ] );
        theCat.list(index).name = 'FrontHalfModel';
    end
    
    theLen = index;
    
end % FillCat_Custom

