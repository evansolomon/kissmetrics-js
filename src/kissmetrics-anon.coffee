# # Kissmetrics Anon

# Inspired by store.js
# https://github.com/deleteme/store

LocalStorage =
  set: (key, value) ->
    window.localStorage.setItem key, value

  delete: (key) ->
    window.localStorage.removeItem key

  get: (key) ->
    window.localStorage.getItem key

Cookie =
  set: (key, value, options = {}) ->
    unless options.expires
        date = new Date
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000))
        options.expires = "expires=" + date.toGMTString()

    document.cookie = "#{name}=#{value}; #{options.expires}; path=/"

  get: (key) ->
    key += '='
    for cookiePart in document.cookie.split ';'
      cleanedPart = cookiePart.replace(/^\s+/, '')
        .substring(key.length + 1, cookiePart.length)

      return cleanedPart if cleanedPart.indexOf key is 0

  delete: (key) ->
    Cookie.set key, '', {expires: -1}


class KissmetricsStorage
  constructor: (@key) ->
    @store = if window.localStorage? then LocalStorage else Cookie

  set: (value) ->
    @store.set @key, value

  get: ->
    @store.get @key

  delete: ->
    @store.delete @key



class AnonKissmetricsClient extends KissmetricsClient
  constructor: (key) ->
    @storage = new KissmetricsStorage 'kissmetricsAnon'

    unless person = @storage.get()
      person = @createID()
      @storage.set person

    super key, person

  # Inspired by http://stackoverflow.com/a/105074/30098
  createID: ->
    parts = for x in [0..10]
      (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

    parts.join ''


global.AnonKissmetricsClient = AnonKissmetricsClient
