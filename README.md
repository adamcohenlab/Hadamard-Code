# Hadamard-Code
Code for Hadamard Microscopy for neural imaging.

# Supplementary Software and Data
Included in this supplement are MATLAB programs and experimental datasets to describe implementation of all-optical neurophysiology functional recordings using Hadamard optical sectioning microscopy. A reduced dataset is provided in this repository with the example code. The example also runs with the original full dataset, which is available from the authors upon request.

Examples were tested on MATLAB R2017a in a Windows 7 computer with a 2.5 GHz CPU and 64GB RAM.	
Requirements: MATLAB R2014b or later; MATLAB Image Processing Toolbox; “Multipage TIFF stack”, available from https://www.mathworks.com/matlabcentral/fileexchange/35684.	
Installation: Examples source codes can be run in MATLAB after copying the supplement folder locally, no installation is necessary. Download time is short for example source codes and data (50 MB) but can be longer if an expanded dataset is included (14 GB, available upon request), see description of Example 1 below for details.
Acquisition and Analysis software is provided for reference but is not expected to run on its own.
1.	Acquisition
1.1.	DMD control. Code used to configure and load a VIALUX digital micromirror device (DMD).
1.2.	DMD pattern generation. Code used to define Hadamard structured illumination patterns, and to format them for the VIALUX DMD.
1.3.	Microscope control. Software to define experimental protocols control.
2.	Analysis. Hadamard microscopy analysis software, used to demodulate optical sections, register functional recordings, and assemble z-stacks.
3.	Examples. Two examples are included: 
1) “example_heatmap_from_raw_data.m” reads raw data and raw calibration, demodulates optical sections, identifies individual responding cells, and shows a heatmap of single cell activity. This example can be run with a full dataset and calibration files as recorded (14 GB), of image size 1024x1024 pixels, or can be run with a cropped version of the same datasets (20 MB) limited to 42x42 pixels. Run time was 3 minutes in the test computer for the large dataset.
2) “example_generate_hadamard_patterns.m” generates and displays Hadamard illumination patterns and their correlation maps with the Hadamard code. Run time was less than 1 minute in the test computer.
3.1.	Data. Contains example raw calibration and experimental data from a large field of view. Not included in this repository, available upon request.
3.2.	Cropped data. A small subset of the full data in 3.1, for a less computationally intensive example.
4.	Other software. Additional custom libraries used for image processing and computation. Includes 2D peak finding, selective frequency filter, and timing display functions.
4.1.	@vm. General purpose vectorized movie processing class. Replaces many native Matlab functions with streamlined syntax.
4.2.	Hadamard matrices. Library to generate Hadamard matrices of flexible sizes.

