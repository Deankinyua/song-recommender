# SongRecommender

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Warning

It is not advisable to store authentication data like user login tokens in Neo4j like
has been the case in this application. I only did this for simplicity purposes and to introduce
an easy way to track a user's data. Authentication data is meant to be stored in other data
stores like relational databases because they are better suited for the job. Graph DBs are best for
connected data that is meant to be used for analytical purposes.
