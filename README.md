# Top Chess Moves

Top Chess Moves is a twitter bot that posts every hour the finest chess moves, with a gif to show how they are done and a generated name for the move. The bot can be seen at [@TopChessMoves](https://twitter.com/topchessmoves)

Top Chess Moves was written in Elixir and uses [ImageMagick's command line tools](https://www.imagemagick.org/script/command-line-tools.php) to generate the gifs and [extwitter](https://hex.pm/packages/extwitter) to post to twitter.

It's got a basic chess engine, capable of generating legal boards and determing all legal moves for a given piece. It doesn't do en passant, castling, checks, or checkmates but it does do pawn promotion, diagonal cpature, and their extra starting move.