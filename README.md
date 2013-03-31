# Kissmetrics JS

A small library to interact with Kissmetrics that can be shared across a client (browser) and server (Node.js)

## Annotated Source

In place of a more detailed readme, the [annotated source](http://evansolomon.github.com/kissmetrics-js/) is very thorough.

## Limitations

Currently there is no support for automatic identifiers for logged out visitors, which is one of the main benefits of Kissmetrics' own JavaScript library. I might add support for it eventually, but it's absent for now. It also won't support (or know anything about) the automatic events you have set in Kissmetrics.

tl;dr -- if you want to record data, it's up to you to figure out what you're recording.
