_                = require 'underscore'
q                = require 'q'
express          = require 'express'
passport         = require 'passport'
util             = require 'util'
fs               = require 'fs'
GoogleStrategy   = require('passport-google-oauth').OAuth2Strategy
TwitterStrategy  = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
LinkedInStrategy = require('passport-linkedin').Strategy
GitHubStrategy   = require('passport-github').Strategy
StackExchangeStrategy = require('passport-stackexchange').Strategy

morgan           = require 'morgan'
cookieParser     = require 'cookie-parser'
bodyParser       = require 'body-parser'
methodOverride   = require 'method-override'
session          = require 'express-session'
cons             = require 'consolidate'

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

app.engine('haml', cons.haml)

app.set('views', __dirname + '/views')
app.set('view engine', 'haml')

app.use(morgan('combined'))
app.use(cookieParser())
app.use(bodyParser.json())
app.use(methodOverride())
app.use(session({ resave:'true', saveUninitialized:'true', secret: "dyrsN4oFWFAff0e2Zroa+7364KHxp+oEL9PcY831IUA=" }))
app.use(passport.initialize())
app.use(passport.session())
app.use(express.static(__dirname + '/public'))

app.get '/', (req, res) ->
  res.render('index', { user: req.user })

app.get '/account', ensureAuthenticated, (req, res) ->
  res.render('account', { user: req.user })

app.get '/login', (req, res) ->
  res.render('login', { user: req.user })

# Google
app.get '/auth/google',
  passport.authenticate 'google', {
    scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email']
  }
  , (req, res) -> null

app.get '/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

# Twitter
app.get '/auth/twitter',
  passport.authenticate 'twitter',
  (req, res) -> null

app.get '/auth/twitter/callback',
  passport.authenticate('twitter', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

# Facebook
app.get '/auth/facebook',
  passport.authenticate 'facebook',
  (req, res) -> null

app.get '/auth/facebook/callback',
  passport.authenticate('facebook', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

# LinkedIn
app.get '/auth/linkedin',
  passport.authenticate 'linkedin',
  (req, res) -> null

app.get '/auth/linkedin/callback',
  passport.authenticate('linkedin', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

# Github
app.get '/auth/github',
  passport.authenticate 'github',
  (req, res) -> null

app.get '/auth/github/callback',
  passport.authenticate('github', { failureRedirect: '/login' }),
  (req, res) -> res.redirect '/'

# StackExchange
app.get '/auth/stackexchange',
  passport.authenticate 'stackexchange',
  (req, res) -> null

app.get '/auth/stackexchange/callback',
  passport.authenticate('stackexchange', { failureRedirect: '/login' }),
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

  passport.use new TwitterStrategy({
    consumerKey: config.TWITTER_CONSUMER_KEY,
    consumerSecret: config.TWITTER_CONSUMER_SECRET,
    callbackURL: "http://127.0.0.1:3000/auth/twitter/callback"
    }, (token, tokenSecret, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  passport.use new FacebookStrategy({
    clientID: config.FACEBOOK_APP_ID,
    clientSecret: config.FACEBOOK_APP_SECRET,
    callbackURL: "http://127.0.0.1:3000/auth/facebook/callback",
    }, (accessToken, refreshToken, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  passport.use new LinkedInStrategy({
    consumerKey: config.LINKEDIN_API_KEY,
    consumerSecret: config.LINKEDIN_SECRET_KEY,
    callbackURL: "http://127.0.0.1:3000/auth/linkedin/callback",
    }, (token, tokenSecret, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  passport.use new GitHubStrategy({
    clientID: config.GITHUB_CLIENT_ID,
    clientSecret: config.GITHUB_CLIENT_SECRET,
    callbackURL: "http://127.0.0.1:3000/auth/github/callback",
    }, (accessToken, refreshToken, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  passport.use new StackExchangeStrategy({
    clientID: config.STACKEXCHANGE_CLIENT_ID,
    clientSecret: config.STACKEXCHANGE_CLIENT_SECRET,
    key: config.STACKEXCHANGE_KEY,
    callbackURL: "http://127.0.0.1:3000/auth/stackexchange/callback",
    }, (accessToken, refreshToken, profile, done) ->
      process.nextTick -> done(null, profile)
    )

  console.log 'listening on port 3000', config
  app.listen(3000)
