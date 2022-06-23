# Overview

This document describes how to create remotely assembles videos for score-based music with separatly recorded parts. This method has two differences from reference-based assembly (e.g. click track): 

- Performers do not need to use a reference track when recording. They can play their part however they want, using any tempo or temporal interpretation that they choose. 
- Algorithmic methods can be used to "preserve" the player's intended temporal interpretation. 


 Not all parts of the pipeline are provided so this code cannot be used out-of-the-box, but I will describe the implementation structure and how this code can be adapted to suit the needs of others. 


# Step 1: Score Match(code not included)

The first step  is to generate a score match specification file linking each note of each part in the music score to the time which each performer played the corresponding note. In the current code, the position-to-time respresenation files are refered to with the extension of ".times" or ".atm" files. 

 - Note that in both these files, beat location is specified in terms of measure+beat offset. For example 1+0/1 is the beginning of the piece (first measure + beat 0/1) and 4+3/4 refers to beat 3 of the 4th measure. A note on conversion to floating point: if the piece is in 4/4, a simple eval() will do the trick. But if the piece has a different number of beats for measure, e.g. 3/4, a specialized function (defined in cell 10 of `Optimization_based_timing_adjustment.ipynb`) must be used. 


- In addition, note the different timing representations in these files. In .atm files, time is represented in seconds. In .times files, time is in audio frames, where 1 frame is equivalent to 256/8000 seconds. 

If a different specification is used, it should be linked up with the dataframe generation step, e.g. cell 11 of `Optimization_based_timing_adjustment.ipynb`

# Step 2: Pitch detection for Tuning(code not included)

Parts recorded in isolation cannot tune to eachother. In this step, the precise pitch of each note is detected and its deviation from an A440 equal temperment standard is recorded. This information is later used for automatic tuning correction. The code uses files with the extension .tun to express the tuning correction needed (in cents) to shift the performer's recorded pitch to A440-based equal temperment tuning. A .tun file should exist for each part, relating the note position to the cents off from an A440 standard. If you do not want to apply tuning correction, a dummy file could be created where for each note location, the correction is 0. 

# Step 3: Mix detection

Calculate or decide on the best relative volume setting for each part. This is specified in the `nonvar_mix` variable in cell 4 of `Optimization_based_timing_adjustment.ipynb`. 
# Step 4: Assembling Audio

Depending on the desired algorithm, either Optimization_based_timing_adjustment.ipynb or Other_algorithms.ipynb could be used to generate assembled audio. For each part, you need the path to the raw audio, the path to the timing file, and the path to the tuning correction file. Remember to save the final unified timing specification (usually refered to as final_df) as a .csv file. Watch units here, it defaults to STFT frames, so the function stft_frames_to_seconds() can be used to make the conversion. 

# Step 5: Assembling Video (note FFMPEG dependency)

Lastly, we want to create a music video that lines up well with our modified audio. Adjusted videos can be generated for each part, then put together using a video editing program like Final Cut Pro. 

- First, create a directory for each part in the part_data folder, and put the original video of each part in its corresponding folder. 
- For each part: 
    - Use `Video Alginment Generator.ipyn`b to create a text file specifying the arrangement of original frames needed to create the adjusted video. Note that you need to know the frames per second of the original video and decide on a final, same FPS for all the instruments. A video's original FPS can be found by opening the video in Quicktime player, then hit command I (on Mac). FPS should be rounded to the nearest whole number for use in this algorithm.  
    - Run `full_assemble.sh` according to instructions in file. 
