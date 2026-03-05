# MediaWiki with Memcached caching.
# Configuration translated from roles/mediawiki/ and group_vars/noisebridge_net/mediawiki.yml.
{ config, pkgs, lib, ... }:
{
  age.secrets = {
    mysql-mediawiki = {
      file = ../secrets/mysql-mediawiki.age;
      owner = "mediawiki";
    };
  };

  services.mediawiki = {
    enable = true;
    name = "Noisebridge";
    url = "https://www.noisebridge.net";
    passwordFile = config.age.secrets.mysql-mediawiki.path;

    database = {
      type = "mysql";
      host = "localhost";
      name = "noisebridge_mediawiki";
      user = "wiki";
      passwordFile = config.age.secrets.mysql-mediawiki.path;
      tablePrefix = "wiki_";
      createLocally = false; # managed by mysql.nix
    };

    # PHP-FPM pool served by Caddy
    webserver = "none";
    poolConfig = {
      "pm" = "dynamic";
      "pm.max_children" = 16;
      "pm.start_servers" = 4;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 8;
      "pm.max_requests" = 500;
    };

    extensions = {
      # Core extensions bundled with MediaWiki
      Renameuser = null;
      Nuke = null;
      ParserFunctions = null;
      ConfirmEdit = null;
      CheckUser = null;
      Gadgets = null;
      Popups = null;
      TextExtracts = null;
      PageImages = null;
      ConfirmAccount = null;
      Interwiki = null;
      InviteSignup = null;
      EmbedVideo = null;
      AdminLinks = null;
      QRLite = null;
      Scribunto = null;
      CharInsert = null;
      VisualEditor = null;
      BetaFeatures = null;
      MultimediaViewer = null;
      CategoryTree = null;
      ImageMap = null;
    };

    skins = {
      CologneBlue = null;
      MonoBook = null;
      Vector = null;
    };

    extraConfig = ''
      # URL rewriting
      $wgScriptPath = "";
      $wgScript = "$wgScriptPath/index.php";
      $wgArticlePath = "/wiki/$1";

      # Branding
      $wgLogo = "/img/nb-logo-131.png";
      $wgFavicon = "/img/favicon.ico";
      $wgDefaultSkin = "vector";

      # Email
      $wgEnableEmail = true;
      $wgEnableUserEmail = true;
      $wgEmergencyContact = "webmaster@noisebridge.net";
      $wgPasswordSender = "do-not-reply@noisebridge.net";
      $wgEnotifUserTalk = true;
      $wgEnotifWatchlist = true;
      $wgEmailAuthentication = true;

      # Database engine
      $wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

      # Memcached caching
      $wgMainCacheType = CACHE_MEMCACHED;
      $wgMessageCacheType = CACHE_MEMCACHED;
      $wgParserCacheType = CACHE_MEMCACHED;
      $wgMemCachedServers = [ "127.0.0.1:11211" ];
      $wgEnableSidebarCache = true;
      $wgSessionsInObjectCache = true;
      $wgSessionCacheType = CACHE_MEMCACHED;

      # Uploads
      $wgEnableUploads = true;
      $wgUseImageMagick = true;
      $wgUseImageResize = true;
      $wgImageMagickConvertCommand = "${pkgs.imagemagick}/bin/convert";

      # Locale
      $wgShellLocale = "en_US.utf8";
      $wgLanguageCode = "en";
      $wgLocaltimezone = "US/Pacific";
      date_default_timezone_set( $wgLocaltimezone );

      # License
      $wgRightsUrl = "https://creativecommons.org/licenses/by-nc-sa/4.0/";
      $wgRightsText = "Creative Commons Attribution-NonCommercial-ShareAlike";
      $wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-nc-sa.png";

      # Diff
      $wgDiff3 = "${pkgs.diffutils}/bin/diff3";

      # Compression
      $wgUseGzip = true;

      # Permissions — restrict page/talk creation to autoconfirmed
      $wgGroupPermissions['*']['createpage'] = false;
      $wgGroupPermissions['user']['createpage'] = false;
      $wgGroupPermissions['*']['createtalk'] = false;
      $wgGroupPermissions['user']['createtalk'] = false;
      $wgGroupPermissions['autoconfirmed']['createpage'] = true;
      $wgGroupPermissions['autoconfirmed']['createtalk'] = true;
      $wgGroupPermissions['*']['move'] = false;
      $wgGroupPermissions['user']['move'] = false;
      $wgGroupPermissions['autoconfirmed']['move'] = true;
      $wgGroupPermissions['*']['upload'] = false;
      $wgGroupPermissions['user']['upload'] = false;
      $wgGroupPermissions['autoconfirmed']['upload'] = true;

      # Auto-confirmation: 5 edits + 3 days + email confirmed
      $wgAutoConfirmCount = 5;
      $wgAutoConfirmAge = 86400 * 3;
      $wgAutopromote = [
        "autoconfirmed" => [ "&",
          [ APCOND_EDITCOUNT, &$wgAutoConfirmCount ],
          [ APCOND_AGE, &$wgAutoConfirmAge ],
          APCOND_EMAILCONFIRMED
        ],
      ];

      # CAPTCHA whitelist for the space IP
      $wgCaptchaWhitelistIP = [ '192.195.83.130' ];

      # File extensions
      $wgFileExtensions[] = 'pdf';
      $wgFileExtensions[] = 'svg';

      # CheckUser
      $wgGroupPermissions['sysop']['checkuser'] = true;
      $wgGroupPermissions['sysop']['checkuser-log'] = true;
      $wgGroupPermissions['sysop']['investigate'] = true;
      $wgGroupPermissions['sysop']['checkuser-temporary-account'] = true;

      # Gadgets
      $wgGroupPermissions['interface-admin']['gadgets-edit'] = true;
      $wgGroupPermissions['interface-admin']['gadgets-definition-edit'] = true;

      # Popups
      $wgPopupsVirtualPageViews = true;
      $wgPopupsReferencePreviewsBetaFeature = false;
      $wgPopupsOptInDefaultState = 1;

      # ConfirmAccount
      $wgGroupPermissions['*']['createaccount'] = false;
      $wgGroupPermissions['bureaucrat']['createaccount'] = true;

      # User JS/CSS
      $wgAllowUserJs = true;
      $wgAllowUserCss = true;

      # Interwiki
      $wgGroupPermissions['sysop']['interwiki'] = true;

      # InviteSignup
      $wgGroupPermissions['bureaucrat']['invitesignup'] = true;
      $wgGroupPermissions['invitesignup']['invitesignup'] = true;
      $wgISGroupsRequired = [ 'invitedIS' ];

      # Scribunto
      $wgScribuntoDefaultEngine = 'luasandbox';

      # Wikimedia Commons foreign file repo
      $wgUseInstantCommons = true;
      $wgForeignFileRepos[] = [
        'class' => ForeignAPIRepo::class,
        'name' => 'commonswiki',
        'apibase' => 'https://commons.wikimedia.org/w/api.php',
        'hashLevels' => 2,
        'fetchDescription' => true,
        'descriptionCacheExpiry' => 43200,
        'apiThumbCacheExpiry' => 86400,
      ];

      # VisualEditor
      $wgGroupPermissions['user']['writeapi'] = true;
    '';
  };

  # Memcached
  services.memcached = {
    enable = true;
    listen = "127.0.0.1";
    port = 11211;
    maxMemory = 64; # MB
  };

  # ImageMagick for image processing
  environment.systemPackages = with pkgs; [
    imagemagick
  ];
}
