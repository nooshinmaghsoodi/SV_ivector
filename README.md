# SV_ivector
i-vector_HMM based Speaker verification

This is a Speaker verification system writte in Matlab based on i-vector_HMM method. This project is implemented mainly for running on RSR2015 dataset. 
RSR is a text-dependent speaker verification corpus supports development, training and testing of automatic text-dependent speaker verification systems. 
Because of copy-right I couldn't load the dataset here.
This project uses HMM-GMM approach to produce speaker supervectors and i-vector for speaker representation.

USAGE

To run this project:
1- At first, you should enter your desired config in the file SpeakerVerification/Resources/config.cfg and also in the corresponding input feature file
 (for example mfcc39.cfg, if you want use 39 dimesional MFCC vector as input feature vector.)
2- Then, you should run ivectorPartIII.m
3- The itermediate files models and feaures will be saved in a new folder named "output".


Contributions

This system uses separate HMM and i-vector model for each digit and proposes three new uncertainty compensation methods based on a new formula for LDA, WCCN
and uncertainty normalization.
 
