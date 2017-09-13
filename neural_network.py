# -*- coding: utf-8 -*-
"""
Created on Fri Aug 11 07:58:25 2017

@author: MHammoud

This script runs a neural network of 7 layers to classify an ECG

Layer (type)                 Output Shape              Param #   
=================================================================
conv2d_1 (Conv2D)            (None, 3, 204, 32)        992       
_________________________________________________________________
batch_normalization_1 (Batch (None, 3, 204, 32)        128       
_________________________________________________________________
dropout_1 (Dropout)          (None, 3, 204, 32)        0         
_________________________________________________________________
max_pooling2d_1 (MaxPooling2 (None, 3, 102, 32)        0         
_________________________________________________________________
flatten_1 (Flatten)          (None, 9792)              0         
_________________________________________________________________
dense_1 (Dense)              (None, 512)               5014016   
_________________________________________________________________
softmax (Dense)              (None, 2)                 1026      
=================================================================
Total params: 5,016,162
Trainable params: 5,016,098
Non-trainable params: 64

"""

import numpy
import csv
import time
import timeit
import keras
import array
import scipy.io as sio
import matplotlib.pyplot as plt
from keras.models import model_from_json
import keras.regularizers as regularizers


import tensorflow as tf
from keras.models import Sequential
from keras.layers.normalization import BatchNormalization
from keras.constraints import maxnorm
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras.utils import np_utils
from keras import backend as K
from matplotlib import pyplot as plt
from keras.layers import TimeDistributed, Bidirectional, LSTM,Dropout, Dense, Flatten
from random import randint


################################
##########LOAD DATA#############
################################
###train and validation dataset
x_data = numpy.load(r'C:\Users\mhammoud\Desktop\Neural Network code\MI-HEALTHY-PHYSIO.npy')
y_data = numpy.load(r'C:\Users\mhammoud\Desktop\Neural Network code\MI-HEALTHY-PHYSIO_LABEL.npy')

x_data = numpy.transpose(x_data,[2, 0, 1])
# y_data = numpy.transpose(y_data,[1,0])


# plt.plot(x_data[0])
# plt.show()
seed = 7

numpy.random.seed(seed)

##########################
######Initialization######
##########################

num_classes = y_data.shape[1]
num_epochs = 20
batch_size = 500
learning_rate = 0.00001


###########################################
#################DEMO DATA#################
###########################################


"""
USING ONLY ONE LEAD

#x_data = numpy.asarray([(x-numpy.mean(y))/numpy.amax(y) for x in ([y for y in x_data])])
x_data = x_data[:,0,:]

for x in range(x_data.shape[0]):
    x_data[x] = x_data[x]/numpy.mean(x_data[x])

x_data = x_data[:,numpy.newaxis,:]
"""

"""
USING 3 LEADS
"""
for x in range(x_data.shape[0]):
    for y in range(x_data.shape[1]):
        x_data[x,y,:] = x_data[x,y,:]/numpy.mean(x_data[x,y,:])
        
        
        
win_row = 3
win_col = 34
nb_channel = 3
L = x_data.shape[2]

x_data = x_data[:, :, :, numpy.newaxis]

seed=numpy.random.permutation(range(0, x_data.shape[0]))
x_data = x_data[seed,:,:,:]
y_data = y_data[seed, :]


x_train = x_data[:15000,:,:,:]
y_train = y_data[:15000,:]
x_test  = x_data[15000:,:,:,:]
y_test  = y_data[15000:,:]


###########################################
# Building model
###########################################

# K.set_learning_phase(1)

model = Sequential()

model.add(Conv2D(32, (3, 10),kernel_regularizer=keras.regularizers.l1_l2(.01),activation='relu',kernel_initializer='glorot_normal', padding='same', input_shape=(x_train.shape[1],x_train.shape[2] ,1)))
model.add(BatchNormalization())
model.add(Dropout(0.5))

model.add(MaxPooling2D(pool_size=(1, 2), data_format='channels_last'))

#fully connected layers
model.add(Flatten())
model.add(Dense(512,kernel_regularizer=keras.regularizers.l1_l2(.01), activation='relu',kernel_initializer='glorot_normal', kernel_constraint=maxnorm(3)))

model.add(Dense(num_classes, activation='softmax', name='softmax'))
# Compile model

#model.compile(loss='categorical_crossentropy', optimizer='adam',learning_rate=learning_rate, metrics=['accuracy'])
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
print(model.summary())

reduceLR=keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=5, verbose=0, mode='auto', epsilon=0.0001, cooldown=0, min_lr=0.0000001)

checkpoints=keras.callbacks.ModelCheckpoint(r'C:\Users\mhammoud\Desktop\mostafa_hammoud.csv' , monitor='val_loss', verbose=0, save_best_only=False, save_weights_only=False, mode='auto', period=1)
history = model.fit(x_train, y_train,
                    batch_size=batch_size,
                    epochs=num_epochs,
                    verbose=1,
                    validation_data=(x_test, y_test),callbacks=[checkpoints,reduceLR],shuffle= True)
score = model.evaluate(x_test, y_test, verbose=0)
acc = history.history['acc']
loss = history.history['loss']
val_acc = history.history['val_acc']
va_loss = history.history['val_loss']
lr = history.history['lr']

data = {'acc': acc,
        'loss': loss,
        'val_acc':val_acc,
        'va_loss':va_loss,
        'lr':lr}

#sio.savemat(r'C:\Users\mhammoud\Desktop\Mostafa_hammoud',data)
# Final evaluation of the modelscores = model.evaluate(x_test, y_test, verbose=0)
# print("Accuracy: %.2f%%" % (scores[1] * 100))


###################################

# saving the model

###################################

#json_string = model.to_json()  # saving model as json
# giving a name to model
#open('model_11_classes.json', 'w').write(json_string)

# save the weights in h5 format

#model.save_weights('model_11_classes_wts.h5')

# uncomment the code below (and modify accordingly) to read a saved model and weights

# model = model_from_json(open('my_model_architecture.json').read())

# model.load_weights('my_model_weights.h5')



###########################################

# Plotting

###########################################

# reading training and validation accuracy history

# ta = t_accuracy_history.accuracy
# va = v_accuracy_history.accuracy
# fig, ax = plt.subplots()
# line_1, = ax.plot(ta, label='Inline label')
# line_2, = ax.plot(va, 'r-', label='Inline label')

# Overwrite the label by calling the method.

line_1.set_label('training set')
line_2.set_label('validation set')
ax.legend()
ax.set_ylabel('Accuracy')
ax.set_title('convnet_reg')
ax.set_xlabel('epoch')
plt.show()


