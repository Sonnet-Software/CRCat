function theLen = FillCat_5N(theCat,theStartIndex)
    % Len = FillCat_5N(Cat,Flag): Fill in catalog for 5 element components XXXI.
    % If Cat.list is zero length, return only number of components. 01Apr2015
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    aLen = length( theCat.list );
    index = theStartIndex;

    syms Ra Rb Rc Rd La Lb Lc Ld Ca Cb Cc Cd  %Symbolic variables for RLC components.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  FIVE ELEMENT MODELS -- XXXII
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an R in series with a parallel RL):  XXXII-1.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-1';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an R in series with a parallel RC):  XXXII-2.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-2';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an R in series with a parallel LC):  XXXII-3.
        theCat.list(index).symV =          [ Ra  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-3';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an L in series with a parallel RL):  XXXII-4.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-4';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an L in series with a parallel RC):  XXXII-5.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-5';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an L in series with a parallel LC):  XXXII-6.
        theCat.list(index).symV =          [ Ra  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-6';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an C in series with a parallel LC):  XXXII-7.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-7';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an C in series with a parallel LC):  XXXII-8.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-8';
    end

    index = index + 1;
    if aLen  % An R in series with (an R in parallel with an C in series with a parallel LC):  XXXII-9.
        theCat.list(index).symV =          [ Ra  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-9';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an R in series with a parallel RL):  XXXII-10.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-10';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an R in series with a parallel RC):  XXXII-11.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-11';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an R in series with a parallel LC):  XXXII-12.
        theCat.list(index).symV =          [ Ra  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-12';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an L in series with a parallel RL):  XXXII-13.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-13';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an L in series with a parallel RC):  XXXII-14.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-14';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an L in series with a parallel LC):  XXXII-15.
        theCat.list(index).symV =          [ Ra  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-15';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an C in series with a parallel LC):  XXXII-16.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-16';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an C in series with a parallel LC):  XXXII-17.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-17';
    end

    index = index + 1;
    if aLen  % An R in series with (an L in parallel with an C in series with a parallel LC):  XXXII-18.
        theCat.list(index).symV =          [ Ra  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-18';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an R in series with a parallel RL):  XXXII-19.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-19';
    end

    index = index + 1;
    if aLen  % An R in series with (an c in parallel with an R in series with a parallel RC):  XXXII-20.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-20';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an R in series with a parallel LC):  XXXII-21.
        theCat.list(index).symV =          [ Ra  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-21';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an L in series with a parallel RL):  XXXII-22.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-22';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an L in series with a parallel RC):  XXXII-23.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-23';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an C in series with a parallel LC):  XXXII-24.
        theCat.list(index).symV =          [ Ra  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-24';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an C in series with a parallel LC):  XXXII-25.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-25';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an C in series with a parallel LC):  XXXII-26.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-26';
    end

    index = index + 1;
    if aLen  % An R in series with (an C in parallel with an C in series with a parallel LC):  XXXII-27.
        theCat.list(index).symV =          [ Ra  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-27';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an R in series with a parallel RL):  XXXII-28.
        theCat.list(index).symV =          [ La  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-28';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an R in series with a parallel RC):  XXXII-29.
        theCat.list(index).symV =          [ La  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-29';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an R in series with a parallel LC):  XXXII-30.
        theCat.list(index).symV =          [ La  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-30';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an L in series with a parallel RL):  XXXII-31.
        theCat.list(index).symV =          [ La  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-31';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an L in series with a parallel RC):  XXXII-32.
        theCat.list(index).symV =          [ La  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-32';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an L in series with a parallel LC):  XXXII-33.
        theCat.list(index).symV =          [ La  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-33';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an C in series with a parallel LC):  XXXII-34.
        theCat.list(index).symV =          [ La  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-34';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an C in series with a parallel LC):  XXXII-35.
        theCat.list(index).symV =          [ La  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-35';
    end

    index = index + 1;
    if aLen  % An L in series with (an R in parallel with an C in series with a parallel LC):  XXXII-36.
        theCat.list(index).symV =          [ La  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-36';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel RL):  XXXII-37.
        theCat.list(index).symV =          [ La  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-37';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel RC):  XXXII-38.
        theCat.list(index).symV =          [ La  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-38';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an R in series with a parallel LC):  XXXII-39.
        theCat.list(index).symV =          [ La  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-39';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an L in series with a parallel RL):  XXXII-40.
        theCat.list(index).symV =          [ La  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-40';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an L in series with a parallel RC):  XXXII-41.
        theCat.list(index).symV =          [ La  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-41';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an L in series with a parallel LC):  XXXII-42.
        theCat.list(index).symV =          [ La  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-42';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an C in series with a parallel LC):  XXXII-43.
        theCat.list(index).symV =          [ La  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-43';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an C in series with a parallel LC):  XXXII-44.
        theCat.list(index).symV =          [ La  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-44';
    end

    index = index + 1;
    if aLen  % An L in series with (an L in parallel with an C in series with a parallel LC):  XXXII-45.
        theCat.list(index).symV =          [ La  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-45';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an R in series with a parallel RL):  XXXII-46.
        theCat.list(index).symV =          [ La  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-46';
    end

    index = index + 1;
    if aLen  % An L in series with (an c in parallel with an R in series with a parallel RC):  XXXII-47.
        theCat.list(index).symV =          [ La  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-47';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an R in series with a parallel LC):  XXXII-48.
        theCat.list(index).symV =          [ La  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-48';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an L in series with a parallel RL):  XXXII-49.
        theCat.list(index).symV =          [ La  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-49';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an L in series with a parallel RC):  XXXII-50.
        theCat.list(index).symV =          [ La  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-50';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an C in series with a parallel LC):  XXXII-51.
        theCat.list(index).symV =          [ La  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-51';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an C in series with a parallel LC):  XXXII-52.
        theCat.list(index).symV =          [ La  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-52';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an C in series with a parallel LC):  XXXII-53.
        theCat.list(index).symV =          [ La  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-53';
    end

    index = index + 1;
    if aLen  % An L in series with (an C in parallel with an C in series with a parallel LC):  XXXII-54.
        theCat.list(index).symV =          [ La  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-54';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an R in series with a parallel RL):  XXXII-55.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-55';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an R in series with a parallel RC):  XXXII-56.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-56';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an R in series with a parallel LC):  XXXII-57.
        theCat.list(index).symV =          [ Ca  Rb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-57';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an L in series with a parallel RL):  XXXII-58.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-58';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an L in series with a parallel RC):  XXXII-59.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-59';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an L in series with a parallel LC):  XXXII-60.
        theCat.list(index).symV =          [ Ca  Rb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-60';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an C in series with a parallel LC):  XXXII-61.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-61';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an C in series with a parallel LC):  XXXII-62.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-62';
    end

    index = index + 1;
    if aLen  % An C in series with (an R in parallel with an C in series with a parallel LC):  XXXII-63.
        theCat.list(index).symV =          [ Ca  Rb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-63';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an R in series with a parallel RL):  XXXII-64.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-64';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an R in series with a parallel RC):  XXXII-65.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-65';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an R in series with a parallel LC):  XXXII-66.
        theCat.list(index).symV =          [ Ca  Lb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).testEL = [ 1 2 3 4 5 ]; % The default starting testEL does not provide a good result.
        theCat.list(index).name =  'XXXII-66';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an L in series with a parallel RL):  XXXII-67.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-67';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an L in series with a parallel RC):  XXXII-68.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-68';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an L in series with a parallel LC):  XXXII-69.
        theCat.list(index).symV =          [ Ca  Lb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-69';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an C in series with a parallel LC):  XXXII-70.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-70';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an C in series with a parallel LC):  XXXII-71.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-71';
    end

    index = index + 1;
    if aLen  % An C in series with (an L in parallel with an C in series with a parallel LC):  XXXII-72.
        theCat.list(index).symV =          [ Ca  Lb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-72';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an R in series with a parallel RL):  XXXII-73.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-73';
    end

    index = index + 1;
    if aLen  % An C in series with (an c in parallel with an R in series with a parallel RC):  XXXII-74.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-74';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an R in series with a parallel LC):  XXXII-75.
        theCat.list(index).symV =          [ Ca  Cb  Rc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-75';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an L in series with a parallel RL):  XXXII-76.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-76';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an L in series with a parallel RC):  XXXII-77.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-77';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an C in series with a parallel LC):  XXXII-78.
        theCat.list(index).symV =          [ Ca  Cb  Lc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-78';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an C in series with a parallel LC):  XXXII-79.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Rd  Ld ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-79';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an C in series with a parallel LC):  XXXII-80.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Rd  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-80';
    end

    index = index + 1;
    if aLen  % An C in series with (an C in parallel with an C in series with a parallel LC):  XXXII-81.
        theCat.list(index).symV =          [ Ca  Cb  Cc  Ld  Cd ];
        theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 3 0 ] );
        theCat.list(index).name =  'XXXII-81';
    end

    theLen = index;

end % FillCat_5N
