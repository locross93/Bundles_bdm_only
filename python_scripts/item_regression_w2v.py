#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 21 10:43:38 2018

@author: logancross
"""

import pandas
import numpy as np
import scipy
from sklearn import linear_model
from sklearn.decomposition import PCA
from sklearn.model_selection import cross_val_score
import matplotlib.pyplot as plt
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import Normalizer
from sklearn.preprocessing import MinMaxScaler
from sklearn.feature_selection import f_regression
from sklearn.feature_selection import SelectKBest
from sklearn.pipeline import Pipeline

subj = '009-1'

#load subject data
item_data = np.genfromtxt('/Users/logancross/Documents/Bundle_Value/python_scripts/ind_items_sub_'+subj+'.csv',delimiter=',')

#load item names used
w2v_list = pandas.read_csv('/Users/logancross/Downloads/Item_Word2Vec_List.csv')

item_nums = w2v_list['ITEM #']
item_names = w2v_list['Word2Vec Name']

#load word2vec dictionary
word2vec_dict = np.load('/Users/logancross/Documents/Bundle_Value/python_scripts/word2vec_dict.npy').item()

#create y's and x's
y = item_data[:,1]
num_trials = len(item_data)
num_vars = 300
x = np.zeros([num_trials, num_vars])
for i in range(num_trials):
    temp_item = item_data[i,0]
    list_idx = np.where(item_nums == temp_item)[0][0]
    temp_name = w2v_list.iloc[list_idx]['Word2Vec Name']
    x[i,:] = word2vec_dict[temp_name]



#scores for sweeping
scores_per_alp = np.zeros([5])

#feature selection - FIX SO NOT DOUBLE DIPPING
#x = x[:,best_vars]
#clf = Pipeline([
#  ('feature_selection', SelectKBest(f_regression, k=5)),
#  ('regression', linear_model.Ridge(alpha=alp,solver='lsqr'))])

#initial for loop for sweeping only
alp_count = -1
alp_seq = np.arange(0,5,1) *0.5
for alp in alp_seq:
    alp = 10**alp
    alp_count+=1
    #clf = linear_model.Ridge(alpha=alp,solver='lsqr')
    #clf = linear_model.ElasticNet(alpha=alp,l1_ratio=0.3)
    #clf = linear_model.Lasso(alpha=alp)
    clf = Pipeline([
    ('feature_selection', SelectKBest(f_regression, k=25)),
    ('regression', linear_model.Ridge(alpha=alp,solver='lsqr'))])
    cv_groups = np.floor(np.arange(0,110)/10)
    scores_per_alp[alp_count] = np.mean(cross_val_score(clf,x,y,groups=cv_groups,cv=11))

#for sweeping
plt.plot(alp_seq, scores_per_alp,'ro-', label="Crossval Fit")
plt.xlabel('Regularization Alpha')
plt.ylabel('R Squared')
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)


#correls = np.zeros([300])
#for i in range(300):
#    temp_x = x[:,i]
#    correls[i] = scipy.stats.pearsonr(y,temp_x)[0]
#
#from sklearn.ensemble import RandomForestRegressor
#from sklearn.metrics import r2_score
#clf = RandomForestClassifier(n_estimators=100)
#clf = Pipeline([
#    ('feature_selection', SelectKBest(f_regression, k=50)),
#    ('regression', RandomForestRegressor(n_estimators=100))])
##print(np.mean(cross_val_score(clf,x,y,groups=cv_groups,cv=11)))
#
#gkf = GroupKFold(n_splits=11)
#temp_scores = np.zeros([11])
#temp_predictions = np.zeros([11,10])
#cv_count = -1
#for train, test in gkf.split(x, y, groups=cv_groups):
#    clf.fit(x[train,:],y[train])
#    cv_count += 1
#    temp_predictions[cv_count,:] = clf.predict(x[test,:])
#    #temp_scores[cv_count] = r2_score(temp_predictions,y[test])
#overall_score = r2_score(temp_predictions.reshape(110,),y)
# 
#  
#from collections import OrderedDict
#
#RANDOM_STATE = 0
#
#ensemble_clfs = [
#    ("RandomForestClassifier, max_features='sqrt'",
#        RandomForestClassifier(warm_start=True, oob_score=True,
#                               max_features="sqrt",
#                               random_state=RANDOM_STATE)),
#    ("RandomForestClassifier, max_features='log2'",
#        RandomForestClassifier(warm_start=True, max_features='log2',
#                               oob_score=True,
#                               random_state=RANDOM_STATE)),
#    ("RandomForestClassifier, max_features=None",
#        RandomForestClassifier(warm_start=True, max_features=None,
#                               oob_score=True,
#                               random_state=RANDOM_STATE))
#]
#
## Map a classifier name to a list of (<n_estimators>, <error rate>) pairs.
#error_rate = OrderedDict((label, []) for label, _ in ensemble_clfs)
#
## Range of `n_estimators` values to explore.
#min_estimators = 15
#max_estimators = 175
#
#for label, clf in ensemble_clfs:
#    for i in range(min_estimators, max_estimators + 1):
#        clf.set_params(n_estimators=i)
#        clf.fit(x, y)
#
#        # Record the OOB error for each `n_estimators=i` setting.
#        oob_error = 1 - clf.oob_score_
#        error_rate[label].append((i, oob_error))
#
## Generate the "OOB error rate" vs. "n_estimators" plot.
#for label, clf_err in error_rate.items():
#    xs, ys = zip(*clf_err)
#    plt.plot(xs, ys, label=label)
#
#plt.xlim(min_estimators, max_estimators)
#plt.xlabel("n_estimators")
#plt.ylabel("OOB error rate")
#plt.legend(loc="upper right")
#plt.show()