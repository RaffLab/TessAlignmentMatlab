function generateSDSEMTNGraphsUpDown(graphName,DownStairsData,UpStairsData, colourMap)
    

    %Sort out colours
    nOfTrends = 2;

    if exist('colourMap','var')
        colourMat = colourMap;
    else
        colourMat = hsv(nOfTrends);
    end

    normTCell = cell(nOfTrends,1);

    %normalise time lengths
    dTmax = max(DownStairsData.T);
    dTmin = min(DownStairsData.T);
    normTCell{2} = (DownStairsData.T - dTmin)/(dTmax-dTmin);

    %normalise time lengths
    uTmax = max(UpStairsData.T);
    uTmin = min(UpStairsData.T);
    normTCell{1} = (UpStairsData.T - uTmin)/(uTmax-uTmin);

    figure('Name', graphName)
    subplot(2,1,1) %SD non-dimentionalised
    hold on 
    yyaxis left
    plot(normTCell{1}, UpStairsData.X, 'k','LineWidth',2,'Color',colourMat(1,:))
    plot(normTCell{1}, UpStairsData.X+UpStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(1,:))
    plot(normTCell{1}, UpStairsData.X-UpStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(1,:))
    yyaxis right
    plot(normTCell{2}, DownStairsData.X, 'k','LineWidth',2,'Color',colourMat(2,:))
    plot(normTCell{2}, DownStairsData.X+DownStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(2,:))
    plot(normTCell{2}, DownStairsData.X-DownStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(2,:))


    subplot(2,1,2) %SEM non-dimentionalised
    hold on 
    yyaxis left
    plot(normTCell{1}, UpStairsData.X, 'k','LineWidth',2,'Color',colourMat(1,:))
    plot(normTCell{1}, UpStairsData.X+UpStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(1,:))
    plot(normTCell{1}, UpStairsData.X-UpStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(1,:))
    yyaxis right
    plot(normTCell{2}, DownStairsData.X, 'k','LineWidth',2,'Color',colourMat(2,:))
    plot(normTCell{2}, DownStairsData.X+DownStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(2,:))
    plot(normTCell{2}, DownStairsData.X-DownStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(2,:))

