function generateSDSEMTNGraphsUpDownEVT(graphName,downStairsData,upStairsData,eventsToAnnotate,spreadMeasure,nPoints,lineColourMap,shadingColourMap)
    %NOTE: unlike the OG EVT stuff, combined EVTs require eventsToAnnotate
    %to be supplied

    %Sort out colours
    nOfTrends = 2;


    %set defaults for optional vars
    if exist('lineColourMap','var')
        lineColourMat = lineColourMap;
    else
        lineColourMat = cool(nOfTrends);
    end

    %combine the EVT cells
    EVTcell = combineEVTCellUpDown(eventsToAnnotate, upStairsData,downStairsData);
    nOfGrad = size(EVTcell,1);

    %makes sure we have a colour maps selected for the data
    if exist('shadingColourMap','var')
        shadingColourMat = shadingColourMap;
    else
        shadingColourMat = copper(nOfGrad);
    end


    %Default is SEM (how the measure of spread is shown)
    if ~exist('spreadMeasure','var')
        spreadMeasure = "SEM";
    end

    %Default is 500 (number of points in the graident for the evtcells)
    if ~exist('nPoints','var')
        nPoints = 500;
    end


    normTCell = cell(nOfTrends,1);

    %normalise time lengths
    dTmax = max(downStairsData.T);
    dTmin = min(downStairsData.T);
    normTCell{2} = (downStairsData.T - dTmin)/(dTmax-dTmin);

    %normalise time lengths
    uTmax = max(upStairsData.T);
    uTmin = min(upStairsData.T);
    normTCell{1} = (upStairsData.T - uTmin)/(uTmax-uTmin);

    figure('Name', strcat("Uncoloured_",graphName))
    hold on
    gradCell = cell(nOfGrad,3); %preallocate cell that describes the timing gradients to be plotted
    
    %First we need to calculate the graph bounds so we need to work out
    %each of the trends we're plotting 

    upYVec = upStairsData.X;
    upPlusSpread = [];
    upMinusSpread = [];

    downYVec = downStairsData.X;
    downPlusSpread = [];
    downMinusSpread = [];

    spreadPresent = true;
    switch spreadMeasure
        case "SD"
            upPlusSpread = upStairsData.X+upStairsData.Xstd;
            upMinusSpread = upStairsData.X-upStairsData.Xstd;
            downPlusSpread = downStairsData.X+downStairsData.Xstd;
            downMinusSpread = downStairsData.X-downStairsData.Xstd;
        case "SEM"
            upPlusSpread = upStairsData.X+upStairsData.Xsem;
            upMinusSpread = upStairsData.X-upStairsData.Xsem;
            downPlusSpread = downStairsData.X+downStairsData.Xsem;
            downMinusSpread = downStairsData.X-downStairsData.Xsem;
        otherwise
            spreadPresent = false;
    end
    

    EVTofInterest = cell(nOfGrad,1);
    for i = 1:nOfGrad
        EVTofInterest{i} = EVTcell{i,3}; %note: use 3 because we're time normalised; use 4 to be time-redimentionalsied
    end

    

    yyaxis left
    
    %plot the first graph to inform the banding
    plot(normTCell{1}, upYVec, 'k','LineWidth',2, 'Color',lineColourMat(1,:))
    if spreadPresent
        plot(normTCell{1}, upPlusSpread,'k--','LineWidth',1, 'Color',lineColourMat(1,:))
        plot(normTCell{1}, upMinusSpread,'k--','LineWidth',1, 'Color',lineColourMat(1,:))
    end

    yLimits = get(gca,'YLim'); % get graph limits
    yyaxis right

    %finally we can plot the stuff atop
    plot(normTCell{2}, downYVec, 'k','LineWidth',2, 'Color',lineColourMat(2,:))
    if spreadPresent
        plot(normTCell{2}, downPlusSpread,'k--','LineWidth',1, 'Color',lineColourMat(2,:))
        plot(normTCell{2}, downMinusSpread,'k--','LineWidth',1, 'Color',lineColourMat(2,:))
    end

    
    gradCell = generateFreqGradientsHandler(EVTofInterest, yLimits(1),yLimits(2), nPoints);

    figure('Name',graphName)
    hold on
   
    yyaxis left

    %now we draw the gradients
    for i = 1:nOfGrad
        patch("Faces",gradCell{i,1},"Vertices",gradCell{i,2},"FaceColor", ...
            shadingColourMat(i,:),"EdgeColor","none","FaceAlpha","interp", ...
            "FaceVertexAlphaData",gradCell{i,3})
    end

    

    %finally we can plot the stuff atop
    plot(normTCell{1}, upYVec, 'k','LineWidth',2, 'Color',lineColourMat(1,:))
    if spreadPresent
        plot(normTCell{1}, upPlusSpread,'k--','LineWidth',1, 'Color',lineColourMat(1,:))
        plot(normTCell{1}, upMinusSpread,'k--','LineWidth',1, 'Color',lineColourMat(1,:))
    end

    yyaxis right

    %finally we can plot the stuff atop
    plot(normTCell{2}, downYVec, 'k','LineWidth',2, 'Color',lineColourMat(2,:))
    if spreadPresent
        plot(normTCell{2}, downPlusSpread,'k--','LineWidth',1, 'Color',lineColourMat(2,:))
        plot(normTCell{2}, downMinusSpread,'k--','LineWidth',1, 'Color',lineColourMat(2,:))
    end

    
end

%function to grab EVT cells from two dataobjects and combine them into
%a whole ass cell 
function combinedEVTCell = combineEVTCellUpDown(eventsToAnnotate,upData,downData)
    
    %validate we have what we need <3
    if exist("eventsToAnnotate", "var") == false
        disp("ERROR: No events to annotate supplied")
        exit
    end
    
    nOfEvts = length(eventsToAnnotate);
    EVTCellLength = 4; % constant value for number of parameters in the EVT table

    %precondition cell
    combinedEVTCell = cell(nOfEvts,EVTCellLength);
        
    %Grab data from each object
    upSubcell = upData.getEVTSubcell(eventsToAnnotate); 
    downSubcell = downData.getEVTSubcell(eventsToAnnotate);

    %itterate through each event merging cells 
    for j=1:nOfEvts
        %iterate through catagories
        for k=3:EVTCellLength % no need to calculate this as this is fixed 
            combinedEVTCell{j,k} = [downSubcell{j,k};upSubcell{j,k}]; %extend off the bottom the volumn vectors
        end
    end
end




%handler to gather multiple freq gradient datas and set up in cell :)
function gradCell = generateFreqGradientsHandler(dataColumn, yMin, yMax, nPoints)
    
    %calculate the number of gradients we're gonna draw
    %disp(dataColumn)
    nOfGrads = length(dataColumn);
    gradCell = cell(nOfGrads,3); %preallocate cell
    for i = 1:nOfGrads
        %compute for each
        [faces,verticies,Alphadata] = generateFreqGradientData(dataColumn{i},yMin,yMax,nPoints);
        gradCell{i,1} = faces;
        gradCell{i,2} = verticies;
        gradCell{i,3} = Alphadata;
    end

end



%     subplot(2,1,1) %SD non-dimentionalised
%     hold on 
%     yyaxis left
%     plot(normTCell{1}, UpStairsData.X, 'k','LineWidth',2,'Color',colourMat(1,:))
%     plot(normTCell{1}, UpStairsData.X+UpStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(1,:))
%     plot(normTCell{1}, UpStairsData.X-UpStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(1,:))
%     yyaxis right
%     plot(normTCell{2}, DownStairsData.X, 'k','LineWidth',2,'Color',colourMat(2,:))
%     plot(normTCell{2}, DownStairsData.X+DownStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(2,:))
%     plot(normTCell{2}, DownStairsData.X-DownStairsData.Xstd, 'k--','LineWidth',1,'Color',colourMat(2,:))
% 
% 
%     subplot(2,1,2) %SEM non-dimentionalised
%     hold on 
%     yyaxis left
%     plot(normTCell{1}, UpStairsData.X, 'k','LineWidth',2,'Color',colourMat(1,:))
%     plot(normTCell{1}, UpStairsData.X+UpStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(1,:))
%     plot(normTCell{1}, UpStairsData.X-UpStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(1,:))
%     yyaxis right
%     plot(normTCell{2}, DownStairsData.X, 'k','LineWidth',2,'Color',colourMat(2,:))
%     plot(normTCell{2}, DownStairsData.X+DownStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(2,:))
%     plot(normTCell{2}, DownStairsData.X-DownStairsData.Xsem, 'k--','LineWidth',1,'Color',colourMat(2,:))

