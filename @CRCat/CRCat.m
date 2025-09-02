 classdef CRCat < handle
    % CRCat: Catalog of RLC networks that use Complex Rational (CR) represenations.
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    
    properties (SetAccess = protected)
        fUnit;
        fMult;
        resUnit;
        indUnit;
        capUnit;
        list;  % Info on each network.
    end
    
    methods ( Access = private ) % Function signatures for external class files.
        theLen = FillCat_Custom(theCat,theStartIndex) % User specified networks.
        theLen = FillCat_5M(theCat,theStartIndex) % XXXI
        theLen = FillCat_5N(theCat,theStartIndex) % XXXII
        theLen = FillCat_5P(theCat,theStartIndex) % XXXIII
    end % methods
    
    methods
        function theCat = CRCat( theLoadStr,theVerbose )
            % Cat = CRCat(LoadStr,Verbose): Construct a CRCat handle object.
            % 
            % LoadStr = 'default', or with no options, load pre-calcualted
            % default catalog (includes both base and custom catalogs). If the
            % time of creation of either the base or custom catalogs is later
            % than the current default catalog, then a new updated default
            % catalog is generated, saved and returned.
            %
            % LoadStr = 'default_nock', load default catalog with no checks
            % for being up-to-date.
            %
            % LoadStr = 'custom', load pre-calcualted custom catalog. Update and
            % save it if data for any Id in FillCat_Custom.m has been changed.
            %
            % LoadStr = 'custom_nock', load custom catalog with no checks
            % for being up-to-date.
            %
            % LoadStr = 'base', load pre-calcualted base catalog. The data
            % in the base catalog is set up by code in CRCat.m, and in FillCat_5M,
            % _5N, _5P. Recalculate the ENTIRE base catalog if any of the data for
            % any Id has been changed. NOTE WELL: Updating the base catalog will take
            % a VERY LONG TIME. Highly recomended that you do not do that.
            %
            % LoadStr = 'base_nock', load base catalog with no checks
            % for being up-to-date.
            %
            % LoadStr = 'empty', returns with no data in Cat.list.
            %
            % If you have other catalogs you wish to use, load them in and
            % execute Cat.Save('default'), Cat.Save('base'), or Cat.Save('custom')
            % in order to use the new result. Be sure to save a backup of
            % the original catalog if you might want to use it in the future,
            % e.g., aCat = CRCat('default'); save('DefaultBackupCatalog','aCat')
            %
            % Units are always initialized to 'GHz' but can be changed at any
            % time with Cat.Units. Changing frequency units also changes the
            % units for R, L, and C so that they are consistent with the
            % frequency units.
            %
            % Verbose = 0, proceed mostly silently, load the LoadStr catalog,
            % and update if needed. Set to any non-zero value or if not
            % specified, print on-going status. Set to negative value,
            % also limit the catalog data update to no more than -Verbose
            % Ids. This is to allow the Cat update to save results and lets the user
            % restart an update as desired and do another batch of Id data part way
            % through...this is needed because a full update of the base catalog
            % can take several days.
            % 
            % CRCat.list array, where all data for each network Id is stored is defined
            % in function Init. 05Apr2015jcr 04Apr2017jcr jcr24Jan2025
            %
            % During update, Cat is first loaded with all basic defining information
            % provided in the code below, such as name, node list, RLC variable
            % names. Next, all derived data is evaluated and loaded into Cat.list
            % (see Cat.Init for definitions) EXCEPT the info on equivalent,
            % degenerate and regenerate components. Once that is complete,
            % it makes another pass through and fills in the information on
            % component relationships, including deriving transformation
            % equations if possible. -- jcr19Jan2025
            
            if nargin == 0
                aLoadStr = 'default';
                aVerbose = 1;
            elseif ~strcmp(theLoadStr,'base') && ~strcmp(theLoadStr,'custom') && ...
                   ~strcmp(theLoadStr,'default') && ~strcmp(theLoadStr,'empty') && ...
                   ~strcmp(theLoadStr,'base_nock') && ~strcmp(theLoadStr,'custom_nock') && ...
                   ~strcmp(theLoadStr,'default_nock')
                error( 'Unrecognized option, ''%s''.',theLoadStr );
            else
                aLoadStr = theLoadStr;
                aVerbose = 1;
                if nargin == 2
                    aVerbose = theVerbose;
                end % if nargin == 2
            end % if nargin

            aDefaultCatName = theCat.DefaultCatName;
            aBaseCatName = theCat.BaseCatName;
            aCustomCatName = theCat.CustomCatName;
            
            if strcmp(aLoadStr,'base_nock')
                if aVerbose
                    fprintf('Loading base catalog with no check that it is up-to-date. This could take a while.\n')
                end % if aVerbose
                aMatFile = load( aBaseCatName );
                aFieldNames = fieldnames( aMatFile );
                theCat = aMatFile.( aFieldNames{1} ); % Use info from present base catalog.
                return
            end % if strcmp
            
            if strcmp(aLoadStr,'default_nock')
                if aVerbose
                    fprintf('Loading default catalog with no check that it is up-to-date. This could take a while.\n')
                end % if aVerbose
                aMatFile = load( aDefaultCatName );
                aFieldNames = fieldnames( aMatFile );
                theCat = aMatFile.( aFieldNames{1} ); % Use info from present base catalog.
                return
            end % if strcmp
            
            if strcmp(aLoadStr,'custom_nock')
                if aVerbose
                    fprintf('Loading custom catalog with no check that it is up-to-date.\n')
                end % if aVerbose
                aMatFile = load( aCustomCatName );
                aFieldNames = fieldnames( aMatFile );
                theCat = aMatFile.( aFieldNames{1} ); % Use info from present base catalog.
                return
            end % if strcmp

            if strcmp(aLoadStr,'empty')
                theCat.Units('GHz'); % Allocate theCat.
                return
            end % if strcmp
            
            if strcmp(aLoadStr,'default') % Load the default file.

                % Get names and dates of all the files.
                if exist( aBaseCatName,'file' ) ~= 2
                    error( 'Base catalog, %s, not found. You must manually regenerate it.\n',aBaseCatName )
                end % if exist
                aTmpInfo = dir(aBaseCatName);
                aBaseDateNum = aTmpInfo.datenum;
                
                if exist( aCustomCatName,'file' ) ~= 2
                    error( 'Custom catalog, %s, not found. You must manually regenerate it.',aCustomCatName )
                end % if exist
                aTmpInfo = dir(aCustomCatName);
                aCustomDateNum = aTmpInfo.datenum;
                
                if exist( aDefaultCatName,'file' ) ~= 2
                    aDefaultDateNum = 0.5 * aBaseDateNum; % No default file, set DateNum to force regeneration.
                else
                    aTmpInfo = dir(aDefaultCatName);
                    aDefaultDateNum = aTmpInfo.datenum;
                end % if exist

                if aVerbose
                    if aBaseDateNum > aDefaultDateNum
                        fprintf( 'Base catalog, %s, is more recent than default catalog.\n',aBaseCatName );
                    else
                        fprintf( 'If there are any changes in the base catalog, you must manually regenerate it.\n')
                    end % if aBaseDateNum
    
                    if aCustomDateNum > aDefaultDateNum
                        fprintf( 'Custom catalog, %s, is more recent than default catalog.\n',aCustomCatName );
                    else
                        fprintf( 'If there are any changes in the custom catalog, you must manually regenerate it.\n')
                    end % if aBaseDateNum
                end % if aVerbose
                
                if (aBaseDateNum > aDefaultDateNum || aCustomDateNum > aDefaultDateNum)
                    if aVerbose
                        fprintf( 'Regenerating the default catalog by appending the custom catalog to the base catalog. This could take a while.\n' );
                    end % aVerbose
                    aMatFile = load( aBaseCatName );
                    aFieldNames = fieldnames( aMatFile );
                    theCat = aMatFile.( aFieldNames{1} );
                    aMatFile = load( aCustomCatName );
                    aFieldNames = fieldnames( aMatFile );
                    aCustomCat = aMatFile.( aFieldNames{1} );
                    theCat.Append( aCustomCat );
                    theCat.CheckSymVn; % Make sure symV and the first part of symVn are the same.
                    theCat.Save('default');
                    return;
                else
                    if aVerbose
                        fprintf('Loading default catalog. This could take a while.\n');
                    end % if aVerbose
                    % Just load the default file in and we are done, no update.
                    aMatFile = load( aDefaultCatName );
                    aFieldNames = fieldnames( aMatFile );
                    theCat = aMatFile.( aFieldNames{1} );
                    theCat.CheckSymVn; % Make sure symV and the first part of symVn are the same.
                end % if aVerbose
                return;

            end % Default file load.
            
            % Update, save, and then return the base catalog. Build on whatever
            % is already there, as long as it is for the same base catalog.
            if strcmp(aLoadStr,'base')
                if exist( aBaseCatName,'file' ) ~= 2
                    fprintf( 'Base catalog file not found, starting fresh: ''%s''.\n',aBaseCatName);
                    fprintf( '   Recommend negative verbose option and multiple CRCat runs.\n');
                    theCat.Units('GHz'); % Allocate theCat.
                    theCat.Init('base'); % Initialize theCat.list with just the basic up-to-date network data.
                    theCat.Recalc('base',aVerbose); % Finish off the rest of theCat.list.
                    theCat.Save('base');
                    return;
                else
                    if aVerbose
                        fprintf( 'Loading base catalog. This could take a while.\n' );
                    end % if aVerbose
                    aMatFile = load( aBaseCatName );
                    aFieldNames = fieldnames( aMatFile );
                    theCat = aMatFile.( aFieldNames{1} ); % Use info from present base catalog.
                    % Check to see if theCat.list has exactly up to date basic network data. If
                    % not, clear out-of-date networks.
                    if aVerbose
                        fprintf( '   Checking to see if stored base catalog is up to date.\n' );
                    end % if aVerbose
                    aCatOK = theCat.BasicDataUpToDate( 'base' );
                    if aCatOK
                        if aVerbose
                            fprintf( '   Stored base catalog is loaded and up to date.\n' );
                        end % if aVerbose
                    else
                        if aVerbose
                            fprintf( '   Regenerating base catalog as needed.\n' );
                        end % if aVerbose
                        theCat.Recalc('base',aVerbose); % Finish off the rest of theCat.list.
                        if aVerbose
                            fprintf( '   Saving updated base catalog: %s\n',aBaseCatName );
                        end % if aVerbose
                        theCat.Save('base');
                    end % if aCatOK
                end % if exist
            end % strcmp

            % Update, save, and then return the custom catalog. Build on whatever
            % is already there, as long as it is for the same custom catalog.
            if strcmp(aLoadStr,'custom')
                if exist( aCustomCatName,'file' ) ~= 2
                    fprintf( 'Custom catalog file not found, starting fresh: ''%s''.\n',aCustomCatName);
                    theCat.Units('GHz'); % Allocate theCat.
                    theCat.Init('custom'); % Initialize theCat.list with just the basic up-to-date network data.
                    theCat.Recalc('custom',aVerbose); % Finish off the rest of theCat.list.
                    theCat.Save('custom');
                    return;
                else
                    if aVerbose
                        fprintf( 'Loading custom catalog.\n' );
                    end % if aVerbose
                    aMatFile = load( aCustomCatName );
                    aFieldNames = fieldnames( aMatFile );
                    theCat = aMatFile.( aFieldNames{1} ); % Use info from present custom catalog.
                    % Check to see if theCat.list has exactly up to date basic network data. If
                    % not, clear out-of-date networks.
                    if aVerbose
                        fprintf( '   Checking to see if stored custom catalog is up to date.\n' );
                    end % if aVerbose
                    aCatOK = theCat.BasicDataUpToDate( 'custom' );
                    if aCatOK
                        if aVerbose
                            fprintf( '   Stored custom catalog is loaded and up to date.\n' );
                        end % if aVerbose
                    else
                        if aVerbose
                            fprintf( '   Regenerating custom catalog as needed.\n' );
                        end % if aVerbose
                        theCat.Recalc('custom',aVerbose); % Finish off the rest of theCat.list.
                        if aVerbose
                            fprintf( '   Saving updated custom catalog: ''%s''\n',aCustomCatName );
                        end % if aVerbose
                        theCat.Save('custom');
                    end % if aCatOK
                end % if exist
            end % strcmp
            
        end % CRCat constructor

        
        %
        % Constant definitions (poor man's #define).
        %
        
        function theConst = ConstDegen( ~ )
            % Const = ConstDegen: Returns text string to indicate that
            % we can to convert From the larger BaseId down To the smaller
            % SameId. The simplification equations are stored. Since there
            % are an infinite number of ways to go in the reverse
            % direction, i.e. from SameId back to BaseId, no transform
            % back. --jcr21mar2025
            theConst = 'Degen';
        end % ConstDegen

        
        function theConst = ConstRvrsDegen( ~ )
            % Const = ConstRvrsDegen: Same as ConstDegen except that the
            % BaseId and the SameId are swapped. The
            % simplification equations are stored in the SameId's data.
            % --jcr21Mar2025
            theConst = 'RvrsDegen';
        end % ConstRvrsDegen

        
        function theConst = ConstDegenNoEqn( ~ )
            % Const = ConstDegenNoEqn: Same as ConstDegen except that solve
            % did not find the transform equations. --jcr21mar2025
            theConst = 'DegenNoEqn';
        end % ConstDegenNoEqn

        
        function theConst = ConstRvrsDegenNoEqn( ~ )
            % Const = ConstRvrsDegenNoEqn: Same as ConstDegenNoEqn except
            % that the BaseId and the SameId are reversed. --jcr21Mar2025
            theConst = 'RvrsDegenNoEqn';
        end % ConstRvrsDegenNoEqn


        function theConst = ConstRegen( ~ )
            % Const = ConstRegen: Returns text string to indicate that we
            % can to convert From the smaller BaseId up To special cases of
            % the larger SameId. The transformation equations are stored. For
            % regenerative situations, there is no general way to go in the
            % reverse direction, i.e. from SameId back down to BaseId, so no
            % transform back. --jcr21mar2025
            theConst = 'Regen';
        end % ConstRegen

        
        function theConst = ConstRvrsRegen( ~ )
            % Const = ConstRvrsRegen: Same as ConstRegen except that the
            % BaseId and the SameId are reversed. The transformation
            % equations are stored in the SameId's data. --jcr21Mar2025
            theConst = 'RvrsRegen';
        end % ConstRvrsRegen

        
        function theConst = ConstRegenNoEqn( ~ )
            % Const = ConstRegenNoEqn: Same as ConstRegen except solve did
            % not find the transform equations. --jcr21mar2025
            theConst = 'RegenNoEqn';
        end % ConstRegenNoEqn

        
        function theConst = ConstRvrsRegenNoEqn( ~ )
            % Const = ConstRvrsRegenNoEqn: Same as ConstRegenNoEqn except
            % that the BaseId and the SameId are reversed. --jcr21Mar2025
            theConst = 'RvrsRegenNoEqn';
        end % ConstRvrsRegenNoEqn

        
        function theConst = ConstTrivial( ~ )
            % Const = ConstTrivial: Returns text string to indicate
            % that we can convert From a BaseId with a smaller order To a
            % SameId with a larger order by simply adding appropriate
            % shorted or open elements. No transformation stored. --jcr21Mar2025
            theConst = 'Trivial';
        end % ConstTrivial

        
        function theConst = ConstRvrsTrivial( ~ )
            % Const = ConstRvrsTrivial: Same as ConstTrivial
            % except the BaseId and the SameId are reversed. --jcr21Mar2025
            theConst = 'RvrsTrivial';
        end % ConstRvrsTrivial

        
        function theConst = ConstEquiv( ~ )
            % Const = ConstEquiv: Returns text string to indicate that
            % the two Ids are equivalent and conversion equations are
            % stored for both directions. jcr21jan2025
            theConst = 'Equiv';
        end % ConstEquiv

        
        function theConst = ConstEquivNoEqn( ~ )
            % Const = ConstEquivNoEqn: Returns text string to indicate that
            % the two Ids are known to be equivalent by the fitting test
            % but solve could not find the equations to go From BaseId To
            % SameId. jcr21jan2025
            theConst = 'EquivNoEqn';
        end % ConstEquivNoEqn

        
        function theConst = ConstNeedSynth( ~ )
            % Const = ConstEquivNoEqn: Returns text string to indicate that
            % we need synthesis equations for either the BaseId or the
            % SameId, one has sythesis, the other needs synthesis, and solve
            % could not find it, but it must exist. jcr6Apr2025
            theConst = 'NeedSynth';
        end % ConstNeedSynth
        

        function theConst = ConstCompound( ~ )
            % Const = ConstCompound: Returns text string to indicate that
            % we can convert From BaseId To SameId but cannot in general
            % convert back. The BaseId degenerates to an Id with fewer RLCs
            % than the SameId, but that Id then regenerates to special
            % cases of SameId, which has more RLCs. --jcr21jan2025
            theConst = 'Compound';
        end % ConstCompound


        function theConst = ConstCompoundNoEqn( ~ )
            % Const = ConstCompoundNoEqn: Same as ConstCompound but solve
            % did not find the transform equations. --jcr21jan2025
            theConst = 'CompoundNoEqn';
        end % ConstCompoundNoEqn


        function theConst = ConstRvrsCompound( ~ )
            % Const = ConstRvrsCompound: Same as ConstCompound but the
            % BaseId and the SameId are reversed. Transform equations stored
            % in the SameId data. --jcr21jan2025
            theConst = 'RvrsCompound';
        end % ConstRvrsCompound


        function theConst = ConstRvrsCompoundNoEqn( ~ )
            % Const = ConstRvrsCompoundNoEqn: Same as ConstRvrsCompound but
            % solve could not find the transform equations. --jcr21jan2025
            theConst = 'RvrsCompoundNoEqn';
        end % ConstRvrsCompoundNoEqn


        function theConst = ConstSelf( ~ )
            % Const = ConstSelf: Returns text string to indicate that
            % the BaseId is converting to itself and, since it is a minimal
            % network, conversion is unique and stored. BaseId must have
            % synthesis equations for this to be known. --jcr22jan2025
            theConst = 'Self';
        end % ConstSelf

        
        function theConst = ConstSelfNoSynth( ~ )
            % Const = ConstSelfNoSynth: Returns text string to indicate that
            % the BaseId is converting to itself but, since it has no
            % known synthesis equations, it is assumed to not be a minimal
            % network, the conversion is not unique and not stored.
            % --jcr22jan2025
            theConst = 'SelfNoSynth';
        end % ConstSelfNoSynth


        function theConst = ConstNoRelation( ~ )
            % Const = ConstNoRelation: The Base and Same Ids do not have
            % the same signature, so no possibility of a relationship.
            % --jcr22jan2025
            theConst = 'NoRelation';
        end % ConstNoRelation


        function theConst = ConstShouldNotBePossible( ~ )
            % Const = ConstShouldNotBePossible: String to return if code
            % reaches a point that should not be reached. Indicates a bug
            % in the code, or a new kind of network relationship.
            % --jcr22jan2025
            theConst = 'ShouldNotBePossible';
        end % ConstShouldNotBePossible


        function theConst = ConstJustSameSig( ~ )
            % Const = ConstJustSameSig: String to return if only relationship
            % between Ids is the same signature. --jcr22jan2025
            theConst = 'JustSameSig';
        end % ConstJustSameSig

        
        function theConst = ConstNil( ~ )
            % Const = ConstNil: Returns text string to indicate that
            % the BaseId is not known to be able to transform to the SameId
            % because SameId has no symEL sythesis equations. --jcr28jan2025
            theConst = 'Nil';
        end % ConstNil

        
        function theConst = ConstNoXfrm( ~ )
            % Const = ConstNoXfrm: Returns text string to indicate that the
            % BaseId is known to not transform to SameId by the fitting test.
            % --jcr28jan2025
            theConst = 'NoXfrm';
        end % ConstNoXfrm

        
        function theConst = ConstEqnNotFound( ~ )
            % Const = ConstEqnNotFound: Returns text string to indicate that
            % no transform equation found, even though there should be one.
            % --jcr7mar2025
            theConst = 'EqnNotFound';
        end % ConstEqnNotFound


        %
        % Regular functions follow...
        %
        
        function CheckSymVn(theCat)
            % ChecSymVn(Cat):  Check to make sure Cat.symV is identical to
            % the first part of Cat.symVn. symVn holds all the nodal
            % variables for a circuit, while symV just holds those
            % variables that are solved for. If symVn is empty, then copy
            % symV into symVn so that they are identical. During initial
            % setup, when all Cat entries are solved for, symVn is usually
            % left empty. 23nov2021jcr
            
            if ~isempty(theCat) && ~isempty(theCat.list)
                for index = 1:length(theCat.list)
                    aCatItem = theCat.list(index);
                    if isempty( aCatItem.symVn )
                        theCat.list(index).symVn = aCatItem.symV;
                    elseif length(aCatItem.symV) <= length(aCatItem.symVn)
                        aStrV = char( aCatItem.symV );
                        aStrVn = char( aCatItem.symVn(1:length(aCatItem.symV)) );
                        if ~strcmp( aStrVn,aStrV )
                            error('For component ID=%d, %s, the intial symVn variables are different from symV.\n',index,aCatItem.list.name);
                        end % if ~strcmp
                    else
                        error('For component ID=%d, %s, there are more symV variables than symVn.\n',index,aCatItem.list.name);
                    end % if isempty
                end % for index
            end % if ~isempty
        end % CRCat.CheckSymVn
     
        
        function theFullPath = DefaultCatName( ~ )
            % FullPath = DefaultCatName: Full path and name for the Default Catlog.
            % 07Apr2015 04Apr2017
            
            % Build the full file name, we want the file to go into the
            % Catalogs folder of the same directory as the file this function is in.
            aStack = dbstack('-completenames');
            aFullPath = aStack(1).file; % Full path and file name of the file that contains this function.
            aEnd = find( aFullPath=='\',1,'last' ); % Peel off the file name, we just want the path.
            theFullPath = [ aStack(1).file(1:aEnd) 'Catalogs\ADefaultCatalog.mat' ];
            
        end % DefaultCatName
        
        
        function theFullPath = BaseCatName( ~ )
            % FullPath = BaseCatName: Full path and name for the Base Catlog. 
            % 07Apr2015 04Apr2017
            
            % Build the full file name, we want the file to go into the
            % Catalogs folder of the same directory as the file this function is in.
            aStack = dbstack('-completenames');
            aFullPath = aStack(1).file; % Full path and file name of the file that contains this function.
            aEnd = find( aFullPath=='\',1,'last' ); % Peel off the file name, we just want the path.
            theFullPath = [ aStack(1).file(1:aEnd) 'Catalogs\ABaseCatalog.mat' ];
            
        end % BaseCatName
        
        
        function theFullPath = CustomCatName( ~ )
            % FullPath = CustomCatName: Full path and name for Custom Catlog.
            % 07Apr2015 04Apr2017
            
            % Build the full file name, we want the file to go into the
            % Catalogs folder of the same directory as the file this function is in.
            aStack = dbstack('-completenames');
            aFullPath = aStack(1).file; % Full path and file name of the file that contains this function.
            aEnd = find( aFullPath=='\',1,'last' ); % Peel off the file name, we just want the path.
            theFullPath = [ aStack(1).file(1:aEnd) 'Catalogs\ACustomCatalog.mat' ];
            
        end % CustomCatName
        
        
        function theNetwork = Id2Name( theCat,theLabel )
            % Network = Id2Name(Cat,Label): Return Network(s) corresponding
            % to Label(s). If Label is a scalar numeric network index (Id),
            % return a string with the network name. If it is an integer
            % array, return a string array of network names corresponding
            % to the integer Ids. Label can also be a string array of network
            % names and the call is passed to Name2Id and an integer or
            % integer array is returned. 25Apr2025
            
            if isempty(theCat.list) || nargin<2 || isempty(theLabel)
                theNetwork = []; % We were passed an empty list.
                return
            end

            if ~isnumeric(theLabel) % Assume theLabel is network names...
                theNetwork = theCat.Name2Id(theLabel); % Return network Ids
                return
            end % if ~isnumeric
            
            if iscell( theLabel )
                aId = cell2mat(theLabel);
            else
                aId = theLabel;
            end % strcmp
            
            theCat.CheckId( aId,1 );
            
            nId = numel( aId );
            theNetwork = strings(1,nId); % Pre-allocate array.
            for iId = 1:nId
                theNetwork(iId) = string( theCat.list( aId(iId) ).name );
            end % for iId
            
        end % Id2Name
        
        
        function theId = Name2Id( theCat,theName )
            % Id = Name2Id(Cat,Name): Return Ids of Name components, Name
            % can be a char vector, a char cell array, a string, or a
            % string array. Returns 0 if nothing found. 10Apr2015jcr
            % Extended to include strings and string arrays. 21Jan2022jcr
            
            if isempty(theCat.list) || nargin<2 || isempty(theName)
                theId = []; % We were passed an empty list.
                return;
            end
            
            aTotalList = string( {theCat.list.name} ); % String array of all the component names in theCat.
            aName = string( theName ); % Make sure theName is also a string or a string array.
            
            nId = numel( aName );
            theId(nId) = uint32(0); % Allocate memory.
            
            for iId = 1:nId
                aFoundId = find( aTotalList==aName(iId) );
                nFound = numel(aFoundId);
                if nFound == 1
                    theId(iId) = uint32(aFoundId);
                elseif nFound > 1
                    error('Duplicate entries for %s in the catalog, Id = %d %d ...',aName(iId),aFoundId(1),aFoundId(2));
                else
                    theId(iId) = 0; % Nothing found.
                end % if nFound
            end % for iId
            
        end % Name2Id
        
        function theList = AllSigs( theCat )
            % List = AllSigs(Cat): List all of the flagA/flagB signature string cell array.
            % 10Apr2015jcr
            
            if isempty(theCat.list)
                theList = []; % We were passed an empty list.
                return;
            end
            
            theList = {theCat.list.flagSig}.';
        end % AllSigs
        
        
        function theList = UniqueSigs( theCat )
            % List = UniqueSigs(Cat): Set up the unique flagA/flagB signature string cell array.
            % 10Apr2015jcr
            
            if isempty(theCat.list)
                theList = []; % We were passed an empty list.
                return;
            end
            
            theList = unique( theCat.AllSigs );
        end % UniqueSigs
        
        
        function theNum = NumRLC( theCat,theId )
            % Num = NumRLC( Cat,Id ): Return int array with number of RLCs for each comp Id.
            
            if isempty(theCat.list)
                theNum = []; % We were passed an empty list.
                return;
            end
            
            if nargin == 1 % Do the entire catalog.
                theNum = int32( cellfun( @length,{theCat.list.symV} ) );
            else
                theCat.CheckId( theId,1 );
                theNum = int32( cellfun( @length,{theCat.list(theId).symV} ) );
            end % if nargin
        end % NumRLC
        
        
        function theNum = NumRLCn( theCat,theId )
            % Num = NumRLCn( Cat,Id ): Return int array with number of full nodal analysis RLCs for each comp Id.
            
            if isempty(theCat.list)
                theNum = []; % We were passed an empty list.
                return;
            end
            
            if nargin == 1 % Do the entire catalog.
                theNum = int32( cellfun( @length,{theCat.list.symVn} ) );
            else
                theCat.CheckId( theId,1 );
                theNum = int32( cellfun( @length,{theCat.list(theId).symVn} ) );
            end % if nargin
        end % NumRLC

        
        function theOK = CheckId( theCat,theId,theTerminate )
            % CheckId( Cat,Id ): Make sure all Id's are in a legal range,
            % numeric Id only, arrays OK, no checking of names. 15Apr2015
            % If theTerminate==0 (default), returns OK=1 if all OK, 0 otherwise.
            % If Terminate~=0, terminates with error message if bad Id.
            % jcr27apr2025
            
            % Make sure we have a numeric Id.
            if ~isnumeric( theId )
                error('Numeric Id needed.' );  % This routine does not check char Id.
            end % if ~isnumeric

            aTerminate = 0; % If bad Id found, just return with logical value.
            if nargin==3
                aTerminate = theTerminate;
            end % if nargin

            iBad = ( theId<0 | theId>length(theCat.list) );
            if any( iBad ) && aTerminate
                fprintf('Valid Id range is 1:%d. Following Ids out of range: ',length(theCat.list));
                fprintf(' %d',theId(iBad));
                fprintf('\n');
                error(' ');
            else
                theOK = ~iBad;
            end % any
        end % CheckId


        function theCount = Census(theCat,theConst)
            % Count = CRCat.Census(Const): Find how many Ids met the criterion
            % specified in Const and return with that count. Possible
            % values that can be found in relations between two Ids are:
            % 'Degen', 'RvrsDegen', 'DegenNoEqn', 'RvrsDegenNoEqn', 'Regen',
            % 'RvrsRegen', 'RegenNoEqn', 'RvrsRegenNoEqn', 'Trivial',
            % 'RvrsTrivial', 'Equiv', 'EquivNoEqn','NeedSynth', 'Compound',
            % 'CompoundNoEqn', 'RvrsCompound', 'RvrsCompoundNoEqn', 'Self',
            % 'SelfNoSynth', 'NoRelation', 'ShouldNotBePossible',
            % 'JustSameSig', 'Nil', 'NoXfrm', 'EqnNotFound'.
            % Additional option: 'Synth': Return array with the number of
            % networks that do (column 2) and don't (column 3) have
            % synthesis equations and of those that don't have, the number
            % that should have, but do not yet have the solved equations
            % available (column 4). Number of RLCs in the first column. -- jcr 4Apr2025

            aStr = theConst;

            if strcmp(aStr,'Synth') % Count how many nets do and don't have synthesis equations.
                aMaxNumRLC = max(theCat.NumRLC);
                aCount = zeros( aMaxNumRLC,4 );
                aCount(:,1) = 1:aMaxNumRLC; % Number of RLCs in the first column.
                for iId = 1:numel(theCat.list)
                    aNumRLC = theCat.NumRLC(iId);
                    if ~isempty( theCat.list(iId).symEL )
                        aCount(aNumRLC,2) = aCount(aNumRLC,2) + 1; % Found a network with synthesis equations.
                    else
                        aCount(aNumRLC,3) = aCount(aNumRLC,3) + 1; % Found a network without synthesis equations.
                        % Determine if it should have synthesis equations.
                        if ( theCat.FindOrder(iId) ==  aNumRLC ) % Found a network without synthesis equations...
                            aCount(aNumRLC,4) = aCount(aNumRLC,4) + 1; % ...that should have them.`
                        end % if aC.FindOrder
                    end % if isa
                end % for iId
            else
                aCount = 0;
                for iId = 1:numel(theCat.list)
                    for iSame = 1:numel(theCat.list(iId).sameId)
                        aRelationship = theCat.Relationship( iId,theCat.list(iId).sameId(iSame) );
                        if strcmp( aStr,aRelationship )
                            aCount = aCount + 1;
                        end % if strcmp
                    end % for iSame
                end % for iId
            end % if strcmp

            theCount = aCount;

        end % CRCat.Census


        function NetworkRelations(theCat,theId)
            % CRCat.NetworkRelations(Id): List out all relations for Id
            % except NoXfrm, Nil, JustSameSig, NoRelation. Id can be an
            % array, in which case list out each Id on one line. --
            % jcr6Apr2025

            if isnumeric( theId(1) )
                aId = theId(1);
            elseif iscell( theId ) && ( ischar( theId{1} ) || isstring( theId{1} ) )
                aId = theCat.Name2Id( theId{1} );
            elseif isstring( theId(1) )
                aId = theCat.Name2Id( theId(1) );
            elseif ischar( theId )
                aId = theCat.Name2Id( theId );
            else
                error('Id not recognized.');
            end

            for iId = aId
                fprintf('%d-> ',iId);
                for iSame = 1:numel(theCat.list(iId).sameId)
                    aSameId = theCat.list(iId).sameId(iSame);
                    aRelationship = theCat.Relationship( iId,aSameId );
                    if ~strcmp( aRelationship,'NoXfrm' ) && ~strcmp( aRelationship,'Nil' ) && ...
                        ~strcmp( aRelationship,'JustSameSig' ) && ~strcmp( aRelationship,'NoRelation' )
                        fprintf('%d %s    ',aSameId,aRelationship);
                    end % if ~stcmp
                end % for iSame
                fprintf('\n');
            end % for iId

        end % CRCat.NetworkRelations
        
        
        function theTransform = Transformation( theCat,theFromId,theToId )
            % Transform = Transformation( Cat,FromId,ToId ): Return the equations
            % to transform the RLCs of FromId to the RLCs of ToId. FromId
            % and ToId are both required and must be scalar integers. Transform
            % is a structure with fromId, fromVar, toId, toVar, and eqn. If no
            % conversion possible, return with Transform.eqn with string indicating
            % why. This routine just looks up equations already stored in Cat. If
            % you need to calculate the equations from scratch, use
            % SameSymConv. To convert a specific component, which has specific
            % element values set, use Transform in CRComp. 16Apr2017jcr
            
            if isempty(theCat.list)
                theTransform = [];
                return; % We were passed an empty theCat.list.
            end
            
            if nargin ~= 3
                error('Both FromId and ToId must be specified.');
            end
            
            if numel(theFromId) ~=1 || numel(theToId) ~= 1
                error('Both FromId and ToId must be scalar.');
            end
            
            theCat.CheckId(theFromId,1);
            theCat.CheckId(theToId,1);
            
            theTransform = struct( 'fromId',theFromId, 'fromVar',theCat.list(theFromId).symV, ...
                                   'toId',theToId, 'toVar',theCat.list(theToId).symV, ...
                                   'eqn',[] ); % Return structure allocated.
            
            index = find( theCat.list(theFromId).sameId == theToId );
            if numel(index) ~= 1
                theTransform.eqn = theCat.ConstNoRelation;
                return; % No conversion equations.
            end % if numel
            
            theTransform.eqn = theCat.list(theFromId).symSame{index};
                
        end % Transformation
        

        function TransformMap( theCat,theBaseId,theNoLegend )
            % TransformMap(Cat,BaseId): Print out a map of
            % transformations from BaseId networks to all other networks.
            % BaseId can be an array. Default is all networks. If NoLegend
            % is present (any non-zero value), skip the 'helpful information'. jcr15Mar2025
            
            if isempty(theCat.list)
                return; % We were passed an empty list.
            end

            if nargin >= 2
                iBase = theBaseId;
            else
                iBase = 1 : numel(theCat.list);
            end % if nargin

            theCat.CheckId( iBase,1 );

            % Output some helpful information for the user.
            if nargin < 3 || theNoLegend == 0
                theCat.NetworkTransformLegend;
            end % if nargin

            for iBaseId = iBase
                fprintf('Transforms for %d RLCs, %s, Id = %d:\t',theCat.NumRLC(iBaseId),theCat.list(iBaseId).name,iBaseId);

                for iSame = 1:numel(theCat.list( iBaseId ).sameId)
                    iSameId = theCat.list( iBaseId ).sameId(iSame);
                    aSolve = theCat.list( iBaseId ).symSame{ iSame };
                    fprintf(' %d',iSameId);
                    if isa( aSolve,'sym' )
                        fprintf('*'); % A solution for transformation equations is present.
                    elseif ~ischar(aSolve)
                        error('Bad data in Id=%d symSame for Id=%d. Must be sym equations or character data.',iBaseId,iSameId)
                    elseif strcmp( aSolve,theCat.ConstEqnNotFound )
                        fprintf('-'); % Found no solution, but there should be one.
                    elseif strcmp( aSolve,theCat.ConstTrivial )
                        fprintf('t'); % The fit resulted in a trivial regen Id.
                    elseif strcmp( aSolve,theCat.ConstNil )
                        fprintf('x'); % iSameId could not be fitted due to no symEL synthesis equations, so no solve attempted.
                    elseif strcmp( aSolve,theCat.ConstNoXfrm )
                        fprintf('X'); % iSameId did not fit iBaseId data perfectly, so no solve attempted.
                    else
                        error('Unrecognized string in Id=%d symSame for Id=%d: %s',iBaseId,iSameId,aSolve)
                    end % if isa
                end % for iSame
                fprintf('\n')
            end % for iBaseId

        end % TransformMap


        function TransformSets( theCat,theBaseId )
            % TransformSets(Cat,BaseId): Print out a map of
            % transformations from BaseId network to all other networks.
            % Order the map so that the Ids with the same flagSig's are
            % listed together. BaseId can be an array. Default is all
            % networks. jcr15Mar2025
            
            if isempty(theCat.list)
                return; % We were passed an empty list.
            end

            if nargin >= 2
                iBase = theBaseId;
            else
                iBase = 1 : numel(theCat.list);
            end % if nargin

            theCat.CheckId( iBase,1 );

            aLogical = zeros( 1,numel(theCat.list) );
            aLogical(iBase) = 1;
            aFirstTime = 1;
            while( sum(aLogical~=0) )
                if aFirstTime
                    fprintf('\nNetwork Relationship Maps Organized with Same-Signature Ids Grouped Together\n')
                    theCat.NetworkTransformLegend;
                end % aFirstTime
                iId = find( aLogical,1,'first' );
                iSetIds = theCat.list(iId).sameId;
                fprintf('\nSignature: %s\n',theCat.list(iId).flagSig)
                theCat.TransformMap( iSetIds,1 );
                aFirstTime = 0;
                aLogical( iSetIds ) = 0;
            end % while

        end % TransformSets


        function NetworkTransformLegend( theCat )
            % Output some helpful information for the user. -- jcr16Mar2025
            fprintf('\nTransform solve codes:\n')
            fprintf('* = Transform solved.\n')
            fprintf('- = Solve failed, but transform should exist: %s\n',theCat.ConstEqnNotFound)
            fprintf('t = Trivial network results, no transform saved: %s\n',theCat.ConstTrivial)
            fprintf('x = No synthesis available so no check for transform: %s\n',theCat.ConstNil)
            fprintf('X = Synthesis indicates no transform: %s\n',theCat.ConstNoXfrm)
            fprintf('o = Used previous result.\n')
        end % NetworkTransformLegend


        function theOrder = FindOrder( theCat,theId )
            % FindOrder( Id ): Return the minimum number of RLCs of any
            % network in Cat that Id can be transformed to. Id must be a
            % scalar. -- jcr22mar2025

            theCat.CheckId( theId,1 );

            if numel(theId) ~= 1
                error('Id must be a scalar.');
            end % if nargin

            % If sythesis equations exist, network order = the number of RLCs.
            theOrder = theCat.NumRLCn(theId);
            if ~isempty( theCat.list(theId).symEL )
                return;
            end % if ~isempty

            % Search for the Id that theId can transform to and has the
            % fewest number of RLCs. This is the order of theId.
            for iSame = 1:numel(theCat.list(theId).sameId)
                aNumRLC = theCat.NumRLCn( theCat.list(theId).sameId(iSame) );
                aSymSame = theCat.list(theId).symSame{iSame};
                if ischar(aSymSame) % Check in case solve did not find a transform that fitting test says must exist.
                    if strcmp( aSymSame,theCat.ConstEqnNotFound ) && aNumRLC < theOrder
                        theOrder = aNumRLC;
                    end % if strcmp
                elseif aNumRLC < theOrder % must be a sym xfrm.
                    theOrder = aNumRLC;
                end % if ischar
            end % for iSame
        end % FindOrder


        function theRelationship = Relationship( theCat,theFromId,theToId )
            % Relationship(Cat,FromId,ToId): Return with a string indicating
            % the relationship From FromId To ToId. Both Ids required. Can
            % network names. If arrays, only first network in each is
            % evaluated. jcr17Mar2025

            if nargin ~= 3
                warning('Both BaseId and SameId required in order to determine their relationship.');
                theRelationship = theCat.ConstNoRelation;
                return;
            end % if nargin
            
            if isempty(theCat.list)
                warning('The CRCat list is empty.')
                theRelationship = theCat.ConstNoRelation;
                return; % We were passed an empty list or we were passed bad Ids.
            end

            if isnumeric( theFromId(1) )
                aFromId = theFromId(1);
            elseif iscell( theFromId ) && ( ischar( theFromId{1} ) || isstring( theFromId{1} ) )
                aFromId = theCat.Name2Id( theFromId{1} );
            elseif isstring( theFromId(1) )
                aFromId = theCat.Name2Id(theFromId(1));
            elseif ischar( theFromId )
                aFromId = theCat.Name2Id( theFromId );
            else
                error('FromId not recognized.');
            end

            if isnumeric( theToId(1) )
                aToId = theToId(1);
            elseif iscell( theToId ) && ( ischar( theToId{1} ) || isstring( theToId{1} ) )
                aToId = theCat.Name2Id( theToId{1} );
            elseif isstring( theToId(1) )
                aToId = theCat.Name2Id(theToId(1));
            elseif ischar( theToId )
                aToId = theCat.Name2Id( theToId );
            else
                error('ToId not recognized.');
            end

            if ~theCat.CheckId( aFromId )
                warning('The FromId, %d, is invalid.',aFromId);
                theRelationship = theCat.ConstNoRelation;
                return; % We were passed an empty list or we were passed bad Ids.
            end
            if ~theCat.CheckId( aToId )
                warning('The ToId, %d, is invalid.',aToId);
                theRelationship = theCat.ConstNoRelation;
                return; % We were passed an empty list or we were passed bad Ids.
            end

            % If the network signatures do not match, no relationship.
            if ~strcmp( theCat.list(aFromId).flagSig,theCat.list(aToId).flagSig )
                theRelationship = theCat.ConstNoRelation;
                return;
            end % of ~strcmp

            aFromNumRLCn = theCat.NumRLCn(aFromId);
            aFromOrder = theCat.FindOrder(aFromId); % Minimum number of RLCs to exactly represent the circuit response.
            aToNumRLCn = theCat.NumRLCn(aToId);
            aToOrder = theCat.FindOrder(aToId);

            % Find the index of the equations (if any) to transform taFromId to aToId.
            % If the signatures match, then each Id should be listed in the other's sameId list.
            iFrom2To = find( aToId == theCat.list(aFromId).sameId, 1 );
            if isempty(iFrom2To)
                warning( 'ToId, %d, not listed in FromId, %d, sameId list.',aToId, aFromId)
                theRelationship = theCat.ConstNoRelation;
                return;
            end % if isempty(iFrom2To)
            % Transform equations, or string saying what the situation is.
            aFrom2To = theCat.list(aFromId).symSame{iFrom2To};
            % Is there, or could there be, a transform for this, the forward direction?
            aFrom2ToExists = isa( aFrom2To,'sym' ) || ( ischar( aFrom2To ) && strcmp( aFrom2To, theCat.ConstEqnNotFound ) );

            % Find the index of the equations (if any) to transform aToId to aFromId (i.e., the reverse direction).
            iTo2From = find( aFromId == theCat.list(aToId).sameId, 1 );
            if isempty(iTo2From)
                warning( 'FromId, %d, not listed in ToId, %d, sameId list.', aFromId ,aToId)
                theRelationship = ConstNoRelation;
                return; % No relationship.
            end % if isempty(iTo2From)
            % Transform equations, or string saying what the situation is.
            aTo2From = theCat.list(aToId).symSame{iTo2From};
            % Is there, or could there be, a transform in this, the reverse direction?
            aTo2FromExists = isa( aTo2From,'sym' ) || ( ischar( aTo2From ) && strcmp( aTo2From, theCat.ConstEqnNotFound ) );

            % If aToId and aFromId are the same, existance of transform
            % equations means synthsis equations exist and it is not degenerate.
            if aFromId == aToId
                if ischar( aFrom2To )
                    theRelationship = theCat.ConstSelfNoSynth;
                else
                    theRelationship = theCat.ConstSelf;
                end % if ischar( aFrom2To )

            % If there are (or could be) equations to transform in both directions.
            elseif aFrom2ToExists && aTo2FromExists % Order == NumRLCn for both From and To.
                if aFromNumRLCn == aToNumRLCn
                    if ischar( aFrom2To )
                        theRelationship = theCat.ConstEquivNoEqn;
                    else
                        theRelationship = theCat.ConstEquiv;
                    end % ischar( aFrom2To )
                else
                    theRelationship = theCat.ConstShouldNotBePossible;
                end % if aFromNumRLCn

            % If there are (or could be) equations to transform forward but not reverse.
            elseif aFrom2ToExists
                if aFromOrder > aToOrder
                    % Not possible to transform From higher order To lower order.
                    theRelationship = theCat.ConstShouldNotBePossible;
                elseif aFromOrder == aToOrder && aFromOrder == aFromNumRLCn
                    % Both nets are minimal, so if we can go from one to the other,
                    % should be able to go back. We have equations to convert FromId
                    % To ToId, but none in reverse. Must exist, so call it equivalent
                    if ischar( aFrom2To )
                        theRelationship = theCat.ConstEquivNoEqn;
                    else
                        theRelationship = theCat.ConstEquiv;
                    end % if ischar( aFrom2To )
                elseif aFromOrder == aToOrder
                    if ischar( aFrom2To )
                        theRelationship = theCat.ConstDegenNoEqn;
                    else
                        theRelationship = theCat.ConstDegen;
                    end % if ischar( aFrom2To )
                elseif aFromOrder == aFromNumRLCn
                    if ischar( aFrom2To )
                        theRelationship = theCat.ConstRegenNoEqn;
                    else
                        theRelationship = theCat.ConstRegen;
                    end % if ischar( aFrom2To )
                else % aFromOrder < aFromNumRLCn must be true.
                    if ischar( aFrom2To )
                        theRelationship = theCat.ConstCompoundNoEqn;
                    else
                        theRelationship = theCat.ConstCompound;
                    end % if ischar( aFrom2To )
                end % if aFromOrder

            % If there are (or could be) equations to transform reverse but not forward.
            elseif aTo2FromExists
                if aToOrder > aFromOrder
                    % Not possible to transform from higher order to lower order.
                    theRelationship = theCat.ConstShouldNotBePossible;
                elseif aFromOrder == aToOrder && aToOrder == aToNumRLCn
                    % Both nets are minimal, so if we can go from one to the other,
                    % should be able to go back. Set this flag so we know
                    % to come back later and try solve even though unable
                    % to do fitting test.
                    theRelationship = theCat.ConstNeedSynth;
                elseif aToOrder == aFromOrder
                    if ischar( aTo2From )
                        theRelationship = theCat.ConstRvrsDegenNoEqn;
                    else
                        theRelationship = theCat.ConstRvrsDegen;
                    end % if ischar( aToOrder )
                elseif aToOrder == aToNumRLCn
                    if ischar( aTo2From )
                        theRelationship = theCat.ConstRvrsRegenNoEqn;
                    else
                        theRelationship = theCat.ConstRvrsRegen;
                    end % if ischar( aToOrder )
                else % aToOrder < aToNumRLCn must be true.
                    if ischar( aTo2From )
                        theRelationship = theCat.ConstRvrsCompoundNoEqn;
                    else
                        theRelationship = theCat.ConstRvrsCompound;
                    end % if ischar( aTo2From )
                end % if aToOrder

            % If the fitting attempt failed in both directions...
            else
                if strcmp( aFrom2To,theCat.ConstTrivial )
                    % Transform would result in one or more open/shorted elements.
                    theRelationship = theCat.ConstTrivial;
                elseif strcmp( aTo2From,theCat.ConstTrivial )
                    theRelationship = theCat.ConstRvrsTrivial;
                elseif strcmp( aTo2From,theCat.ConstNoXfrm ) || strcmp( aFrom2To,theCat.ConstNoXfrm )
                    theRelationship = theCat.ConstNoXfrm;
                elseif strcmp( aTo2From,theCat.ConstNil) || strcmp( aFrom2To,theCat.ConstNil )
                    theRelationship = theCat.ConstJustSameSig;
                else
                    theRelationship = theCat.ConstShouldNotBePossible;
                end % if strcmp

            end % if aFromId

        end % Relationship
        
        
        function theCount = FlagCensus( theCat )
            % Count = FlagCensus(Cat): Count how many of each Cat.UniqueSigs there are.
            % 10Apr2015jcr
            
            if isempty(theCat.list)
                theCount = []; % We were passed an empty list.
                return;
            end
            
            aList = theCat.UniqueSigs;
            aTotalList = theCat.AllSigs;
            for index = length(aList):-1:1
                theCount(index) = sum( strcmp( aList(index),aTotalList ) );
            end % for index
                
        end % FlagCensus
        
        
        function [ theFlagA,theFlagB ] = Sig2Flags( theCat,theSig )
            % [FlagA,FlagB] = Sig2Flags(Cat,Sig): Convert flag signature
            % string (or CRCat Id index) Sig into FlagA and FlagB. Returns
            % both FlagA and FlagB = 0 if invalid string or CRCat Index.
            % 10Apr2015jcr

            if iscell(theSig) % Signature from FindBestSignatures comes back
                aSig = theSig{1}; % as a char array wrapped in a cell.
            else
                aSig = theSig;
            end % if iscell

            if isnumeric( aSig ) % We were passed an index into theCat.
                if ~isempty(theCat.list) && theCat.CheckId( aSig )
                    aSig = theCat.list( uint32(aSig) ).flagSig;
                end % if isempty
            end % if numeric

            if ischar( aSig ) && isscalar( find(aSig=='-') ) ...
                        && ~any( aSig~='0' & aSig~='1' & aSig~='-' )
                % Get the index of the '-', which separates the FlagA from the FlagB data.
                aSep = find( aSig == '-' );
                theFlagA = ( aSig( 1:aSep-1 ) == '1' );
                theFlagB = ( aSig( aSep+1:end ) == '1' );
            else
                theFlagA = 0;
                theFlagB = 0;
            end % if ischar

        end % Sig2Flags
        
         
        function [ theSigReturn, theMinError ] = FindBestSignatures( theCat,theY,theFreq,theSig )
            % [ SigReturn,MinError ] = FindBestSignatures( Cat,Y,Freq,Sig ): Find
            % the signature(s) in Cat that best fits the Y data at Freq.
            % Restrict search to only those signatures in the cell array
            % Sig. If not passed, search all signatures.
            % The signature that likely corresponds to the simplest circuit
            % is listed first in SigReturn. Use CRCat.Sig2Id to find the Id's for each sig.
            % Sig is a string or a cell string array and is optional. If
            % not present, all unique signatures in theCat are evaluated.
            % Return a string cell arrray with all the signatures that
            % have rms error within 1% of the minimum error.
            % Large powers of Freq are calculated, so Freq is normalized
            % within this routine to max value of 2.
            % The best fit signature is passed back in FlagA,FlagB and are
            % returned empty if no fit (should only happen if no elements in theCat).
            % Y (complex) and Freq (real, CRCat.Units, default: GHz) must be the same length.
            % Mutlitple Y rows throws an error. 10Nov2021jcr
            
            % Check theSig.
            if nargin == 4
                if ischar(theSig)
                    aSig = { theSig }; % Make it into a single cell cell array.
                else
                    aSig = theSig;
                end % if ischar
            else
                % Get cell list string array of all unique signatures in theCat.
                aSig = theCat.UniqueSigs;
            end % nargin
            
            % Check conditions on theFreq and theY.
            [ aNumYRows,aNumYCols ] = size(theY);
            if ( aNumYRows ~= 1 )
                error('Only one set of admittance data can be checked at a time.\n');
            end % if aNumYRows
            if aNumYCols ~= numel(theFreq)
                error('Number frequencies at which admittance data was provided, %d, and number of frequencies provided, %d, do not match.\n', ...
                    aNumYCols,numel(theFreq) );
            end % if aNumYCols
            
            % Normalize the frequency list so the highest frequency is 2.0.
            aFreqNorm = 0.5 * max( theFreq );
            aFreq = theFreq ./ aFreqNorm;
            % aFreqNorm = 2 * pi * aFreqNorm; % Needed if converting RLCs back from normalized radian freq.
            
            % Get a vector of theY magnitude to normalize the RSS error for each fit.
            aYMag = abs( double(theY) );
            % if aYMag too small, leave that term out of the RSS summation.
            aYNotZero = aYMag > 1.0e-10; % Arbitrary small number, to avoid divide by zero.
            aYMagOk = aYMag( aYNotZero );
            aYInOk = double( theY( aYNotZero ) );
            
            aError = -2.0*ones( 1,length(aSig) ); % Preallocate and initialize the error storage.
            
            % Do each signature, one at a time.
            for iSig = 1:length(aSig)
                [ aFlagA,aFlagB ] = theCat.Sig2Flags( aSig{iSig} ); % We want to see how well we can fit this signature.
                try
                    [ aNumCoef,aDenCoef,aResultFlag ] = CRFit( theY,aFreq,aFlagA,aFlagB ); % Do the fit.
                catch
                    aResultFlag = -4; % CRFit had an error, probably divide by zero or some such.
                end

                if aResultFlag < 0
                    warning('Signature %d, %s: Unable to fit, CRFit error code=%d. Signature will be ignored.\n', ...
                        iSig,char(aSig(iSig)),aResultFlag);
                    aError(iSig) = -1.0; % Negative number is signal to ignore.
                else
                    % Calc fitted Y.
                    aFittedY = double( CREval( aNumCoef,aDenCoef,aFreq ) );
                    aError(iSig) = sum( abs( aYInOk-aFittedY(aYNotZero)) ./ aYMagOk ) / (length(aFreq)+1);
                end % if aResultFlag
                    
            end % for iSig
            
            theMinError = min( aError(aError>=0.0) ); % Return everything within 1 percent of the minimum.
            aSigBest = aSig( aError < theMinError*1.01 & aError >= 0.0 );
            [~,aSortIndex] = sort( cellfun( @length,aSigBest ) ); % Sort by string length with shortest signature first.
            theSigReturn = aSigBest( aSortIndex );
            
        end % CRCat.FindBestSignatures
        
        
        function theId = Sig2Id( theCat,theSig )
            % Id = Sig2Id( Cat,Sig ): Find all comp Id's that have
            % a signature of Sig in Cat. Result returned in an integer
            % vector. Sig must be a single string.  11Nov2021jcr
            
            % Input must be a character array.
             if ( ~ischar( theSig ) )
                error('The signature must be a string, i.e., a character array.\n');
            end % if ischar
            
            % Indices of all comps with theSig signature.
            theId = find( arrayfun( @(x)all( strcmp(x.flagSig,theSig) ),theCat.list ) );
            
        end % CRCat.Sig2Id
        
        
        function theFinalEnds = Draw( theCat,theAction,theEnds,theSize,thePlotOption )
            % FinalEnds = CRCat.Draw( Action,Ends,Size,PlotOption )
            % Action = 'figure' : Set up a figure and axes. Ends determines
            %   axis ranges. If Ends not specified or has zero size, size is
            %   set to seven inches square (convenient for capaturing IEEE
            %   graphics). If Ends has only one non-zero dimension, axes set
            %   to square with that dimension. Otherwise axes set to area
            %   indicated by Ends. The two points in Ends may be listed in
            %   either order. Additional text is used to title the figure.
            % Action = component name in the catalog : Draw the component
            %   schematic. Default Ends place the component vertically near
            %   the top in the center of the plot. The component starts at
            %   the first end. The second end is used only for direction.
            %   Actual final ends returned, useful for adding grounds,
            %   ports, and text. Only one component at a time.
            % Action = integer : Draw the component with that ID (i.e.,
            %   index) in the catalog. Only one component at a time.
            % Action = 'port': Draw a port touching the first End. Any
            %   extra characters are used to label the port, e.g. 'port1'
            %   generates the label '1'. Ends required.
            % Action = 'ground': Draw a ground on the 2nd End. Additional
            %   letters are used to label the ground, e.g., 'groundXXI-15'
            %   labels the ground 'XXI-15'. Ends required.
            % Ends = [x1 y1 x2 y2]: Start and stop locations for drawing.
            %   When drawing a component, port, stop indicates direction.
            %   When drawing a ground, start is used for direction and the
            %   ground starts and the stop point. The actual end point is
            %   returned in FinalEnds when drawing a component.
            % Size = [RLen LineWidth FontSize]: All parts
            %   optional. RLen is the length of an R or L as a fraction of
            %   the X-axis length. Default RLen is 1/10th the length of
            %   the X-axis. If the length of the X-axis changes between
            %   calls to this routine, the size of the next drawing also
            %   changes. Linewidth and FontSize are measured in points.
            %   Default is 1 and 10. Default is used for values set to NaN
            %   and for missing values.
            % PlotOption is a string passed to the plot routine for line 
            %   type and color. Default is '-k'. A linear x and y axis is assumed.
            % Use CRComp.Label to label Figure with component values. Use
            % use DrawRLC to add other components, etc. -- 14Dec2021jcr
            
            if nargin > 5
                error('Too many arguments.');
            end % if nargin
            if nargin > 2 && length(theEnds)~=4
                error('Four numbers required for Ends.');
            end % if nargin
            
            aAction = "figure"; % Default if no action specified.
            aCAction = char( aAction );
            if nargin > 1
                aAction = string(theAction); % So no guessing if char or string.
                aCAction = char( aAction );
            end % if nargin
            
            aPlotOption = '-k'; % Default
            if nargin == 5
                aPlotOption = thePlotOption;
            end % if nargin
            
            % Set the remaining defaults.
            aRLen = 0.1;
            aLineWidth = 1; % Line width in points.
            aFontSize = 10; % Text size in points.
            if nargin > 3
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
            aSize = [ aRLen aLineWidth aFontSize ];
            
            aId = 0;
            if nargin > 1
                if isnumeric( theAction ) % Check for a valid component Id.
                    aId = round( theAction(1) ); % Ignore any extra Id's
                    if aId <= 0 || aId > length( theCat.list )
                        aId = 0;
                    end % if isnumeric
                else % Check for a valid component name.
                    aId = theCat.Name2Id( upper(theAction) ); % Returns 0 if not found.
                    aId = aId(1); % Ignore any extra components.
                end % if isnumeric
            end % if nargin
            
            aFig = gcf;
            if strncmp( aCAction,'figure',6 ) || isempty(aFig.CurrentAxes) % Initialize a figure and axes.
                close( aFig );
                aEnds = [ 3.5 7.0 3.5 0.0 ]; % Default
                aXLim = [ 0.0 7.0 ];
                aYLim = [ 0.0 7.0 ];
                aTitle = '';
                if length( aCAction ) > 6
                    aTitle = aCAction(7:end);
                end % if length
                if nargin > 2 && length(theEnds) == 4
                    aEnds = theEnds;
                    aXLim = [ min( aEnds(3),aEnds(1) ), max( aEnds(3),aEnds(1) ) ];
                    aYLim = [ min( aEnds(4),aEnds(2) ), max( aEnds(4),aEnds(2) ) ];
                end % nargin
                aAxisLength = max( abs(aEnds(3)-aEnds(1)), abs(aEnds(4)-aEnds(2)) );
                if aAxisLength < 1.0e-20
                    aAxisLength = 7.0; % Default.
                end % if aTotalLength
                if min( abs(aEnds(3)-aEnds(1)), abs(aEnds(4)-aEnds(2)) ) / aAxisLength < 0.1 
                    % aEnds make for a plot that is too narrow. Make the limits so plot is square.
                    aXLim = 0.5 * [ aEnds(3)+aEnds(1)-aAxisLength ...
                                    aEnds(3)+aEnds(1)+aAxisLength ];
                    aYLim = 0.5 * [ aEnds(4)+aEnds(2)-aAxisLength ...
                                    aEnds(4)+aEnds(2)+aAxisLength ];
                end % if min
            
                % Setup the figure, axes and aspect ratio
                figure('Name',aTitle,'Units','inches','Position',[0.5 0.5 aXLim(2)-aXLim(1)+0.5 aYLim(2)-aYLim(1)+0.5]);
                axes('Units','inches','Xlim',aXLim,'Ylim',aYLim);
                daspect ( [1 1 1] );
                pbaspect( [1 1 1] ); % All done.
                theFinalEnds = aEnds;
                if strncmp( aCAction,'figure',6 )
                    return;
                end % if strncmp
            end % if strncmp
                
            if strncmp( aCAction,'port',4 ) % Put a port on the figure at first point in aEnds.
                if nargin < 3 % theEnds are required.
                    error('No location specified for drawing a port.');
                end % if nargin
                aEnds = theEnds;
                aLabel = strcat( 'P',aCAction(5:end) );
                DrawRLC( aLabel,aEnds,aSize,aPlotOption );
                theFinalEnds = aEnds;
                
            elseif strncmp( aCAction,'ground',6 ) % Put a ground on the figure at second (last) point in aEnds.
                if nargin < 3 % theEnds are required.
                    error('No location specified for drawing a ground.');
                end % if nargin
                aEnds = theEnds;
                aLabel = strcat( 'G',aCAction(7:end) );
                DrawRLC( aLabel,aEnds,aSize,aPlotOption );
                theFinalEnds = aEnds;
                
            elseif aId % Draw component.
                if nargin > 2 && length(theEnds) == 4
                    aEnds = theEnds;
                else
                    aXlim = get(gca,'Xlim');
                    aYlim = get(gca,'Ylim');
                    aEnds = [ 0.5*(aXlim(2)+aXlim(1)) 0.9*aYlim(2)  0.5*(aXlim(2)+aXlim(1)) 0.0 ]; % Default
                end % if nargin

                % Pull up the library entry for the component.
                aCatEntry = theCat.list( aId );

                % Extract the group (usually a Roman numeral) from the name.
                aIndex = find( aCatEntry.name == '-' );
                if isempty( aIndex )
                    aIndex = 1+length( aCatEntry.name );
                end % if isempty
                aGroup = aCatEntry.name(1:aIndex-1);

                switch aGroup

                    case { 'R', 'L', 'C' }
                        aX = [ 0.0 1.5 ]; % End points of element(s) to be drawn,
                        aY = [ 0.0 0.0 ]; % before scaling and rotating. Last xy
                                          % pair is the final end point for
                                          % return in theFinalEnds.
                        aLabels = string( aCatEntry.symV );

                    case { 'ParRL', 'ParRC', 'ParLC' }
                        %      1          2          3          4          5        6
                        aX = [ 0.25 1.75  0.25  1.75 0.25  0.25 1.75  1.75 0.0 0.25 1.75 2.0 ];
                        aY = [ 0.50 0.50 -0.50 -0.50 0.50 -0.50 0.50 -0.50 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ]; % 'W' == Wire.

                    case { 'SerRL', 'SerRC', 'SerLC' }
                        %      1       2
                        aX = [ 0.0 1.5 1.5 3.0 ];
                        aY = [ 0.0 0.0 0.0 0.0 ];
                        aLabels = string( aCatEntry.symV );

                    case 'ParRLC'
                        %      1         2         3         4         5         6         7
                        aX = [ 0.25 1.75 0.25 1.75 0.25 1.75 0.25 0.25 1.75 1.75 0.00 0.25 1.75 2.00 ];
                        aY = [ 1.00 1.00 0.00 0.00 -1.0 -1.0 -1.0 1.00 -1.0 1.00 0.00 0.00 0.00 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'SerRLC'
                        %      1       2       3
                        aX = [ 0.0 1.5 1.5 3.0 3.0 4.5 ];
                        aY = [ 0.0 0.0 0.0 0.0 0.0 0.0 ];
                        aLabels = string( aCatEntry.symV );

                    case 'III' % Nodal: 1 0 1 2 2 0
                        %      1          2           3           4         5          6         7
                        aX = [ 0.25 3.25  0.25  1.75  1.75  3.25  0.25 0.25 0.00 0.25  3.25 3.25 3.25 3.50 ];
                        aY = [ 0.50 0.50 -0.50 -0.50 -0.50 -0.50 -0.50 0.50 0.00 0.00 -0.50 0.50 0.00 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'IV' % Nodal: 1 2 2 0 2 0
                        %      1        2        3        4        5       6 
                        aX = [ 0.0 1.5  1.5  3.0 1.5 3.0  1.5 1.5  3.0 3.0 3.0 3.25 ];
                        aY = [ 0.0 0.0 -0.5 -0.5 0.5 0.5 -0.5 0.5 -0.5 0.5 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'V' % Nodal: 1 0 1 2 2 3 3 0
                        %      1          2           3           4          5          6         7         8
                        aX = [ 0.25 4.75  0.25  1.75  1.75  3.25  3.25  4.75 0.25 0.25 0.00 0.25  4.75 4.75 4.75 5.0 ];
                        aY = [ 0.50 0.50 -0.50 -0.50 -0.50 -0.50 -0.50 -0.50 -0.5 0.50 0.00 0.00 -0.50 0.50 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'VI' % Nodal: 1 2 2 0 2 0 2 0
                        %      1       2       3        4         5        6       7  
                        aX = [ 0.0 1.5 1.5 3.0 1.5 3.0  1.5  3.0  1.5 1.5  3.0 3.0 3.0 3.25 ];
                        aY = [ 0.0 0.0 1.0 1.0 0.0 0.0 -1.0 -1.0 -1.0 1.0 -1.0 1.0 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'VII' % Nodal: 1 2 2 0 1 3 3 0
                        %      1         2         3         4          5         6        7         8  
                        aX = [ 0.25 1.75 1.75 3.25 0.25 1.75 1.75 3.25  0.25 0.25 0.0 0.25 3.25 3.25 3.25 3.5 ];
                        aY = [ 0.60 0.60 0.60 0.60 -0.6 -0.6 -0.6 -0.6 -0.60 0.60 0.0 0.00 -0.6 0.60 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'VIII' % Nodal: 1 2 1 2 2 0 2 0
                        %      1         2         3         4          5         6        7         8        9  
                        aX = [ 0.25 1.75 0.25 1.75 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 0.60 0.60 -0.6 -0.6 0.6  0.6 -0.60 -0.6 -0.6 0.60 -0.6 0.60 -0.6 0.60 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'IX' % Nodal: 1 0 1 0 1 2 2 0
                        %      1         2         3         4         5         6         7        8   
                        aX = [ 0.25 3.25 0.25 3.25 0.25 1.75 1.75 3.25 0.25 0.25 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.0  1.0  0.0  0.0  -1.0 -1.0 -1.0 -1.0 -1.0 1.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'X' % Nodal: 1 2 2 3 3 0 3 0
                        %      1       2       3        4         5         6      7 
                        aX = [ 0.0 1.5 1.5 3.0 3.0 4.5  3.0  4.5  3.0 3.0  4.5 4.5 4.5 4.75 ];
                        aY = [ 0.0 0.0 0.0 0.0 0.6 0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XI' % Nodal: 1 0 1 2 2 0 2 0
                        %      1         2         3         4         5         6         7         6        9 
                        aX = [ 0.25 3.25 0.25 1.75 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.00 1.00 0.00 0.00 0.00 0.00 -1.0 -1.0 0.00 1.00 -1.0 0.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XII' % Nodal: 1 2 2 0 2 3 3 0
                        %      1       2        3         4         5        6       7
                        aX = [ 0.0 1.5 1.5 4.5  1.5  3.0  3.0  4.5  1.5 1.5  4.5 4.5 4.5 4.75 ];
                        aY = [ 0.0 0.0 0.6 0.6 -0.6 -0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XIII' % Nodal: 1 0 1 0 1 2 2 3 3 0
                        %      1         2          3        4         5         6         7         8        9
                        aX = [ 0.25 4.75 0.25 4.75 0.25 1.75 1.75 3.25 3.25 4.75 0.25 0.25 4.75 4.75 0.0 0.25 4.75 5.0 ];
                        aY = [ 1.00 1.00 0.00 0.00 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 -1.0 1.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XIV' % Nodal: 1 2 2 3 3 0 3 0 3 0
                        %      1       2       3       4        5         6        7       8
                        aX = [ 0.0 1.5 1.5 3.0 3.0 4.5 3.0 4.5  3.0  4.5  3.0 3.0  4.5 4.5 4.5 4.75 ];
                        aY = [ 0.0 0.0 0.0 0.0 1.0 1.0 0.0 0.0 -1.0 -1.0 -1.0 1.0 -1.0 1.0 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XV' % Nodal: 1 2 2 0 1 3 3 4 4 0
                        %      1        2        3         4         5         6         7         8        9
                        aX = [ 0.25 2.5 2.5 4.75 0.25 1.75 1.75 3.25 3.25 4.75 0.25 0.25 4.75 4.75 0.0 0.25 4.75 5.0 ];
                        aY = [ 0.60 0.6 0.6 0.60 -0.6 -0.6 -0.6 -0.6 -0.6 -0.6 -0.6 0.60 -0.6 0.60 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XVI' % Nodal: 1 2 1 2 2 0 2 0 2 0
                        %      1         2         3         4         5         6         7         8         9        10
                        aX = [ 0.25 1.75 0.25 1.75 1.75 3.25 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 0.60 0.60 -0.6 -0.6 1.00 1.00 0.00 0.00 -1.0 -1.0 -0.6 0.60 -1.0 1.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XVII' % Nodal: 1 0 1 0 1 0 1 2 2 0
                        %      1         2         3         4         5         6         7         8         9
                        aX = [ 0.25 3.25 0.25 3.25 0.25 3.25 0.25 1.75 1.75 3.25 0.25 0.25 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.50 1.50 0.50 0.50 -0.5 -0.5 -1.5 -1.5 -1.5 -1.5 -1.5 1.50 -1.5 1.50 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XVIII' % Nodal: 1 2 2 3 3 4 4 0 4 0
                        %      1       2       3       4        5         6        7       8 
                        aX = [ 0.0 1.5 1.5 3.0 3.0 4.5 4.5 6.0  4.5  6.0  4.5 4.5  6.0 6.0 6.0 6.25 ];
                        aY = [ 0.0 0.0 0.0 0.0 0.0 0.0 0.6 0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XIX' % Nodal: 1 0 1 2 2 0 2 0 2 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 3.25 0.25 1.75 1.75 3.25 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.50 1.50 0.00 0.00 0.50 0.50 -0.5 -0.5 -1.5 -1.5 0.00 1.50 0.50 -1.5 1.50 -1.5 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XX' % Nodal: 1 2 2 0 2 3 3 4 4 0
                        %      1       2        3         4         5         6        7       8 
                        aX = [ 0.0 1.5 1.5 5.5  1.5  3.0  3.0  4.5  4.5  5.5  1.5 1.5  5.5 5.5 5.5 5.75 ];
                        aY = [ 0.0 0.0 0.6 0.6 -0.6 -0.6 -0.6 -0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XXI' % Nodal: 1 0 1 2 2 0 1 3 3 0
                        %      1         2         3         4         5         6         7         8        9 
                        aX = [ 0.25 3.25 0.25 1.75 1.75 3.25 0.25 1.75 1.75 3.25 0.25 0.25 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.10 1.10 0.00 0.00 0.00 0.00 -1.1 -1.1 -1.1 -1.1 -1.1 1.10 -1.1 1.10 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XXII' % Nodal: 1 2 2 3 2 3 3 0 3 0
                        %      1       2        3        4        5         6        7        8       9 
                        aX = [ 0.0 1.5 1.5 3.0  1.5  3.0 3.0 4.5  3.0  4.5  1.5 1.5  3.0 3.0  4.5 4.5 4.5 4.75 ];
                        aY = [ 0.0 0.0 0.6 0.6 -0.6 -0.6 0.6 0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XXIII' % Nodal: 1 0 1 2 1 2 2 0 2 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 3.25 0.25 1.75 0.25 1.75 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.00 1.00 0.00 0.00 -1.0 -1.0 0.00 0.00 -1.0 -1.0 -1.0 1.00 -1.0 0.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXIV' % Nodal: 1 2 2 3 3 0 2 4 4 0
                        %      1       2       3        4         5         6        7        8
                        aX = [ 0.0 1.5 1.5 3.0 3.0 4.5  1.5  3.0  3.0  4.5  1.5 1.5  4.5 4.5  4.5 4.75 ];
                        aY = [ 0.0 0.0 0.6 0.6 0.6 0.6 -0.6 -0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6  0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' ];

                    case 'XXV' % Nodal: 1 0 1 2 2 3 3 0 3 0
                        %      1        2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 4.75 0.25 1.75 1.75 3.25 3.25 4.75 3.25 4.75 0.25 0.25 3.25 3.25 4.75 4.75 0.0 0.25 4.75 5.0 ];
                        aY = [ 1.00 1.00 0.00 0.00 0.00 0.00 0.00 0.00 -1.0 -1.0 0.00 1.00 -1.0 0.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXVI' % Nodal: 1 2 2 0 2 0 2 3 3 0
                        %      1       2       3        4         5         6        7       8        9
                        aX = [ 0.0 1.5 1.5 4.5 1.5 4.5  1.5  3.0  3.0  4.5  1.5 1.5  4.5 4.5 0.0 0.25 4.5 4.75 ];
                        aY = [ 0.0 0.0 1.0 1.0 0.0 0.0 -1.0 -1.0 -1.0 -1.0 -1.0 1.0 -1.0 1.0 0.0 0.00 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XXVII' % Nodal: 1 0 1 0 1 2 2 0 2 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 3.25 0.25 3.25 0.25 1.75 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.50 1.50 0.50 0.50 -0.5 -0.5 -0.5 -0.5 -1.5 -1.5 -0.5 1.50 -1.5 -0.5 -1.5 1.50 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXVIII' % Nodal: 1 2 2 3 3 0 3 4 4 0
                        %      1       2       3        4         5         6        7       8        9
                        aX = [ 0.0 1.5 1.5 3.0 3.0 6.0  3.0  4.5  4.5  6.0  3.0 3.0  6.0 6.0 0.0 0.25 6.0 6.25 ];
                        aY = [ 0.0 0.0 0.0 0.0 0.6 0.6 -0.6 -0.6 -0.6 -0.6 -0.6 0.6 -0.6 0.6 0.0 0.00 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' ];

                    case 'XXIX' % Nodal: 1 2 2 0 1 3 3 0 3 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 1.75 1.75 3.25 0.25 1.75 1.75 3.25 1.75 3.25 0.25 0.25 1.75 1.75 3.25 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.00 1.00 1.00 1.00 0.00 0.00 0.00 0.00 -1.0 -1.0 0.00 1.00 -1.0 0.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXX' % Nodal: 1 2 1 2 2 0 2 3 3 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 1.75 0.25 1.75 1.75 4.75 1.75 3.25 3.25 4.75 0.25 0.25 1.75 1.75 4.75 4.75 0.0 0.25 4.75 5.0 ];
                        aY = [ 0.60 0.60 -0.6 -0.6 0.60 0.60 -0.6 -0.6 -0.6 -0.6 -0.6 0.60 -0.6 0.60 -0.6 0.60 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXXI' % Nodal: 1 0 1 2 2 0 2 3 3 0
                        %      1         2         3         4         5         6         7         8         9        10 
                        aX = [ 0.25 4.75 0.25 1.75 1.75 4.75 1.75 3.25 3.25 4.75 0.25 0.25 1.75 1.75 4.75 4.75 0.0 0.25 4.75 5.0 ];
                        aY = [ 1.00 1.00 0.00 0.00 0.00 0.00 -1.0 -1.0 -1.0 -1.0 0.00 1.00 -1.0 0.00 -1.0 1.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXXII' % Nodal: 1 2 2 0 2 3 3 0 3 0
                        %      1       2       3       4        5        6        7        8       9        10
                        aX = [ 0.0 1.5 1.5 4.5 1.5 3.0 3.0 4.5  3.0  4.5 1.5 1.5  3.0 3.0  4.5 4.5 0.0 0.25 4.5 4.75 ];
                        aY = [ 0.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 -1.0 -1.0 0.0 1.0 -1.0 0.0 -1.0 1.0 0.0 0.00 0.0 0.00 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' 'W' 'W' 'W' ];

                    case 'XXXIII' % Nodal: 1 2 1 3 2 3 2 0 3 0
                        %      1         2         3         4         5         6        7 
                        aX = [ 1.75 0.25 0.25 1.75 1.75 1.75 3.25 1.75 1.75 3.25 0.0 0.25 3.25 3.5 ];
                        aY = [ 1.50 0.00 0.00 -1.5 1.50 -1.5 0.00 1.50 -1.5 0.00 0.0 0.00 0.00 0.0 ];
                        aLabels = [ string( aCatEntry.symV ) 'W' 'W' ];

                    otherwise
                        error('No schematic is yet set up for network %s.',aCatEntry.name);

                end % switch
                
                % Get the data aspect ratio of the current set of axes.
                aDataAspectRatio = get( gca,'DataAspectRatio' );
                aAspectRatio = aDataAspectRatio(1) / aDataAspectRatio(2);
                
                aXLim = xlim(gca);
                aRLength = aRLen * (aXLim(2) - aXLim(1));
                % Get the rotation angle.
                aAngle = atan2( aEnds(4)-aEnds(2),aEnds(3)-aEnds(1) );

                % Rotate and scale the coordinates.
                aXFinal = aEnds(1) + aRLength * ( cos(aAngle) * aX - sin(aAngle) * aY );
                aYFinal = aEnds(2) + (1.0/aAspectRatio) * aRLength * ( sin(aAngle) * aX + cos(aAngle) * aY );

                aNumGraphics = length( aLabels ); % Draw the component.
                for aIndex = 1:aNumGraphics
                    aElementEnds = [ aXFinal(2*aIndex-1) aYFinal(2*aIndex-1) aXFinal(2*aIndex) aYFinal(2*aIndex) ];
                    DrawRLC( aLabels(aIndex),aElementEnds,aSize,aPlotOption );
                end % for aIndex

                theFinalEnds = [ aEnds(1) aEnds(2) aXFinal(end) aYFinal(end) ];
            else
                warning('No valid action found.');
            end % if action
            
        end % CRCat.Draw
        
        
        function DrawArray( theCat,theComp,theOption)
            % CRCat.DrawArray( Comp,Option ) Draw an array of the
            % first 10 components stored in Comp that have a non-zero id.
            % Include the component values in the plot (assume first is the
            % desired solution, when there is more than one). When the Comp
            % array is a CRSprout, pass Option set to 'ports' and
            % each odd indexed comp will be labeled Series and even
            % indexed Comps will be labeled Shunt. If Option is not passed,
            % or is passed with any other value, there will be no port
            % labeling. Comp can also be an array of integer comp id's, or
            % network names, in which case no series/shunt or element
            % value labels are added. -- 21Dec2021jcr
            % 15Jan2022jcr(added Sprout ability).
            
            if isempty(theComp)
                return; % Nothing to draw.
            end % if isempty
            
            % Figure out number of components to be drawn.
            if isa(theComp,'CRComp')
                aId = theCat.Name2Id( [theComp.name] );
            elseif isnumeric(theComp)
                aId = theComp; % theComp should be an array of ints.
            elseif isstring(theComp)||ischar(theComp)||iscellstr(theComp)
                aId = theCat.Name2Id(theComp);
            else
                error('Argument must be a CRComp or network names or Ids.')
            end % if isa
            aNumCompTotal = nnz(aId); % Components with id==0 are not drawn.
            aNumComp = min( aNumCompTotal,10 ); % Limit aNumComp to the maximum number that will be drawn.
            if aNumComp ~= aNumCompTotal && nargin >= 3 % Give this warning only for CRSprouts.
                warning('There are %d components. Only the first 10 will be drawn.',aNumCompTotal);
            end % aNumComp
            
            if aNumComp == 0
                warning('No components listed in Comp vector.');
                return;
            elseif aNumComp <= 5
                aNumRow = 1; % One row if 5 or fewer components to draw.
                aNumCol = aNumComp;
            else
                aNumRow = 2; % Two rows if more than 5 components to be drawn.
                aNumCol = round( 0.5*aNumComp + 0.01 );  % Be sure it rounds up.
            end % if aNumComp
            
            aComponentHeight = 3; % Plot area for each component in inches.
            aComponentWidth = 2;
            aEnds = [ 0.5*aComponentWidth 0.95*aComponentHeight 0.5*aComponentWidth 0.0 ]; % Ends for drawing component schematic.
            aSize = [ 0.2 1 12 ]; % Resistor length as a fraction of x-axis length, line point size, font point size.

            figure('Units','Inches','Position',[1 1 aNumCol*aComponentWidth aNumRow*aComponentHeight])
            set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
            
            aCount = 1; % Counts number of drawn components.
            for aIndex = 1:length(aId) % Index into aId and theComp arrays.
                if aId(aIndex) && aCount <= aNumComp % Ignore components with id == 0.
                    aAxis = subplot('position',[ 0.9 0.1 0.1 0.1 ] ); % Create the axes so sure not to overlapp an existing set of axes.
                    aRow = fix(1+(aCount-.9)/aNumCol);
                    aCol = aCount - (aRow-1)*aNumCol;
                    aPosition = [ (aCol-1)*aComponentWidth (aNumRow-aRow)*aComponentHeight aComponentWidth aComponentHeight ];
                    set( aAxis,'Units','inches','Position',aPosition );
                    daspect( [1 1 1] ); % Now fixed so all drawings at same scale.
                    pbaspect( [aComponentWidth aComponentHeight 1] ); % Fix the physical dimensions of the component plot.
                    xlim( [ 0 aComponentWidth ] );
                    ylim( [ 0 aComponentHeight ] );
                    aFinalEnds = theCat.Draw(aId(aIndex),aEnds,aSize); % Position schematic starting near the center top and going down.
                    if isa(theComp(aIndex),'CRComp')
                        aPortStr = 'port';  % Default is draw the port, no CRSprout label
                        if nargin>=3 && strcmpi( theOption,'ports' ) % Case insensitive str comparison.
                            if aCount == aNumCompTotal % Do a START label for the last Comp.
                                aPortStr = 'port1) START';
                            elseif mod(aIndex,2) % Index is odd, so this component is connected in shunt.
                                aPortStr = sprintf('port%d) SHUNT',aNumCompTotal-aCount+1);
                            else % Index is even, so this component is connected in series.
                                aPortStr = sprintf('port%d) SERIES',aNumCompTotal-aCount+1);
                            end % if mod
                        end % if nargin
                        theCat.Draw(aPortStr,aFinalEnds,aSize); % Draw and (optionally) label the port.
                        aGroundEnds(1:2) = aFinalEnds(3:4);
                        aGroundEnds(2) = aGroundEnds(2) - 0.35*aSize(1); % Move port symbol down so the top touches the bottom line.
                        aGroundEnds(3:4) = aFinalEnds(3:4);
                        aGroundEnds(4) = 0.5*aGroundEnds(4); % To put the label on the left side of the port symbol.
                        aGroundStr = sprintf('port%s.%d',theCat.list(aId(aIndex)).name,aId(aIndex)); % Label the ground with the component name and Id and mark it with a port symbol.
                        theCat.Draw(aGroundStr,aGroundEnds,aSize);
                        % Now add a label with all the element values.
                        theComp(aIndex).Label( [aFinalEnds(3)+0.5*aSize(1) aFinalEnds(4)+0.5*aSize(1)],theCat ); % Assume the desired solution has been moved to, or is, solution number 1.
                    else
                        theCat.Draw('port',aFinalEnds,aSize);
                        aGroundStr = sprintf('ground%s/%d',theCat.list(aId(aIndex)).name,aId(aIndex)); % Label the ground with the component name and Id.
                        theCat.Draw(aGroundStr,aFinalEnds,aSize);
                    end % if isa
                    axis off;
                    aCount = aCount + 1;
                end % if aId
            end % aIndex
        end % CRCat.DrawArray
        
        
        function theSymConv = SameSymConv( theCat, theId1, theId2 )
            % SymConv = SameSymConv( Cat,Id1,Id2 ) Return an array of syms for converting
            % the RLCs of Id1 to Id2. If no conversion possible, return empty. This routine
            % solves for the equations from scratch for storage in Cat. Generally used only when adding new
            % components to the Cat. If you want to simply access transformation equations that
            % are already determined and stored, use Transformation(Cat,FromId,ToId). 12Apr2015jcr
            
            if isempty(theCat.list)
                theSymConv = []; % We were passed an empty list.
                return;
            end
            
            theCat.CheckId( [theId1 theId2],1 );

            % If theId1 and theId2 are the same, just copy the theId2
            % variables over into the solution, theSymConv. Sometimes, like
            % with network Id 543, the pure resistor Wheatstone bridge, it
            % is not strictly equivalent to itself, but is rather one of many
            % possible mappings from it to itself.
            if theId1 == theId2
                theSymConv = theCat.list(theId1).symVn;
                return;
            end % if theId1

            % Check for special cases.
            if strcmp(theCat.list(theId1).name,'XXIV-2') && strcmp(theCat.list(theId2).name,'XXIX-1')
                % In this case, Ids=211,327, I let solve try to solve for 36 hours, no
                % result, so either there is some kind of incredible solution
                % that would have eventually come, or there is a solve bug. -- jcr31Mar2025
                theSymConv = [];
                return
            elseif strcmp(theCat.list(theId1).name,'XXV-4') && strcmp(theCat.list(theId2).name,'XXIX-1')
                % Id 231->327 is similar sitaution to Id 211->327. Did not wait so long this time.
                theSymConv = [];
                return
            elseif strcmp(theCat.list(theId1).name,'XXVI-1') && strcmp(theCat.list(theId2).name,'XXIX-1')
                % Id 246->327 is similar sitaution to Id 211->327. Did not wait so long this time.
                theSymConv = [];
                return
            elseif strcmp(theCat.list(theId1).name,'XXX-11') && strcmp(theCat.list(theId2).name,'XXIX-1')
                % Id 364->327 is similar sitaution to Id 211->327. Did not wait so long this time.
                theSymConv = [];
                return
            elseif strcmp(theCat.list(theId1).name,'XXXI-11') && strcmp(theCat.list(theId2).name,'XXIX-1')
                % Id 391->327 is similar sitaution to Id 211->327. Did not wait so long this time.
                theSymConv = [];
                return
            end % if strcmp
            
            % Check for not same flagSig (i.e., transfer functions are differnet form).
            if ~strcmp( theCat.list(theId1).flagSig, theCat.list(theId2).flagSig )
                theSymConv = []; % Not possible to convert from one to the other.
                return
            end % if theCat
            
            % Get array of the sym for all the coefficients of both comps.
            syms s % We want the coeffients of powers of s.
            aC1 = [ coeffs( theCat.list(theId1).symA,s )  coeffs( theCat.list(theId1).symB,s ) ];
            aC2 = [ coeffs( theCat.list(theId2).symA,s )  coeffs( theCat.list(theId2).symB,s ) ];
            
            % Normalize both sets of coefficents to the last coefficent,
            % and then throw that last coefficent away.
            aC1 = aC1./aC1(end);
            aC1(end) = [];
            aC2 = aC2./aC2(end);
            aC2(end) = [];
            
            % Create syms variables for comp Id2.
            aV = sym( 'aV',[1,length(theCat.list(theId2).symVn)] );
            aC2s = subs( aC2,theCat.list(theId2).symVn,aV );
            
            warning('off','symbolic:solve:warnmsg3');
            warning('off','symbolic:solve:SolutionsDependOnConditions');
            warning('off','symbolic:solve:FallbackToNumerical');
            % DO NOT use simplify on aC1-aC2s, it can make the equation unsolvable or yield spurious solutions by MATLAB's solve function.
            % See, for example, solutions to or from id=330, 'XXIX-4'. jcr07Jan2025.
            try
                aSolve = solve( aC1 - aC2s, aV ); % DO NOT use simplify on aC1-aC2s, it can make the equation unsolvable or yield spurious solutions by solve.
            catch
                aSolve = []; % No solution, keep going.
            end % try
            warning('on','symbolic:solve:warnmsg3');
            warning('on','symbolic:solve:SolutionsDependOnConditions');
            warning('on','symbolic:solve:FallbackToNumerical');

            if isempty( aSolve )
                theSymConv = []; % No solution.
                return
            end % if isempty
            
            if isstruct(aSolve) % simplify added jcr13Apr2017
                for index = length(aV):-1:1 % Transfer structure to a sym array and return.
                    theSymConv(:,index) = simplify( aSolve.( char( aV(index) ) ) ); % If multiple solutions, put each one on a different row.
                end % for iV
            elseif ~isempty( aSolve ) % Must already be an array.
                theSymConv = simplify( aSolve );
            end % if isstruct
            
            % if any of the solutions do not have a symbolic variable in them, then that is
            % not a desired solution. See solution for XI-26 -> XII-26 for example.
            aIsNoVar = cellfun( @isempty, arrayfun( @symvar,theSymConv,'UniformOutput',false ) );
            if any( aIsNoVar(:) )
                theSymConv = []; % No variables in solution...so no solution.
                return
            end % if isempty
            
            % Sometimes solve produces gigantic warnings, so check the solution(s) to see if they really work.
            [aNumSolutions,~] = size( theSymConv );
            for index = aNumSolutions:-1:1
                % Check each solution to make sure it works. Calculate the sym coeffs of aId2 using the
                % solution for the aV in terms of the RLCs of the aId2 comp.
                try
                    aC2BackSolved = subs( aC2s, aV, theSymConv(index,:) );
                    % Set up a numerical sym test vector for the values of the aId1 RLCs. The equations are
                    % sometimes pretty long, and should simplify, but sometimes MATLAB cannot do it with the
                    % RLCs left in there symbolically.
                    aSymError = aC2BackSolved - aC1; % For theId1=97,theId2=588, do not use simplify on this one becasue it takes forever.
                    if ~isempty( symvar(aSymError) )
                        % Check to see if numercally evaluates to zero error, i.e., simplify should have worked but is not smart enough.
                        aNumericalError = norm( double( subs(aSymError,theCat.list(theId1).symV,theCat.list(theId1).testEL) ) );
                        if aNumericalError > 1.0e-10
                            % warning('#1 Solve appears to have provided a bad solution for converting id %d (%s) to id %d (%s). Solution ignored.',theId1,theCat.list(theId1).name,theId2,theCat.list(theId2).name);
                            % Bad solution example, first 2 of 4 solutions for Id 33 to 557.
                            theSymConv(index,:) = []; % Remove solution, it is not valid.
                        end % if aNumericalError
                    end % if ~isempty
                catch
                    theSymConv(index,:) = []; % Remove solution, it is not valid.
                    % warning('#2 Solve appears to have provided a bad solution for converting id %d (%s) to id %d (%s). Solution ignored.',theId1,theCat.list(theId1).name,theId2,theCat.list(theId2).name);
                    % Bad solution example, first 2 of 4 solutions for Id 33 to 557.
                end % try
            end % for index
                
        end % SameSymConv
        
        
        function SameSet( theCat,theMoreToDo )
            % SameSet(Cat): Go through Cat and, if possible, solve for
            % conversion equations from each Id to its equivalent or
            % degenerate mates. 01May2015jcr
            % Substantially reduced time required by trying to fit an
            % evaluated admittance result from a given iBaseId to its
            % candidate mating iSameId. Go on to try to
            % solve for the transformation equations only if the numerical fit
            % using the test RLC values is essentially perfect.
            % Will reuse any existing symSame transformation equations
            % assuming that they are correct. If passed, do no more
            % than MoreToDo components. jcr19jan2025
            
            if isempty(theCat.list) || theMoreToDo <= 0
                return; % We were passed an empty list or told to do nothing this time around.
            end

            % If there are any Ids in theCat that have not already been
            % filled except for sameId and symSame members, return. They must
            % all be filled before finishing off sameId and symSame members.
            aAllSigs = theCat.AllSigs'; % String cell row vector of all flag signatures.
            if any( cellfun(@isempty,aAllSigs) )
                return
            end % if any
            
            % Limit all calculations to no
            % more than an additional theMoreToDo Ids in theCat.list.
            % This is to allow the base cat calculation to save results and
            % lets the user restart and do another bunch part way through...
            % this is because a complete fill can take several days. jcr19jan2025
            if nargin == 2
                aCountLimit = theMoreToDo;
            else
                aCountLimit = numel(theCat.list);
            end % if nargin
            aCount = 0;
            aFreq = linspace(1,10,20); % Used during quick test for equivalency or degeneracy.
            
            % Go through each Id in theCat and find how many Ids have
            % the same flagSig (these are candidate equiv/degen comps) and
            % put their numerical Ids in the iNewSameId vector
            % and determine the transformation equations if possible and
            % put them in aNewSymSame vector. Copy any existing symSame
            % data, data that is assumed to be correct. When finished with
            % each iBaseId, drop the data into theCat.list(iBaseId).symSame
            % and theCat.list(iBaseId).sameId.
            aLegendNeeded = 1; % Info on codes for the various transforms found.
            for iBaseId = 1:numel(theCat.list)
                % Get the indices of all Ids with the same flagSig.
                iNewSameId = find( strcmp( aAllSigs,aAllSigs{ iBaseId } ) );
                % If the iBaseID vector is identical to iNewSameId, iBaseId is already done.
                if aCount < aCountLimit && ~isequal( theCat.list( iBaseId ).sameId,iNewSameId )

                    if aLegendNeeded % There were some transforms solved for.
                        % Output some helpful information for the user.
                        theCat.NetworkTransformLegend;
                        aLegendNeeded = 0;
                    end % if aLegendNeeded

                    fprintf('Solving transforms for %s, Id = %d:',theCat.list(iBaseId).name,iBaseId);
                    aCount = aCount + 1;
                    aRmsErrorLimit = 1e-10; % Accept rms error of a fit less than this amount to be perfect fit.
                    aBaseComp = CRComp( iBaseId,theCat ); % Create base component pre-loaded with test RLC values.
                    aBaseY = aBaseComp.Eval(aFreq); % Will attempt to synthesize same response for iSameId component.

                    % Transfer previous symSame equations for any unchanged sameId values.
                    aNumNew = numel(iNewSameId);
                    aNumOld = numel(theCat.list( iBaseId ).sameId);
                    aNumMin = min(aNumNew,aNumOld);
                    aNewSymSame = cell( 1,aNumNew ); % Allocate new and maybe larger cell memory.
                    if aNumMin > 0
                        for iIndex = 1:aNumMin
                            if theCat.list( iBaseId ).sameId(iIndex) == iNewSameId(iIndex)
                                aNewSymSame{ iIndex } = theCat.list( iBaseId ).symSame{ iIndex };
                            end % if theCat.list
                        end % for iIndex
                    end % if aNumMin

                    % Look for transform equations from iBaseId to iSameId.
                    for iSame = 1:numel(iNewSameId)
                        % if symSame already present for iSameId, no more
                        % to do for this iSameId. If error of fitting Base
                        % data to Same component is close to zero, solve for transform.
                        iSameId = iNewSameId(iSame);
                        fprintf(' %d',iSameId);
                        if isempty( aNewSymSame{iSame} )
                            % Set up the Same component for quick relationship test with Base component.
                            aSameComp = CRComp( iSameId,theCat ); 
                            % See if we can synthesize (using symEL equations)
                            % iSameId based on the iBaseId data and
                            % see if we get the exact same results.
                            if ~isempty(aSameComp.symEL)
                                aRmsError = aSameComp.Fit( aBaseY,aFreq );
                                if isempty(aRmsError) % If there are synthesis
                                    % equations but still no fit, likely there are fixed
                                    % elements, so try to solve transform anyway.
                                    aRmsError = -0.1; % Signal that there was no fit even though we have synthesis equations.
                                    % Need to set some dummy element values so
                                    % test for trivial relationship fails.
                                    aSameComp.SetEL( theCat.list(iSameId).testEL );
                                end % if isempty
                            else % iSameId could not be fitted due to no symEL synthesis...
                                fprintf('x'); % ...equations, so no solve attempted.
                                aNewSymSame{iSame} = theCat.ConstNil;
                                aRmsError = 10000; % Large value, to signal no fit.
                            end % ~isempty

                            if aRmsError(1) < aRmsErrorLimit
                                if ( any( abs(aSameComp.valEL)>1e10,'all' ) || any( abs(aSameComp.valEL)<1e-10,'all' ) )
                                    aNewSymSame{iSame} = theCat.ConstTrivial; % If any short or open RLCs.
                                    fprintf('t'); % The fit resulted in a trivial regen Id.
                                else
                                    aSolve = theCat.SameSymConv( iBaseId,iSameId ); % Solve for the transformation equations.
                                    if ~isempty(aSolve)
                                        aNewSymSame{iSame} = aSolve;
                                        fprintf('*'); % Found a solution for transformation equations.
                                    elseif aRmsError >= 0
                                        aNewSymSame{iSame} = theCat.ConstEqnNotFound;
                                        fprintf('-'); % Found no solution, but there should be one.
                                    else % Lilely has fixed elements and no transform found.
                                        fprintf('X'); % There is a very slim chance that a transform exists...
                                        aNewSymSame{iSame} = theCat.ConstEqnNotFound; % ...and solve just could not find it.
                                    end % if ~isempty(aSolve)
                                end % if any
                            else
                                fprintf('X'); % iSameId did not fit iBaseId data perfectly, so we know there is no...
                                aNewSymSame{iSame} = theCat.ConstNoXfrm; % ...transform, so no solve attempted.
                            end % if ~isempty
                        else
                            fprintf('o'); % Previous data used.
                        end % if isempty
                    end % for iSame

                    fprintf('\n');
                    theCat.list( iBaseId ).sameId = iNewSameId;
                    theCat.list( iBaseId ).symSame = aNewSymSame;

                end % if aCount
            end % for iBaseId

            fprintf('\n\n');

        end % SameSet


        function SetSymAB( theCat,theId )
            % For each Id component, symbolically evaluate symA and symB, the numerator and denonminator
            % of the admittance. If Id is empty or not there, all components are done. This routine does symbolically what
            % CRComp.Nodal does numerically. jcr09Apr2019
                     
            if isempty(theCat.list)
                return; % We were passed an empty list.
            end
            
            if nargin <= 1 || numel( theId ) == 0
                aIdList = 1:numel(theCat.list) ; % Do all elements.
            else
                if isnumeric( theId )
                    theCat.CheckId( theId,1 );
                    aIdList = theId;
                else
                    error('Passed variable Id is not numeric.\n');
                end
            end % if nargin
            
            for aIndex = 1:numel(aIdList) % Go through each component in theCat.
                aId = aIdList( aIndex );
                aSymV = theCat.list(aId).symV;
                aSymVn = theCat.list(aId).symVn; % Nodal variables, could be function of any symV variables, first letter must be R, L, or C.
                if isempty( aSymVn )
                    aSymVn = aSymV; % If special nodal variables not set up, use the basic aSymV variables.
                end

                % aSymV must be a subset of aSymVn.
                if ~all( ismember( aSymV,aSymVn ) )
                    error('symV must be a subset of symVn.\n');
                end % is ~all

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
                aB(1) = 1;
                syms s; % Declare the symbolic frequency variable.

                aN = sym( zeros( length(aB) ) ); % Allocate and clear the nodal matrix.

                for iV = 1:length(aSymVn) % Go thru each variable (e.g., R, L, and C).
                    aELName = char(aSymVn(iV)); % All symbolic variable names for elements have an R, L, or C.
                    switch aELName( find( aELName=='R' | aELName=='L' | aELName=='C',1 ) )
                        case 'R'
                            aAdmittance = 1/aSymVn(iV);
                        case 'L'
                            aAdmittance = 1 / (s * aSymVn(iV));
                        case 'C'
                            aAdmittance = s * aSymVn(iV);
                        otherwise
                            error('Unrecognized element: %s. Element name must begin with R, L, or C.\n',aELName);
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
                [ aSymA,aSymB ] = numden( 1.0/aResult(1) );
                theCat.list(aId).symA = simplify( aSymA );
                theCat.list(aId).symB = simplify( aSymB );
                
            end % for aId
            
        end % CRCat.SetSymAB
        
        
        function theSens = ELSens( theCat,theId,theTestEL,theTestFreq )
            % Sens = ELGrad( Cat,Id,TestEL,Freq ): Calculate the sensitivity of the Id Comp
            % admittance with respect to TestEL RLC values. If a 1% change in an RLC
            % value results in a 1% change in the abs(Y), then sensitivity = 1.0.
            % If TestEL not passed, use the default Comp.testEL RLC values.
            % If no values for Freq passed, 1.0 is used. If Freq is a vector, then
            % one column in Sens for each Freq. Single Comp only. jcr29Apr2015
            
            if isempty(theCat.list)
                theSens = []; % We were passed an empty list.
                return;
            end
            
            if theId == 0
                theSens = []; % Ignore component.
            end % if theId
            
            theCat.CheckId( theId,1 );
            if numel( theId ) ~= 1
                error('Gradient is calculated only for single components, first one is Id = %d, %s\n',theId,theCat.list( theId ).name );
            end % if numel
            
            if nargin >= 3
                if numel( theTestEL ) ~= theCat.NumRLCn( theId )
                    error('Wrong number of test values for the RLC''s in component gradient calculation, Id = %d, %s\n',theId,theCat.list( theId ).name );
                end % if numel theTestEL.
                aTestEL = theTestEL;
            else
                aTestEL = theCat.list( theId ).testEL;
            end % if nargin
            
            if nargin == 4
                aFreq = theTestFreq;
            else
                aFreq = 1.0; % Default value.
            end % if nargin
            
            % Create the component, evaluate the baseline admittance using aTestEL values.
            aComp = CRComp( theId, theCat );
            aComp.SetEL( aTestEL );
            aYBase = aComp.Eval( aFreq );
            if isempty( aYBase )
                theSens = zeros( 1,numel( aTestEL ) ); % Could not evaluate admittance, probably divide by zero.
            else
                % Do deltas on each component and evaluate the new admittance and sensitivity.
                aDelta = 0.001; % Fractional change to calculate sensitivity.
                for index = numel( aTestEL ):-1:1
                    aTestDelta = aTestEL;
                    aTestDelta( index ) = (1.0 + aDelta) * aTestDelta( index );
                    aComp.SetEL( aTestDelta );
                    aYDelta = aComp.Eval( aFreq );
                    if isempty( aYDelta )
                        theSens = zeros( 1,numel( aTestEL ) ); % Could not evaluate admittance, probably divide by zero.
                        return;
                    end % if isempty
                    theSens(:,index) = abs( ( aYBase - aYDelta ) ./ aYBase ) / aDelta;
                end % for index
            end % if isempty
            
        end % ELSens
        
        
        function theSensEL = FindSensEL( theCat,theId,theStartEL,theFreq )
            % SensEL = FindSensEL( Cat,Id,StartEL,Freq ): Look for a set of RLC
            % values to which Y is at least reasonably sensitive.
            % If StartEL not passed, start with the default Comp.testEL RLC values.
            % If no values for Freq passed, 1.0 is used. If Freq is a vector, then
            % use average sensitivity across Freq. Single Comp only. jcr29Apr2015
            
            if isempty(theCat.list)
                theSensEL = []; % We were passed an empty list.
                return;
            end
            
            if theId == 0
                theSensEL = []; % Ignore component.
                return;
            end % if theComp.id
            
            theCat.CheckId( theId,1 );
            if numel( theId ) ~= 1
                error('Will find sensitive RLC valus only for single components, first one is Id = %d, %s\n',theId,theCat.list( theId ).name );
            end % if numel
            
            aNumRLCn = theCat.NumRLCn( theId );
            if nargin >= 3
                if numel( theStartEL ) ~= aNumRLCn
                    error('Wrong number of test values for the RLCs in component sensitivity calculation, Id = %d, %s\n',theId,theCat.list( theId ).name );
                end % if numel
                aStartEL = theStartEL;
            else
                aStartEL = theCat.list( theId ).testEL;
            end
            aBestEL = aStartEL;
            
            if nargin == 4
                aFreq = theFreq; % Value that was passed.
            else
                aFreq = 1.0; % Default value.
            end % if nargin
            
            % Evaluate the baseline RLC sensitivity for the aEL values.
            aNumFreq = numel( aFreq );
            if aNumFreq == 1
                aBestSens = min( theCat.ELSens( theId,aBestEL,aFreq ) );
            else
                aBestSens  = min( mean( theCat.ELSens( theId,aBestEL,aFreq ) ) );
            end % if aNumFreq
            
            aSensStep = 10.0; % Factor that each RLC changes by in search for sensitive value.
            aSensLimit = 0.1; % We want at least this much sensitivity, if possible.
            iStep = 1; % Count how many times through loop, so no infinite loop.
            iStepLimit = 100; % Max total aSensStep.
            rng('default'); % In case search is restarted with random values, will be repeatable.
            while iStep < iStepLimit && aBestSens < aSensLimit
                
                for index = 1:aNumRLCn
                    aTrialEL = aBestEL;
                    aTrialEL(index) = aTrialEL(index) * aSensStep; % Try bigger EL value.
                    if aNumFreq == 1
                        aTrialSens = min( theCat.ELSens( theId,aTrialEL,aFreq ) );
                    else
                        aTrialSens = min( mean( theCat.ELSens( theId,aTrialEL,aFreq ) ) );
                    end % if aNumFreq
                    if aTrialSens > aBestSens
                        aBestSens = aTrialSens;
                        aBestEL = aTrialEL;
                    else
                        aTrialEL = aBestEL;
                        aTrialEL(index) = aTrialEL(index) / aSensStep; % Try smaller EL value.
                        if aNumFreq == 1
                            aTrialSens = min( theCat.ELSens( theId,aTrialEL,aFreq ) );
                        else
                            aTrialSens = min( mean( theCat.ELSens( theId,aTrialEL,aFreq ) ) );
                        end % if aNumFreq
                        if aTrialSens > aBestSens
                            aBestSens = aTrialSens;
                            aBestEL = aTrialEL;
                        end % if aTrialSens (smaller)
                    end % if aTrialSens (bigger)
                end % for index
                
                iStep = iStep + 1;
                if mod( iStep,5 ) == 0 % Restart with random EL values.
                    if iStep < 50
                        aBestEL = aStartEL.*10.^(2.0*rand(1,aNumRLCn)-1); % Mult factor is 0.1 to 10.
                    else
                        aBestEL = aStartEL.*10.^(4.0*rand(1,aNumRLCn)-2); % Mult factor is 0.01 to 100.
                    end % if iStep
                    aBestEL = str2num( sprintf('%5.1e ',aBestEL) ); %#ok<ST2NM> % Knock off all but the first two digits.
                    if aNumFreq == 1
                        aBestSens = min( theCat.ELSens( theId,aBestEL,aFreq ) );
                    else
                        aBestSens  = min( mean( theCat.ELSens( theId,aBestEL,aFreq ) ) );
                    end % if aNumFreq
                end % if mod
                
            end % while iStep
            
            if aBestSens < aSensLimit
                fprintf('FindSensEL: Last sensitivity calculated: ');
                fprintf( '%f ',theCat.ELSens( theId,aBestEL,aFreq ) );
                fprintf('\n');
                warning('Not all RLC values found significantly influence component Id = %d, %s.',theId,theCat.list(theId).name);
            end % if aBestSens
            
            theSensEL = aBestEL;
            
        end % FindSensEL
        
        
        function SetBestTestEL( theCat,theId,theFreq )
            % SetBestTestEL( Cat,Id,Freq ): Set testEL in theId to RLC values that Y
            % is sufficiently sensitive to. theId can be a vector. If not
            % specified, do entire theCat at default Freq = 1.0.
            % If no values for Freq passed, 1.0 is used. If Freq is a vector, then
            % use average sensitivity across Freq. jcr29Apr2015
            
            if isempty(theCat.list)
                return; % We were passed an empty list.
            end
            
            if nargin == 1
                aId = 1:numel(theCat.list); % If no theId, do all Ids at default freq 1.0.
            else
                aId = theId;
            end % if nargin
            
            if nargin == 3
                aFreq = theFreq; % Value that was passed.
            else
                aFreq = 1.0; % Default value.
            end % if nargin
             
            for index = aId
                theCat.list(index).testEL = theCat.FindSensEL( index,theCat.list(index).testEL,aFreq );
                if numel(aId) > 1 % Don't print info if only one component being set.
                    fprintf('Completed Id = %d, %s: ',index,theCat.list(index).name);
                    fprintf( '%f ',theCat.list(index).testEL );
                    fprintf('\n');
                end % if numel
            end
                
        end % SetBestTestEL
        
        
        function Append(theCat,theCat2)
            % CRCat(Cat,Cat2): Append Cat2 to Cat. 07Apr2015jcr
            
            aLen = numel( theCat.list );
            aLen2 = numel( theCat2.list );
            
            if aLen2 > 0
                aTotalList = [ char(theCat) char(theCat2) ];
                [ aUniqueList,~,iC ] = unique( aTotalList );
                % Check to make sure no duplicate names in the two catalogs.
                if aLen+aLen2 ~= length( aUniqueList )
                    iHist = histcounts( iC,1:numel(iC) );
                    aDupeList = aUniqueList( (iHist>1) );
                    fprintf('Duplicate component names found: ');
                    disp( aDupeList );
                    error( 'Two or more components, listed above, have the same name.\n' );
                end % if length

                theCat.list( aLen+1:aLen+aLen2 ) = theCat2.list;
                theCat.SameSet( numel(theCat.list) ); % Copy previous SameSet() results where possible.
            end % if aLen2
            
        end % Append
        
        
        function Save( theCat,theSaveStr )
            % SaveAsBase( Cat,SaveStr ): Saves Cat as a catalog in the @CRCat
            % dir according to SaveStr as 'base', 'custom', or 'default'.
            % SaveStr required. jcr24jan2025

            if nargin == 0
                error('SaveStr option required.')
            end % if nargin

            if strcmp(theSaveStr,'base')
                save( theCat.BaseCatName,'theCat' );
            elseif strcmp(theSaveStr,'custom')
                save( theCat.CustomCatName,'theCat' );
            elseif strcmp(theSaveStr,'default')
                save( theCat.DefaultCatName,'theCat' );
            else
                error( 'Unrecognized option, ''%s''.',theSaveStr );
            end % ~strcmp

        end % Save
        
        
        function Units(theCat,theFUnit)
            % CRCat(Cat,FUnit): Set the frequency and RLC units for Cat.
            % FUnit = 'Hz' to 'THz', case insensitive. RLC set to correspond
            % so no changes in numbers. This can be done at anytime. 05Apr2015jcr
            
            theCat.resUnit = char(937); % 'Ohm' --> Greek letter. Same no matter theFUnit;

            switch upper(theFUnit)
                case 'HZ'
                    theCat.fUnit = 'Hz';
                    theCat.fMult = 1.0;
                    theCat.indUnit = 'H';
                    theCat.capUnit = 'F';
                case 'KHZ'
                    theCat.fUnit = 'kHz';
                    theCat.fMult = 1.0e3;
                    theCat.indUnit = 'mH';
                    theCat.capUnit = 'mF';
                case 'MHZ'
                    theCat.fUnit = 'MHz';
                    theCat.fMult = 1.0e6;
                    theCat.indUnit = 'uH';
                    theCat.capUnit = 'uF';
                case 'GHZ'
                    theCat.fUnit = 'GHz';
                    theCat.fMult = 1.0e9;
                    theCat.indUnit = 'nH';
                    theCat.capUnit = 'nF';
                case 'THZ'
                    theCat.fUnit = 'THz';
                    theCat.fMult = 1.0e12;
                    theCat.indUnit = 'pH';
                    theCat.capUnit = 'pF';
                otherwise
                    error('FUnit must be a string, Hz to THz, not %s.\n',theFUnit);
            end
        end % Units
            
        
        function theList = char( theCat )
            % Build a cell array of the names of every component in theCat.
            % The index of each name is used as the id in CRComp. 11Mar2015
            
            if isempty(theCat.list)
                theList = []; % We were passed an empty theCat.list.
                return;
            end
            
            theList = { theCat.list.name };
            
        end % CRCat.char
        
        function Zeros( theCat,theId )
            % Calculate the zeros of theId's admittance. Set symZero member of theCat.list.
            % Only a single Id is allowed. 13Apr2017
            syms s;
            
            theCat.CheckId( theId(1),1 );
            if numel(theId) ~= 1
                error('Single integer required for Id.');
            end
            
            aSolution = solve( theCat.list(theId(1)).symA,s );
            if ~isempty(aSolution)
                theCat.list( theId ).symZeros = simplify( aSolution );
            else
                theCat.list( theId ).symZeros = [];
            end
            
        end % CRCat.Zeros
            
        
        function Poles( theCat,theId )
            % Calculate the poles of theId's admittance. Return in symbolic array. Set the symPoles member of theCat.list.
            % theId must be a single integer. 13Apr2017
            syms s;
            
            theCat.CheckId( theId(1),1 );
            if numel(theId) ~= 1
                error('Single integer required for Id.');
            end
            
            aSolution = solve( theCat.list(theId(1)).symB,s );
            if ~isempty(aSolution)
                theCat.list( theId ).symPoles = simplify( aSolution );
            else
                theCat.list( theId ).symPoles = [];
            end
            
        end % CRCat.Poles

    end % methods (from very top of the this file)
    
    
    methods ( Access = private )
        
        
        function Init( theCat,theTargetStr )
            % Init( theCat,TargetStr ): Allocate CRCat and put initial, usually user
            % specified, information in theCat. 21jan2025
            
            theCat.Units('GHz'); % Default units.
            
            theCat.list = []; % Deallocate theCat.list in case there is anything there.
            aLen = theCat.InitFillCat(theTargetStr); % theCat->list not allocated, so this call returns only the number of
                                                     % components to be created, it does not create any networks.
            theCat.list = struct( ...
                'symV', cell(1,aLen), ... % Symbolic vars for the RLCs, cell forces list to be array, 1 x aLen.
                'symVn',[], ...     % Var for nodal analysis, usually same as symV, and treated so if left empty.
                'symC',[], ...      % Symbolic representation of CRPoly coefficients [an:a0 bn:b0].
                'symA',[], ...      % Symbolic representation of numerator of admittance, f(R,L,C,s).
                'symB',[], ...      % Symbolic representation of denominator of admittance, f(R,L,C,s).
                'symEL',[], ...     % Vector of solutions for element values in terms of CRPoly coeffs.
                'testEL',[], ...    % Default test vector for EL (RLC) values.
                'flagSig',[], ...   % String with signature of flagA/flagB (which terms are in numerator and denominator).
                'nodes',[], ...     % List of nodes needed for symV RLCs. 1 and 0 are in and out.
                'name',[], ...      % Name of component. Search key, don't change arbitrarily.
                'sameId',[], ...    % Info to convert element values to an equivalent or nondegenerate components.
                'symSame',[], ...   % Symbolic equations to convert element values to an equivalent or nondegenerate components.
                'symZeros',[], ...  % Symbolic equations for the zeros of symA, the numerator of the admittance.
                'symPoles',[] );    % Symbolic equations for the zeros of symB, the denominator of the admittance, thus the poles of the admittance.
           
            [ ~ ] = theCat.InitFillCat(theTargetStr); % Fill theCat.list with initial Id data.SameSet
            
        end % Init
        
        function Recalc( theCat,theTargetStr,theVerbose )
            % Recalc( theCat,TargetStr ): Fill or update theCat.list.
            % Verbose required. 21jan2025
           
            if isempty( theCat.list )
                theCat.Init(theTargetStr); % Fill theCat.list with the inital basic data on each Id.
            end % if isempty

            if theVerbose < 0
                aMoreToDo = -theVerbose; % Fill no more than this number of Ids.
            else
                aMoreToDo = 2 * numel(theCat.list); % Need to go through theCat.list twice for complete fill.
            end % if theVerbose

            % Complete all the information (except equivalency and degeneracy) for each Id.
            aMoreToDo = theCat.FinishCatFill( aMoreToDo );
            % Set conversion equations for all equivalent or degenerate Ids for each Id.
            theCat.SameSet( aMoreToDo );
            
        end % Recalc
        
        
        function theMoreToDo = FinishCatFill( theCat,theMoreToDo )
            % FinishCatFill(Cat): Finish (or start) the Cat fill. 05Apr2015jcr
            % Limit number of Id data fills to no more than MoreToDo.
            % Used to do base cat in segments because full fill can take days. jcr13Apr2017
            % Returns MoreToDo, the number of components left to do if limited.
            % To do the entire fill of theCat.list, set to 2*numel(theCat.list). jcr17Feb2025
            
            % Set up vectors with synbolic representations all possible coefficients.
            aMaxNumTerms = 21; % e.g., a0 to a20. If bigger circuits analyzed, add more terms.
            syms a20 a19 a18 a17 a16 a15 a14 a13 a12 a11 a10 a9 a8 a7 a6 a5 a4 a3 a2 a1 a0;
            syms b20 b19 b18 b17 b16 b15 b14 b13 b12 b11 b10 b9 b8 b7 b6 b5 b4 b3 b2 b1 b0;
            syms s; % Complex frequency, j * omega.
            aAAll = [a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20]; % Template for symbolic representation of numerator coef.
            aBAll = [b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 b19 b20]; % Template for symbolic representation of denominator coef.
            
            aCountLimit = theMoreToDo;
            aCount = 0; % Number of components completed.
            
            theCat.CheckSymVn; % Make sure the first part of symVn is the same as symV.
            
            for iCatId = 1:numel( theCat.list ) % Update the data for those Ids not yet completed.
                if aCount < aCountLimit && isempty( theCat.list(iCatId).flagSig ) % flagSig empty means data at this Id not yet filled.
                    aCount = aCount + 1;
                    fprintf('\nCat Id %d, %s: Solving for synthesis equations.\n',iCatId,theCat.list(iCatId).name);

                    % aNumRLC = theCat.NumRLC( iCatId ); % Number of RLCs to be solved for.
                    aNumRLCn = theCat.NumRLCn( iCatId ); % Number of RLCs used in the nodal description.

                    theCat.SetSymAB( iCatId ); % Evaluate the numerator and denominator of the component admittance and store in symA and symB.
                    % flagSig is the signature of what coeffs are present in numerator and denominator.
                    aFlagA = ~arrayfun( @(x) isequaln(x,sym(0)), coeffs( theCat.list(iCatId).symA,s,'All' ) );
                    aFlagB = ~arrayfun( @(x) isequaln(x,sym(0)), coeffs( theCat.list(iCatId).symB,s,'All' ) );
    
                    % Build a character signature of this flagA/flagB combination.
                    aFlagSig = sprintf( '%d',aFlagA );
                    if length(aFlagA) > aMaxNumTerms || length(aFlagB) > aMaxNumTerms
                        error('Too many terms in symbolic poly for component id = %d, %s.',iCatId,theCat.list(iCatId).name);
                    end % if length
                    aFlagSig = strcat( aFlagSig,'-');
                    theCat.list(iCatId).flagSig = strcat( aFlagSig,sprintf( '%d',aFlagB ) );
                    
                    % Set a default testEL vector. Values will then be tuned for sensitivity.
                    if isempty( theCat.list(iCatId).testEL ) % If something is already set, leave it alone.
                        theCat.list(iCatId).testEL = linspace( 1,double(aNumRLCn),double(aNumRLCn) );
                        % Make any capacitor values 0.01 times smaller, so they don't short anything out.
                        for iV = 1:aNumRLCn
                            aVarName = char( theCat.list(iCatId).symVn(iV) );
                            if ( aVarName(1) == 'C' )
                                theCat.list(iCatId).testEL(iV) = theCat.list(iCatId).testEL(iV) * 0.01;
                            end % if aVarName
                        end % for iV
                        theCat.SetBestTestEL( iCatId ); % Tune the testEL values so all have significant effect on Y.
                    end % if isempty
    
                    % Build vectors with symbolic reps of all the coef actually being used for this component.
                    aCa = aAAll( aFlagA(end:-1:1) ); % Symbolic numerator coef, a0 a1 ...
                    aCb = aBAll( aFlagB(end:-1:1) ); % Symbolic denominator coef, b0 b1 ...
                    theCat.list(iCatId).symC = [ aCa(end:-1:1) aCb(end:-1:1) ]; % This is the order generated by CRFit.
                    % Normalize aC and aV, below, so lowest order s^i term (usually DC) numerator coef, aC(1) and aV(1), is 1.
                    aC = [ aCa(2:end) aCb ]/aCa(1); % This is the order generated by [aV] = coeffs([symA symB]).
                    aVtmp = [ coeffs( theCat.list(iCatId).symA,s ) coeffs( theCat.list(iCatId).symB,s ) ]; % Num and Den coeff in terms of RLC.
                    aV = aVtmp(2:end) / aVtmp(1); % We load the normalized coef because we already know that 1 == 1.
                    aVmC = aV - aC; % Set equal to zero and solve for RLCs.

                    theCat.SetSynthEqn( iCatId,aVmC );
                    
                    % Set the zeros and poles.
                    theCat.Zeros( iCatId );
                    theCat.Poles( iCatId );
                    
                end % if aCount

            end % for iCatId
            
            [ aUniqueList,~,iC ] = unique( char(theCat) );
            % Check to make sure no duplicate names in the catalog.
            if length( char(theCat) ) ~= length( aUniqueList )
                iHist = histcounts( iC,1:numel(iC) );
                aDupeList = aUniqueList( (iHist>1) );
                fprintf('Duplicate component names found:');
                disp( aDupeList );
                error( 'Two or more components, listed above, have the same name.' );
            end % if length

            theMoreToDo = aCountLimit - aCount;
            
        end % FinishCatFill
        
                
        function theELAns = AltCalcXXX_1( ~ )
            % AltCalcXXX_1: Direct application of MATLAB solve
            % does not work for this Id. Instead, do the solution
            % for eqv Id XXII-1 and transform it to the XXX-1 solution. jcr31Mar2015
            
            syms a0 a1 a2 b0 b1 b2

            ra = b0/a0; % Solution for XXII-1.
            rb = ((a0^2*a1*b2 - 2*a0^2*a2*b1 + a0*a1*a2*b0)*(a0*b1 - a1*b0 + a1^2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2) + 2*a0^2*b2*(-1/(- a1^2 + 4*a0*a2))^(1/2) - a0*a1*b1*(-1/(- a1^2 + 4*a0*a2))^(1/2) - 2*a0*a2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2)))/(2*a0^2*(- 2*b2*a0^2*a2 + b1*a0*a1*a2 + 2*b0*a0*a2^2 - b0*a1^2*a2)) + (a0^3*b2^2 - 2*a0^2*a2*b0*b2 - a0^2*a2*b1^2 + 2*a0*a1*a2*b0*b1 + a0*a2^2*b0^2 - a1^2*a2*b0^2)/(a0*a2*(2*b2*a0^2 - b1*a0*a1 - 2*a2*b0*a0 + b0*a1^2));
            lb = (a0*b1 - a1*b0)/a0^2 - (a0*b1 - a1*b0 + a1^2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2) + 2*a0^2*b2*(-1/(- a1^2 + 4*a0*a2))^(1/2) - a0*a1*b1*(-1/(- a1^2 + 4*a0*a2))^(1/2) - 2*a0*a2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2))/(2*a0^2);
            rc = - (a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2)/(- 2*b2*a0^2*a2 + b1*a0*a1*a2 + 2*b0*a0*a2^2 - b0*a1^2*a2) - ((a0^2*a1*b2 - 2*a0^2*a2*b1 + a0*a1*a2*b0)*(a0*b1 - a1*b0 + a1^2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2) + 2*a0^2*b2*(-1/(- a1^2 + 4*a0*a2))^(1/2) - a0*a1*b1*(-1/(- a1^2 + 4*a0*a2))^(1/2) - 2*a0*a2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2)))/(2*a0^2*(- 2*b2*a0^2*a2 + b1*a0*a1*a2 + 2*b0*a0*a2^2 - b0*a1^2*a2));
            lc = (a0*b1 - a1*b0 + a1^2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2) + 2*a0^2*b2*(-1/(- a1^2 + 4*a0*a2))^(1/2) - a0*a1*b1*(-1/(- a1^2 + 4*a0*a2))^(1/2) - 2*a0*a2*b0*(-1/(- a1^2 + 4*a0*a2))^(1/2))/(2*a0^2);
            
            theELAns(2,5) = lb * (ra/rb + 1)^2; % Next 3 eqns convert XXII-1 to XXX-1.
            theELAns(2,4) = (ra/rb + 1) * ra;
            theELAns(2,3) = ra + rb;
            theELAns(2,2) = lc;
            theELAns(2,1) = rc;
            
            theELAns(1,5) = lc * (ra/rc + 1)^2; % Next 3 eqns convert XXII-1 to XXX-1.
            theELAns(1,4) = (ra/rc + 1) * ra;
            theELAns(1,3) = ra + rc;
            theELAns(1,2) = lb;
            theELAns(1,1) = rb;
        end % AltCalcXXX_1
            
                
        function theELAns = AltCalcXXIX_1( ~ )
            % AltCalcXXIX_1: Direct application of MATLAB solve
            % does not work for this Id. Instead, do the solution
            % for eqv Id XXI-1 and transform it to the XXIX-1 solution. jcr31Mar2015
            
            syms a0 a1 a2 b0 b1 b2

            Ra = b2/a2; % Solution for XXI-1.
            Rb = ((- b1^2 + 4*b0*b2)*(a0^2*b2^3 - 2*a0*a2*b0*b2^2 - a1^2*b0*b2^2 + 2*a1*a2*b0*b1*b2 + a2^2*b0^2*b2 - a2^2*b0*b1^2))/((a2*b1^2 - a1*b1*b2 + 2*a0*b2^2 - 2*a2*b0*b2)*(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2)) - ((a0*b1*b2 - 2*a1*b0*b2 + a2*b0*b1)*(a2*b1^3 - 2*a0*b2^2*(b1^2 - 4*b0*b2)^(1/2) - a2*b1^2*(b1^2 - 4*b0*b2)^(1/2) + 4*a1*b0*b2^2 - a1*b1^2*b2 + a1*b1*b2*(b1^2 - 4*b0*b2)^(1/2) + 2*a2*b0*b2*(b1^2 - 4*b0*b2)^(1/2) - 4*a2*b0*b1*b2))/(2*(a2*b1^2 - a1*b1*b2 + 2*a0*b2^2 - 2*a2*b0*b2)*(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2));
            Lb = ((- b1^2 + 4*b0*b2)*(a1*b2 - a2*b1))/(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2) - (a2*b1^3 - 2*a0*b2^2*(b1^2 - 4*b0*b2)^(1/2) - a2*b1^2*(b1^2 - 4*b0*b2)^(1/2) + 4*a1*b0*b2^2 - a1*b1^2*b2 + a1*b1*b2*(b1^2 - 4*b0*b2)^(1/2) + 2*a2*b0*b2*(b1^2 - 4*b0*b2)^(1/2) - 4*a2*b0*b1*b2)/(2*(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2));
            Rc = (- b1^2*b2 + 4*b0*b2^2)/(a2*b1^2 - a1*b1*b2 + 2*a0*b2^2 - 2*a2*b0*b2) + ((a0*b1*b2 - 2*a1*b0*b2 + a2*b0*b1)*(a2*b1^3 - 2*a0*b2^2*(b1^2 - 4*b0*b2)^(1/2) - a2*b1^2*(b1^2 - 4*b0*b2)^(1/2) + 4*a1*b0*b2^2 - a1*b1^2*b2 + a1*b1*b2*(b1^2 - 4*b0*b2)^(1/2) + 2*a2*b0*b2*(b1^2 - 4*b0*b2)^(1/2) - 4*a2*b0*b1*b2))/(2*(a2*b1^2 - a1*b1*b2 + 2*a0*b2^2 - 2*a2*b0*b2)*(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2));
            Lc = (a2*b1^3 - 2*a0*b2^2*(b1^2 - 4*b0*b2)^(1/2) - a2*b1^2*(b1^2 - 4*b0*b2)^(1/2) + 4*a1*b0*b2^2 - a1*b1^2*b2 + a1*b1*b2*(b1^2 - 4*b0*b2)^(1/2) + 2*a2*b0*b2*(b1^2 - 4*b0*b2)^(1/2) - 4*a2*b0*b1*b2)/(2*(a0^2*b2^2 - a0*a1*b1*b2 - 2*a0*a2*b0*b2 + a0*a2*b1^2 + a1^2*b0*b2 - a1*a2*b0*b1 + a2^2*b0^2));
            
            theELAns(2,5) = Lb * ( Ra/(Ra+Rb) )^2; % Next 3 eqns convert XXI-1 to XXIX-1.
            theELAns(2,4) = Ra*Ra/(Ra+Rb);
            theELAns(2,3) = Ra*Rb/(Ra+Rb);
            theELAns(2,2) = Lc;
            theELAns(2,1) = Rc;
            
            theELAns(1,5) = Lc * ( Ra/(Ra+Rc) )^2; % Next 3 eqns convert XXI-1 to XXIX-1.
            theELAns(1,4) = Ra*Ra/(Ra+Rc);
            theELAns(1,3) = Ra*Rc/(Ra+Rc);
            theELAns(1,2) = Lb;
            theELAns(1,1) = Rb;
        end % AltCalcXXIX_1
        
                
        function theELAns = AltCalcXXIX_5( ~, theVmC )
            % AltCalcXXIX_5(~,VmC): Direct application of MATLAB solve
            % does not work for this Id. Instead, do a couple obvious
            % substitutions and then solve for what's left. jcr1Apr2015
            
            syms Ra La Lb Rc Cc a0 a2 b0 b3
            
            at1 = subs( theVmC, La, Lb/(a2*Lb/b3-1) ); %Eliminate La from the equations.
            at2 = subs( at1, Ra, Rc/(a0*Rc/b0-1) ); % Eliminate Ra from the equations.
            aV = [ Lb,Rc,Cc ]; % These are the variables that remain.
            
            warning('off','symbolic:solve:SolutionsDependOnConditions');
            aResult = solve( at2( [1 2 5] ), aV,'MaxDegree',4 );
            warning('on','symbolic:solve:SolutionsDependOnConditions');
            theELAns(:,5) = aResult.Cc;
            theELAns(:,4) = aResult.Rc;
            theELAns(:,3) = aResult.Lb;
            theELAns(:,2) = aResult.Lb./( a2*aResult.Lb./b3-1 );
            theELAns(:,1) = aResult.Rc./( a0*aResult.Rc./b0-1 );
            
        end % AltCalcXXIX_5



        function SetSynthEqn( theCat,theId,theVmC )
            % SymEL = SetSynthEqn( Cat,Id,VmC ): Find the best synthesis
            % equation(s) and store them at ID in Cat. VmC is the expression
            % to be solved for the RLC values in terms of the rational
            % polynomial coefficients. Calculate all possible
            % solutions and store one for each unique solution (i.e.,
            % synthesis equations that yield different RLC values. Stop
            % looking for solutions after aMaxNumSto found. Since not all
            % transfer function polynomial coefficents are matched (i.e. if
            % there are more coefficients than RLC elements), include only
            % solutions that match all coefficients. jcr07Feb2025
            
            aCatItem = theCat.list(theId);
            aNumCoef = numel( theVmC );
            aNumRLC = theCat.NumRLC(theId); % Number of RLC values to solve synthesis equations for.
            aNumRLCn = theCat.NumRLCn(theId); % Total number of RLCs.
            
            if aNumCoef < numel( aCatItem.symV )
                fprintf('Too many variables for number of coefficients, %s. No synthesis equations.\n',aCatItem.name);
                theCat.list(theId).symEL = [];
                return;
            end % ~isempty

            % Set up the test component, initalized here to the default test values.
            aComp = CRComp(theId,theCat);
            % Be sure we have plenty enough frequencies to do a fit.
            aFreqw = linspace( 1,10,2*( numel(aComp.flagA)+numel(aComp.flagB) ) ); % Frequencies for analysis.
            aY = aComp.Eval(aFreqw); % Accept only synthesis solutions that give this result.

            % Make sure the analysis equations (used by aComp.Eval, above) are correct.
            aYNodal = aComp.Nodal(aFreqw,theCat); % Evaluate data using nodal analysis.
            if rmse( aY,aYNodal ) > 1e-10
                error('Excessive difference between nodal and symbolic analysis, id = %d, %s\n',aId,theCat.list(aId).name);
            end % if aRmsError

            aMaxNumSto = 5; % Most likely only one or two synthesis equation sets will be found.
            aSymSto = sym( zeros( aMaxNumSto,aNumRLC ) ); % Allocate empty cell array to hold synthesis equations.
            aValSto = zeros(aMaxNumSto,aNumRLC) ; % Store the synthesized RLC element values, looking for unique ones.
            iSto = 1; % Next row in aSymSto and aValSto to use.
            
            % If there are more coeff than RLCs (symV) to solve for, must ignore some of the coeff.
            aComboList = nchoosek( 1:aNumCoef,numel(aCatItem.symV) ); % Try all possible combos of aVmC.
            nRow = numel( aComboList(:,1) );
            for iCombo = 1:ceil( nRow/7 ):nRow % if more than 7 combos, skip some so that we get about 7 cases done.
                if iSto <= aMaxNumSto
    
                    % A couple Ids have alternate solutions
                    switch aCatItem.name
                        case  'XXX-1' % Xfm eqv comp XXII-1 for solution. A direct solve fails for this one.
                           aSolveEL = theCat.AltCalcXXX_1;
                        case  'XXIX-1' % Xfm eqv comp XXI-1 for solution. A direct solve fails for this one.
                           aSolveEL = theCat.AltCalcXXIX_1;
                        case  'XXIX-5' % A direct solve fails for this one. Use alt approach.
                           aSolveEL = theCat.AltCalcXXIX_5( theVmC( aComboList(iCombo,:) ) );
                        otherwise
                           warning('off','symbolic:solve:warnmsg3');
                           warning('off','symbolic:solve:SolutionsDependOnConditions');                   
                           warning('off','symbolic:solve:FallbackToNumerical');
                           try
                               aSolveEL = solve( theVmC( aComboList(iCombo,:) ), aCatItem.symV );
                           catch
                               aSolveEL = []; % Solution is no good, keep on going and find others.
                           end % try
                           warning('on','symbolic:solve:warnmsg3');
                           warning('on','symbolic:solve:SolutionsDependOnConditions');
                           warning('on','symbolic:solve:FallbackToNumerical');
                    end % switch aCatItem
    
                    if isempty( aSolveEL )
                        aNumSolutions = 0;
                    elseif isstruct( aSolveEL ) % If only one variable, it is vector sym, otherwise, it should be a struct.
                        [ aNumSolutions,~ ] = size( aSolveEL.( char( theCat.list(theId).symV(1) ) ) );
                    else
                        [ aNumSolutions,~ ] = size( aSolveEL );
                    end % if isstruct
    
                    if aNumSolutions % Don't bother with this if there are no solutions this go-around.
                        % Transfer structure members with symbolic solution of RLCs in terms of coeff to an array.
                        % Also simplify each soltuion before storing.
                        if isstruct( aSolveEL ) % If only one variable, it is vector sym, otherwise, it should be a struct.
                            aTempSymEL = sym( zeros(aNumSolutions,aNumRLC) );
                            for iV = 1:aNumRLC
                                aTempSymEL(:,iV) = simplify( aSolveEL.( char( aCatItem.symV(iV) ) ) ); % If multiple solutions, put each one on a different row.
                            end % for iV
                        elseif ~isempty( aSolveEL )
                            aTempSymEL = simplify( aSolveEL );
                        else
                            aTempSymEL = [];
                        end % if isstruct
        
                        % Check each solution to find the one(s), if any, that
                        % match the ENTIRE transfer function rational
                        % polynomial, not just the coefficents that we used to
                        % solve for the synthesis equations. Check this by
                        % actually using the sythesis equations just now solved
                        % for to see if they re-create the numerical transfer function.
                        aComp.SetSymEL(aTempSymEL);
                        if aNumRLC < aNumRLCn % There are fixed element values to be set in order to do a fit.
                            aFixedEL = aComp.valEL( :,aNumRLC+1:aNumRLCn );
                        else
                            aFixedEL = [];
                        end % if aNumRLC

                        aRmsError = aComp.Fit(aY,aFreqw,aFixedEL); % RMS Error in the transfer function for each synthesis solution.
                        
                        for iTry = 1 : numel( aRmsError )
                            if ( aRmsError(iTry)<1e-10 ) && iSto <= aMaxNumSto % We have room for a good solution.
                                % Check to see that we do not already have a solution
                                % that gives these same RLC values for the test case.
                                if ~any( rmse( aValSto',aComp.valEL(iTry,1:aNumRLC)' ) < 1e-10 )
                                    aSymSto(iSto,:) = aTempSymEL(iTry,:); % Store the synthesis equations.
                                    aValSto(iSto,:) = aComp.valEL(iTry,1:aNumRLC); % Store the synthesized RLC element values.
                                    iSto = iSto + 1;
                                end % if any
                            end % if aRMSE(iTry)
                        end % for iTry
                    end % if aNumSolutions
                end % if iSto
            end % for iCombo

            % Remove all empty rows and store aSymSto in theCat at theId.
            if iSto <= aMaxNumSto
                theCat.list(theId).symEL = resize( aSymSto,iSto-1 );
            end % if iSto

            if iSto > 2
                fprintf('Found %d unique synthesis solutions.\n',iSto-1);
            end % if iSto

            if iSto == 1
                fprintf('Found no synthesis solutions.\n');
            end % if iSto

        end % SetSynthEqn
        
        
        function theOK = BasicDataUpToDate( theCat,theTargetStr )
            % Cat.BasicDataUpToDate( CopyCat ); Check to see if theCat.list has up-to-date
            % basic Id data. If not, clear it out, start fresh and return 0. Targetstr
            % can only be 'base' or 'custom'. 22jan2025

            if ~strcmp(theTargetStr,'base') && ~strcmp(theTargetStr,'custom')
                error( 'Unrecognized option, ''%s''.',theTargetStr );
            end % if ~strcmp

            theOK = 1; % Default answer if no out-of-date networks found.

            aCkCat = CRCat('empty'); % Allocate aCkCat.
            aCkCat.Init(theTargetStr); % Initialize aCkCat.list with just the basic up-to-date network data.
            aCkCat.CheckSymVn; % Make sure symV and the first part of symVn are the same.

            aCatLength = length( theCat.list );
            aCkCatLength = length( aCkCat.list );
            if aCatLength > aCkCatLength
                theCat.list(aCkCatLength+1:aCatLength) = []; % Throw away excess theCat networks.
                theOK = 0;
            elseif aCatLength == 0
                theCat.list = aCkCat.list(aCatLength+1:aCkCatLength); % Add theCat networks.
                theOK = 0;
            elseif aCatLength < aCkCatLength
                theCat.list(aCatLength+1:aCkCatLength) = aCkCat.list(aCatLength+1:aCkCatLength); % Add theCat networks.
                theOK = 0;
            end % if length

            % See if basic info in theCat is the same as the up-to-date info in aCkCat.
            for aId = 1:length( theCat.list )
                if numel( aCkCat.list(aId).symV )  ~= numel( theCat.list(aId).symV )  || ...
                   numel( aCkCat.list(aId).symVn ) ~= numel( theCat.list(aId).symVn ) || ...
                   any( ~strcmp( string(aCkCat.list(aId).symV),  string(theCat.list(aId).symV)  ) ) || ...
                   any( ~strcmp( string(aCkCat.list(aId).symVn), string(theCat.list(aId).symVn) ) ) || ...
                   ~isequal( aCkCat.list(aId).nodes, theCat.list(aId).nodes ) || ...
                   ~strcmp( aCkCat.list(aId).name, theCat.list(aId).name ) || ...
                   isempty( theCat.list(aId).symC )
                        theCat.list(aId) = aCkCat.list(aId); % Throw away the pre-existing base data, it is out of date.
                        theOK = 0;
                end % if ~strcmp
            end % for aId

        end % BasicDataUpToDate

        
        function theLen = InitFillCat(theCat,theTargetStr)
            % Len = InitFillDefaultCat(Cat,TargetStr): Start filling in catalog components.
            % If Cat.list is zero length, return only number of components.
            % TargetStr = 'base' or 'custom'. 11Mar2015
            
            aIndex = 0;
            
            if strcmp( theTargetStr, 'base' )
                aIndex = FillCat_1o2(theCat,aIndex);
                aIndex = FillCat_3(theCat,aIndex);
                aIndex = FillCat_4A(theCat,aIndex);
                aIndex = FillCat_4B(theCat,aIndex);
                aIndex = FillCat_4C(theCat,aIndex);
                aIndex = FillCat_5A(theCat,aIndex);
                aIndex = FillCat_5B(theCat,aIndex);
                aIndex = FillCat_5C(theCat,aIndex);
                aIndex = FillCat_5D(theCat,aIndex);
                aIndex = FillCat_5E(theCat,aIndex);
                aIndex = FillCat_5F(theCat,aIndex);
                aIndex = FillCat_5G(theCat,aIndex);
                aIndex = FillCat_5H(theCat,aIndex);
                aIndex = FillCat_5I(theCat,aIndex);
                aIndex = FillCat_5J(theCat,aIndex);
                aIndex = FillCat_5K(theCat,aIndex);
                aIndex = FillCat_5L(theCat,aIndex);
                aIndex = FillCat_5M(theCat,aIndex);
                aIndex = FillCat_5N(theCat,aIndex);
                aIndex = FillCat_5P(theCat,aIndex);
                
            elseif strcmp( theTargetStr, 'custom' )
                aIndex = FillCat_Custom(theCat,aIndex);
                
            else
                error('Bad CRCat.InitCatFill option: %s',theTargetStr);
            end % if strcmp
            
            theLen = aIndex;
            
        end % InitFillCat
        
        
        function theLen = FillCat_1o2(theCat,theStartIndex)
            % Len = FillCat_1o2(Cat,StartIndex): Fill in catalog for all 1 and 2 element components.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  ONE ELEMENT MODELS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up a single resistor.
                theCat.list(index).symV = R;
                theCat.list(index).nodes = uint32( [ 1 0 ] );
                theCat.list(index).name = 'R';
            end
            
            index = index + 1;
            if aLen % Set up a single inductor.
                theCat.list(index).symV = L;
                theCat.list(index).nodes = uint32( [ 1 0 ] );
                theCat.list(index).name = 'L';
            end
            
            index = index + 1;
            if aLen % Set up a single capacitor.
                theCat.list(index).symV = C;
                theCat.list(index).nodes = uint32( [ 1 0 ] );
                theCat.list(index).name = 'C';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  TWO ELEMENT MODELS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up parallel RL.
                theCat.list(index).symV = [R L];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 ] );
                theCat.list(index).name = 'ParRL';
            end
            
            index = index + 1;
            if aLen % Set up parallel RC.
                theCat.list(index).symV = [R C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 ] );
                theCat.list(index).name = 'ParRC';
            end
            
            index = index + 1;
            if aLen % Set up parallel LC.
                theCat.list(index).symV = [L C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 ] );
                theCat.list(index).name = 'ParLC';
            end
            
            index = index + 1;
            if aLen % Set up series RL.
                theCat.list(index).symV = [R L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 ] );
                theCat.list(index).name = 'SerRL';
            end
            
            index = index + 1;
            if aLen % Set up series RC.
                theCat.list(index).symV = [R C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 ] );
                theCat.list(index).name = 'SerRC';
            end
            
            index = index + 1;
            if aLen % Set up series LC.
                theCat.list(index).symV = [L C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 ] );
                theCat.list(index).name = 'SerLC';
            end
            
            theLen = index;
            
        end % FillCat_1o2
            
        
        function theLen = FillCat_3(theCat,theStartIndex)
            % Len = FillCat_3(Cat,StartIndex): Fill in catalog for all 3 element components.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C Ra Rb  La Lb  Ca Cb  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  THREE ELEMENT MODELS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up PARALLEL RLC. I-1
                theCat.list(index).symV = [R L C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 0 ] );
                theCat.list(index).name = 'ParRLC';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RLC. II-1
                theCat.list(index).symV = [R L C];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'SerRLC';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RL WITH R in PARALLEL. III-1
                theCat.list(index).symV = [Ra Rb L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-1';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RC WITH R in PARALLEL. III-2
                theCat.list(index).symV = [Ra Rb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-2';
            end
            
            index = index + 1;
            if aLen % Set up SERIES LC WITH R in PARALLEL. III-3
                theCat.list(index).symV = [R L C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-3';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RL WITH L in PARALLEL. III-4
                theCat.list(index).symV = [La R Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-4';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RC WITH L in PARALLEL. III-5
                theCat.list(index).symV = [L R C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-5';
            end
            
            index = index + 1;
            if aLen % Set up SERIES LC WITH L in PARALLEL. III-6
                theCat.list(index).symV = [La Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-6';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RL WITH C in PARALLEL. III-7
                theCat.list(index).symV = [C R L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-7';
            end
            
            index = index + 1;
            if aLen % Set up SERIES RC WITH C in PARALLEL. III-8
                theCat.list(index).symV = [Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-8';
            end
            
            index = index + 1;
            if aLen % Set up SERIES LC WITH C in PARALLEL. III-9
                theCat.list(index).symV = [Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'III-9';
            end
            
            index = index + 1;
            if aLen % Set up R IN SERIES WITH A PARALLEL RL. IV-1
                theCat.list(index).symV = [Ra Rb L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-1';
            end
            
            index = index + 1;
            if aLen % Set up R IN SERIES WITH A PARALLEL RC. IV-2
                theCat.list(index).symV = [Ra Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-2';
            end
            
            index = index + 1;
            if aLen % Set up R IN SERIES WITH A PARALLEL LC. IV-3
                theCat.list(index).symV = [R L C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-3';
            end
            
            index = index + 1;
            if aLen % Set up L IN SERIES WITH A PARALLEL RL. IV-4
                theCat.list(index).symV = [La R Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-4';
            end
            
            index = index + 1;
            if aLen % Set up L IN SERIES WITH A PARALLEL RC. IV-5
                theCat.list(index).symV = [L R C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-5';
            end
            
            index = index + 1;
            if aLen % Set up L IN SERIES WITH A PARALLEL LC. IV-6
                theCat.list(index).symV = [La Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-6';
            end
            
            index = index + 1;
            if aLen % Set up C IN SERIES WITH A PARALLEL RL. IV-7
                theCat.list(index).symV = [C R L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-7';
            end
            
            index = index + 1;
            if aLen % Set up C IN SERIES WITH A PARALLEL RC. IV-8
                theCat.list(index).symV = [Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-8';
            end
            
            index = index + 1;
            if aLen % Set up C IN SERIES WITH A PARALLEL LC. IV-9
                theCat.list(index).symV = [Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'IV-9';
            end
            
            theLen = index;
            
        end % FillCat_3
            
        
        function theLen = FillCat_4A(theCat,theStartIndex)
            % Len = FillCat_4A(Cat,StartIndex): Fill in catalog for 4 element components V to X.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C Ra Rb La Lb Ca Cb  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- V and VI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up R in parallel with a series RLC. V-1
                theCat.list(index).symV = [Ra Rb L C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'V-1';
            end
            
            index = index + 1;
            if aLen % Set up L in parallel with a series RLC. V-2
                theCat.list(index).symV = [La R Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'V-2';
            end
            
            index = index + 1;
            if aLen % Set up C in parallel with a series RLC. V-3
                theCat.list(index).symV = [Ca R L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'V-3';
            end
            
            index = index + 1;
            if aLen % Set up R in series with a parallel RLC. VI-1
                theCat.list(index).symV = [Ra Rb L C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'VI-1';
            end
            
            index = index + 1;
            if aLen % Set up L in series with a parallel RLC.. VI-2
                theCat.list(index).symV = [La R Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'VI-2';
            end
            
            index = index + 1;
            if aLen % Set up C in series with a parallel RLC. VI-3
                theCat.list(index).symV = [Ca R L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'VI-3';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- VII and VIII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up series RL in parallel with a series RL. VII-1
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-1';
            end
            
            index = index + 1;
            if aLen % Set up series RL in parallel with a series RC. VII-2
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-2';
            end
            
            index = index + 1;
            if aLen % Set up series RL in parallel with a series LC. VII-3
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-3';
            end
            
            index = index + 1;
            if aLen % Set up series RC in parallel with a series RC. VII-4
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-4';
            end
            
            index = index + 1;
            if aLen % Set up series RC in parallel with a series LC. VII-5
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-5';
            end
            
            index = index + 1;
            if aLen % Set up series LC in parallel with a series LC. VII-6
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'VII-6';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RL in series  with a parallel RL. VIII-1
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-1';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RL in series with a parallel RC. VIII-2
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-2';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RL in series with a parallel LC. VIII-3
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-3';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RC in series with a parallel RC. VIII-4
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-4';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RC in series with a parallel LC. VIII-5
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-5';
            end
            
            index = index + 1;
            if aLen % Set up a parallel LC in series with a parallel LC. VIII-6
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'VIII-6';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- IX
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up an R, L, and series RL all in parallel. IX-1
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-1';
            end
            
            index = index + 1;
            if aLen % Set up an R, L, and series RC all in parallel. IX-2
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-2';
            end
            
            index = index + 1;
            if aLen % Set up an R, L, and series LC all in parallel. IX-3
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-3';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and series RL all in parallel. IX-4
                theCat.list(index).symV = [Ra C Rb L];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-4';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and series RC all in parallel. IX-5
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-5';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and series LC all in parallel. IX-6
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-6';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and series RL all in parallel. IX-7
                theCat.list(index).symV = [La C R Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-7';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and series RC all in parallel. IX-8
                theCat.list(index).symV = [L Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-8';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and series LC all in parallel. IX-9
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'IX-9';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- X
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            index = index + 1;
            if aLen % Set up an R, L, and parallel RL all in series. X-1
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-1';
            end
            
            index = index + 1;
            if aLen % Set up an R, L, and parallel RC all in series. X-2
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-2';
            end
            
            index = index + 1;
            if aLen % Set up an R, L, and parallel LC all in series. X-3
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-3';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and parallel RL all in series. X-4
                theCat.list(index).symV = [Ra C Rb L];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-4';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and parallel RC all in series. X-5
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-5';
            end
            
            index = index + 1;
            if aLen % Set up an R, C, and parallel LC all in series. X-6
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-6';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and parallel RL all in series. X-7
                theCat.list(index).symV = [La C R Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-7';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and parallel RC all in series. X-8
                theCat.list(index).symV = [L Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-8';
            end
            
            index = index + 1;
            if aLen % Set up an L, C, and parallel LC all in series. X-9
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'X-9';
            end
            
            theLen = index;
            
        end % FillCat_4A
        
        function theLen = FillCat_4B(theCat,theStartIndex)
            % Len = FillCat_4B(Cat,Flag): Fill in catalog for 4 element components XI.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            % NOTE WELL: XI and XII -1, -2, -13, -15, -26, -27 are all equivalent to 3 element components.
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- XI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an R in series with a parallel RC). XI-1.
                theCat.list(index).symV = [Ra Rb Rc L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-1';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an R in series with a parallel RC). XI-2.
                theCat.list(index).symV = [Ra Rb Rc C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-2';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an R in series with a parallel LC). XI-3.
                theCat.list(index).symV = [Ra Rb L C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-3';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an L in series with a parallel RL). XI-4.
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-4';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an L in series with a parallel RC). XI-5.
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-5';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (an L in series with a parallel LC). XI-6.
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-6';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (a C in series with a parallel RL). XI-7.
                theCat.list(index).symV = [Ra C Rb L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-7';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (a C in series with a parallel RC). XI-8.
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-8';
            end
            
            index = index + 1;
            if aLen % Set up an R in parallel with (a C in series with a parallel LC). XI-9.
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-9';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an R in series with a parallel RL). XI-10.
                theCat.list(index).symV = [La Ra Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-10';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an R in series with a parallel RC). XI-11.
                theCat.list(index).symV = [L Ra Rb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-11';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an R in series with a parallel LC). XI-12.
                theCat.list(index).symV = [La R Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-12';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an L in series with a parallel RL). XI-13.
                theCat.list(index).symV = [La Lb R Lc];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-13';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an L in series with a parallel RC). XI-14.
                theCat.list(index).symV = [La Lb R C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-14';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (an L in series with a parallel LC). XI-15.
                theCat.list(index).symV = [La Lb Lc C];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-15';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (a C in series with a parallel RL). XI-16.
                theCat.list(index).symV = [La C R Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-16';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (a C in series with a parallel RC). XI-17.
                theCat.list(index).symV = [L Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-17';
            end
            
            index = index + 1;
            if aLen % Set up an L in parallel with (a C in series with a parallel LC). XI-18.
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-18';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an R in series with a parallel RL). XI-19.
                theCat.list(index).symV = [C Ra Rb L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-19';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an R in series with a parallel RC). XI-20.
                theCat.list(index).symV = [Ca Ra Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-20';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an R in series with a parallel LC). XI-21.
                theCat.list(index).symV = [Ca R L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-21';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an L in series with a parallel RL). XI-22.
                theCat.list(index).symV = [C La R Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-22';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an L in series with a parallel RC). XI-23.
                theCat.list(index).symV = [Ca L R Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-23';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (an L in series with a parallel LC). XI-24.
                theCat.list(index).symV = [Ca La Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-24';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (a C in series with a parallel RL). XI-25.
                theCat.list(index).symV = [Ca Cb R L];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-25';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (a C in series with a parallel RC). XI-26.
                theCat.list(index).symV = [Ca Cb R Cc];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-26';
            end
            
            index = index + 1;
            if aLen % Set up a C in parallel with (a C in series with a parallel LC). XI-27.
                theCat.list(index).symV = [Ca Cb Lc Cc];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XI-27';
            end
            theLen = index;
            
        end % FillCat_4B
        
        
        function theLen = FillCat_4C(theCat,theStartIndex)
            % Len = FillCat_4C(Cat,Flag): Fill in catalog for 4 element components XII.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            % NOTE WELL: XI and XII -1, -2, -13, -15, -26, -27 are all equivalent to 3 element components.
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FOUR ELEMENT MODELS -- XII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            index = index + 1;
            if aLen % Set up an R in series with (an R in parallel with a series RL). XII-1.
                theCat.list(index).symV = [Ra Rb Rc L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-1';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (an R in parallel with a series RC). XII-2.
                theCat.list(index).symV = [Ra Rb Rc C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-2';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (an R in parallel with a series LC). XII-3.
                theCat.list(index).symV = [Ra Rb L C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-3';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (an L in parallel with a series RL). XII-4.
                theCat.list(index).symV = [Ra La Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-4';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (an L in parallel with a series RC). XII-5.
                theCat.list(index).symV = [Ra L Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-5';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (an L in parallel with a series LC). XII-6.
                theCat.list(index).symV = [R La Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-6';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (a C in parallel with a series RL). XII-7.
                theCat.list(index).symV = [Ra C Rb L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-7';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (a C in parallel with a series RC). XII-8.
                theCat.list(index).symV = [Ra Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-8';
            end
            
            index = index + 1;
            if aLen % Set up an R in series with (a C in parallel with a series LC). XII-9.
                theCat.list(index).symV = [R Ca L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-9';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an R in parallel with a series RL). XII-10.
                theCat.list(index).symV = [La Ra Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-10';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an R in parallel with a series RC). XII-11.
                theCat.list(index).symV = [L Ra Rb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-11';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an R in parallel with a series LC). XII-12.
                theCat.list(index).symV = [La R Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-12';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an L in parallel with a series RL). XII-13.
                theCat.list(index).symV = [La Lb R Lc];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-13';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an L in parallel with a series RC). XII-14.
                theCat.list(index).symV = [La Lb R C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-14';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (an L in parallel with a series LC). XII-15.
                theCat.list(index).symV = [La Lb Lc C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-15';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (a C in parallel with a series RL). XII-16.
                theCat.list(index).symV = [La C R Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-16';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (a C in parallel with a series RC). XII-17.
                theCat.list(index).symV = [L Ca R Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-17';
            end
            
            index = index + 1;
            if aLen % Set up an L in series with (a C in parallel with a series LC). XII-18.
                theCat.list(index).symV = [La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-18';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an R in parallel with a series RL). XII-19.
                theCat.list(index).symV = [C Ra Rb L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-19';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an R in parallel with a series RC). XII-20.
                theCat.list(index).symV = [Ca Ra Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-20';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an R in parallel with a series LC). XII-21.
                theCat.list(index).symV = [Ca R L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-21';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an L in parallel with a series RL). XII-22.
                theCat.list(index).symV = [C La R Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-22';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an L in parallel with a series RC). XII-23.
                theCat.list(index).symV = [Ca L R Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-23';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (an L in parallel with a series LC). XII-24.
                theCat.list(index).symV = [Ca La Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-24';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (a C in parallel with a series RL). XII-25.
                theCat.list(index).symV = [Ca Cb R L];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-25';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (a C in parallel with a series RC). XII-26.
                theCat.list(index).symV = [Ca Cb R Cc];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-26';
            end
            
            index = index + 1;
            if aLen % Set up a C in series with (a C in parallel with a series LC). XII-27.
                theCat.list(index).symV = [Ca Cb Lc Cc];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XII-27';
            end
            
            theLen = index;
            
        end % FillCat_4C
        
        
        function theLen = FillCat_5A(theCat,theStartIndex)
            % Len = FillCat_5A(Cat,Flag): Fill in catalog for 5 element components XIII - XVIII.
            % If Cat.list is zero length, return only number of components. 16Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms R L C Ra Rb  La Lb  Ca Cb   %Symbolic variables for RLC components.
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XIII and XIV
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up a parallel RL in parallel with a series RLC. XIII-1.
                theCat.list(index).symV = [Ra La Rb Lb C];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'XIII-1';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RC in parallel with a series RLC. XIII-2.
                theCat.list(index).symV = [Ra Ca Rb L Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'XIII-2';
            end
            
            index = index + 1;
            if aLen % Set up a parallel LC in parallel with a series RLC. XIII-3.
                theCat.list(index).symV = [La Ca R Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 3 3 0 ] );
                theCat.list(index).name = 'XIII-3';
            end
            
            index = index + 1;
            if aLen % Set up a series RL in series with a parallel RLC. XIV-1.
                theCat.list(index).symV = [Ra La Rb Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 3 0 ] );
                theCat.list(index).name = 'XIV-1';
            end
            
            index = index + 1;
            if aLen % Set up a series RC in series with a parallel RLC. XIV-2.
                theCat.list(index).symV = [Ra Ca Rb L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 3 0 ] );
                theCat.list(index).name = 'XIV-2';
            end
            
            index = index + 1;
            if aLen % Set up a series LC in series with a parallel RLC. XIV-3.
                theCat.list(index).symV = [La Ca R Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 0 3 0 ] );
                theCat.list(index).name = 'XIV-3';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XV and XVI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up a series RL in parallel with a series RLC. XV-1.
                theCat.list(index).symV = [Ra La Rb Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 4 4 0 ] );
                theCat.list(index).name = 'XV-1';
            end
            
            index = index + 1;
            if aLen % Set up a series RC in parallel with a series RLC. XV-2.
                theCat.list(index).symV = [Ra Ca Rb L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 4 4 0 ] );
                theCat.list(index).name = 'XV-2';
            end
            
            index = index + 1;
            if aLen % Set up a series LC in parallel with a series RLC. XV-3.
                theCat.list(index).symV = [La Ca R Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 4 4 0 ] );
                theCat.list(index).name = 'XV-3';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RL in series with a parallel RLC. XVI-1.
                theCat.list(index).symV = [Ra La Rb Lb C];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XVI-1';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RC in series with a parallel RLC. XVI-2.
                theCat.list(index).symV = [Ra Ca Rb L Cb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XVI-2';
            end
            
            index = index + 1;
            if aLen % Set up a parallel LC in series with a parallel RLC. XVI-3.
                theCat.list(index).symV = [La Ca R Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XVI-3';
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XVII and XVIII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen % Set up a parallel RLC in parallel with a series RL. XVII-1.
                theCat.list(index).symV = [Ra La C Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'XVII-1';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RLC in parallel with a series RC. XVII-2.
                theCat.list(index).symV = [Ra L Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'XVII-2';
            end
            
            index = index + 1;
            if aLen % Set up a parallel RLC in parallel with a series LC. XVII-3.
                theCat.list(index).symV = [R La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 0 1 2 2 0 ] );
                theCat.list(index).name = 'XVII-3';
            end
            
            index = index + 1;
            if aLen % Set up a series RLC in series with a parallel RL. XVIII-1.
                theCat.list(index).symV = [Ra La C Rb Lb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 4 4 0 4 0 ] );
                theCat.list(index).name = 'XVIII-1';
            end
            
            index = index + 1;
            if aLen % Set up a series RLC in series with a parallel RC. XVIII-2.
                theCat.list(index).symV = [Ra L Ca Rb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 4 4 0 4 0  ] );
                theCat.list(index).name = 'XVIII-2';
            end
            
            index = index + 1;
            if aLen % Set up a series RLC in series with a parallel LC. XVIII-3.
                theCat.list(index).symV = [R La Ca Lb Cb];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 4 4 0 4 0  ] );
                theCat.list(index).name = 'XVIII-3';
            end
  
            theLen = index;
            
        end % FillCat_5A
        
        
        function theLen = FillCat_5B(theCat,theStartIndex)
            % Len = FillCat_5B(Cat,Flag): Fill in catalog for 5 element components XIX and XX.
            % If Cat.list is zero length, return only number of components. 21Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            % NOTE WELL: XX-1,5,9 and XIX-1,5,9 are equivalent to 4 EL
            % circuits. For example, XX-1 a2/a0 = b2/b0 and this
            % leaves only 4 independent equations to solve for 5 variables.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XIX and XX
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            index = index + 1;
            if aLen  % R in parallel with (an R in seires with a parallel RLC): XIX-1.
                theCat.list(index).symV =          [ Ra  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-1';
            end
            
            index = index + 1;
            if aLen  % R in parallel with (an L in seires with a parallel RLC): XIX-2.
                theCat.list(index).symV =          [ Ra  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-2';
            end
           
            index = index + 1;
            if aLen  % R in parallel with (an C in series with a parallel RLC): XIX-3.
                theCat.list(index).symV =          [ Ra  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-3';
            end
           
            index = index + 1;
            if aLen  % L in parallel with (an R in series with a parallel RLC): XIX-4.
                theCat.list(index).symV =          [ La  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-4';
            end
           
            index = index + 1;
            if aLen  % L in parallel with (an L in series with a parallel RLC): XIX-5.
                theCat.list(index).symV =          [ La  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-5';
            end
           
            index = index + 1;
            if aLen  % L in parallel with (an C in series with a parallel RLC): XIX-6.
                theCat.list(index).symV =          [ La  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-6';
            end
           
            index = index + 1;
            if aLen  % C in parallel with (an R in series with a parallel RLC): XIX-7.
                theCat.list(index).symV =          [ Ca  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-7';
            end
           
            index = index + 1;
            if aLen  % C in parallel with (an L in series with a parallel RLC): XIX-8.
                theCat.list(index).symV =          [ Ca  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-8';
            end
           
            index = index + 1;
            if aLen  % C in parallel with (an C in series with a parallel RLC): XIX-9.
                theCat.list(index).symV =          [ Ca  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 2 0 2 0 ] );
                theCat.list(index).name = 'XIX-9';
            end
           
            index = index + 1;
            if aLen  % R in series with (an R in parallel with a series RLC): XX-1.
                theCat.list(index).symV =          [ Ra  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-1';
            end
           
            index = index + 1;
            if aLen  % R in series with (an L in parallel with a series RLC): XX-2.
                theCat.list(index).symV =          [ Ra  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-2';
            end
           
            index = index + 1;
            if aLen  % R in series with (an C in parallel with a series RLC): XX-3.
                theCat.list(index).symV =          [ Ra  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-3';
            end
           
            index = index + 1;
            if aLen  % L in series with (an R in parallel with a series RLC): XX-4.
                theCat.list(index).symV =          [ La  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-4';
            end
           
            index = index + 1;
            if aLen  % L in series with (an L in parallel with a series RLC): XX-5.
                theCat.list(index).symV =          [ La  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-5';
            end
           
            index = index + 1;
            if aLen  % L in series with (an C in parallel with a series RLC): XX-6.
                theCat.list(index).symV =          [ La  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-6';
            end
           
            index = index + 1;
            if aLen  % C in series with (an R in parallel with a series RLC): XX-7.
                theCat.list(index).symV =          [ Ca  Rb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-7';
            end
           
            index = index + 1;
            if aLen  % C in series with (an L in parallel with a series RLC): XX-8.
                theCat.list(index).symV =          [ Ca  Lb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-8';
            end
           
            index = index + 1;
            if aLen  % C in series with (an C in parallel with a series RLC): XX-9.
                theCat.list(index).symV =          [ Ca  Cb  Rc  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 3 3 4 4 0 ] );
                theCat.list(index).name = 'XX-9';
            end
           
            theLen = index;
            
        end % FillCat_5B
        
        
        function theLen = FillCat_5C(theCat,theStartIndex)
            % Len = FillCat_5C(Cat,Flag): Fill in catalog for 5 element components XXII.
            % If Cat.list is zero length, return only number of components. 24Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in parallel with a series RL: XXI-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-1';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in parallel with a series RC: XXI-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-2';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in parallel with a series LC: XXI-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-3';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RC in parallel with a series RC: XXI-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-4';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RC in parallel with a series LC: XXI-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-5';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series LC in parallel with a series LC: XXI-5.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-6';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in parallel with a series RL: XXI-7.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-7';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in parallel with a series RC: XXI-8.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-8';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in parallel with a series LC: XXI-9.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-9';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RC in parallel with a series RC: XXI-10.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-10';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RC in parallel with a series LC: XXI-11.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-11';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series LC in parallel with a series LC: XXI-12.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-12';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series RL in parallel with a series RL: XXI-13.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-13';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series RL in parallel with a series RC: XXI-14.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-14';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series RL in parallel with a series LC: XXI-15.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-15';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series RC in parallel with a series RC: XXI-16.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-16';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series RC in parallel with a series LC: XXI-17.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-17';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a series LC in parallel with a series LC: XXI-18.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 0 1 3 3 0 ] );
                theCat.list(index).name = 'XXI-18';
            end
        
            theLen = index;
            
        end % FillCat_5C
        
        
        function theLen = FillCat_5D(theCat,theStartIndex)
            % Len = FillCat_5D(Cat,Flag): Fill in catalog for 5 element components XXI.
            % If Cat.list is zero length, return only number of components. 21Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in series with a parallel RL: XXII-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-1';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in series with a parallel RC: XXII-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-2';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in series with a parallel LC: XXII-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-3';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in series with a parallel RC: XXII-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-4';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in series with a parallel LC: XXII-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-5';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in series with a parallel LC: XXII-6.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-6';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in series with a parallel RL: XXII-7.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-7';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in series with a parallel RC: XXII-8.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-8';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in series with a parallel LC: XXII-9.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-9';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in series with a parallel RC: XXII-10.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-10';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in series with a parallel LC: XXII-11.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-11';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in series with a parallel LC: XXII-12.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-12';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in series with a parallel RL: XXII-13.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-13';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in series with a parallel RC: XXII-14.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).testEL = [ 0.1 2 3 4 0.005 ]; % Ca = 0.001 is too small.
                theCat.list(index).name = 'XXII-14';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in series with a parallel LC: XXII-15.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-15';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in series with a parallel RC: XXII-16.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-16';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in series with a parallel LC: XXII-17.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-17';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in series with a parallel LC: XXII-18.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXII-18';
            end
            
            theLen = index;
            
        end % FillCat_5D
        
        
        function theLen = FillCat_5E(theCat,theStartIndex)
            % Len = FillCat_5E(Cat,Flag): Fill in catalog for 5 element components XXIV.
            % If Cat.list is zero length, return only number of components. 25Mar2015
            
            % NOTE WELL: Components XXIII-1,4,7,12,16,18 all reduce to simpler components.
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXIII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RL in series with a parallel RL: XXIII-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-1';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RL in series with a parallel RC: XXIII-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-2';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RL in series with a parallel LC: XXIII-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-3';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RC in series with a parallel RC: XXIII-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-4';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RC in series with a parallel LC: XXIII-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-5';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a parallel RC in series with a parallel LC: XXIII-6.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-6';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a parallel RL in series with a parallel RL: XXIII-7.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-7';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a parallel RL in series with a parallel RC: XXIII-8.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-8';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a parallel RL in series with a parallel LC: XXIII-9.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-9';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a parallel RC in series with a parallel RC: XXIII-10.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-10';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a parallel RC in series with a parallel LC: XXIII-11.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-11';
            end

            index = index + 1;
            if aLen  % L in parallel with a parallel RC in series with a parallel LC: XXIII-12.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-12';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RL in series with a parallel RL: XXIII-13.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-13';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RL in series with a parallel RC: XXIII-14.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                % theCat.list(index).testEL = [ 0.1 2 3 4 0.005 ]; % Ca = 0.001 is too small.
                theCat.list(index).name = 'XXIII-14';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RL in series with a parallel LC: XXIII-15.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-15';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RC in series with a parallel RC: XXIII-16.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-16';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RC in series with a parallel LC: XXIII-17.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-17';
            end
           
            index = index + 1;
            if aLen  % C in parallel with a parallel RC in series with a parallel LC: XXIII-18.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXIII-18';
            end
            
            theLen = index;
            
        end % FillCat_5E
        
        
        function theLen = FillCat_5F(theCat,theStartIndex)
            % Len = FillCat_5F(Cat,Flag): Fill in catalog for 5 element components XXIII.
            % If Cat.list is zero length, return only number of components. 24Mar2015
            
            %%%% NOTE WELL: XXIV-1,4,7,12,16,18 are equivalent to smaller circuits.
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms  Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXIV
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in series with a series RL in parallel with a series RL: XXIV-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-1';
            end
           
            index = index + 1;
            if aLen  % R in series with a series RL in parallel with a series RC: XXIV-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-2';
            end
           
            index = index + 1;
            if aLen  % R in series with a series RL in parallel with a series LC: XXIV-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-3';
            end
           
            index = index + 1;
            if aLen  % R in series with a series RC in parallel with a series RC: XXIV-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-4';
            end
           
            index = index + 1;
            if aLen  % R in series with a series RC in parallel with a series LC: XXIV-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-5';
            end
           
            index = index + 1;
            if aLen  % R in series with a series LC in parallel with a series LC: XXIV-5.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-6';
            end
           
            index = index + 1;
            if aLen  % L in series with a series RL in parallel with a series RL: XXIV-7.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-7';
            end
           
            index = index + 1;
            if aLen  % L in series with a series RL in parallel with a series RC: XXIV-8.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-8';
            end
           
            index = index + 1;
            if aLen  % L in series with a series RL in parallel with a series LC: XXIV-9.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-9';
            end
           
            index = index + 1;
            if aLen  % L in series with a series RC in parallel with a series RC: XXIV-10.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-10';
            end
           
            index = index + 1;
            if aLen  % L in series with a series RC in parallel with a series LC: XXIV-11.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-11';
            end
           
            index = index + 1;
            if aLen  % L in series with a series LC in parallel with a series LC: XXIV-12.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-12';
            end
           
            index = index + 1;
            if aLen  % C in series with a series RL in parallel with a series RL: XXIV-13.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-13';
            end
           
            index = index + 1;
            if aLen  % C in series with a series RL in parallel with a series RC: XXIV-14.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-14';
            end
           
            index = index + 1;
            if aLen  % C in series with a series RL in parallel with a series LC: XXIV-15.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-15';
            end
           
            index = index + 1;
            if aLen  % C in series with a series RC in parallel with a series RC: XXIV-16.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-16';
            end
           
            index = index + 1;
            if aLen  % C in series with a series RC in parallel with a series LC: XXIV-17.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-17';
            end
           
            index = index + 1;
            if aLen  % C in series with a series LC in parallel with a series LC: XXIV-18.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 2 4 4 0 ] );
                theCat.list(index).name = 'XXIV-18';
            end
        
            theLen = index;
            
        end % FillCat_5F
        
        
        function theLen = FillCat_5G(theCat,theStartIndex)
            % Len = FillCat_5G(Cat,Flag): Fill in catalog for 5 element components XXV.
            % If Cat.list is zero length, return only number of components. 26Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc  Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXV
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in series with a parallel RL: XXV-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-1';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in series with a parallel RC: XXV-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-2';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RL in series with a parallel LC: XXV-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-3';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RC in series with a parallel RL: XXV-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-4';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RC in series with a parallel RC: XXV-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-5';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series RC in series with a parallel LC: XXV-6.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-6';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series LC in series with a parallel RL: XXV-7.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-7';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series LC in series with a parallel RC: XXV-8.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-8';
            end
           
            index = index + 1;
            if aLen  % R in parallel with a series LC in series with a parallel LC: XXV-9.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-9';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in series with a parallel RL: XXV-10.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-10';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in series with a parallel RC: XXV-11.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-11';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RL in series with a parallel LC: XXV-12.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-12';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RC in series with a parallel RL: XXV-13.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-13';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RC in series with a parallel RC: XXV-14.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-14';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series RC in series with a parallel LC: XXV-15.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-15';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series LC in series with a parallel RL: XXV-16.
                theCat.list(index).symV =          [ La  Lb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-16';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series LC in series with a parallel RC: XXV-17.
                theCat.list(index).symV =          [ La  Lb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-17';
            end
           
            index = index + 1;
            if aLen  % L in parallel with a series LC in series with a parallel LC: XXV-18.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 2 2 3 3 0 3 0 ] );
                theCat.list(index).name = 'XXV-18';
            end
        
            theLen = index;
            
        end % FillCat_5G
        
        
        function theLen = FillCat_5H(theCat,theStartIndex)
            % Len = FillCat_5H(Cat,Flag): Fill in catalog for 5 element components XXVI.
            % If Cat.list is zero length, return only number of components. 28Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXVI
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in parallel with a series RL: XXVI-1.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-1';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in parallel with a series RC: XXVI-2.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-2';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RL in parallel with a series LC: XXVI-3.
                theCat.list(index).symV =          [ Ra  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-3';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in parallel with a series RL: XXVI-4.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-4';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in parallel with a series RC: XXVI-5.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-5';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel RC in parallel with a series LC: XXVI-6.
                theCat.list(index).symV =          [ Ra  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-6';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel LC in parallel with a series RL: XXVI-7.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-7';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel LC in parallel with a series RC: XXVI-8.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-8';
            end
           
            index = index + 1;
            if aLen  % R in series with a parallel LC in parallel with a series LC: XXVI-9.
                theCat.list(index).symV =          [ Ra  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-9';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in parallel with a series RL: XXVI-10.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-10';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in parallel with a series RC: XXVI-11.
                theCat.list(index).symV =          [ La  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-11';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RL in parallel with a series LC: XXVI-12.
                theCat.list(index).symV =          [ La  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-12';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in parallel with a series RL: XXVI-13.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-13';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in parallel with a series RC: XXVI-14.
                theCat.list(index).symV =          [ La  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-14';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel RC in parallel with a series LC: XXVI-15.
                theCat.list(index).symV =          [ La  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-15';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel LC in parallel with a series RL: XXVI-16.
                theCat.list(index).symV =          [ La  Lb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-16';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel LC in parallel with a series RC: XXVI-17.
                theCat.list(index).symV =          [ La  Lb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-17';
            end
           
            index = index + 1;
            if aLen  % L in series with a parallel LC in parallel with a series LC: XXVI-18.
                theCat.list(index).symV =          [ La  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-18';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in parallel with a series RL: XXVI-19.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-19';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in parallel with a series RC: XXVI-20.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-20';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RL in parallel with a series LC: XXVI-21.
                theCat.list(index).symV =          [ Ca  Rb  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-21';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in parallel with a series RL: XXVI-22.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-22';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in parallel with a series RC: XXVI-23.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-23';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel RC in parallel with a series LC: XXVI-24.
                theCat.list(index).symV =          [ Ca  Rb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-24';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel LC in parallel with a series RL: XXVI-25.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-25';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel LC in parallel with a series RC: XXVI-26.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-26';
            end
           
            index = index + 1;
            if aLen  % C in series with a parallel LC in parallel with a series LC: XXVI-27.
                theCat.list(index).symV =          [ Ca  Lb  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 2 0 2 3 3 0 ] );
                theCat.list(index).name = 'XXVI-27';
            end
            
            theLen = index;
            
        end % FillCat_5H
        
        
        function theLen = FillCat_5I(theCat,theStartIndex)
            % Len = FillCat_5I(Cat,Flag): Fill in catalog for 5 element components XXVII.
            % If Cat.list is zero length, return only number of components. 28Mar2015
            
            % NOTE WELL: Components XXVII-1,2,4,6,10,11,17,18,22,24,26,27 all reduced to simpler components.
            % They are commented out below.
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXVII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an R in series with a parallel RL: XXVII-1.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-1';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an R in series with a parallel RC: XXVII-2.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-2';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an R in series with a parallel LC: XXVII-3.
                theCat.list(index).symV =          [ Ra  La  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-3';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an L in series with a parallel RL: XXVII-4.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-4';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an L in series with a parallel RC: XXVII-5.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-5';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an L in series with a parallel LC: XXVII-6.
                theCat.list(index).symV =          [ Ra  La  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-6';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an C in series with a parallel RL: XXVII-7.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-7';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an C in series with a parallel RC: XXVII-8.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-8';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in parallel with an C in series with a parallel LC: XXVII-9.
                theCat.list(index).symV =          [ Ra  La  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-9';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an R in series with a parallel RL: XXVII-10.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-10';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an R in series with a parallel RC: XXVII-11.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-11';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an R in series with a parallel LC: XXVII-12.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-12';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an L in series with a parallel RL: XXVII-13.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-13';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an L in series with a parallel RC: XXVII-14.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-14';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an L in series with a parallel LC: XXVII-15.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-15';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an C in series with a parallel RL: XXVII-16.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-16';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an C in series with a parallel RC: XXVII-17.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-17';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in parallel with an C in series with a parallel LC: XXVII-18.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-18';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an R in series with a parallel RL: XXVII-19.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-19';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an R in series with a parallel RC: XXVII-20.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-20';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an R in series with a parallel LC: XXVII-21.
                theCat.list(index).symV =          [ La  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-21';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an L in series with a parallel RL: XXVII-22.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-22';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an L in series with a parallel RC: XXVII-23.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-23';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an L in series with a parallel LC: XXVII-24.
                theCat.list(index).symV =          [ La  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-24';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an C in series with a parallel RL: XXVII-25.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-25';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an C in series with a parallel RC: XXVII-26.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-26';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in parallel with an C in series with a parallel LC: XXVII-27.
                theCat.list(index).symV =          [ La  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 0 1 0 1 2 2 0 2 0 ] );
                theCat.list(index).name = 'XXVII-27';
            end

            theLen = index;
            
        end % FillCat_5I
        
        
        function theLen = FillCat_5J(theCat,theStartIndex)
            % Len = FillCat_5J(Cat,Flag): Fill in catalog for 5 element components XXVII.
            % If Cat.list is zero length, return only number of components. 28Mar2015
            
            % NOTE WELL: Components XXVIII-1,2,4,6,10,11,17,18,22,24,26,27 all reduced to simpler components.
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXVIII
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1;
            if aLen  % Series RL in series with an R in parallel with a series RL: XXVIII-1.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-1';
            end
           
            index = index + 1;
            if aLen  % Series RL in series with an R in parallel with a series RC: XXVIII-2.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-2';
            end

            index = index + 1;
            if aLen  % Series RL in series with an R in parallel with a series RC: XXVIII-3.
                theCat.list(index).symV =          [ Ra  La  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-3';
            end
           
            index = index + 1;
            if aLen  % Series RL in series with an L in parallel with a series RL: XXVIII-4.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-4';
            end
           
            index = index + 1;
            if aLen  % Series RL in series with an L in parallel with a series RC: XXVIII-5.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-5';
            end

            index = index + 1; % Enough coef, just a2 times b0 = b2, so only 4 indepent eqns...reduces to 4 element circuit.
            if aLen  % Series RL in series with an L in parallel with a series RC: XXVIII-6.
                theCat.list(index).symV =          [ Ra  La  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-6';
            end
           
            index = index + 1;
            if aLen  % Series RL in series with an C in parallel with a series RL: XXVIII-7.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-7';
            end
           
            index = index + 1;
            if aLen  % Series RL in series with an C in parallel with a series RC: XXVIII-8.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-8';
            end

            index = index + 1;
            if aLen  % Series RL in series with an C in parallel with a series RC: XXVIII-9.
                theCat.list(index).symV =          [ Ra  La  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-9';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an R in parallel with a series RL: XXVIII-10.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-10';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an R in parallel with a series RC: XXVIII-11.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-11';
            end

            index = index + 1;
            if aLen  % Series RC in series with an R in parallel with a series RC: XXVIII-12.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-12';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an L in parallel with a series RL: XXVIII-13.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-13';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an L in parallel with a series RC: XXVIII-14.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-14';
            end

            index = index + 1;
            if aLen  % Series RC in series with an L in parallel with a series RC: XXVIII-15.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-15';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an C in parallel with a series RL: XXVIII-16.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-16';
            end
           
            index = index + 1;
            if aLen  % Series RC in series with an C in parallel with a series RC: XXVIII-17.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-17';
            end

            index = index + 1;
            if aLen  % Series RC in series with an C in parallel with a series RC: XXVIII-18.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-18';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an R in parallel with a series RL: XXVIII-19.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-19';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an R in parallel with a series RC: XXVIII-20.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-20';
            end

            index = index + 1;
            if aLen  % Series LC in series with an R in parallel with a series RC: XXVIII-21.
                theCat.list(index).symV =          [ La  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-21';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an L in parallel with a series RL: XXVIII-22.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-22';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an L in parallel with a series RC: XXVIII-23.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-23';
            end

            index = index + 1;
            if aLen  % Series LC in series with an L in parallel with a series RC: XXVIII-24.
                theCat.list(index).symV =          [ La  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-24';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an C in parallel with a series RL: XXVIII-25.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-25';
            end
           
            index = index + 1;
            if aLen  % Series LC in series with an C in parallel with a series RC: XXVIII-26.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-26';
            end

            index = index + 1;
            if aLen  % Series LC in series with an C in parallel with a series RC: XXVIII-27.
                theCat.list(index).symV =          [ La  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 3 3 0 3 4 4 0 ] );
                theCat.list(index).name = 'XXVIII-27';
            end
            
            theLen = index;
            
        end % FillCat_5J
        
        
        function theLen = FillCat_5K(theCat,theStartIndex)
            % Len = FillCat_5K(Cat,Flag): Fill in catalog for 5 element components XXX.
            % If Cat.list is zero length, return only number of components. 28Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXIX
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            index = index + 1; % NOTE: Direct solve does not work for this one. AltCalcXXX_1 used.
            if aLen  % Series RL in parallel with an R in series with a parallel RL:  XXIX-1.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-1';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an R in series with a parallel RC:  XXIX-2.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-2';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an R in series with a parallel LC:  XXIX-3.
                theCat.list(index).symV =          [ Ra  La  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-3';
            end
           
            index = index + 1;
            if aLen  % Series RL in parallel with an L in series with a parallel RL:  XXIX-4.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-4';
            end
            
            index = index + 1; % NOTE: Direct solve does not work for this one. AltCalcXXX_5 used.
            if aLen  % Series RL in parallel with an L in series with a parallel RC:  XXIX-5.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-5';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an L in series with a parallel LC:  XXIX-6.
                theCat.list(index).symV =          [ Ra  La  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-6';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an C in series with a parallel RL:  XXIX-7.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-7';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an C in series with a parallel RC:  XXIX-8.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-8';
            end
            
            index = index + 1;
            if aLen  % Series RL in parallel with an C in series with a parallel LC:  XXIX-9.
                theCat.list(index).symV =          [ Ra  La  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-9';
            end
           
            index = index + 1;
            if aLen  % Series RC in parallel with an R in series with a parallel RL:  XXIX-10.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-10';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an R in series with a parallel RC:  XXIX-11.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-11';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an R in series with a parallel LC:  XXIX-12.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-12';
            end
           
            index = index + 1;
            if aLen  % Series RC in parallel with an L in series with a parallel RL:  XXIX-13.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).testEL = [ 100  .002  0.03  4  0.5 ];
                theCat.list(index).name =  'XXIX-13';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an L in series with a parallel RC:  XXIX-14.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-14';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an L in series with a parallel LC:  XXIX-15.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-15';
            end
           
            index = index + 1;
            if aLen  % Series RC in parallel with an C in series with a parallel RL:  XXIX-16.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).testEL = [ 100  .002  .03  40  5 ];
                theCat.list(index).name =  'XXIX-16';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an C in series with a parallel RC:  XXIX-17.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-17';
            end
            
            index = index + 1;
            if aLen  % Series RC in parallel with an C in series with a parallel LC:  XXIX-18.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-18';
            end
           
            index = index + 1;
            if aLen  % Series LC in parallel with an R in series with a parallel RL:  XXIX-19.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-19';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an R in series with a parallel RC:  XXIX-20.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-20';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an R in series with a parallel LC:  XXIX-21.
                theCat.list(index).symV =          [ La  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-21';
            end
           
            index = index + 1;
            if aLen  % Series LC in parallel with an L in series with a parallel RL:  XXIX-22.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-22';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an L in series with a parallel RC:  XXIX-23.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-23';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an L in series with a parallel LC:  XXIX-24.
                theCat.list(index).symV =          [ La  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-24';
            end
           
            index = index + 1;
            if aLen  % Series LC in parallel with an C in series with a parallel RL:  XXIX-25.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-25';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an C in series with a parallel RC:  XXIX-26.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-26';
            end
            
            index = index + 1;
            if aLen  % Series LC in parallel with an C in series with a parallel LC:  XXIX-27.
                theCat.list(index).symV =          [ La  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 2 0 1 3 3 0 3 0 ] );
                theCat.list(index).name =  'XXIX-27';
            end
           
            theLen = index;
            
        end % FillCat_5K
        
        
        function theLen = FillCat_5L(theCat,theStartIndex)
            % Len = FillCat_5L(Cat,Flag): Fill in catalog for 5 element components XXIX.
            % If Cat.list is zero length, return only number of components. 28Mar2015
            
            aLen = length( theCat.list );
            index = theStartIndex;
            
            syms Ra Rb Rc La Lb Lc Ca Cb Cc  %Symbolic variables for RLC components.
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%  FIVE ELEMENT MODELS -- XXX
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            index = index + 1; % NOTE: Direct solve does not work for this one. AltCalcXXIX_1 used.
            if aLen % Parallel RL in series with an R in parallel with a series RL: XXX-1.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-1';
            end

            index = index + 1; %Solve for XXII-1, equiv to XXX-1, and transform answer.
            if aLen  % Parallel RL in series with an R in parallel with a series RC: XXX-2.
                theCat.list(index).symV =          [ Ra  La  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-2';
            end

            index = index + 1;
            if aLen  % Parallel RL in series with an R in parallel with a series RC: XXX-3.
                theCat.list(index).symV =          [ Ra  La  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-3';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in series with an L in parallel with a series RL: XXX-4.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).testEL = [4.3000 1.3000 5.4000 2.7000 0.9200]; % Default could not be fit.
                theCat.list(index).name =  'XXX-4';
            end
           
            index = index + 1; % Direct solve does not work for this one. Uses AltCalcXXIX_5 instead.
            if aLen  % Parallel RL in series with an L in parallel with a series RC: XXX-5.
                theCat.list(index).symV =          [ Ra  La  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-5';
            end

            index = index + 1;
            if aLen  % Parallel RL in series with an L in parallel with a series RC: XXX-6.
                theCat.list(index).symV =          [ Ra  La  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-6';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in series with an C in parallel with a series RL: XXX-7.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-7';
            end
           
            index = index + 1;
            if aLen  % Parallel RL in series with an C in parallel with a series RC: XXX-8.
                theCat.list(index).symV =          [ Ra  La  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-8';
            end

            index = index + 1;
            if aLen  % Parallel RL in series with an C in parallel with a series RC: XXX-9.
                theCat.list(index).symV =          [ Ra  La  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-9';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an R in parallel with a series RL: XXX-10.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-10';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an R in parallel with a series RC: XXX-11.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-11';
            end

            index = index + 1;
            if aLen  % Parallel RC in series with an R in parallel with a series RC: XXX-12.
                theCat.list(index).symV =          [ Ra  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-12';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an L in parallel with a series RL: XXX-13.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-13';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an L in parallel with a series RC: XXX-14.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-14';
            end

            index = index + 1;
            if aLen  % Parallel RC in series with an L in parallel with a series RC: XXX-15.
                theCat.list(index).symV =          [ Ra  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-15';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an C in parallel with a series RL: XXX-16.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-16';
            end
           
            index = index + 1;
            if aLen  % Parallel RC in series with an C in parallel with a series RC: XXX-17.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-17';
            end

            index = index + 1;
            if aLen  % Parallel RC in series with an C in parallel with a series RC: XXX-18.
                theCat.list(index).symV =          [ Ra  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-18';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an R in parallel with a series RL: XXX-19.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-19';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an R in parallel with a series RC: XXX-20.
                theCat.list(index).symV =          [ La  Ca  Rb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-20';
            end

            index = index + 1;
            if aLen  % Parallel LC in series with an R in parallel with a series RC: XXX-21.
                theCat.list(index).symV =          [ La  Ca  Rb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-21';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an L in parallel with a series RL: XXX-22.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-22';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an L in parallel with a series RC: XXX-23.
                theCat.list(index).symV =          [ La  Ca  Lb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-23';
            end

            index = index + 1;
            if aLen  % Parallel LC in series with an L in parallel with a series RC: XXX-24.
                theCat.list(index).symV =          [ La  Ca  Lb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-24';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an C in parallel with a series RL: XXX-25.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Lc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-25';
            end
           
            index = index + 1;
            if aLen  % Parallel LC in series with an C in parallel with a series RC: XXX-26.
                theCat.list(index).symV =          [ La  Ca  Cb  Rc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-26';
            end

            index = index + 1;
            if aLen  % Parallel LC in series with an C in parallel with a series RC: XXX-27.
                theCat.list(index).symV =          [ La  Ca  Cb  Lc  Cc ];
                theCat.list(index).nodes = uint32( [ 1 2 1 2 2 0 2 3 3 0 ] );
                theCat.list(index).name =  'XXX-27';
            end
            
            theLen = index;
            
        end % FillCat_5L
        
            
    end % CRCat private methods.
    
end % CRCat Class

