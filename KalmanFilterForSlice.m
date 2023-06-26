%Based on the Kalman Stack Filter of Fiji made by Christopher Philip Mauer%
%http://imagej.net/plugins/kalman.html%

clear
close all

%Read a tiff stack%
[file,path] = uigetfile('*.tif;*.tiff');
TiffStack = file;
Info = imfinfo(TiffStack);
StackW = Info(1).Width;
StackH = Info(1).Height;
StackN = length(Info);
StackRead = zeros(StackW, StackH, StackN, 'uint8');
 
T = Tiff(TiffStack, 'r');

for i=1:StackN
    
   T.setDirectory(i);
   StackRead(:,:,i)=T.read();
   
end

T.close();

%Concatenate tiff stack%
StackCCn = StackN+50;
StackCC = zeros(StackW, StackH, StackCCn, 'uint8');
StackCC(:,:,1:50) = StackRead(:,:,1:50);
StackCC(:,:,51:StackN+50) = StackRead;

%Create a tiff stack to write%
[filepath, name, ext] = fileparts(file);
newfilename = strcat(name, '-kf.tif');
K = Tiff(newfilename, 'w');
tagstruct.ImageLength = size(StackCC, 1);
tagstruct.ImageWidth = size(StackCC, 2);
tagstruct.BitsPerSample = 8;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = 1;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;

%User-defined Kamlan filter value%
SensorNoiseEst=0.1;    %SensorNoice(R)%
FilterGain=0.8;  %Prediction Matrix(F)%

%Initialization%
PreviousImage=StackCC(:,:,StackCCn);
ErrorSeed=SensorNoiseEst;

%Assuming H = 1, i.e. ignore sensor reading represents the actual value%

tic

for i=1:StackCCn
    
    %Correction%
    KalmanGain=ErrorSeed/(ErrorSeed+SensorNoiseEst);
    NewEstimate=FilterGain*PreviousImage+(1-FilterGain)*StackCC(:,:,i)+KalmanGain*(StackCC(:,:,i)-PreviousImage);
    NewVarianceEstimate=ErrorSeed*(1-KalmanGain);    
    
    %Writing tiff stack on the second round%
    if i > 50
        K.setTag(tagstruct);
        K.write(NewEstimate);
        K.writeDirectory();
    end
    
    %Update values%
    PreviousImage=NewEstimate;
    ErrorSeed=NewVarianceEstimate;

end
toc

K.close
