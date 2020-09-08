from app import app
from app.models import MovieSchema, Movie
from app.utils import retrive_small_movie_metadata, compute_cosine_similarity,\
    convert_int, train_model

from flask import abort, g, jsonify, request, Response
import pandas as pd

movie_schema = MovieSchema()


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


@app.route('/api/movies')
def get_movies_by_ids():
    movieIds = request.args.getlist('movieIds')
    movies = Movie.query.filter(Movie.id.in_(movieIds)).all()
    if len(movies) is None:
        abort(404, description="Resource not found")
    else:
        return movie_schema.jsonify(movies, many=True)


@app.route('/api/suggested_movies/<user_id>/<title>')
def suggest_movies(user_id, title):
    smd = retrive_small_movie_metadata()
    cosine_sim = compute_cosine_similarity(smd)
    model = train_model()
    user_id = convert_int(user_id)

    # The similar movies
    smd = smd.reset_index(drop=True)
    indices = pd.Series(smd.index, index=smd['title'])
    idx = indices[title]

    if not isinstance(idx.tolist(), int):
        idx = idx.values[0]
    sim_scores = list(enumerate(cosine_sim[int(idx)]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    sim_scores = sim_scores[1:11]
    movie_indices = [i[0] for i in sim_scores]
    # movie_indices

    # Compute the rating for each movie
    links_small_file = 'ml_database/links_small.csv'
    id_map = pd.read_csv(links_small_file)[['movieId', 'tmdbId']]
    id_map = id_map[id_map['tmdbId'].notnull()]
    id_map['tmdbId'] = id_map['tmdbId'].apply(convert_int)
    id_map.columns = ['movieId', 'id']
    id_map = id_map.merge(smd[['title', 'id']], on='id')
    indices_map = id_map.set_index('id')

    movies = smd.iloc[movie_indices][['title', 'id']]
    movies['est'] = movies['id'].apply(lambda x: model.predict(
        user_id, indices_map.loc[x]['movieId']).est)
    movies = movies.sort_values('est', ascending=False)

    return Response(movies.to_json(orient="records"),
                    mimetype='application/json')
