// Generated by CoffeeScript 1.8.0
(function() {
  var FacebookStrategy, GitHubStrategy, GoogleStrategy, LinkedInStrategy, StackExchangeStrategy, TwitterStrategy, app, bodyParser, config, cons, cookieParser, ensureAuthenticated, express, fs, loadConfig, methodOverride, morgan, passport, q, session, util, _;

  _ = require('underscore');

  q = require('q');

  express = require('express');

  passport = require('passport');

  util = require('util');

  fs = require('fs');

  GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

  TwitterStrategy = require('passport-twitter').Strategy;

  FacebookStrategy = require('passport-facebook').Strategy;

  LinkedInStrategy = require('passport-linkedin').Strategy;

  GitHubStrategy = require('passport-github').Strategy;

  StackExchangeStrategy = require('passport-stackexchange').Strategy;

  morgan = require('morgan');

  cookieParser = require('cookie-parser');

  bodyParser = require('body-parser');

  methodOverride = require('method-override');

  session = require('express-session');

  cons = require('consolidate');

  config = {};

  loadConfig = function() {
    var deferred;
    deferred = q.defer();
    fs.readFile(__dirname + '/../conf/conf.js', function(err, data) {
      if (err) {
        console.warn('error loading config!');
        deferred.reject(err);
      }
      return deferred.resolve(JSON.parse(data));
    });
    return deferred.promise;
  };

  ensureAuthenticated = function(req, res, next) {
    if (req.isAuthenticated()) {
      return next();
    }
    return res.redirect('/login');
  };

  passport.serializeUser(function(user, done) {
    return done(null, user);
  });

  passport.deserializeUser(function(obj, done) {
    return done(null, obj);
  });

  app = express();

  app.engine('haml', cons.haml);

  app.set('views', __dirname + '/views');

  app.set('view engine', 'haml');

  app.use(morgan('combined'));

  app.use(cookieParser());

  app.use(bodyParser.json());

  app.use(methodOverride());

  app.use(session({
    resave: 'true',
    saveUninitialized: 'true',
    secret: "dyrsN4oFWFAff0e2Zroa+7364KHxp+oEL9PcY831IUA="
  }));

  app.use(passport.initialize());

  app.use(passport.session());

  app.use(express["static"](__dirname + '/public'));

  app.get('/', function(req, res) {
    return res.render('index', {
      user: req.user
    });
  });

  app.get('/account', ensureAuthenticated, function(req, res) {
    return res.render('account', {
      user: req.user
    });
  });

  app.get('/login', function(req, res) {
    return res.render('login', {
      user: req.user
    });
  });

  app.get('/auth/google', passport.authenticate('google', {
    scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email']
  }, function(req, res) {
    return null;
  }));

  app.get('/auth/google/callback', passport.authenticate('google', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/auth/twitter', passport.authenticate('twitter', function(req, res) {
    return null;
  }));

  app.get('/auth/twitter/callback', passport.authenticate('twitter', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/auth/facebook', passport.authenticate('facebook', function(req, res) {
    return null;
  }));

  app.get('/auth/facebook/callback', passport.authenticate('facebook', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/auth/linkedin', passport.authenticate('linkedin', function(req, res) {
    return null;
  }));

  app.get('/auth/linkedin/callback', passport.authenticate('linkedin', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/auth/github', passport.authenticate('github', function(req, res) {
    return null;
  }));

  app.get('/auth/github/callback', passport.authenticate('github', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/auth/stackexchange', passport.authenticate('stackexchange', function(req, res) {
    return null;
  }));

  app.get('/auth/stackexchange/callback', passport.authenticate('stackexchange', {
    failureRedirect: '/login'
  }), function(req, res) {
    return res.redirect('/');
  });

  app.get('/logout', function(req, res) {
    req.logout();
    return res.redirect('/');
  });

  loadConfig().then(function(cfg) {
    _(cfg).each(function(v, k) {
      return config[k] = v;
    });
    passport.use(new GoogleStrategy({
      clientID: config.GOOGLE_CLIENT_ID,
      clientSecret: config.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://127.0.0.1:3000/auth/google/callback"
    }, function(accessToken, refreshToken, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    passport.use(new TwitterStrategy({
      consumerKey: config.TWITTER_CONSUMER_KEY,
      consumerSecret: config.TWITTER_CONSUMER_SECRET,
      callbackURL: "http://127.0.0.1:3000/auth/twitter/callback"
    }, function(token, tokenSecret, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    passport.use(new FacebookStrategy({
      clientID: config.FACEBOOK_APP_ID,
      clientSecret: config.FACEBOOK_APP_SECRET,
      callbackURL: "http://127.0.0.1:3000/auth/facebook/callback"
    }, function(accessToken, refreshToken, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    passport.use(new LinkedInStrategy({
      consumerKey: config.LINKEDIN_API_KEY,
      consumerSecret: config.LINKEDIN_SECRET_KEY,
      callbackURL: "http://127.0.0.1:3000/auth/linkedin/callback"
    }, function(token, tokenSecret, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    passport.use(new GitHubStrategy({
      clientID: config.GITHUB_CLIENT_ID,
      clientSecret: config.GITHUB_CLIENT_SECRET,
      callbackURL: "http://127.0.0.1:3000/auth/github/callback"
    }, function(accessToken, refreshToken, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    passport.use(new StackExchangeStrategy({
      clientID: config.STACKEXCHANGE_CLIENT_ID,
      clientSecret: config.STACKEXCHANGE_CLIENT_SECRET,
      key: config.STACKEXCHANGE_KEY,
      callbackURL: "http://127.0.0.1:3000/auth/stackexchange/callback"
    }, function(accessToken, refreshToken, profile, done) {
      return process.nextTick(function() {
        return done(null, profile);
      });
    }));
    console.log('listening on port 3000', config);
    return app.listen(3000);
  });

}).call(this);