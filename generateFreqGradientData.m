function [faces, verticies, vertexAlpha] = generateFreqGradientData(data, yMin, yMax, nPoints)

%generateFreqGradientData converts 1d data values into the requesit
%paramenters needed to plot as a gradient patch onto a matlab graph
%
%   Inputs: data - 1d column vector of data to construct the gradient from
%           yMin & yMax - min and max values defining the upper and lower
%           y positions of the gradient effect to be drawn
%           nPoints - number of points to interpolate and evalute the
%           distribution at
%
%   Outputs: faces - matrix allocating verticies to faces
%            verticies - matrix of vertex points constructing the gradient
%            area
%            vertexAlpha - 1d Vector supplying alpha values at each vertex



%transform the data into a frequency distribution
%kernal is essentially a smoothing dist so will allow for variable dists
distribution = fitdist(data, "Kernel"); 

%generate arbitrary interpolated space to generate polygons for the
%gradient; cut off this space at the 99% percent limits
distLimits = icdf(distribution,[0.01,0.99]);
xInterpolated = linspace(distLimits(1),distLimits(2),nPoints);
distY = pdf(distribution,xInterpolated);

%preallocate matricies for the vertex data and the vertex alpha values
verticies = zeros((nPoints*2), 2); %verticies for each face making up the effect
vertexAlpha = zeros((nPoints*2),1); %alpha values per vertex

%populate vertex matricies
for i = 1:nPoints
    twoi = i*2;
    verticies(twoi-1,:) = [xInterpolated(i),yMax];
    vertexAlpha(twoi-1) = distY(i);
    verticies(twoi,:) = [xInterpolated(i),yMin];
    vertexAlpha(twoi) = distY(i);
end

%preallocate matrix defining face verticies 
faces = zeros(nPoints-1,4); %prealocate the faces matrix

%populate the matrix defining face verticies
for i = 1:(nPoints-1)
    twoi = i*2;
    faces(i,:) = [twoi-1,twoi,twoi+2,twoi+1];
end