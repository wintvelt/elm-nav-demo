#Elm-Nav, a demo

Demo of Elm navigation in combination with Evan's UrlParser.

Using a new setup.

##Making Impossible Routes Impossible##

In apps, you often have a URLs like `/movies/movie1234`.
For URLs, this is fine. It basically says "I want to see the details of movie 1234".
Typically, the browser makes a request to a server, and the server comes back with either:

 - The page with the details of this particular movie
 - A "Sorry no details found" page.

In a Single Page Application, you would *not* want this behavior, but instead, something like:

 - A new page with movie details (same as above)
 - Some error message on the same page that the user came from

##A new `Page` type in Elm##
In Elm, I use a new type for this, a `Page`. Which is not just the `Route`, but also has all the relevant data to display.

So if the routes for the app would be e.g.

    /home
    /movies
    /movies/movie1234

The corresponding definition of the `Page` type would be

		type Page
				= HomePage
				| MoviesPage (List Movie)
				| MovieDetails Movie

So any `Page` also holds *all data that is scoped to that page*.  

The details page holds the data for a single movie, because that data ONLY exists on that page.
