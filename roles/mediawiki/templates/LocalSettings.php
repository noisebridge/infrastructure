<?php
{{ ansible_managed | comment }}
# See includes/DefaultSettings.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

## Enable to put site in maintence.
# $wgReadOnly = ( PHP_SAPI === 'cli' ) ? false : 'This wiki is currently being upgraded to a newer software version. Please check back in a couple of hours.';

## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = "Noisebridge";

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath = "";
$wgScript = "$wgScriptPath/index.php";
$wgRedirectScript = "$wgScriptPath/index.php";
$wgArticlePath = "/wiki/$1";

## The protocol and server name to use in fully-qualified URLs
$wgServer = "https://www.{{ mediawiki.domain }}";

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL path to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogo = "/img/nb-logo-131.png";
$wgFavicon = "/img/favicon.ico";

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "webmaster@noisebridge.net";
$wgPasswordSender = "do-not-reply@noisebridge.net";

$wgEnotifUserTalk = true; # UPO
$wgEnotifWatchlist = true; # UPO
$wgEmailAuthentication = true;

## Database settings
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "{{ mediawiki.database }}";
$wgDBuser = "{{ mediawiki.database_username }}";
$wgDBpassword = "{{ mysql_users|selectattr('name', 'equalto', 'wiki')|map(attribute='password')|join('')}}";

# MySQL specific settings
$wgDBprefix = "wiki_";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = false;

## Shared memory settings
$wgMainCacheType = CACHE_MEMCACHED;
$wgMessageCacheType = CACHE_MEMCACHED;
$wgParserCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = array( "127.0.0.1:11211" );
$wgEnableSidebarCache = true;
$wgSessionsInObjectCache = true; # optional
$wgSessionCacheType = CACHE_MEMCACHED; # optional

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgUseImageResize = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "en_US.utf8";

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "en";

$wgLocaltimezone = "US/Pacific";
date_default_timezone_set( $wgLocaltimezone );

$wgSecretKey = "{{ mediawiki_secret_key }}";

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "{{ mediawiki_upgrade_key }}";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "https://creativecommons.org/licenses/by-nc-sa/4.0/";
$wgRightsText = "Creative Commons Attribution-NonCommercial-ShareAlike";
$wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-nc-sa.png";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook':
$wgDefaultSkin = "vector";

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'CologneBlue' );
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Vector' );


# Enabled extensions. Most of the extensions are enabled by adding
# wfLoadExtensions('ExtensionName');
# to LocalSettings.php. Check specific extension documentation for more details.
# The following extensions were automatically enabled:
wfLoadExtension( 'Renameuser' );
wfLoadExtension( 'Nuke' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtensions([ 'ConfirmEdit', 'ConfirmEdit/ReCaptchaNoCaptcha' ]);
wfLoadExtension( 'mwGoogleSheet' );

# End of automatically generated settings.
# Add more configuration options below.

$wgUseGzip = true;
$wgUseFileCache = false;
$wgFileCacheDirectory = '/var/cache/mediawiki/';

wfLoadExtensions([ 'ConfirmEdit', 'ConfirmEdit/ReCaptchaNoCaptcha' ]);
#wfLoadExtensions([ 'ConfirmEdit', 'ConfirmEdit/QuestyCaptcha', 'QuestyCaptchaEditor' ]);
#wfLoadExtensions([ 'ConfirmEdit', 'ConfirmEdit/QuestyCaptcha' ]);
#wfLoadExtensions([ 'ConfirmEdit', 'ConfirmEdit/ReCaptchaNoCaptcha', 'ConfirmEdit/QuestyCaptcha', 'QuestyCaptchaEditor' ]);

## ConfirmEdit/QuestyCaptcha questions
$wgCaptchaQuestions = [
	'What is the guiding principle of Noisebridge?' => [ 'be excellent' ],
];
## https://www.mediawiki.org/wiki/Extension:ConfirmEdit#URL_and_IP_whitelists
$wgCaptchaWhitelistIP = [ '192.195.83.130' ]; ## Noisebridge space IP, from MonkeyBrains

# Configure ReCaptcha
$wgCaptchaClass = 'ReCaptchaNoCaptcha';
$wgReCaptchaSiteKey = '{{ mediawiki_recaptcha_site_key }}';
$wgReCaptchaSecretKey = '{{ mediawiki_recaptcha_secret_key }}';
$wgReCaptchaSendRemoteIP = false;
$ceAllowConfirmedEmail = true;

# Require CAPTCHA for edit, create, new account.
$wgCaptchaTriggers['edit'] = true;
$wgCaptchaTriggers['create'] = true;
$wgCaptchaTriggers['addurl'] = true;
$wgCaptchaTriggers['createaccount'] = true;
$wgCaptchaTriggers['badlogin'] = true;

$wgGroupPermissions['*']['createpage'] = false;
$wgGroupPermissions['user']['createpage'] = false;
$wgGroupPermissions['*']['createtalk'] = false;
$wgGroupPermissions['user']['createtalk'] = false;
$wgGroupPermissions['autoconfirmed' ]['createpage'] = true;
$wgGroupPermissions['autoconfirmed' ]['createtalk'] = true;
$wgGroupPermissions['*']['move'] = false;
$wgGroupPermissions['user']['move'] = false;
$wgGroupPermissions['autoconfirmed' ]['move'] = true;
$wgGroupPermissions['*']['upload'] = false;
$wgGroupPermissions['user']['upload'] = false;
$wgGroupPermissions['autoconfirmed' ]['upload'] = true;

$wgGroupPermissions['*'             ]['skipcaptcha'] = false;
$wgGroupPermissions['user'          ]['skipcaptcha'] = false;
$wgGroupPermissions['autoconfirmed' ]['skipcaptcha'] = true;
$wgGroupPermissions['emailconfirmed']['skipcaptcha'] = true;
$wgGroupPermissions['bot'           ]['skipcaptcha'] = true; // registered bots
$wgGroupPermissions['sysop'         ]['skipcaptcha'] = true;


$wgGroupPermissions['confirmed' ] = $wgGroupPermissions['autoconfirmed' ];

$wgAutoConfirmCount = 5;
$wgAutoConfirmAge = 86400*3; // three days

$wgAutopromote = array(
	"autoconfirmed" => array( "&",
		array( APCOND_EDITCOUNT, &$wgAutoConfirmCount ),
		array( APCOND_AGE, &$wgAutoConfirmAge ),
		APCOND_EMAILCONFIRMED
	),
);

$wgFileExtensions[] = 'pdf';
$wgFileExtensions[] = 'svg';


# https://www.mediawiki.org/wiki/Extension:CheckUser
wfLoadExtension( 'CheckUser' ); # requires 1.41.0 > 1.35.8 current version
# give sysops all the rights this extension provides
$wgGroupPermissions['sysop']['checkuser'] = true;
$wgGroupPermissions['sysop']['checkuser-log'] = true;
$wgGroupPermissions['sysop']['investigate'] = true;
$wgGroupPermissions['sysop']['checkuser-temporary-account'] = true;

# comes installed, but not enabled.
wfLoadExtension( 'Gadgets' );
# https://www.mediawiki.org/wiki/Extension:Gadgets#User_rights
$wgGroupPermissions['interface-admin']['gadgets-edit'] = true;
$wgGroupPermissions['interface-admin']['gadgets-definition-edit'] = true;

# https://www.mediawiki.org/wiki/Extension:Popups
wfLoadExtensions( [ 'TextExtracts', 'PageImages', 'Popups' ] );
$wgPopupsVirtualPageViews = true;
$wgPopupsReferencePreviewsBetaFeature = false;
$wgPopupsOptInDefaultState = 1; # 0

# https://www.mediawiki.org/wiki/Manual:$wgContentNamespaces - to enable Popups on more namespaces
# $wgContentNamespaces = ... + Meeting: ?

# https://www.mediawiki.org/wiki/Extension:ConfirmAccount
wfLoadExtension( 'ConfirmAccount' );
$wgGroupPermissions['*']['createaccount'] = false; # not sure I want to block this
$wgGroupPermissions['bureaucrat']['createaccount'] = true;

# https://www.mediawiki.org/wiki/Manual:Interface/JavaScript
$wgAllowUserJs = true;
$wgAllowUserCss = true;

# https://www.mediawiki.org/wiki/Extension:Interwiki
wfLoadExtension( 'Interwiki' );
$wgGroupPermissions['sysop']['interwiki'] = true;

# https://www.mediawiki.org/wiki/Extension:InviteSignup
wfLoadExtension( 'InviteSignup' );
$wgGroupPermissions['bureaucrat']['invitesignup'] = true;
$wgGroupPermissions['invitesignup']['invitesignup'] = true; # :D - hacker takeoff
$wgISGroupsRequired = [ 'invitedIS' ];

# https://www.mediawiki.org/wiki/Extension:EmbedVideo#Installation
wfLoadExtension( 'EmbedVideo' ); # mainly allowed embeded links for services. ignore ffmpeg options

# https://www.mediawiki.org/wiki/Extension:Admin_Links
wfLoadExtension( 'AdminLinks' );
#$wgGroupPermissions['...']['.adminlinks'] = true;

# https://www.mediawiki.org/wiki/Extension:QRLite
wfLoadExtension( 'QRLite' );

#Set Default Timezone
$wgLocaltimezone = "US/Pacific";
date_default_timezone_set( $wgLocaltimezone );

# https://www.mediawiki.org/wiki/Extension:Scribunto
wfLoadExtension( 'Scribunto' );
$wgScribuntoDefaultEngine = 'luasandbox'; #'luastandalone';

# https://www.mediawiki.org/wiki/Extension:CharInsert
wfLoadExtension( 'CharInsert' );
$wgUseInstantCommons = true;
$wgForeignFileRepos[] = [
        'class' => ForeignAPIRepo::class,
        'name' => 'commonswiki', // Must be a distinct name
        'apibase' => 'https://commons.wikimedia.org/w/api.php',
        'hashLevels' => 2,
        'fetchDescription' => true, // Optional
        'descriptionCacheExpiry' => 43200, // 12 hours, optional (values are seconds)
        'apiThumbCacheExpiry' => 86400, // 24 hours, optional, but required for local thumb caching
];

# https://www.mediawiki.org/wiki/Extension:VisualEditor
wfLoadExtension( 'VisualEditor' );
$wgGroupPermissions['user']['writeapi'] = true;
# concern about pages containing slashes in their names (at least on apache, 2+ mentions. Caddy might be fine)
# https://www.mediawiki.org/wiki/Extension:VisualEditor
# Optional: Set VisualEditor as the default editor for anonymous users
# otherwise they will have to switch to VE
##$wgDefaultUserOptions['visualeditor-editor'] = "visualeditor";
# Optional: Don't allow users to disable it
#$wgHiddenPrefs[] = 'visualeditor-enable';
# Optional: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
# Activate ONLY the 2017 wikitext editor by default
#$wgDefaultUserOptions['visualeditor-autodisable'] = true;
#$wgDefaultUserOptions['visualeditor-newwikitext'] = 1;

# https://www.mediawiki.org/wiki/Extension:BetaFeatures  # needed run of $ php8.2 maintenance/update.php
wfLoadExtension( 'BetaFeatures' );
#$wgBetaFeaturesWhitelist = [  # READ BEFORE MODIFYING https://www.mediawiki.org/wiki/Extension:BetaFeatures#Configuration
#        'myextension-awesome-feature'
#];

# https://www.mediawiki.org/wiki/Extension:MultimediaViewer
wfLoadExtension( 'MultimediaViewer' );
#$wgMediaViewerIsInBeta = true;
#$wgMediaViewerEnableByDefault = false;  # default =true
#$wgMediaViewerEnableByDefaultForAnonymous = false; # default =true
#$wgMediaViewerUseThumbnailGuessing = false;  # improves perf, fragile dep on wiki set up: 404 handler

# https://www.mediawiki.org/wiki/Extension:CategoryTree
wfLoadExtension( 'CategoryTree' );

# https://www.mediawiki.org/wiki/Extension:ImageMap
wfLoadExtension( 'ImageMap' );

# https://www.noisebridge.net/wiki/Nb.wtf # https://github.com/audiodude/nb.wtf
wfLoadExtension( 'NBWTF' );

#$wgReadOnly = '[issue] [timeframe] -User:[admin]';
