## SCRIPT_classifyFR
import scipy.io as sio
import os
import numpy as np

# define a variable representing the session directory
sessions_folder = 'C:/Users/uggriffin/Documents/BACKUP - Stout 2023 - dissertation/Stout et al 2022 Harnessing neural synchrony'
session         = '/Data'
os.chdir(sessions_folder+session) # cd equivalent

# array to load
arrayload = "data_pyFR.mat"

# import data as hierarchical data format (HDF5)
import h5py
data = h5py.File(array2load, 'r')
list(data.keys())

# get data
frHighMat = data['frUnitHigh'][:]
frLowMat  = data['frUnitLow'][:]

# remove any arrays with all NAN
idx = np.argwhere(np.isnan(frHighMat[:,0]))
frHighMat = np.delete(frHighMat,idx,axis=0)
frLowMat  = np.delete(frLowMat,idx,axis=0)

idx = np.argwhere(np.isnan(frLowMat[:,0]))
frHighMat = np.delete(frHighMat,idx,axis=0)
frLowMat  = np.delete(frLowMat,idx,axis=0)

# smallest number of units is 12, cut this back by 4 to 8
k = 12

# number of units
numUnits = frHighMat.shape[0]
print(numUnits,'recorded units')

# over 1000 iterations, randomly extract signals
n = 1000
range(n)

# bootstrapping
trainingArrayHigh = [] 
trainingArrayLow = []
rng = np.random.seed(1) # setting seed so that these results can be replicated. This was set before analysis
for i in range(n):
    # loop over units
    trainingDataHigh = [] 
    trainingDataLow = []
    for ui in range(numUnits): 
            # get firing rate data
            tempdatahigh = frHighMat[ui,:]
            tempdatalow  = frLowMat[ui,:]
            #tempdata.shape
            #print(tempdata)

            # remove nans from high and low coh arrays
            idx = np.argwhere(np.isnan(tempdatahigh))
            tempdatahigh = np.delete(tempdatahigh,idx)
            idx = np.argwhere(np.isnan(tempdatalow))
            tempdatalow = np.delete(tempdatalow,idx)

            # randomly select k points
            randdatahigh = np.random.choice(tempdatahigh, size=k, replace=False, p=None)
            randdatalow  = np.random.choice(tempdatalow, size=k, replace=False, p=None)
            #print(randdata)
            # create a list containing the training data
            trainingDataHigh.append(randdatahigh.tolist())  
            trainingDataLow.append(randdatalow.tolist())

    # store training data as a list
    trainingArrayHigh.append(np.transpose(np.array(trainingDataHigh)))
    trainingArrayLow.append(np.transpose(np.array(trainingDataLow)))
    print('Completed with bootstrap',i+1)
    #print(trainingArray)
    #type(trainingArray)
    #trainingArray[0].shape

# append the two arrays and create a label variable
trainingData = []
for i in range(n):
    trainingData.append(np.vstack((trainingArrayHigh[i],trainingArrayLow[i])))

# perform linear classification via leave one out
from sklearn.svm import LinearSVC
from sklearn.model_selection import train_test_split

# loop over 1000 iterations of random combinations of data (permutation style classification)
score = []; predictedLabels = []; scoreShuff = []; predictedLabelsShuff = []
for i in range(n):
    # the random state is set to 0 to ensure reproducibility. This means that over 1000 iterations, the same
    # indices will be pulled. Critically, because the 1000 combinations are shuffled for trial order, this does
    # not matter
    # X_train, X_test, y_train, y_test = train_test_split(trainingData[i], labels, stratify=None, random_state=0)
    # designate labels variable to zeros
    labels = np.zeros(trainingData[0].shape[0], dtype=int)

    # replace half of zeros with 1s
    labels[int(len(labels)/2):int(len(labels))]=1    
    
    # split data and train/test model
    X_train, X_test, y_train, y_test = train_test_split(trainingData[i], labels, stratify=None, random_state=0)
    svm = LinearSVC().fit(X_train, y_train)
    score.append(svm.score(X_test, y_test))

    # perform classification on shuffled labels
    labelsShuff = labels  
    for s in range(n):
        np.random.shuffle(labelsShuff)

    X_train, X_test, y_train, y_test = train_test_split(trainingData[i], labelsShuff, stratify=None, random_state=0)
    svm = LinearSVC().fit(X_train, y_train)
    scoreShuff.append(svm.score(X_test, y_test))
    predictedLabelsShuff.append(svm.predict(X_test))
    print('Completed with bootstrap',i+1)    

# now collect an average and generate distributions
scoreMean = np.mean(score)
scoreSEM  = np.std(score)/(np.sqrt(n))
shuffMean = np.mean(scoreShuff)
shuffSEM  = np.std(scoreShuff)/(np.sqrt(n))

os.chdir(sessions_folder+session) # cd equivalent
sio.savemat('data_pyClassifier_outputs.mat', {'score':np.array(score), 'shuffled':np.array(scoreShuff)})