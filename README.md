# Demo


# A Naive Song Recommendation System

A **song recommendation system** powered by **Neo4j** and **ElixirLang** that utilizes **content-based filtering**. With a graph database containing approximately **300,000** songs, **35** different genres of music and over **26,000** artists, it makes simple recommendations by considering which songs you have **'listened to** in the past, which artists you have **followed**, which genres you **prefer** and the **musical attributes** of the particular song. 

It does this by **tracking** user activity, so when you **play a song** then **play another one**, it already **knows** how many minutes you spent on the previous song.
Note that I am not tracking the `actual time` you spent on a song, rather, where the player progress bar was at the time you clicked next or when you chose to play another song. So if you play a song and immediately drag the progress bar to the end, you have actually 'listened to' the whole song.

# Autoplay

The system fetches more songs as long as a song is playing. You don't have to explicitly interact with the player everytime.

# No Actual Music

It is important to note that **no sound** will actually be coming from your computer. 
Next to each song is a link that when clicked, will open the song on **Spotify**. You can test the quality of the recommendations from there.

The tech stack used is **Phoenix**, **Elixir**, **Neo4j** for all application data and **PostgreSQL** for job scheduling. You'll find a lot of **Cypher** throughout the app.

Finally, the recommendations are not absolute shit, try it out!

# Setup

- Install [Neo4j Desktop](https://neo4j.com/deployment-center/?desktop-gdb) on your PC and create an empty Neo4j instance. You can do it with [Docker](https://neo4j.com/docs/operations-manual/current/docker/introduction/) as well. 
- Download the dump file from [here](https://drive.google.com/drive/folders/1SeOridgsPwETBSU9c_4hVzy4JJEN35DC?usp=sharing). 
- In the instance box, on the top right corner you will see 3 dots. Click that button, then you'll see an option that says 'Load Database from file'. Choose the file you just downloaded above.
- You can also create the data yourself directly from the spotify_data.csv file by running the scripts in the [priv directory](https://github.com/Deankinyua/song-recommender/blob/main/priv/add_graph.exs). 
- Create a .env file with the contents of `.env.example` and adjust accordingly. 
- Setup the application with `mix setup`, ensure your Neo4j instance is **running** then start your Phoenix server with `iex -S mix phx.server`

# Testing

Testing has been implemented via [TestContainers](https://github.com/testcontainers/testcontainers-elixir) by spinning up an ephemeral Neo4j sandbox environment. You need to have Docker installed to be able to run tests. Note that due to port mapping issues, you might need to stop the instance running on the Desktop app to be able to run tests effectively. 
Make sure you can run docker commands without sudo e.g `docker ps`. If you are on Linux and can't do that then check out this [guide](https://docs.docker.com/engine/install/linux-postinstall/)
Run the whole ci suite with `mix ci` and tests with `mix test`. 


