function TessExample()

    close all

    wideColourMap = [82,27,147;...
        255,64,255;255,38,0;118,214,255;84,130,53];
    wideColourMap = wideColourMap ./ 255;

    %blueColourMap = [115,253,214;...
    %    118,213,255;1,125,255;4,50,255;1,24,147];
    orangeColourMap = [255,147,0;255,253,120];
    orangeColourMap = orangeColourMap ./ 255;
    
    Cep135UpBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/Cep135/Cep135 Ideal/Exports/Mean ch2_S";
    Cep135UpCyc12Itt = [6	7	9	17	18	20	25	27	28];
    Cep135UpCyc12lb = [204	108	300	684	708	480	984	660	612];
    Cep135UpCyc12ub = [1068	948	1080	1464	1488	1236	1836	1572	1608];
    Cep135UpCyc12EVTCell = {"meta/ana",[960	732	960	1344	1356	1104	1716	1452	1464]; ...
    "NEB",[780	636	840	1200	1248	972	1548	1272	1320]};

    Cep135DownBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/SORA comparisons/Hard core qunatiifcation/Cep135/CSCT exports/Data ";
    Cep135DownCyc12Itt = [1,2,15,16,20];
    Cep135DownCyc12lb = [345,15,210,240,330];
    Cep135DownCyc12ub = [1335,975,1200,1185,1395];
    Cep135DownFL = 15;
    Cep135DownCyc12EVTCell = {"meta/ana",[1140	825	1005	1005	1200];...
        "NEB",[990	675	870	855	1020]};

    Ana3UpBasePath ="/Users/thomas/Documents/PhD/Data/Project Laura/Ana3/Ideal/Exports/Mean ch2_S";
    Ana3UpCyc12Itt = [2	4	6	8	17	18	19	21];
    Ana3UpCyc12lb = [816	1248	1464	768	504	840	1500	1056];
    Ana3UpCyc12ub = [1884	2496	2556	1764	1680	1788	2652	2232];
    Ana3UpCyc12EVTCell = {"meta/ana",[1692	2232	2328    1560	1416	1560	2448	1920]; ...
    "NEB",[1500	2076	2184    1404	1272	1428	2292	1848]};

    Ana3DownBasePath =  "/Users/thomas/Documents/PhD/Data/Project Laura/SORA comparisons/Hard core qunatiifcation/Ana3/CSCT exports/S";
    Ana3DownCyc12Itt = [2,3,4,6,11];
    Ana3DownCyc12lb = [150,360,90,60,480];
    Ana3DownCyc12ub = [1125,1200,660,630,1590];
    Ana3DownCyc12FL = [15,15,15,15,30];
    Ana3DownCyc12EVTCell = {"meta/ana", [840	975	540	510	1350];...
        "NEB",[765	855	450	405	1170]};


    Ana2UpBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/Ana2/HS2/Exports/S";
    Ana2UpCyc12Itt = [3,4,8,11,12];
    Ana2UpCyc12lb = [216,648,900,864,84];
    Ana2UpCyc12ub = [1044,1476,1812,1800,948];
    Ana2UpCyc12EVTCell = {"meta/ana",[876	1320	1644	1644	780];"NEB",[744	1200	1524	1524	672]};

    Ana2DownBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/SORA comparisons/Hard core qunatiifcation/ana2/CSCT exports/S";
    Ana2DownCyc12Itt = [5,8,9];
    Ana2DownCyc12lb = [90,90,120];
    Ana2DownCyc12ub = [960,960,1050];
    Ana2DownFL = 30;
    Ana2DownCyc12EVTCell = {"meta/ana",[720,750,810];"NEB",[600,600,660]};

    Sas6UpBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/Sas6/Round 2 highspeed/Exports/Mean ch2_S";
    Sas6UpCyc12Itt = [1	3	6	7	13	14	16];
    Sas6UpCyc12lb = [300	396	300	672	468	228	576];
    Sas6UpCyc12ub = [1224	1548	1368	1608	1500	1176	1536];
    Sas6UpCyc12EVTCell = {"meta/ana",[1008	1356	1152	1380	1296	972	1320];...
        "NEB",[852	1128	972	1236	1116	792	1176]};

    Sas6DownBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/SORA comparisons/Hard core qunatiifcation/Sas6/CSCT Exports/S";
    Sas6DownCyc12Itt = [3, 5];
    Sas6DownCyc12lb = [210,210];
    Sas6DownCyc12ub = [1200,1200];
    Sas6DownCyc12FL = 30;
    Sas6DownCyc12EVTCell = {"meta/ana",[960	990];...
        "NEB",[870	840]};

    AslDownBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/SORA comparisons/Hard core qunatiifcation/Asl/CSCT exports/S";
    AslDownCyc12Itt = [13	15	20];
    AslDownCyc12lb = [165	30	180];
    AslDownCyc12ub = [1215	1140	1215];
    AslDownFL = 15;
    AslDownCyc12EVTCell = {"meta/ana",[1050	915	1050];"NEB",[855	795	855]};

    AslUpBasePath = "/Users/thomas/Documents/PhD/Data/Project Laura/Asl/Exports/Mean ch2_S";
    AslUpCyc12Itt = [1	5	6	7	8	10	12	15	17	18];
    AslUpCyc12lb = [828	180	672	576	144	828	300	744	720	816];
    AslUpCyc12ub = [1896	1512	1692	1644	1020	1920	1284	1932	1740	1704];
    AslUpCyc12EVTCell = {"meta/ana",[1704	1320	1488	1476	864	1752	1056	1776	1560	1512];...
    "NEB",[1476	1104	1320	1296	708	1572	924	1584	1404	1368]};

    Cep135UpData = normalisedEmbryoData(Cep135UpCyc12lb,Cep135UpCyc12ub,Cep135UpCyc12Itt,"meanPercentile95",12,Cep135UpBasePath);
    Ana3UpData = normalisedEmbryoData(Ana3UpCyc12lb,Ana3UpCyc12ub,Ana3UpCyc12Itt,"meanPercentile95",12,Ana3UpBasePath);
    Ana2UpData = normalisedEmbryoData(Ana2UpCyc12lb,Ana2UpCyc12ub,Ana2UpCyc12Itt,"meanPercentile95",12,Ana2UpBasePath);
    Sas6UpData = normalisedEmbryoData(Sas6UpCyc12lb,Sas6UpCyc12ub,Sas6UpCyc12Itt,"meanPercentile95",12,Sas6UpBasePath);
    AslUpData = normalisedEmbryoData(AslUpCyc12lb,AslUpCyc12ub,AslUpCyc12Itt,"meanPercentile95",12,AslUpBasePath);

    Cep135DownData = normalisedSoraData(Cep135DownCyc12lb, Cep135DownCyc12ub, Cep135DownCyc12Itt, Cep135DownFL, Cep135DownBasePath);
    Ana3DownData = normalisedSoraData(Ana3DownCyc12lb, Ana3DownCyc12ub, Ana3DownCyc12Itt, Ana3DownCyc12FL,Ana3DownBasePath);
    Ana2DownData = normalisedSoraData(Ana2DownCyc12lb, Ana2DownCyc12ub, Ana2DownCyc12Itt, Ana2DownFL, Ana2DownBasePath);
    Sas6DownData = normalisedSoraData(Sas6DownCyc12lb, Sas6DownCyc12ub, Sas6DownCyc12Itt, Sas6DownCyc12FL, Sas6DownBasePath);
    AslDownData = normalisedSoraData(AslDownCyc12lb,AslDownCyc12ub,AslDownCyc12Itt,AslDownFL,AslDownBasePath);

    Cep135UpData.appendEventTimes(Cep135UpCyc12EVTCell)
    Cep135DownData.appendEventTimes(Cep135DownCyc12EVTCell)
    Ana3UpData.appendEventTimes(Ana3UpCyc12EVTCell)
    Ana3DownData.appendEventTimes(Ana3DownCyc12EVTCell)
    Ana2UpData.appendEventTimes(Ana2UpCyc12EVTCell)
    Ana2DownData.appendEventTimes(Ana2DownCyc12EVTCell)
    Sas6UpData.appendEventTimes(Sas6UpCyc12EVTCell)
    Sas6DownData.appendEventTimes(Sas6DownCyc12EVTCell)
    AslUpData.appendEventTimes(AslUpCyc12EVTCell)
    AslDownData.appendEventTimes(AslDownCyc12EVTCell)

    eventsToAnnotate = ["NEB","meta/ana"];

    
    generateSDSEMTNGraphsUpDown("Cep135",Cep135DownData,Cep135UpData)
    generateSDSEMTNGraphsUpDown("Ana3", Ana3DownData,Ana3UpData)
    generateSDSEMTNGraphsUpDown("Ana2", Ana2DownData,Ana2UpData)
    generateSDSEMTNGraphsUpDown("Sas6", Sas6DownData,Sas6UpData)
    generateSDSEMTNGraphsUpDown("Asl", AslDownData,AslUpData)

    generateSDSEMTNGraphsUpDownEVT("Cep135",Cep135DownData,Cep135UpData,eventsToAnnotate,"SEM")
    generateSDSEMTNGraphsUpDownEVT("Ana3", Ana3DownData,Ana3UpData,eventsToAnnotate,"SEM")
    generateSDSEMTNGraphsUpDownEVT("Ana2", Ana2DownData,Ana2UpData,eventsToAnnotate,"SEM")
    generateSDSEMTNGraphsUpDownEVT("Sas6", Sas6DownData,Sas6UpData,eventsToAnnotate,"SEM")
    generateSDSEMTNGraphsUpDownEVT("Asl", AslDownData,AslUpData,eventsToAnnotate,"SEM")

    generateSDSEMTNGraphsEVT("Cep135,Ana3,Ana2,Sas6,Asl SORA comparison",[Cep135DownData,Ana3DownData,Ana2DownData,Sas6DownData,AslDownData],eventsToAnnotate,...
        "SEM",500,wideColourMap,orangeColourMap)
    generateSDSEMTNGraphsEVT("Cep135,Ana3,Ana2,Sas6,Asl upstairs comparison",[Cep135UpData,Ana3UpData,Ana2UpData,Sas6UpData,AslUpData],eventsToAnnotate,...
        "SEM",500,wideColourMap,orangeColourMap)
    generateSDSEMTNGraphsEVT("Cep135,Ana3,Ana2,Sas6 SORA comparison",[Cep135DownData,Ana3DownData,Ana2DownData,Sas6DownData],eventsToAnnotate,...
        "SEM",500,wideColourMap,orangeColourMap)
    generateSDSEMTNGraphsEVT("Cep135,Ana3,Ana2,Sas6 SORA comparison",[Cep135DownData,Ana3DownData,Ana2DownData,Sas6DownData],eventsToAnnotate,...
        "none",500,wideColourMap,orangeColourMap)


end