[![Build Status](https://travis-ci.org/evansolomon/kissmetrics-js.png)](https://travis-ci.org/evansolomon/kissmetrics-js)

# Kissmetrics JS

A small library to interact with Kissmetrics that can be shared across a client (browser) and server (Node.js).

The minified source is about 3k, compared to about 20k for the version served by Kissmetrics. If you gzip the minified source, it is about 1k (Kissmetrics does not gzip their JavaScript for backward compatability reasons with older browsers). The only feature missing is the "automatic" events that Kissmetrics will record for you. These are things like page views or site visits. Since only Kissmetrics has access to the options you've sent, it's not possible to know which events you want to record automatically without using their JavaScript. For that trade off you save 95% of the file size *and* can use the same library on the client and server.

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

## Batching

The library support's Kissmetrics' batch API in Node.js (not in browsers). Batching queries works in two parts, adding to the batch queue and processing the batch queue.

To add queries to the queue, you need to pass in a queue object to the `KissmetricsClient` constructor when you create your instance.

```javascript
myQueueObject = {
  add: function(data) {
    someQueue.add('kissmetrics', data);
  },
  get: function() {
    return someQueue.get('kissmetrics');
  }
};

KM = require('kissmetrics');
client = new KM(null, 'Evan', {queue: myQueueObject});
client.record('This event will be batched').set({addedToQueue: 'yup'});
```

The queue object you provide to `KissmetricsClient` must expose a method called `add()` that accepts an object and adds it to your queue. Once your instance of `KissmetricsClient` is created, you can use it normally to record events, properties and aliases. The difference is that those queries will not be sent to Kissmetrics immediately, they'll be formed into objects and added to your queue. You'll also notice that I didn't pass in an API key when I created my client instance. Batch requests send the API key when the batch is processed, and all queries in a batch must use the same API key. You can pass in an API key if you want, like a normal client, it will just be silently ignored.

When you're ready to process the queue, you need to use the `BatchKissmetricsClient` class' `process()` method. You'll need to pass in your a queue object, API key, API secret, and product GUID. Note that these credential are all *different* than your normal API key, and all come from Kissmetrics.

```javascript
Batch = require('kissmetrics-batch');
Batch.process(myQueueObject, 'clientKey', 'clientApiSecret', 'product-guid');
```

The queue object you provid must expose a `get()` method. It's possible to provide an entirely different queue object to `Batch.process()` than you do to `KissmetricsClient`, though for simplicity's sake you may use the same one. The `get()` method should return all of the objects that were added to the queue by `KissmetricsClient`. Note that managing race conditions is your responsibility and will not be done by the library. It's a good idea to keep track of this in the queue object that you provide.
