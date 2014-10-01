_              = require 'underscore'
q              = require 'q'
express        = require 'express'
passport       = require 'passport'
util           = require 'util'
fs             = require 'fs'
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

# express middleware
# see https://github.com/senchalabs/connect#middleware
# see https://github.com/strongloop/express/wiki/Migrating-from-3.x-to-4.x
morgan         = require 'morgan' # morgan is logger for express 4.x
cookieParser   = require 'cookie-parser'
bodyParser     = require 'body-parser'
methodOverride = require 'method-override'
session        = require 'express-session'

config = {}

loadConfig = ->
  deferred = q.defer()
  fs.readFile __dirname + '/../conf/conf.js', (err, data) ->
    if err
      console.warn 'error loading config!'
      deferred.reject err
    deferred.resolve JSON.parse(data)
  deferred.promise

ensureAuthenticated = (req, res, next) ->
  return next() if (req.isAuthenticated())
  res.redirect '/login'

passport.serializeUser  (user, done) -> done(null, user)
passport.deserializeUser (obj, done) -> done(null, obj)

app = express()

app.set('views', __dirname + '/views')
app.set('view engine', 'ejs') # note: we'll change this to haml

app.use(morgan('combined')) # morgan is logger for express 4.x
app.use(cookieParser())
# parse application/json
app.use(bodyParser.json())
app.use(methodOverride())

app.use(session({ resave:'true', saveUninitialized:'true', secret: 'dyrsN4oFWFAff0e2Zroa+7364KHxp+oEL9PcY831IUA=' }))
app.use(passport.initialize())
app.use(passport.session())
# app.use(app.router) --> deprecated
app.use(express.static(__dirname + '/public'))

app.get '/', (req, res) ->
  res.render('index', { user: req.user })

app.get '/account', ensureAuthenticated, (req, res) ->
  res.render('account', { user: req.user })

app.get '/login', (req, res) ->
  res.render('login', { user: req.user })

app.get '/auth/google',
  passport.authenticate 'google', {
    scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email']
  }
  , (req, res) -> null

app.get '/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

app.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/'

loadConfig().then (cfg) ->
  _(cfg).each (v, k) -> config[k] = v

  # we need config before we can use the strateg(ies)
  passport.use new GoogleStrategy({
      clientID: config.GOOGLE_CLIENT_ID,
      clientSecret: config.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://127.0.0.1:3000/auth/google/callback"
    }, (accessToken, refreshToken, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  console.log 'listening on port 3000', config
  app.listen(3000)
