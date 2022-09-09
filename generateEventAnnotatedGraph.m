function generateEventAnnotatedGraph(graphName, dataObject,eventsToAnnotate,spreadMeasure,dataStatus,nPoints,shadingColourMap)

    %default is redimentionalised
    if ~exist('dataStatus',"var")
        dataStatus = "redimentionalised";
    end 
    
    %Default is SEM
    if ~exist('spreadMeasure','var')
        spreadMeasure = "SEM";
    end

    %Default is 500
    if ~exist('nPoints','var')
        nPoints = 500;
    end

    EVTcell = {};
    %setup the events to annotate subcell; by default everything
    if ~exist("eventsToAnnotate","var")
        EVTcell = dataObject.eventTimingsCell;
    else
        EVTcell = dataObject.getEVTSubcell(eventsToAnnotate);
    end

    nOfGrad = size(EVTcell,1);

    %makes sure we have a colour maps selected for the data
    if exist('shadingColourMap','var')
        shadingColourMap = shadingColourMap;
    else
        shadingColourMap = hsv(nOfGrad);
    end

    %now we need to work out what we want to do with regards to the 
    %figure
    
    

    figure('Name',graphName);
    hold on
    gradCell = cell(nOfGrad,3); %preallocate
    %we have to handle differently if raw hence if not switch
    if dataStatus == "raw"
        
        %need to work out the graph bounds, so lets get the max of Xcell
        yMax = max(dataObject.Xcell); %not sure if this will work
        yMin = min(dataObject.Xcell);

        %calculate gradient parameters <- fix this cos multiple cell
        %assignment
        EVTofInterest = EVTcell{:,2};
        gradCell = generateFreqGradientsHandler(EVTofInterest,yMin,yMax,nPoints);

        %slap the gradients on the graph
        for i = 1:nOfGrad
            patch("Faces",gradCell{i,1},"Vertices",gradCell{i,2},"FaceColor", ...
                shadingColourMap(i,:),"EdgeColor","none","FaceAlpha","interp", ...
                "FaceVertexAlphaData",gradCell{i,3})
        end

        %slap the trends on the graph
        for i = 1:dataObject.N
            plot(dataObject.Tcell{i,1}, dataObject.Xcell{i})
        end
    
    else
        %so here we're either going to be looking at normalised or
        %redimentionalised, which are essentially the same, just with a
        %different transform 
        yVec =[];
        initDevVector = [];
        yPlusSpread = [];
        yMinusSpread = [];

        %first we're gonna do the transforms to inform on how much space we
        %need
        %We'll start by splitting between ploting SD or SEM

        if spreadMeasure == "SD"
            initDevVector = dataObject.Xstd;
        else %defaulting to SEM
            initDevVector = dataObject.Xsem;
        end

        %now lets compute the plots
        if dataStatus == "redimentionalised"
            yVec = dataObject.Xmin+dataObject.X*(dataObject.Xmax - dataObject.Xmin);
            yPlusSpread = dataObject.Xmin+(dataObject.X+initDevVector)*(dataObject.Xmax-dataObject.Xmin);
            yMinusSpread = dataObject.Xmin+(dataObject.X-initDevVector)*(dataObject.Xmax-dataObject.Xmin);
        else
            yVec = dataObject.X;
            yPlusSpread = dataObject.X+initDevVector;
            yMinusSpread = dataObject.X-initDevVector;
        end 

        %now this can give us maxima and minima
        yMax = max(yPlusSpread);
        yMin = min(yMinusSpread);

        %now we can compute the gradients
        EVTofInterest = cell(nOfGrad,1);
        for i = 1:nOfGrad
            EVTofInterest{i} = EVTcell{i,4};
        end
        
        %EVTofInterest = EVTcell{:,4};
        gradCell = generateFreqGradientsHandler(EVTofInterest, yMin,yMax,nPoints);

        %now we draw the gradients
        for i = 1:nOfGrad
            patch("Faces",gradCell{i,1},"Vertices",gradCell{i,2},"FaceColor", ...
                shadingColourMap(i,:),"EdgeColor","none","FaceAlpha","interp", ...
                "FaceVertexAlphaData",gradCell{i,3})
        end

        %finally we can plot the stuff atop
        plot(dataObject.T, yVec, 'k','LineWidth',2)
        plot(dataObject.T, yPlusSpread,'k--','LineWidth',1)
        plot(dataObject.T, yMinusSpread,'k--','LineWidth',1)

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
