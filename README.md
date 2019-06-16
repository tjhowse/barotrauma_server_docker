This is a Dockerfile that builds the linux dedicated server for Barotrauma.
At the moment it clones a specific commit from the Barotrauma source repo which
corresponds to v0.9.0.6. At time of writing the master branch of the upstream repo
is broken, so it's currently building from my fork.
You will need to build the image with a copy of the game in a directory called "game"
so the content directory can be pulled in. This is not distributed with the source.
https://barotraumagame.com/
https://github.com/Regalis11/Barotrauma
