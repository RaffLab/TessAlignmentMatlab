function generateSDSEMGraphsEVT(graphName,processedSoraArr, eventsToAnnotate,spreadMeasure,nPoints,lineColourMap, shadingColourMap)
    

    %Sort data
    nOfTrends = length(processedSoraArr);
    
    EVTcell = combineEVTCells(eventsToAnnotate,processedSoraArr);
    nOfGrad = size(EVTcell,1);


    %get colours
    if exist('shadingColourMap','var')
        shadingColourMat = shadingColourMap;
    else
        shadingColourMat = copper(nOfGrad);
    end


    if exist('lineColourMap','var')
        lineColourMat = lineColourMap;
    else
        lineColourMat = cool(nOfTrends);
    end

    %Default is SEM (how the measure of spread is shown)
    if ~exist('spreadMeasure','var')
        spreadMeasure = "SEM";
    end

    %Default is 500 (number of points in the graident for the evtcells)
    if ~exist('nPoints','var')
        nPoints = 500;
    end

    figure('Name',strcat("Uncoloured_",graphName))
    hold on
    for i = 1:nOfTrends
        currData = processedSoraArr(i);
        plot(currData.T, currData.X, 'k','LineWidth',2,'Color',lineColourMat(i,:))
        
        switch spreadMeasure
            case "SD"
                plot(currData.T, currData.X+currData.Xstd, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
                plot(currData.T, currData.X-currData.Xstd, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
            case "SEM"
                plot(currData.T, currData.X+currData.Xsem, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
                plot(currData.T, currData.X-currData.Xsem, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
        end
    end
    yLimits = get(gca, "YLim");

    EVTofInterest = cell(nOfGrad,1);
    for i = 1:nOfGrad
        EVTofInterest{i} = EVTcell{i,4}; %4 due to time re-dimentionalised
    end
    gradCell = generateFreqGradientsHandler(EVTofInterest, yLimits(1),yLimits(2), nPoints);
    
    figure("Name",graphName)
    hold on
    
    %now we draw the gradients
    for i = 1:nOfGrad
        patch("Faces",gradCell{i,1},"Vertices",gradCell{i,2},"FaceColor", ...
            shadingColourMat(i,:),"EdgeColor","none","FaceAlpha","interp", ...
            "FaceVertexAlphaData",gradCell{i,3})
    end
     for i = 1:nOfTrends
        currData = processedSoraArr(i);
        plot(currData.T, currData.X, 'k','LineWidth',2,'Color',lineColourMat(i,:))
        
        switch spreadMeasure
            case "SD"
                plot(currData.T, currData.X+currData.Xstd, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
                plot(currData.T, currData.X-currData.Xstd, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
            case "SEM"
                plot(currData.T, currData.X+currData.Xsem, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
                plot(currData.T, currData.X-currData.Xsem, 'k--','LineWidth',1,'Color',lineColourMat(i,:))
        end
    end



end

%function to grab EVT cells from various dataobjects and combine them into
%a whole ass cell 
function combinedEVTCell = combineEVTCells(eventsToAnnotate,dataObjects)
    
    %validate we have what we need <3
    if exist("eventsToAnnotate", "var") == false
        disp("ERROR: No events to annotate supplied")
        exit
    end
    
    nOfEvts = length(eventsToAnnotate);
    EVTCellLength = 4; % constant value for number of parameters in the EVT table

    %precondition cell
    combinedEVTCell = cell(nOfEvts,EVTCellLength);
        
    %loop through data objects merging the cells
    for i=1:length(dataObjects)
        currSubcell = dataObjects(i).getEVTSubcell(eventsToAnnotate); %grab the data from one data object
    
        %itterate through each event merging cells 
        for j=1:nOfEvts
            %iterate through catagories
            for k=3:EVTCellLength % no need to calculate this as this is fixed 
                %EVTRC = size(combinedEVTCell{j,k})debugging
                %SCRC = size(currSubcell{j,k})
                combinedEVTCell{j,k} = [combinedEVTCell{j,k};currSubcell{j,k}]; %extend off the bottom the volumn vectors
            end
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
