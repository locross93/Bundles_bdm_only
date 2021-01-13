#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 11 13:48:03 2020

@author: logancross
"""

from scipy.io import loadmat
import numpy as np
import matplotlib.pyplot as plt
import statsmodels.api as sm
from scipy.stats import pearsonr
from sklearn.metrics import r2_score
from statsmodels.formula.api import ols
import pandas as pd

log_folder = '/Users/logancross/Documents/Bundle_Value/stim_presentation/Bundles_fMRI/logs/'

#can analyze one day or across all day
subID = '108'

#linear model intercept
intercept = True

if len(subID) == 5:
    sub_logs = log_folder+'bdm_items_sub_'+subID+'.mat'
    sub_data = loadmat(sub_logs)
    bdm_item_value_orig = sub_data['value'].reshape(-1)
    response_ind = np.where(bdm_item_value_orig != 100)[0]
    bdm_item_value = bdm_item_value_orig[response_ind]
    bdm_item_orig = sub_data['item'].reshape(-1)
    bdm_item = bdm_item_orig[response_ind]
    bdm_category = np.zeros([len(bdm_item)]).astype(int)
    trinket_inds = np.where(bdm_item >= 71)[0]
    bdm_category[trinket_inds] = 1
elif len(subID) == 3:
    bdm_item_value_orig = []
    bdm_item_orig = []
    for day in range(1,4):
        subID_temp = subID+'-'+str(day)
        sub_logs_temp = log_folder+'bdm_items_sub_'+subID_temp+'.mat'
        sub_data_temp = loadmat(sub_logs_temp)
        bdm_item_value_orig.append(sub_data_temp['value'].reshape(-1))
        bdm_item_orig.append(sub_data_temp['item'].reshape(-1))
    bdm_item_value_orig = np.ravel(bdm_item_value_orig)
    bdm_item_orig = np.ravel(bdm_item_orig)
    response_ind = np.where(bdm_item_value_orig != 100)[0]
    bdm_item_value = bdm_item_value_orig[response_ind]
    bdm_item = bdm_item_orig[response_ind]
    bdm_category = np.zeros([len(bdm_item)]).astype(int)
    trinket_inds = np.where(bdm_item > 71)[0]
    bdm_category[trinket_inds] = 1
    
#load bundle data
if len(subID) == 5:
    sub_logs_bun = log_folder+'bdm_bundle_sub_'+subID+'.mat'
    sub_data_bun = loadmat(sub_logs_bun)
    bdm_bundle_value_orig = sub_data_bun['value'].reshape(-1)
    bdm_bundle_orig = sub_data_bun['item']
elif len(subID) == 3:
    bdm_bundle_value_orig = []
    bdm_bundle_orig = []
    for day in range(1,4):
        subID_temp = subID+'-'+str(day)
        sub_logs_temp = log_folder+'bdm_bundle_sub_'+subID_temp+'.mat'
        sub_data_temp = loadmat(sub_logs_temp)
        bdm_bundle_value_orig.append(sub_data_temp['value'].reshape(-1))
        bdm_bundle_orig.append(sub_data_temp['item'])
    bdm_bundle_value_orig = np.ravel(bdm_bundle_value_orig)
    bdm_bundle_orig = np.vstack(bdm_bundle_orig)
response_ind = np.where(bdm_bundle_value_orig != 100)[0]
bdm_bundle_value = bdm_bundle_value_orig[response_ind]
bdm_bundle_items = bdm_bundle_orig[response_ind]
bdm_bundle_category = bdm_bundle_items > 71
bdm_bundle_category = bdm_bundle_category.astype(int)

#Assuming that first column is left item and 2nd column is right item.
#Linear regression across left (x1) and right (x2) item
#Bundle value=B1*x1+B2*x2+C
bundle_item_values = np.zeros([bdm_bundle_items.shape[0], bdm_bundle_items.shape[1]]).astype(int)
for j in range(2):
    for i in range(bdm_bundle_items.shape[0]):
        assert np.max(bdm_item==bdm_bundle_items[i,j]) == True, 'Bundle item not in ind item WTP'
        #for items valued every day, take the first value
        #CHANGE THIS SO ITEM VALUE AND BUNDLE VALUES ARE FROM SAME DAY
        temp = bdm_item_value[bdm_item==bdm_bundle_items[i,j]]
        bundle_item_values[i,j]=temp[0]
        
data = pd.DataFrame({"Bundle_Value":bdm_bundle_value, "Val_Item1":bundle_item_values[:,0], "Val_Item2":bundle_item_values[:,1]})
model1 = ols(formula = 'Bundle_Value ~ Val_Item1 + Val_Item2', data = data).fit()
print model1.summary()

#model2 = ols(formula = 'Bundle_Value ~ Val_Item1 + Val_Item2 + np.power(Val_Item1,2) + np.power(Val_Item2,2)', data = data).fit()
model2 = ols(formula = 'Bundle_Value ~ Val_Item1 + Val_Item2 + np.power(Val_Item1,3) + np.power(Val_Item2,3)', data = data).fit()
print model2.summary()

print subID
print 'Linear model '+'%.3f'%model1.rsquared
print 'Quadratic model '+'%.3f'%model2.rsquared

#zero vs non zero
nz_inds = np.nonzero(bdm_bundle_value)[0]
data = pd.DataFrame({"Bundle_Value":bdm_bundle_value[nz_inds], "Val_Item1":bundle_item_values[nz_inds,0], "Val_Item2":bundle_item_values[nz_inds,1]})
model1 = ols(formula = 'Bundle_Value ~ Val_Item1 + Val_Item2', data = data).fit()
print model1.summary()

bundle_value_class = bdm_bundle_value
bundle_value_class[nz_inds] = 1

#bundle_X = sm.add_constant(bundle_item_values)
#log_reg = sm.Logit(bundle_value_class, bundle_X).fit()

from sklearn.linear_model import LogisticRegression

clf = LogisticRegression().fit(bundle_item_values, bundle_value_class)
clf.score(bundle_item_values, bundle_value_class)
