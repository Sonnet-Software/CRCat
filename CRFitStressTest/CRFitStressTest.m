function CRFitStressTest()
    % Stress test complex rational function fitting routines jcr05feb2023
    % Fitting times and errors refreshed. jcr28Aug2025
    % CRCat and associated software is licensed under the MIT open software
    % license. See the file LICENSE.TXT in the main directory.
    aOriginalDigits = digits;

    
    % *************************************************************
    % ******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % *************************************************************
    % 
    aName = 'N100_0o01-10exp_nd_nadap.s1p'; % 100 points 0.1 - 10 GHz, nd, no adap.
    aDat = SnP; % Allocate a variable to hold the n-port data.
    aDat.Get(aName);
    fprintf('\n *** File = %s\n',aName);
    fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );

    % ****** Run test cases using the above data file.
    digits(32);
    CRStressTestBody( 'Short Stub',5,5,aDat,'y11',[5.996187e-04, 5.840103e-21],3); % 0.6 0.4s/fit
    % Numerator: Number of zeros with positive real parts set to zero = 1.
    % Denominator: Number of zeros with positive real parts set to zero = 0.
    % Cleaned Result Error (Fit 2) = 1.452538e-07
    % 
    % digits(100);
    % CRStressTestBody( 'Short Stub',5,5,aDat,'y11',[5.996187e-04, 5.840103e-21],2); % 0.4 0.4s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 1.
    % % Denominator: Number of zeros with positive real parts set to zero = 0.
    % % Cleaned Result Error (Fit 2) = 1.452538e-07
    % 
    % digits(200);
    % CRStressTestBody( 'Short Stub',5,5,aDat,'y11',[5.996187e-04, 5.840103e-21],2); % 0.4 0.4s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 1.
    % % Denominator: Number of zeros with positive real parts set to zero = 0.
    % % Cleaned Result Error (Fit 2) = 1.452538e-07
    % 
    % fprintf('\n');
    % digits(32);
    % CRStressTestBody( 'Short Stub',10,10,aDat,'y11',[5.707407e-09, 2.724562e-19],2); % 1.0 1.0s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 1.
    % % Denominator: Number of zeros with positive real parts set to zero = 0.
    % % Cleaned Result Error (Fit 2) = 3.316619e-09
    % 
    % digits(100);
    % CRStressTestBody( 'Short Stub',10,10,aDat,'y11',[5.707407e-09, 2.724562e-19],2); % 1.0 1.0s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 1.
    % % Denominator: Number of zeros with positive real parts set to zero = 0.
    % % Cleaned Result Error (Fit 2) = 3.316619e-09
    % 
    % digits(200);
    % CRStressTestBody( 'Short Stub',10,10,aDat,'y11',[5.707407e-09, 2.724562e-19],2); % 1.0 1.0s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 1.
    % % Denominator: Number of zeros with positive real parts set to zero = 0.
    % % Cleaned Result Error (Fit 2) = 3.316619e-09
    % 
    % fprintf('\n');
    % digits(32);
    % CRStressTestBody( 'Short Stub',20,20,aDat,'y11',[1.504108e-11, 9.183004e-20],2); % 4.3 4.2s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 4.
    % % Denominator: Number of zeros with positive real parts set to zero = 4.
    % % Cleaned Result Error (Fit 2) = 7.366942e+00
    % 
    % digits(100);
    % CRStressTestBody( 'Short Stub',20,20,aDat,'y11',[1.504108e-11, 9.183004e-20],2); % 4.4 4.4s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 4.
    % % Denominator: Number of zeros with positive real parts set to zero = 4.
    % % Cleaned Result Error (Fit 2) = 7.366942e+00
    % 
    % digits(200);
    % CRStressTestBody( 'Short Stub',20,20,aDat,'y11',[1.504108e-11, 9.183004e-20],2); % 4.8 5.1s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 4.
    % % Denominator: Number of zeros with positive real parts set to zero = 4.
    % % Cleaned Result Error (Fit 2) = 7.366942e+00

    % fprintf('\n');
    % digits(32);
    % CRStressTestBody( 'Short Stub',40,40,aDat,'y11',[ 1.654049e-12, 1.869859e-12],2); % 23.5 24.0s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 21.
    % % Denominator: Number of zeros with positive real parts set to zero = 22.
    % % Cleaned Result Error (Fit 2) = 7.924671e-02 
    % 
    % digits(100);
    % CRStressTestBody( 'Short Stub',40,40,aDat,'y11',[1.526068e-13, 6.016284e-18],2); % 24.8 24.6s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 10.
    % % Denominator: Number of zeros with positive real parts set to zero = 11.
    % % Cleaned Result Error (Fit 2) = 3.970618e-10
    % 
    % digits(200);
    % CRStressTestBody( 'Short Stub',40,40,aDat,'y11',[1.526068e-13, 6.016284e-18],2); % 27.0 28.0s/fit.
    % % Numerator: Number of zeros with positive real parts set to zero = 10.
    % % Denominator: Number of zeros with positive real parts set to zero = 11.
    % % Cleaned Result Error (Fit 2) = 3.970618e-10


    %*************************************************************
    %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    %*************************************************************

    % aName = 'N1000_0o01-100exp_nd_nadap.s1p'; % 1000 points 0.1 - 100 GHz, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s, %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit);
    % 
    % 
    % fprintf('\n');
    % digits(100);
    % CRStressTestBody( 'Highly Moded Resonator',50,50,aDat,'y11',[4.401777e-01, 1.210007e-17],2); % 24.6 24.8s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 39.
    % % Denominator: Number of zeros with positive real parts set to zero = 17.
    % % Cleaned Result Error (Fit 2) = 6.002001e+01
    % 
    % digits(200);
    % CRStressTestBody( 'Highly Moded Resonator',50,50,aDat,'y11',[4.401777e-01, 1.210007e-17],2); %  25.3 25.3s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 39.
    % % Denominator: Number of zeros with positive real parts set to zero = 17.
    % % Cleaned Result Error (Fit 2) = 6.002001e+01
    % 
    % fprintf('\n');
    % digits(100);
    % CRStressTestBody( 'Highly Moded Resonator',70,70,aDat,'y11',[5.060131e-01, 1.358028e-17],2); % 47.8 62.2s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 53.
    % % Denominator: Number of zeros with positive real parts set to zero = 39.
    % % Cleaned Result Error (Fit 2) = 3.834887e+01
    % 
    % digits(200);
    % CRStressTestBody( 'Highly Moded Resonator',70,70,aDat,'y11',[4.241138e-02, 2.152302e-17],2); % 47.5 46.6s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 53.
    % % Denominator: Number of zeros with positive real parts set to zero = 39.
    % % Cleaned Result Error (Fit 2) = 3.642145e+01
    % 
    % fprintf('\n');
    % digits(100);
    % CRStressTestBody( 'Highly Moded Resonator',100,100,aDat,'y11',[1.585588e-01, 6.357006e-16],2); % 77.1 83.4s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 57.
    % % Denominator: Number of zeros with positive real parts set to zero = 43.
    % % Cleaned Result Error (Fit 2) = 4.880114e+01
    % 
    % digits(200);
    % CRStressTestBody( 'Highly Moded Resonator',100,100,aDat,'y11',[1.585588e-01, 6.357006e-16],2); % 147.7 92.8s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 57.
    % % Denominator: Number of zeros with positive real parts set to zero = 43.
    % Cleaned Result Error (Fit 2) = 4.880114e+01

    % fprintf('\n');
    % digits(100);
    % CRStressTestBody( 'Highly Moded Resonator',150,150,aDat,'y11',[1.407487e-01, 1.014769e-01],2); % 337.7 348.4s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 73.
    % % Denominator: Number of zeros with positive real parts set to zero = 65.
    % % Cleaned Result Error (Fit 2) = 5.526034e-01
    % 
    % digits(200);
    % CRStressTestBody( 'Highly Moded Resonator',150,150,aDat,'y11',[2.695081e-02, 2.455201e-12],2); % 347.2 342.1s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 69.
    % % Denominator: Number of zeros with positive real parts set to zero = 58.
    % % Cleaned Result Error (Fit 2) = 2.638028e-01
    % 
    % digits(300);
    % CRStressTestBody( 'Highly Moded Resonator',250,250,aDat,'y11',[3.988574e-10, 7.206240e-11],3); 965.4 982.5s/fit
    % % Numerator: Number of zeros with positive real parts set to zero = 117.
    % % Denominator: Number of zeros with positive real parts set to zero = 102.
    % % Cleaned Result Error (Fit 2) = 2.154405e-01

    %*************************************************************
    %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    %*************************************************************
    % 
    % aName = 'N1000_0o1-100_nd_nadap.s1p'; % 1000 points 0.1 - 100 GHz, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % % ****** Run a bunch of test cases using the above data file.
    % digits(300);
    % CRStressTestBody( 'OverModed LinSweep 0.02mmCell',150,150,aDat,'y11',[2.849552e-01, 1.506404e-13]); % Fit 1 good up to 20 GHz. Cleaned matches Fit 1 up to 30 GHz. N1000_0o1-100lin_NM150_d300_NotCleaned.fig N1000_0o1-100lin_NM150_d300_Cleaned.fig 
    % digits(300);
    % CRStressTestBody( 'OverModed LinSweep 0.02mmCell',250,250,aDat,'y11',[2.129566e-01, 6.320563e-10]); % Cleaned error = 3.605430e-02 Total crap everywhere. N1000_0o1-100lin_NM250_d300_NotCleaned.fig N1000_0o1-100lin_NM250_d300_Cleaned.fig.
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'N1000_0o1-100exp_nd_nadap.s1p'; % 1000 points 0.1 - 100 GHz, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(300);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',250,250,aDat,'y11',[2.909529e-02, 5.334321e-10]); % 951.4 538.4s/fit 
    % % Fit 1 good except 23-32GHz. N1000_0o1-100exp_NM250_d300_NotCleaned.fig. Cleaned was near total crap, error 1.974743e+00
    % 
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',300,300,aDat,'y11',[7.444910e-07, 3.441068e-12]); % 1504.2 1520.4s/fit
    % 
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',350,350,aDat,'y11',[4.092764e-11, 4.749332e-11]); %  1190.4 1197.0s/fit
    % % 2263.6s/fit
    % 
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',400,400,aDat,'y11',[1.087349e-10, 3.386328e-10]); % 1686.8 1642.4s/fit
    % % 2267.9s/fit
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',450,450,aDat,'y11',[6.331551e-11, 5.207494e-11]); % 2378.5 2546.3s/fit
    % % 3821.5s/fit
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',500,500,aDat,'y11',[3.648563e-10, 7.870713e-09]); % 2969.5 3824.9s/fit
    % % 4435.6s/fits/fit small fit2 glitch just above 2.5 GHz.
    % 
    % digits(500);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',500,500,aDat,'y11',[3.375769e-10, 2.821972e-10]); % 3702.9 4837.2s/fit
    % 
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'N1000_0o1-100exp_0o05Cell_nd_nadap.s1p'; % 1000 points 0.1 - 100 GHz, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.05mmCell',350,350,aDat,'y11',[5.822571e-11, 3.366181e-11]); % 1234.9 1334.4s/fit
    % % Essentially the same error as with 0o02 cell size. 
    % 
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'N3000_0o1-100exp_nd_nadap.s1p'; % 3000 points 0.1 - 100 GHz, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(400);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',350,350,aDat,'y11',[1.423449e-01, 4.481329e-09]); % 1564.1 2310.4s/fit
    % digits(500);
    % CRStressTestBody( 'OverModed ExpSweep 0.02mmCell',350,350,aDat,'y11',[1.423449e-01, 4.481329e-09]); % 2718.0 2010.0s/fit
    % 
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'F10k_0o01-100lin_nd_nadap.s1p'; % 10000 points 0.01 - 100 GHz linear sweep, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(500);
    % CRStressTestBody( 'OverModed ExpSweep Ftest',350,350,aDat,'y11',[9.470041e-03, 1.293339e-09]); % 2447.2 2458.9s/fit
    % 
    % digits(500);
    % CRStressTestBody( 'OverModed LinSweep Ftest',400,400,aDat,'y11',[1.492837e-02, 2.877017e-09]); % 3308.9 3332.0s/fit 
    % 
    % digits(500);
    % CRStressTestBody( 'OverModed LinSweep Ftest',450,450,aDat,'y11',[1.068946e-02, 1.682134e-09]); % 4282.8 4064.7s/fit 
    % 
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'E10k_0o01-100lin_nd_nadap.s1p'; % 10000 points 0.01 - 100 GHz linear sweep, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % % 
    % % digits(500);
    % % CRStressTestBody( 'OverModed Etest',350,350,aDat,'y11',[3.135303e-03, 2.172295e-09]); % 3221.7 2711.7s/fit
    % 
    % digits(500);
    % CRStressTestBody( 'OverModed Etest',400,400,aDat,'y11',[42.644468e-03, 6.403330e-09]); % 3740.7 3013.8s/fit
    % 
    % digits(600);
    % CRStressTestBody( 'OverModed Etest',350,350,aDat,'y11',[3.135303e-03, 2.172295e-09]); % 3472.3 2379.3s/fit
    % 
    % digits(600);
    % CRStressTestBody( 'OverModed Etest',450,450,aDat,'y11',[1.112802e-03, 1.823969e-09]); % 4216.1 4553.9s/fit
    % 
    % digits(600);
    % CRStressTestBody( 'OverModed Etest',500,500,aDat,'y11',[1.390154e-03, 4.612125e-10]); % 5091.5 6872.7s/fit.
    % 
    % digits(600);
    % CRStressTestBody( 'OverModed Etest',550,550,aDat,'y11',[9.963818e-04, 1.378965e-09]); % 6515.5 8422.2s/fit
    % 
    % digits(700); % This is the test case with results plotted in Fig. 1 and 2 of my CR paper.
    % CRStressTestBody( 'OverModed Etest',600,600,aDat,'y11',[2.513174e-04, 1.662095e-10],1); % 8532.2 8237.6s/fit
    % 
    % 
    % 
    % % *************************************************************
    % % ******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % % *************************************************************
    % 
    % aName = 'E2k_0o01-20lin_nd_nadap.s1p'; % 2000 points 0.01 - 20 GHz linear sweep, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, no debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(32);
    % CRStressTestBody( 'OverModed Etest',10,10,aDat,'y11',[9.447294e-07, 1.922653e-18]); % 4.8 5.0s/fit
    % 
    % 
    % %*************************************************************
    % %******* LOAD DATA TO BE USED FOR NEXT FEW TEST CASES ********
    % %*************************************************************
    % 
    % aName = 'hairpin_InBand_Nf251.s2p'; % 10000 points 0.01 - 100 GHz linear sweep, nd, no adap.
    % aDat = SnP; % Allocate a variable to hold the n-port data.
    % aDat.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, debed, no adaptive sweep.\n',length(aDat.freq),aDat.freq(1),aDat.freq(end),aDat.fUnit );
    % 
    % digits(500);
    % CRStressTestBody( 'Hairpin',100,100,aDat,'S11',[3.037834e-09, 4.618215e-16]); % 62.7 61.9s/fit
    % 
    % digits(400);
    % CRStressTestBody( 'Hairpin',100,100,aDat,'S21',[6.865323e-09, 2.407288e-17]); % 59.9 67.5s/fit
    % digits(400);
    % CRStressTestBody( 'Hairpin',50,50,aDat,'S21',[6.221242e-09, 2.691606e-17]); % 19.2 17.6s/fit
    % digits(400);
    % CRStressTestBody( 'Hairpin',25,25,aDat,'S21',[5.230466e-09, 2.632602e-17]); % 11.7 11.8s/fit
    % digits(400);
    % CRStressTestBody( 'Hairpin',10,10,aDat,'S21',[1.490338e-01, 8.205240e-18]); % 2.0 2.0s/fit
    % digits(400);
    % CRStressTestBody( 'Hairpin',15,15,aDat,'S21',[2.404356e-08, 2.017092e-17]); % 4.3 4.0s/fit
    % digits(200);
    % CRStressTestBody( 'Hairpin',15,15,aDat,'S21',[2.404356e-08, 2.017092e-17]); % 3.5 3.4s/fit
    % digits(100);
    % CRStressTestBody( 'Hairpin',15,15,aDat,'S11',[2.126096e-03, 2.600818e-16]); % 2.9 3.9s/fit
    % digits(100);
    % CRStressTestBody( 'Hairpin',15,15,aDat,'S21',[2.404356e-08, 2.017092e-17]); % 4.1 3.5s/fit
    % digits(32);
    % CRStressTestBody( 'Hairpin',15,15,aDat,'S21',[5.995384e-09, 3.087809e-09]); % 3.5 3.5s/fit
    % 


    digits(aOriginalDigits);
    fprintf('\n');

end % CRStressTest

function CRStressTestBody( theTestId,theNumSize,theDenSize,theDat,thePullStr,theErrorNominal,theTasks)
    % CRStressTestBody (TestNum,NumSize,DenSize,Dat,Pull,ErrorNominal) Name of test is
    % in TestId and is documented in plot title. Test the CRFit routine
    % for NumSize numerator and DenSize denominator for data from SnP Dat
    % and for data to be pulled from Dat as specified by PullStr.
    % ErrorNominal is used print out the error if worse than expected.
    % jcr03Mar2023
    % Tasks, if not passed, or is 0, no plot, no cleaning of zeros. If 1, do
    % plot of fit 1 and fit 2. If 2, clean zeros. If 3, do both and plot both.
    % Ignore if other. 23Aug2025

    aTasks = 0;
    if nargin == 7
        aTasks = theTasks;
    end % nargin

    aAFlag = ones(1,theNumSize);
    aBFlag = ones(1,theDenSize);

    [aPull,aDescription] = theDat.Pull(thePullStr); % Pull out data for fitting.

    tic; % Start the timer.
    [aA1,aB1,~] = CRFit(aPull,theDat.freq,aAFlag,aBFlag);
    aTime1 = toc;
    aFit1 = double( CREval(aA1,aB1,theDat.freq) );
    aError1 = rmse(aPull,aFit1);

    tic; % Start the timer.
    [aA2,aB2,~] = CRFit(aFit1,theDat.freq,aAFlag,aBFlag);
    aTime2 = toc;
    aFit2 = double( CREval(aA2,aB2,theDat.freq) );
    aError2 = rmse(aFit1,aFit2);

    fprintf('\n');
    fprintf('    Test %s, %s, Time per fit1, fit2 = %.1f %.1fs/fit.\n',theTestId,aDescription,aTime1,aTime2);
    fprintf('    Digits=%d M=%d N=%d Nf=%d Error = %e, %e\n',digits,theNumSize,theDenSize,length(aFit1),aError1,aError2);
    if 0.9*aError1 > theErrorNominal(1) || 0.9*aError2 > theErrorNominal(2)
        fprintf('---> Errors are usually %e %e.\n',theErrorNominal(1),theErrorNominal(2));
    end % if 0.9*theError10
    
    if aTasks == 1 || aTasks == 3 % Do plots.
        aTitle = sprintf( '%s %s; M=%d N=%d Nf=%d Nd=%d',theTestId,thePullStr,theNumSize,theDenSize,length(aFit1),digits );
        CRStressTestPlot( theDat,aPull,aFit2,aFit2,aTitle );
    end % aTasks

    % % Check a high resolution scan of the data, in case rational polynomial
    % % blows up between data points. Using linear sweep.
    % aFreqHiRes = linspace(theDat.freq(1),theDat.freq(end),5*length(theDat.freq));
    % aFit1HiRes = double( CREval(aA1,aB1,aFreqHiRes) );
    % aFit2HiRes = double( CREval(aA2,aB2,aFreqHiRes) );
    % aTitle = sprintf( 'HiRes: %s %s; M=%d N=%d Nf=%d Nd=%d',theTestId,thePullStr,theNumSize,theDenSize,length(aFit1),digits );
    % CRFitStressPlotHiRes( theDat,aPull,aFit1HiRes,aFit2HiRes,aFreqHiRes/(2*pi*theDat.fMult),aTitle );


    % % Load another data file, usually over a broader frequency range, and
    % % extrapolate Fits 1 and 2 and compare to loaded data.
    % aName = 'hairpin_BroadBand_Nf991.s2p'; % 991 points 0.1 - 10 GHz linear sweep, nd, no adap.
    % aDat2 = SnP; % Allocate a variable to hold the n-port data.
    % aDat2.Get(aName);
    % fprintf('\n *** File = %s\n',aName);
    % fprintf(' *** %d freqs, %f-%f %s, debed, no adaptive sweep.\n',length(aDat2.freq),aDat2.freq(1),aDat2.freq(end),aDat2.fUnit );
    % [aPull2,~] = aDat2.Pull(thePullStr); % Pull out data for fitting.
    % aFit1HiRes = double( CREval(aA1,aB1,aDat2.freq) );
    % aFit2HiRes = double( CREval(aA2,aB2,aDat2.freq) );
    % aTitle = sprintf( 'Extrapolated: %s %s; M=%d N=%d Nf=%d Nd=%d',theTestId,thePullStr,theNumSize,theDenSize,length(aFit1),digits );
    % CRStressTestPlot( aDat2,aPull2,aFit1HiRes,aFit2HiRes,aTitle );

    % Check for stability.
    if aTasks == 2 || aTasks == 3 % Do pole zero real part clean.
        fprintf('Numerator: ');
        aA2Cleaned = CRFitClean(aA2,1); % Set any positive real parts of zeros to zero.
        fprintf('Denominator: ');
        aB2Cleaned = CRFitClean(aB2,1); % Set any positive real parts of poles to zero.
        aFitCleaned = double( CREval(aA2Cleaned,aB2Cleaned,theDat.freq) ); % Recalculate the stable response.
        aErrorCleaned = rmse( aFit2,aFitCleaned );
        fprintf('    Cleaned Result Error (Fit 2) = %e\n',aErrorCleaned);
    end % if aTasks

    if aTasks == 3 % Do plots.
        aTitle = sprintf( 'CLEANED RESULT (Fit 2): %s %s; M=%d N=%d Nf=%d Nd=%d',theTestId,thePullStr,theNumSize,theDenSize,length(aFit1),digits );
        CRStressTestPlot( theDat,aPull,aFit2,aFitCleaned,aTitle );
    end % if aTasks

end % CRStressTestBody
    
function CRStressTestPlot(theDat,thePull,theFit1,theFit2,theTitle)
    % CRStressTestPlot(Dat,Pull,Fit1,Fit2,Title) Plot results
    % from a CRFitStressTest test case. Dat is the original SnP file. The
    % Pull is complex array of data pulled from Dat. Fit1 and Fit 2 are
    % complex data fitted to Pull. jcr27Feb2023

    % Calc magnitude dB of the results.
    adBPull = 20.0*log10( abs( thePull ) );
    adBFit1 = 20.0*log10( abs( theFit1 ) );
    adBFit2 = 20.0*log10( abs( theFit2 ) );
    
    % Calc phase of the results in degrees.
    aRadToDeg = 180.0/pi;
    aAngPull = aRadToDeg*angle( thePull );
    aAngFit1 = aRadToDeg*angle( theFit1 );
    aAngFit2 = aRadToDeg*angle( theFit2 );

    if nargin == 5
        aTitle = theTitle;
    else
        aTitle = 'CR Stress Test Result';
    end % if nargin

    % Plot the result
    
    figure; % Open up a new figure.
    hold on;
    title( aTitle );
    xlabel( sprintf('Frequency (%s)',theDat.fUnit) );
    ylabel( sprintf('%s-Parameter Magnitude (dB)',theDat.pType) );
    aGca = gca;
    aGca.FontSize = 12;
    aGca.YColor = 'black';
%     aT = text( aXmin+0.05*(aXmax-aXmin), aYmin+0.3*(aYmax-aYmin),aPlotLabel );
%     set( aT,'FontSize',12 );
    aGcf = gcf;
    aGcf.Units = 'inches';
    aGcf.Position = [1 1 8 5];

    yyaxis right
    aGca.YColor = [0 0 .5];
    aYLabel = ylabel( sprintf('%s-Parameter Phase (degrees)',theDat.pType) );
    set(aYLabel,'Rotation',-90,'VerticalAlignment','bottom');

    plot(theDat.freq,aAngPull,'-','LineWidth',10,'Color',[.8 .8 1]);
    plot(theDat.freq,aAngFit1,':','LineWidth',5,'Color',[.6 .6 1]);
    plot(theDat.freq,aAngFit2,'-k','LineWidth',1);

    yyaxis left
    aGca.YColor = [0 0 0];
    aZ = ones(1,length(adBPull));
    aCurve1Handle = plot3(theDat.freq,adBPull,aZ,'-','LineWidth',10,'Color',[.8 .8 .8]);
    aCurve2Handle = plot3(theDat.freq,adBFit1,2*aZ,':','LineWidth',5,'Color',[.6 .6 .6]);
    aCurve3Handle = plot3(theDat.freq,adBFit2,3*aZ,'-k','LineWidth',1);
    set(gca, 'SortMethod', 'depth')

    legend([aCurve1Handle(1),aCurve2Handle(1),aCurve3Handle(1)],' Original ',' Fit 1 ',' Fit 2 ');

    annotation('textbox',[0.1482 0.1438 0.1396 0.0917],'string','Curves Above: Magnitude','HorizontalAlignment','center','BackgroundColor','white');
    annotation('textbox',[0.7266 0.1438 0.1580 0.0917],'string','Curves Beneath: Phase','HorizontalAlignment','center','BackgroundColor','white');

    hold off;
    set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
    box on;

end % CRStressTestPlot


% function CRFitStressPlotHiRes(theDat,thePull,theFit1,theFit2,theFreqHiRes,theTitle)
%     % CRStressTestPlot(Dat,Pull,Fit1,Fit2,FreqHiRes,Title) Plot results
%     % from a CRFitStressTest test case. Fit1 and Fit2 ploted at FreqHiRes
%     % frequencies. Usually at high resolution to make sure rational
%     % polynomial is well behaved between frequencies in theDat.
%     % Dat is the original SnP file. The
%     % Pull is complex array of data pulled from Dat. Fit1 and Fit 2 are
%     % complex data fitted to Pull. jcr09Mar2023
% 
%     % Calc magnitude dB of the results.
%     adBPull = 20.0*log10( abs( thePull ) );
%     adBFit1 = 20.0*log10( abs( theFit1 ) );
%     adBFit2 = 20.0*log10( abs( theFit2 ) );
% 
%     % Calc phase of the results in degrees.
%     aRadToDeg = 180.0/pi;
%     aAngPull = aRadToDeg*angle( thePull );
%     aAngFit1 = aRadToDeg*angle( theFit1 );
%     aAngFit2 = aRadToDeg*angle( theFit2 );
% 
%     if nargin == 6
%         aTitle = theTitle;
%     else
%         aTitle = 'CR Stress Test Result High Resolution Sweep';
%     end % if nargin
% 
%     % Plot the result
% 
%     figure; % Open up a new figure.
%     hold on;
%     title( aTitle );
%     xlabel( sprintf('Frequency (%s)',theDat.fUnit) );
%     ylabel( sprintf('%s-Parameter Magnitude (dB)',theDat.pType) );
%     aGca = gca;
%     aGca.FontSize = 12;
%     aGca.YColor = 'black';
% %     aT = text( aXmin+0.05*(aXmax-aXmin), aYmin+0.3*(aYmax-aYmin),aPlotLabel );
% %     set( aT,'FontSize',12 );
%     aGcf = gcf;
%     aGcf.Units = 'inches';
%     aGcf.Position = [1 1 8 5];
% 
%     yyaxis right
%     aGca.YColor = [0 0 .5];
%     aYLabel = ylabel( sprintf('%s-Parameter Phase (degrees)',theDat.pType) );
%     set(aYLabel,'Rotation',-90,'VerticalAlignment','bottom');
% 
%     plot(theDat.freq,aAngPull,'-','LineWidth',10,'Color',[.8 .8 1]);
%     plot(theFreqHiRes,aAngFit1,':','LineWidth',5,'Color',[.6 .6 1]);
%     plot(theFreqHiRes,aAngFit2,'-k','LineWidth',1);
% 
%     yyaxis left
%     aGca.YColor = [0 0 0];
%     aZ = ones(1,length(adBPull));
%     aCurve1Handle = plot3(theDat.freq,adBPull,aZ,'-','LineWidth',10,'Color',[.8 .8 .8]);
%     aZ = ones(1,length(adBFit1));
%     aCurve2Handle = plot3(theFreqHiRes,adBFit1,2*aZ,':','LineWidth',5,'Color',[.6 .6 .6]);
%     aCurve3Handle = plot3(theFreqHiRes,adBFit2,3*aZ,'-k','LineWidth',1);
%     set(gca, 'SortMethod', 'depth')
% 
%     legend([aCurve1Handle(1),aCurve2Handle(1),aCurve3Handle(1)],' Original ',' Fit 1 ',' Fit 2 ');
% 
%     annotation('textbox',[0.1482 0.1438 0.1396 0.0917],'string','Curves Above: Magnitude','HorizontalAlignment','center','BackgroundColor','white');
%     annotation('textbox',[0.7266 0.1438 0.1580 0.0917],'string','Curves Beneath: Phase','HorizontalAlignment','center','BackgroundColor','white');
% 
%     hold off;
%     set(gcf, 'color', [1 1 1]); % Set the background color of the figure to white.
%     box on;
% 
% end % CRStressPlotHiRes
