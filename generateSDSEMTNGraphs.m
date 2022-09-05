function generateSDSEMTNGraphs(graphName, processedDataArr, colourMap)
    

    %Sort out colours
    nOfTrends = length(processedDataArr);

    if exist('colourMap','var')
        colourMat = colourMap;
    else
        colourMat = hsv(nOfTrends);
    end

    normTCell = cell(nOfTrends,1);

    %normalise time lengths
    for i=1:nOfTrends
        currData = processedDataArr(i);
        currTmax = max(currData.T);
        currTmin = min(currData.T);
        normTCell{i} = (currData.T - currTmin)/(currTmax-currTmin);
    end

    figure('Name', graphName)
    subplot(2,2,1) %SD non-dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(normTCell{i}, currData.X, 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.X+currData.Xstd, 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.X-currData.Xstd, 'k--','LineWidth',1,'Color',colourMat(i,:))
    end
    
    subplot(2,2,2) %SD dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(normTCell{i}, currData.Xmin+currData.X*(currData.Xmax - currData.Xmin), 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.Xmin+(currData.X+currData.Xstd)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.Xmin+(currData.X-currData.Xstd)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
    end

    subplot(2,2,3) %SEM non-dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(normTCell{i}, currData.X, 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.X+currData.Xsem, 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.X-currData.Xsem, 'k--','LineWidth',1,'Color',colourMat(i,:))
    end

    subplot(2,2,4) %SEM dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(normTCell{i}, currData.Xmin+currData.X*(currData.Xmax - currData.Xmin), 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.Xmin+(currData.X+currData.Xsem)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(normTCell{i}, currData.Xmin+(currData.X-currData.Xsem)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
    end
    

