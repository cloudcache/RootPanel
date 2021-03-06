Model = require './Model'
auth = require '../auth'
db = require '../db'
_ = require 'underscore'

module.exports = class User extends Model
  @create: (data) ->
    new User data

  @register: (username, email, passwd, callback = null) ->
    passwd_salt = auth.randomSalt()

    data =
      name: username
      passwd: auth.hashPasswd(passwd, passwd_salt)
      passwd_salt: passwd_salt
      email: email
      signup: new Date()
      group: []
      setting: {}
      attribure: {}
      tokens: []
    @insert data, callback

  # @param callback(token)
  createToken: (attribute, callback) ->
    # @param callback(token)
    generateToken = (callback) ->
      token = exports.randomSalt()

      User.findOne
        'tokens.token': token
      , (result) ->
        if result
          generateToken callback
        else
          callback token

    generateToken (token) ->
      @update
        $push:
          tokens:
            token: token
            available: true
            created_at: new Date()
            updated_at: new Date()
            attribute: attribute
      , ->
        callback token

  removeToken: (token, callback = null) ->
    @update
      $pull:
        tokens:
          token: token
    , ->
      callback() if callback

  # @return bool
  matchPasswd: (passwd) ->
    return auth.hashPassword(passwd, @data.passwd_salt) == @data.passwd

  @byUsername: (username, callback) ->
    @findOne
      username: username
    , (result) ->
      callback result

  @byEmail: (email, callback) ->
    @findOne
      email: email
    , (result) ->
      callback result
