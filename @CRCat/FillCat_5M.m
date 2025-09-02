function theLen = FillCat_5M(theCat,theStartIndex)
    % Len = FillCat_5M(Cat,Flag): Fill in catalog for 5 element components XXXII.
    % If Cat.list is zero length, return only number of components. 02Apr2015
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    aLen = length( theCat.list );
    index = theStartIndex;

    syms Ra Rb Rc Rd La Lb Lc Ld Ca Cb Cc Cd  %Symbolic variables for RLC components.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  FIVE ELEMENT MODELS -- XXXI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an R in parallel with a series RL):  XXXI-1.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-1';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an R in parallel with a series RC):  XXXI-2.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-2';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an R in parallel with a series LC):  XXXI-3.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-3';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an L in parallel with a series RL):  XXXI-4.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-4';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an L in parallel with a series RC):  XXXI-5.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-5';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an L in parallel with a series LC):  XXXI-6.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-6';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an C in parallel with a series RL):  XXXI-7.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-7';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an C in parallel with a series RC):  XXXI-8.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-8';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an R in series with an C in parallel with a series LC):  XXXI-9.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-9';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an R in parallel with a series RL):  XXXI-10.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-10';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an R in parallel with a series RC):  XXXI-11.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-11';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an R in parallel with a series LC):  XXXI-12.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-12';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an L in parallel with a series RL):  XXXI-13.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-13';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an L in parallel with a series RC):  XXXI-14.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-14';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an L in parallel with a series LC):  XXXI-15.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-15';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an C in parallel with a series RL):  XXXI-16.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-16';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an C in parallel with a series RC):  XXXI-17.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-17';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an L in series with an C in parallel with a series LC):  XXXI-18.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-18';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an R in parallel with a series RL):  XXXI-19.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-19';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an R in parallel with a series RC):  XXXI-20.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-20';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an R in parallel with a series LC):  XXXI-21.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-21';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an L in parallel with a series RL):  XXXI-22.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-22';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an L in parallel with a series RC):  XXXI-23.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-23';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an L in parallel with a series LC):  XXXI-24.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-24';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an C in parallel with a series RL):  XXXI-25.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-25';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an C in parallel with a series RC):  XXXI-26.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-26';
    end

    index = index + 1;
    if aLen  % An R in parallel with (an C in series with an C in parallel with a series LC):  XXXI-27.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-27';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an R in parallel with a series RL):  XXXI-28.
        theCat.list(index).symV =          [ La  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-28';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an R in parallel with a series RC):  XXXI-29.
        theCat.list(index).symV =          [ La  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-29';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an R in parallel with a series LC):  XXXI-30.
        theCat.list(index).symV =          [ La  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-30';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an L in parallel with a series RL):  XXXI-31.
        theCat.list(index).symV =          [ La  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-31';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an L in parallel with a series RC):  XXXI-32.
        theCat.list(index).symV =          [ La  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-32';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an L in parallel with a series LC):  XXXI-33.
        theCat.list(index).symV =          [ La  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-33';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an C in parallel with a series RL):  XXXI-34.
        theCat.list(index).symV =          [ La  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-34';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an C in parallel with a series RC):  XXXI-35.
        theCat.list(index).symV =          [ La  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-35';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an R in series with an C in parallel with a series LC):  XXXI-36.
        theCat.list(index).symV =          [ La  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-36';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an R in parallel with a series RL):  XXXI-37.
        theCat.list(index).symV =          [ La  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-37';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an R in parallel with a series RC):  XXXI-38.
        theCat.list(index).symV =          [ La  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-38';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an R in parallel with a series LC):  XXXI-39.
        theCat.list(index).symV =          [ La  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-39';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an L in parallel with a series RL):  XXXI-40.
        theCat.list(index).symV =          [ La  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-40';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an L in parallel with a series RC):  XXXI-41.
        theCat.list(index).symV =          [ La  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-41';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an L in parallel with a series LC):  XXXI-42.
        theCat.list(index).symV =          [ La  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-42';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an C in parallel with a series RL):  XXXI-43.
        theCat.list(index).symV =          [ La  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-43';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an C in parallel with a series RC):  XXXI-44.
        theCat.list(index).symV =          [ La  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-44';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an L in series with an C in parallel with a series LC):  XXXI-45.
        theCat.list(index).symV =          [ La  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-45';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an R in parallel with a series RL):  XXXI-46.
        theCat.list(index).symV =          [ La  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-46';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an R in parallel with a series RC):  XXXI-47.
        theCat.list(index).symV =          [ La  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-47';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an R in parallel with a series LC):  XXXI-48.
        theCat.list(index).symV =          [ La  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-48';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an L in parallel with a series RL):  XXXI-49.
        theCat.list(index).symV =          [ La  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).testEL = [ 1 0.001 3 40 5 ];
        theCat.list(index).name =  'XXXI-49';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an L in parallel with a series RC):  XXXI-50.
        theCat.list(index).symV =          [ La  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-50';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an L in parallel with a series LC):  XXXI-51.
        theCat.list(index).symV =          [ La  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-51';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an C in parallel with a series RL):  XXXI-52.
        theCat.list(index).symV =          [ La  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-52';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an C in parallel with a series RC):  XXXI-53.
        theCat.list(index).symV =          [ La  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-53';
    end

    index = index + 1;
    if aLen  % An L in parallel with (an C in series with an C in parallel with a series LC):  XXXI-54.
        theCat.list(index).symV =          [ La  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-54';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an R in parallel with a series RL):  XXXI-55.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-55';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an R in parallel with a series RC):  XXXI-56.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-56';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an R in parallel with a series LC):  XXXI-57.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-57';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an L in parallel with a series RL):  XXXI-58.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-58';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an L in parallel with a series RC):  XXXI-59.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-59';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an L in parallel with a series LC):  XXXI-60.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-60';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an C in parallel with a series RL):  XXXI-61.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-61';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an C in parallel with a series RC):  XXXI-62.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-62';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an R in series with an C in parallel with a series LC):  XXXI-63.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-63';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an R in parallel with a series RL):  XXXI-64.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-64';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an R in parallel with a series RC):  XXXI-65.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-65';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an R in parallel with a series LC):  XXXI-66.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-66';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an L in parallel with a series RL):  XXXI-67.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-67';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an L in parallel with a series RC):  XXXI-68.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-68';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an L in parallel with a series LC):  XXXI-69.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-69';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an C in parallel with a series RL):  XXXI-70.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-70';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an C in parallel with a series RC):  XXXI-71.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-71';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an L in series with an C in parallel with a series LC):  XXXI-72.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-72';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an R in parallel with a series RL):  XXXI-73.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-73';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an R in parallel with a series RC):  XXXI-74.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-74';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an R in parallel with a series LC):  XXXI-75.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-75';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an L in parallel with a series RL):  XXXI-76.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-76';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an L in parallel with a series RC):  XXXI-77.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-77';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an L in parallel with a series LC):  XXXI-78.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-78';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an C in parallel with a series RL):  XXXI-79.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-79';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an C in parallel with a series RC):  XXXI-80.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-80';
    end

    index = index + 1;
    if aLen  % An C in parallel with (an C in series with an C in parallel with a series LC):  XXXI-81.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 3 3 0 ] );
        theCat.list(index).name =  'XXXI-81';
    end

    theLen = index;

end % FillCat_5M

