function EqivSchematicFig(theCat)
% Figure 7 in the CR paper.
    theCat.Draw('figure')
    aSize= [ 0.09 1.5 14 ];

    aCompNum = 27;
    aEnds = [ 1 6 1 2 ];
    aEnds = theCat.Draw(aCompNum,aEnds,aSize);
    aEnds = theCat.Draw('port',aEnds,aSize);
    aEnds = theCat.Draw(strcat('ground',theCat.list(aCompNum).name),aEnds,aSize);

    aCompNum = 39;
    aEnds = [ 2.5 6 2.5 2 ];
    aEnds = theCat.Draw(aCompNum,aEnds,aSize);
    aEnds = theCat.Draw('port',aEnds,aSize);
    aEnds = theCat.Draw(strcat('ground',theCat.list(aCompNum).name),aEnds,aSize);

    aCompNum = 112;
    aEnds = [ 4 6 4 2 ];
    aEnds = theCat.Draw(aCompNum,aEnds,aSize);
    aEnds = theCat.Draw('port',aEnds,aSize);
    aEnds = theCat.Draw(strcat('ground',theCat.list(aCompNum).name),aEnds,aSize);

    aCompNum = 560;
    aEnds = [ 5.75 6 5.75 2 ];
    aEnds = theCat.Draw(aCompNum,aEnds,aSize);
    aEnds = theCat.Draw('port',aEnds,aSize);
    aEnds = theCat.Draw(strcat('ground',theCat.list(aCompNum).name),aEnds,aSize);

end