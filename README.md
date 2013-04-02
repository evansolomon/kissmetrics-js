[![Build Status](https://travis-ci.org/evansolomon/kissmetrics-js.png)](https://travis-ci.org/evansolomon/kissmetrics-js)

# Kissmetrics JS

A small library to interact with Kissmetrics that can be shared across a client (browser) and server (Node.js).

## Annotated Source

In place of a more detailed readme, the [annotated source](http://evansolomon.github.com/kissmetrics-js/) is very thorough.

## Installation

In a browser, load the compiled JavaScript.

```html
<script src="min/kissmetrics.min.js"></script>
<script>
km = new KissmetricsClient(API_KEY);
// ...
</script>
```

In Node.js, you probably just want to require the main class.

```javascript
KM = require('./src/kissmetrics');
km = new KM(API_KEY);
// ...
```

## Usage Examples

Record data about a logged **in** user.

```javascript
// General activity
km = new KissmetricsClient(API_KEY, user.name);
km.record('Published post');
km.set({last_seen: new Date()});

// Change username
km.record('Change username');
km.alias(user.name);
```


Record data about a logged **out** user.

```javascript
// New visitor
km = new AnonKissmetricsClient(API_KEY);
km.record('Visited front page');
km.record('Visited signup form');

// Signs up
km.record('Signed up');
km.alias(user.name);

// Record more data as the new logged in user
km = new KissmetricsClient(API_KEY, user.name);
km.record('Publish post');
```

Data methods can be chained.

```javascript
km = new AnonKissmetricsClient(API_KEY);
km.record('Visited front page')
	.record('Visited signup form')
	.record('Signed up')
	.alias(user.name)
	.record('Published post');
```

Calling `alias()` updates the instance's `person` attribute, so future data is recorded using the new identity.

```javascript
km = new KissmetricsClient(API_KEY, 'evan');
console.log(km.person);
// evan

km.alias('evansolomon');
console.log(km.person);
// evansolomon

km.record('foobar');
// Recorded as "evansolomon" doing "foobar"
```