# from flask import request, jsonify
import pickle
from os import path
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
from surprise import Reader, Dataset, SVD
import numpy as np

def convert_int(x):
    try:
        return int(x)
    except ValueError:
        return np.nan

def retrive_small_movie_metadata():
    pkl_filename = "ml_models/pickle_small_movie_metadata.pkl"
    

    if path.exists(pkl_filename):
        # Load smd from pickle file
        with open(pkl_filename, 'rb') as file:
            smd = pickle.load(file)
    else:
        links_small_file = 'ml_database/links_small.csv'
        movies_metadata_file = 'ml_database/movies_metadata.csv'

        # Link small
        links_small = pd.read_csv(links_small_file)
        links_small = links_small[links_small['tmdbId']
                                  .notnull()]['tmdbId'].astype('int')

        # Movie Metadata file
        md = pd.read_csv(movies_metadata_file)
        md = md.drop([19730, 29503, 35587])
        md['id'] = md['id'].astype('int')
        # md.shape #(45463, 24)

        # smd: small movies metadata
        smd = md[md['id'].isin(links_small)]
        # smd.shape #(9099, 24)

        # Save smd to file in the current working directory
        with open(pkl_filename, 'wb') as file:
            pickle.dump(smd, file)

    return smd

def compute_cosine_similarity(smd):
    pkl_filename = "ml_models/pickle_cosine_sim.pkl"
    if path.exists(pkl_filename):
        # Load cosine_sim from pickle file
        with open(pkl_filename, 'rb') as file:
            cosine_sim = pickle.load(file)
    else:
        # new feature: description= overview + tagline
        smd['tagline'] = smd['tagline'].fillna('')
        smd['description'] = smd['overview'] + smd['tagline']
        smd['description'] = smd['description'].fillna('')

        # TF-IDF Vectorizer to vectorize description feature
        # (removing stop_words)
        tf = TfidfVectorizer(analyzer='word', ngram_range=(
            1, 2), min_df=0, stop_words='english')
        tfidf_matrix = tf.fit_transform(smd['description'])

        # tfidf_matrix= tfidf_matrix[0:1000]
        # ############################### nhớ xóa

        # linear_kernel to calculate similarity between 2 movies
        # (linear_kernel is much faster than cosine)
        cosine_sim = linear_kernel(tfidf_matrix, tfidf_matrix)

        # Save cosine_sim to file in the current working directory
        with open(pkl_filename, 'wb') as file:
            pickle.dump(cosine_sim, file)

    return cosine_sim



def train_model():
    pkl_filename = "ml_models/pickle_user_movie_rating_model.pkl"
    if path.exists(pkl_filename):
        # Load model from pickle file
        with open(pkl_filename, 'rb') as file:
            model = pickle.load(file)
    else:
        reader = Reader()
        rating_file = 'ml_database/ratings_small.csv'
        ratings = pd.read_csv(rating_file)
        data = Dataset.load_from_df(
            ratings[['userId', 'movieId', 'rating']], reader)

        # Use the famous SVD algorithm
        model = SVD()
        trainset = data.build_full_trainset()
        model.fit(trainset)

        # Save model to file in the current working directory
        with open(pkl_filename, 'wb') as file:
            pickle.dump(model, file)
    return model

