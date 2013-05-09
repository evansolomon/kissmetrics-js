[![Build Status](https://travis-ci.org/evansolomon/kissmetrics-js.png)](https://travis-ci.org/evansolomon/kissmetrics-js)

# Kissmetrics JS

A small library to interact with Kissmetrics that can be shared across a client (browser) and server (Node.js).

## Annotated Source

In place of a more detailed readme, the [annotated source](http://evansolomon.github.com/kissmetrics-js/) is very thorough.

## Installation

Install from NPM with: `npm install kissmetrics-js`

In a browser, load the compiled JavaScript.

```html
<script src="min/kissmetrics.min.js"></script>
<script>
km = new KissmetricsClient(API_KEY, user.name);
// ...
</script>
```

In Node.js, you probably just want to require the module.

```javascript
KM = require('kissmetrics-js');
km = new KM(API_KEY, user.name);
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

Automatically-generated ID's are deleted from storage by default when `alias()` is called, but you have the option to save them by passing a second argument of `false`.

```javascript
km = new AnonKissmetricsClient(API_KEY);
km.record('Signed up').alias(user.name);
console.log(km._storage.get());
// null

km = new AnonKissmetricsClient(API_KEY);
km.record('Signed up').alias(user.name, false);
console.log(km._storage.get());
// "56a44b65ddad8a4ab00885ec42e7d2f7db46dcd69c3f"
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
