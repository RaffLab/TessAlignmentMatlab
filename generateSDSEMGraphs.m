function generateSDSEMGraphs(graphName, processedDataArr, colourMap)
    
    nOfTrends = length(processedDataArr);
    %makes sure we have a colour map selected for the data
    if exist('colourMap',"var")
        colourMat = colourMap;
    else
        colourMat = hsv(nOfTrends);
    end 
    
    figure('Name', graphName)
    subplot(2,2,1) %SD non-dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(currData.T, currData.X, 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(currData.T, currData.X+currData.Xstd, 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(currData.T, currData.X-currData.Xstd, 'k--','LineWidth',1,'Color',colourMat(i,:))
    end
    
    subplot(2,2,2) %SD dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(currData.T, currData.Xmin+currData.X*(currData.Xmax - currData.Xmin), 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(currData.T, currData.Xmin+(currData.X+currData.Xstd)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(currData.T, currData.Xmin+(currData.X-currData.Xstd)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
    end

    subplot(2,2,3) %SEM non-dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(currData.T, currData.X, 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(currData.T, currData.X+currData.Xsem, 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(currData.T, currData.X-currData.Xsem, 'k--','LineWidth',1,'Color',colourMat(i,:))
    end

    subplot(2,2,4) %SEM dimentionalised
    hold on 
    for i = 1:nOfTrends
        currData = processedDataArr(i);
        plot(currData.T, currData.Xmin+currData.X*(currData.Xmax - currData.Xmin), 'k','LineWidth',2,'Color',colourMat(i,:))
        plot(currData.T, currData.Xmin+(currData.X+currData.Xsem)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
        plot(currData.T, currData.Xmin+(currData.X-currData.Xsem)*(currData.Xmax - currData.Xmin), 'k--','LineWidth',1,'Color',colourMat(i,:))
    end
    

    
    