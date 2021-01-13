#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 20 17:56:26 2018

@author: logancross
"""
import pandas
import gensim
import numpy as np

#load Word2Vec Model
model = gensim.models.KeyedVectors.load_word2vec_format('GoogleNews-vectors-negative300.bin', binary=True)

#load item names used
w2v_list = pandas.read_csv('/Users/logancross/Downloads/Item_Word2Vec_List.csv')

item_nums = w2v_list['ITEM #']
item_names = w2v_list['Word2Vec Name']
bundle_combos = list(itertools.combinations(item_nums, 2))
bundle_combo_names = list(itertools.combinations(item_names, 2))

sim_matrix = np.zeros([len(bundle_combos),3])

for i in range(len(bundle_combo_names)):
    item1, item2 = bundle_combos[i]
    sim_matrix[i,0] = item1
    sim_matrix[i,1] = item2
    name1, name2 = bundle_combo_names[i]
    sim_matrix[i,2] = model.similarity(name1, name2)
    
np.savetxt('/Users/logancross/Documents/Bundle_Value/python_scripts/word2vec_item_similarity.csv', sim_matrix, delimiter=" ")

#create dictionary with latent variables as elements
word2vec_dict = {}
for i in range(len(item_names)):
    word2vec_dict[item_names[i]] = model[item_names[i]]

np.save('/Users/logancross/Documents/Bundle_Value/python_scripts/word2vec_dict.npy', word2vec_dict) 