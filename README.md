# Portfolio
 A collection of code organized by projects

# --- Descriptions --- #

# MATLAB
    Folder: 
        MATLAB pipeline
            Description:
                A set of libraries containing functions and SCRIPTS to facilitate data analysis, improve reproducibility of results, and promote reproduction across studies within the laboratory.
                These libraries are a collection of codes written by John Stout (1), Henry Hallock (2), Andrew Garcia (3), Allison George (4), Suhaas Adiraju (5), along with libraries that are freely available on Mathworks that have some copywrites. Importantly, while not all code was written by me (John Stout) or by other lab members, various scripts written use these codes.
                **This pipeline was also created with the "new user" in mind. There is a folder containing example codes on how to use some really fundamental functions for neuroscience.
                There is also libraries supporting brain machine interfacing techniques as well as data sharing.
                **This pipeline was developed by myself.
    Folder: 
        CodingClub
            Description:
                I developed various scripts to demonstrate how to perform various analyses in neuroscience.
                These included the creation of rate maps, the use of fourier trasnform for power and coherence analysis,
                Filtering and extracting signal envelopes and more!
                This code was described over a sequence of zoom calls where I walked the lab through the code, what the code means,
                what the code does, when to use the analyses, issues with the analyses, and how to interpret the findings.

# Python
    Folder:
        NeuroDataReHack
            Description:
                As a participant of the NeuroDataReHack event held at the Allen Institute in Seattle, Washington (2022), I spent 3 days learning about a standardized format for neuroscience data analysis (neurodata without borders - "nwb") and also learned how to use a new website for storing nwb data (DANDIhub).

                Code: SCRIPT_neurorehack_finalCode
                    This code was run on the DANDIhub server using jupyter lab (it wont work if you try to rerun on anything else). In this script, I demonstrate various abilities:
                        Data wrangling:
                            Streamed and extracted the data from an nwb format into something that I could actively work with. This data was avalailable on the DANDIhub (Watson dataset)
                        Data visualization:
                            Examined features of the metadata (see lines 25, 10, 11, 154 for some examples)
                            Visualized the data:
                                -> Examined whether the signals that I was extracting were what I expected (line 13 - demonstrates example local field potential, recordings taken from the brain. In this case, these recordings matched my expectation)
                                -> Examined full signal to identify potential noise peaks (data anomalies - see line 155)
                        Data preprocessing
                            -> Detrended the signal by fitting and subtracting a third degree polynomial in order to account for potential slow movement artifacts (156)
                        Data analysis/visualization
                            -> Performed a power spectral analysis to determine the presence of certain brain rhythms (157)
                            -> Performed a moving window analysis, where I calculated power in fixed windows with subtle shifts forward in time. This approach allows us to create a distribution of power estimations to determine when features of the signal were "strong" or "weak" (411)
                                -> Plotted the results and noticed that the power estimations within a 6-11Hz range was clustered
                                -> Used k-means clustering to separate these events
                            -> After using k-means to identify these clustered events, I discovered that the signal shifted significantly overtime (497)
                    I streamed data from a published paper, examined features of the metadata, extracted example neural data recorded from the prefrontal cortex, visualized features of this data included a snippet of the signal (chunk 13/153), examined the full signal for potential sources of noise (chunk 155)
        Subfolder: NeuroDataReHack - 2022
            Contains various codes, some created by me, most created by others as source code so that I could learn how to use python for nwb based analysis
        Example NeuroCode
            Some codes that were written to perform analyses on neural and behavioral data
        Introduction_to_ml_with_python
            Code that I followed along with for the book: Introduction to machine learning with python. I annotated some scripts and extended the approaches to learn more

# R
    Folder:
        Base folder:
            Contains example ANOVA code that I regularly use for data analysis
        Statistics course:
            Example assignments from a statistics course where I used R Markdown to complete the assignment. See Assignment05

# C++
    Folder
        ArduinoCode
            Contains various C++ code used in the arduino IDE for projects. Such projects were personal hobbies, like:
                --> A set of halloween props that were triggered based on motion sensor detecting movement. At baseline, I had white LED lights flickering in a bowl with candy. When movement was detected, these lights began flickering red, a skeleton dog prop began to howl, a hand controlled with a servo began to move, and a scary doll cup screamed. These occured in a sequence and this project was created to enhance the halloween experience of our locals
                --> an automated gardening system that used a solenoid valve
                --> a work project to control some doors on a maze for rodents 

# HTML:
    Folder:
        Webpage
            Description: 
                I used the backbone of code on github.com to create a precursor webpage for myself.
                When launching, just double click "index"




