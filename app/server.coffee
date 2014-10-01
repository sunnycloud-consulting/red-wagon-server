_              = require 'underscore'
q              = require 'q'
express        = require 'express'
passport       = require 'passport'
util           = require 'util'
fs             = require 'fs'
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

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

app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'ejs') # note: we'll change this to haml
  app.use(express.logger())
  app.use(express.cookieParser())
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.session({ secret: 'dyrsN4oFWFAff0e2Zroa+7364KHxp+oEL9PcY831IUA=' })) # use your own random value
  app.use(passport.initialize())
  app.use(passport.session())
  app.use(app.router)
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
