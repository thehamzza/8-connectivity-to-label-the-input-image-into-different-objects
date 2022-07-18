% Digital Image Processing - Assignment 1 - BEE 10
% Hamza - Iqra - Abdul Wasayh
% Object Labeling using 8-Connectivity.
% November 02, 2021
%%
clc
clear all
close all

Image_File = 'Assignment_01_Image_01.bmp';      %Input Image name.
Input_Image = imread(Image_File);               %Reading input image.

%Some Initializations.
[rows cols] = size(Input_Image);   %Dimentions of input image.
Bkgrd = 0;                          %Background value.
Label_Matrix = zeros(rows,cols); %Separate Matrix for labels. Dimentions are same as input image.
Current_Label=0;
Equivalent_Table= {}; %Cell array

%% (Pass 1)
for i=1:rows   %Outer loop. Changing rows.       
                                               % ** Scan through each pixel
    for j=1:cols  %Inner loop. Changing coloumn.   
        %% If Pixel is not Background.
        if(Input_Image(i,j)~=Bkgrd) 
            % Checking Neigbours.
           
            % If no neighbour is labelled.    
            if(Label_Matrix(i-1,j-1)==0 && Label_Matrix(i-1,j)==0 && Label_Matrix(i-1,j+1)==0 && Label_Matrix(i,j-1)==0) %No neighbour is labelled.           
                Current_Label = Current_Label + 1 ; %Go to new label.
                Label_Matrix(i,j) = Current_Label;  %Assign new label to current pixe
                Equivalent_Table{Current_Label} = Current_Label;   %Store new label value in the cell array as same index as label.
            
            % If Any neigbour is labelled.
            else 
            %Get neigbouring labels and put them in a vector. (For 1 Left and 3 top pixels.)
            Neighbor_Labels = [Label_Matrix(i-1,j-1) Label_Matrix(i-1,j) Label_Matrix(i-1,j+1) Label_Matrix(i,j-1)];
            Neighbor_Labels = Neighbor_Labels(find(Neighbor_Labels~=Bkgrd)); %Neighbouring labels other than background.
            Minimum_label = min(Neighbor_Labels);  %Pick the smallest label from neighbours.
            Label_Matrix(i,j) = Minimum_label; %Assign minimum label from pixel to current pixel..   
            Equivalent_Table{Minimum_label} = union(Equivalent_Table{Minimum_label},Neighbor_Labels); %Put neighboring pixels to equivalence table.  
            end        
        end
    end
end

%% Gathering all equivalence values in each of respective index.

[m n] =  size(Equivalent_Table);
for k = n:-1:1 %Accessing each array withing the cell
   for l = Equivalent_Table{k} %Acessing each elecment within the array.
       Equivalent_Table{l} = union(Equivalent_Table{k},Equivalent_Table{l});
   end 
end
for k = 1:n
   for l = Equivalent_Table{k}
       Equivalent_Table{l} = union(Equivalent_Table{k},Equivalent_Table{l});
   end    
end

%% Re labeling (Pass 2)

for i=1:rows   %Outer loop. Changing rows.       
                                               % ** Scan through each pixel
    for j=1:cols  %Inner loop. Changing coloumn.   
        if(Label_Matrix(i,j) ~= 0) %If any label is found.
            Label_Matrix(i,j) = min(Equivalent_Table{Label_Matrix(i,j)}); %Relabel the pixel with the lowest equivalent label. 
        end
    end
end

%% Colouring 

RGB_Image = uint8(zeros(rows,cols,3)); %Initializing Matrix with three chanels.
Unique_Labels = unique(Label_Matrix);
Unique_Labels = Unique_Labels(find(Unique_Labels~=0)); %Unique Labels (Exclude 0).
RGB_Clrs = randi(255,[length(Unique_Labels),3]); %Generating Random Colour for each unique label. 1 row = 1 color.

for i=1:rows   %Outer loop. Changing rows.       
                                               % ** Scan through each pixel
    for j=1:cols  %Inner loop. Changing coloumn.   
        if(Label_Matrix(i,j) ~= 0) %If any label is found.
            RGB_Image(i,j,:) = RGB_Clrs(find(Unique_Labels==Label_Matrix(i,j)),:); %Making RGB Image. 1st color assigned to 1st label.
        end
    end
end

%% Ploting 
%Labeled and Original Image
figure;
subplot(1,2,1);
imshow(Input_Image);
title('\bf \color{blue} Original Image - DIP Assignment 1','linewidth',2)

subplot(1,2,2);
imshow(RGB_Image);
title('\bf \color{blue} Labeled Objects - DIP Assignment 1 ','linewidth',2)
