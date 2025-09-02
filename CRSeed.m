function theComp = CRSeed( theSeed,theCat,theFit,theId,theSprout )
    % Comp = CRSeed( Seed,Cat,Fit,Id,Sprout ): Find best fit(s) to Seed
    %   data after removing Sprout (see below). Search for the best fit
    %   from among the Id components of Cat. Return Comp, the fitted
    %   component last selected by the user for plotting. If none was
    %   selected, return lowest error comp. Skip all degenerate components.
    % Seed is an SnP class variable containing the S-, Y-, or Z-parameter data
    %   to be fitted. If Seed is a string, it is treated as the name of a
    %   file that contains Touchstone formated data. That file is read and
    %   loaded into an SnP class variable.
    % Cat is the catalog of components to be searched.
    % Examples of Fit follow. For more detail see Pull method in SnP class.
    %    Data is pulled from Seed as specified by Fit. That is the data
    %    that is to be fitted.
    % Fit = 'y10' or 'y11' or 'y' (default): Fit the sum of Column 1 of the Y-parameters.
    %     = 'y21': -Y21  (Lower case inidicates pi-model admittance.)
    %     = 'y12': -Y12  (Upper case indicates Y-parameter.)
    %     = 'y20': Fit the sum of Column 2 of the Y-parameters.
    %     = 'Y11' or 'Y': Y11
    %     = 'Y22': Y22
    %     = 'z10' or 'z11' or 'z' Z11 minus the sum of the rest of column 1
    %        of the Z-parameters.
    %     = 'z21': Z21  (Lower case inidicates T-model impedance.)
    %     = 'z12': Z12  (Upper case indicates Z-parameter.)
    %     = 'Z11' or 'Z': Z11
    %     = 'Z22': Z22
    % Fit can be prefaced with a number which will be the number of
    % frequencies from Seed used for actual fitting. Default is to use all
    % frequencies in Seed.
    % Id is the component(s) in Cat to be searched for a match with Seed.
    %   If no Id or Id==0, fit all components in catalog. Id may be vector of Ids.
    % Sprout is an array of Comps. If not passed, the data pulled from Seed is
    %   fitted as is. If present, the impedance of the first component in Sprout
    %   is subtracted from the pulled data. The admittance of the second
    %   component in Sprout is subtracted from the resulting admittance. And so on,
    %   odd being an impedance that is subtracted and even being an admitance
    %   that is subtracted. Then, the best fitting component for what is left
    %   is searched for and, when selected by the user, it is returned.
    %   The complete Sprout is compared to the orginal Seed for plotting.
    % The frequencies are set by the data in the Base SnP data type.
    % The frequency units are set by the units in Cat. 02Jan2022jcr
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.

    if nargin < 2
        error('Missing argument.\n');
    end % if nargin
    
    if nargin == 2 % Setting NoiseFloor to -200 dB means no noise added.
        theComp = CRSeedAddNoise( theSeed,-200,theCat );
    elseif nargin == 3
        theComp = CRSeedAddNoise( theSeed,-200,theCat,theFit );
    elseif nargin == 4
        theComp = CRSeedAddNoise( theSeed,-200,theCat,theFit,theId );
    else
        theComp = CRSeedAddNoise( theSeed,-200,theCat,theFit,theId,theSprout );
    end % if nargin
    
end % CRSeed
    