function theLen = FillCat_5P(theCat,theStartIndex)
    % Len = FillCat_5P(Cat,Flag): Fill in catalog for 5 element components XXXIII.
    % If Cat.list is zero length, return only number of components. 22Apr2015
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    aLen = length( theCat.list );
    index = theStartIndex;

    % Symbolic variable 'Re' is skipped below. At least in MATLAB
    % 2024a, when we save the base catalog, it changes 'Re' to 'real' and
    % that really messes things up.
    syms Ra Rb Rc Rd Rf La Lb Lc Ld Le Ca Cb Cc Cd Ce  % Symbolic variables for RLC components.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  FIVE ELEMENT MODELS -- XXXIII
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    index = index + 1;
    if aLen  % An RRRRR Wheatstone bridge: XXXIII-1.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-1';
    end
    
    index = index + 1;
    if aLen  % An RRRRL Wheatstone bridge: XXXIII-2.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-2';
    end
    
    index = index + 1;
    if aLen  % An RRRRC Wheatstone bridge: XXXIII-3.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-3';
    end

    index = index + 1;
    if aLen  % An RRRLL Wheatstone bridge: XXXIII-4.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-4';
    end
    
    index = index + 1;
    if aLen  % An RRRLC Wheatstone bridge: XXXIII-5.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-5';
    end
    
    index = index + 1;
    if aLen  % An RRRCC Wheatstone bridge: XXXIII-6.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-6';
    end

    index = index + 1;
    if aLen  % An RRLRR Wheatstone bridge: XXXIII-7.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-7';
    end
    
    index = index + 1;
    if aLen  % An RRLRL Wheatstone bridge: XXXIII-8.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-8';
    end
    
    index = index + 1;
    if aLen  % An RRLRC Wheatstone bridge: XXXIII-9.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).testEL = [ 10 20 1 400 0.005 ];
        theCat.list(index).name = 'XXXIII-9';
    end

    index = index + 1;
    if aLen  % An RRLLL Wheatstone bridge: XXXIII-10.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-10';
    end
    
    index = index + 1;
    if aLen  % An RRLLC Wheatstone bridge: XXXIII-11.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-11';
    end
    
    index = index + 1;
    if aLen  % An RRLCC Wheatstone bridge: XXXIII-12.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-12';
    end

    index = index + 1;
    if aLen  % An RRCRR Wheatstone bridge: XXXIII-13.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-13';
    end
    
    index = index + 1;
    if aLen  % An RRCRL Wheatstone bridge: XXXIII-14.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-14';
    end
    
    index = index + 1;
    if aLen  % An RRCRC Wheatstone bridge: XXXIII-15.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-15';
    end
    
    index = index + 1;
    if aLen  % An RRCLL Wheatstone bridge: XXXIII-16.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-16';
    end
    
    index = index + 1;
    if aLen  % An RRCLC Wheatstone bridge: XXXIII-17.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-17';
    end
    
    index = index + 1;
    if aLen  % An RRCCC Wheatstone bridge: XXXIII-18.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-18';
    end
    
    index = index + 1;
    if aLen  % An RLRRL Wheatstone bridge: XXXIII-19.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-19';
    end
    
    index = index + 1;
    if aLen  % An RLRRC Wheatstone bridge: XXXIII-20.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-20';
    end
    
    index = index + 1;
    if aLen  % An RLRLR Wheatstone bridge: XXXIII-21.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Ld  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-21';
    end
    
    index = index + 1;
    if aLen  % An RLRLL Wheatstone bridge: XXXIII-22.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-22';
    end

    index = index + 1;
    if aLen  % An RLRLC Wheatstone bridge: XXXIII-23.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-23';
    end

    index = index + 1;
    if aLen  % An RLRCR Wheatstone bridge: XXXIII-24.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-24';
    end

    index = index + 1;
    if aLen  % An RLRCL Wheatstone bridge: XXXIII-25.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-25';
    end

    index = index + 1;
    if aLen  % An RLRCC Wheatstone bridge: XXXIII-26.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-26';
    end

    index = index + 1;
    if aLen  % An RLLRL Wheatstone bridge: XXXIII-27.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-27';
    end

    index = index + 1;
    if aLen  % An RLLRC Wheatstone bridge: XXXIII-28.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-28';
    end

    index = index + 1;
    if aLen  % An RLLLR Wheatstone bridge: XXXIII-29.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Ld  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-29';
    end

    index = index + 1;
    if aLen  % An RLLLL Wheatstone bridge: XXXIII-30.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-30';
    end

    index = index + 1;
    if aLen  % An RLLLC Wheatstone bridge: XXXIII-31.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-31';
    end

    index = index + 1;
    if aLen  % An RLLCR Wheatstone bridge: XXXIII-32.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-32';
    end

    index = index + 1;
    if aLen  % An RLLCL Wheatstone bridge: XXXIII-33.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-33';
    end

    index = index + 1;
    if aLen  % An RLLCC Wheatstone bridge: XXXIII-34.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-34';
    end

    index = index + 1;
    if aLen  % An RLCRL Wheatstone bridge: XXXIII-35.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-35';
    end

    index = index + 1;
    if aLen  % An RLCRC Wheatstone bridge: XXXIII-36.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-36';
    end

    index = index + 1;
    if aLen  % An RLCLR Wheatstone bridge: XXXIII-37.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Ld  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-37';
    end

    index = index + 1;
    if aLen  % An RLCLL Wheatstone bridge: XXXIII-38.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-38';
    end

    index = index + 1;
    if aLen  % An RLCLC Wheatstone bridge: XXXIII-39.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-39';
    end

    index = index + 1;
    if aLen  % An RLCCR Wheatstone bridge: XXXIII-40.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-40';
    end

    index = index + 1;
    if aLen  % An RLCCL Wheatstone bridge: XXXIII-41.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-41';
    end

    index = index + 1;
    if aLen  % An RLCCC Wheatstone bridge: XXXIII-42.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-42';
    end

    index = index + 1;
    if aLen  % An RCRRC Wheatstone bridge: XXXIII-43.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-43';
    end

    index = index + 1;
    if aLen  % An RCRLL Wheatstone bridge: XXXIII-44.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-44';
    end

    index = index + 1;
    if aLen  % An RCRLC Wheatstone bridge: XXXIII-45.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-45';
    end

    index = index + 1;
    if aLen  % An RCRCR Wheatstone bridge: XXXIII-46.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-46';
    end

    index = index + 1;
    if aLen  % An RCRCL Wheatstone bridge: XXXIII-47.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-47';
    end

    index = index + 1;
    if aLen  % An RCRCC Wheatstone bridge: XXXIII-48.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-48';
    end

    index = index + 1;
    if aLen  % An RCLRC Wheatstone bridge: XXXIII-49.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-49';
    end

    index = index + 1;
    if aLen  % An RCLLL Wheatstone bridge: XXXIII-50.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-50';
    end

    index = index + 1;
    if aLen  % An RCLLC Wheatstone bridge: XXXIII-51.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-51';
    end

    index = index + 1;
    if aLen  % An RCLCR Wheatstone bridge: XXXIII-52.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-52';
    end

    index = index + 1;
    if aLen  % An RCLCL Wheatstone bridge: XXXIII-53.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-53';
    end

    index = index + 1;
    if aLen  % An RCLCC Wheatstone bridge: XXXIII-54.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-54';
    end

    index = index + 1;
    if aLen  % An RCCRC Wheatstone bridge: XXXIII-55.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Rd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-55';
    end

    index = index + 1;
    if aLen  % An RCCLL Wheatstone bridge: XXXIII-56.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-56';
    end

    index = index + 1;
    if aLen  % An RCCLC Wheatstone bridge: XXXIII-57.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-57';
    end

    index = index + 1;
    if aLen  % An RCCCR Wheatstone bridge: XXXIII-58.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Cd  Rf ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-58';
    end

    index = index + 1;
    if aLen  % An RCCCL Wheatstone bridge: XXXIII-59.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-59';
    end

    index = index + 1;
    if aLen  % An RCCCCC Wheatstone bridge: XXXIII-60.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-60';
    end

    index = index + 1;
    if aLen  % An LLRLL Wheatstone bridge: XXXIII-61.
        theCat.list(index).symV =          [ La  Lb  Rc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-61';
    end

    index = index + 1;
    if aLen  % An LLRLC Wheatstone bridge: XXXIII-62.
        theCat.list(index).symV =          [ La  Lb  Rc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-62';
    end

    index = index + 1;
    if aLen  % An LLRCC Wheatstone bridge: XXXIII-63.
        theCat.list(index).symV =          [ La  Lb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-63';
    end
    
    index = index + 1;
    if aLen  % An LLLLL Wheatstone bridge: XXXIII-64.
        theCat.list(index).symV =          [ La  Lb  Lc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-64';
    end
    
    index = index + 1;
    if aLen  % An LLLLC Wheatstone bridge: XXXIII-65.
        theCat.list(index).symV =          [ La  Lb  Lc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-65';
    end
    
    index = index + 1;
    if aLen  % An LLLCC Wheatstone bridge: XXXIII-66.
        theCat.list(index).symV =          [ La  Lb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-66';
    end
    
    index = index + 1;
    if aLen  % An LLCLL Wheatstone bridge: XXXIII-67.
        theCat.list(index).symV =          [ La  Lb  Cc  Ld  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-67';
    end
    
    index = index + 1;
    if aLen  % An LLCLC Wheatstone bridge: XXXIII-68.
        theCat.list(index).symV =          [ La  Lb  Cc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-68';
    end
    
    index = index + 1;
    if aLen  % An LLCCC Wheatstone bridge: XXXIII-69.
        theCat.list(index).symV =          [ La  Lb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-69';
    end
    
    index = index + 1;
    if aLen  % An LCRLC Wheatstone bridge: XXXIII-70.
        theCat.list(index).symV =          [ La  Cb  Rc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-70';
    end
    
    index = index + 1;
    if aLen  % An LCRCL Wheatstone bridge: XXXIII-71.
        theCat.list(index).symV =          [ La  Cb  Rc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-71';
    end
    
    index = index + 1;
    if aLen  % An LCRCC Wheatstone bridge: XXXIII-72.
        theCat.list(index).symV =          [ La  Cb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-72';
    end
    
    index = index + 1;
    if aLen  % An LCLLC Wheatstone bridge: XXXIII-73.
        theCat.list(index).symV =          [ La  Cb  Lc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-73';
    end
    
    index = index + 1;
    if aLen  % An LCLCL Wheatstone bridge: XXXIII-74.
        theCat.list(index).symV =          [ La  Cb  Lc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-74';
    end
    
    index = index + 1;
    if aLen  % An LCCLC Wheatstone bridge: XXXIII-75.
        theCat.list(index).symV =          [ La  Cb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-75';
    end
    
    index = index + 1;
    if aLen  % An LCCLC Wheatstone bridge: XXXIII-76.
        theCat.list(index).symV =          [ La  Cb  Cc  Ld  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-76';
    end
    
    index = index + 1;
    if aLen  % An LCCCL Wheatstone bridge: XXXIII-77.
        theCat.list(index).symV =          [ La  Cb  Cc  Cd  Le ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-77';
    end
    
    index = index + 1;
    if aLen  % An LCCCC Wheatstone bridge: XXXIII-78.
        theCat.list(index).symV =          [ La  Cb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-78';
    end
    
    index = index + 1;
    if aLen  % An CCRCC Wheatstone bridge: XXXIII-79.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-79';
    end
    
    index = index + 1;
    if aLen  % An CCLCC Wheatstone bridge: XXXIII-80.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-80';
    end
    
    index = index + 1;
    if aLen  % An CCCCC Wheatstone bridge: XXXIII-81.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Cd  Ce ];
        theCat.list(index).nodes = uint32( [ 1 2 1 3 2 3 2 0 3 0 ] );
        theCat.list(index).name = 'XXXIII-81';
    end

    theLen = index;

end % FillCat_5P

