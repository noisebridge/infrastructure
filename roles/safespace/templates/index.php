declare(strict_types=1);

<!DOCTYPE html>
{{ ansible_managed | comment('xml') }}
<!--
<?php
date_default_timezone_set("America/Los_Angeles");

echo "Server Debug Messages Start Here:";


define(constant_name: 'DISCORD_WEBHOOK_BASE_URL', value: 'https://discord.com/api/webhooks/');
define(constant_name: 'DISCORD_WEBHOOK_URL_PUBLIC', value: DISCORD_WEBHOOK_BASE_URL.'{ safespace_public_discord_channel_webhook_token }');
define(constant_name: 'DISCORD_WEBHOOK_URL_PRIVATE', value: DISCORD_WEBHOOK_BASE_URL.'{ safespace_private_discord_channel_webhook_token }');

define(
	constant_name: 'DISCORD_WEBHOOK_URL_PUBLIC',
	value: 'https://discord.com/api/webhooks/');
define(
	constant_name: 'DISCORD_WEBHOOK_URL_PRIVATE',
	value: 'https://discord.com/api/webhooks/');


function post_to_discord(
	string $msg,
	string $name_or_empty = "",
	string $contact_or_empty = "",
	string $location_or_empty = "",
	bool $wants_to_be_private = true): bool {

	// Filters message for undesired tags
	$replaces = 1;
	while ($replaces) {
		$msg = str_replace(
			search: ["@channel", "@everyone", "@here"],
			replace: "-AT-",
			subject: $msg,
			count: $replaces
		);
	}

	$report_time = date(format: "Y/m/d l h:ia");
	// Sets defaults.
	$name_or_empty = $name_or_empty ?: "Anonymous";
	$contact_or_empty = $contact_or_empty ?: "no-contact-provided";
	$location_or_empty = $location_or_empty ?: "no-location-provided";

	$username = "SafeSpaceBot({$name_or_empty})";
	$thead_name = "{$report_time}: {$location_or_empty}";
	$msg .="\n\nThis message was posted using the [Safespace Reporting Tool](https://nb.wtf/report).";
	$msg .="\n**Reporter:** {$name_or_empty}({$contact_or_empty})";
	$msg .="\n**Time:** {$report_time}";
	$msg .="\n**Location:** {$location_or_empty}";
	if ($wants_to_be_private) {
		$msg .="\n\n**IMPORTANT:** This reporter has indicated their wish for this to be handled **with minimal publicity**.";
	}

	// Ping relevant roles
	$msg .= "\n\nPinging: ";
	// @brave
	$msg .= "<@&1095925058771374131>";
	// @stewards
	$msg .= "<@&720517701382045767>";
	// @admin
	$msg .= "<@&720517641890037772>";
	// @member
	$msg .= "<@&720517758726438996>";
	// @space-guardians
	$msg .= "<@&1348361508467376138>";


	echo "msg:". $msg ."\nusername:". $name_or_empty.
	$json_data = json_encode(
		value: [
			"thread_name" => $thead_name,
			"content" => $msg,
			"username" => $username,
			// Text-to-speech
			"tts" => false
		],
		flags: JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE 
	);
	
	$webhook_url = $wants_to_be_private ? DISCORD_WEBHOOK_URL_PRIVATE : DISCORD_WEBHOOK_URL_PUBLIC;
	
	$ch = curl_init( url: $webhook_url );
	curl_setopt( handle: $ch, option: CURLOPT_HTTPHEADER, value: ['Content-type: application/json']);
	curl_setopt( handle: $ch, option: CURLOPT_POST, value: 1);
	curl_setopt( handle: $ch, option: CURLOPT_POSTFIELDS, value: $json_data);
	curl_setopt( handle: $ch, option: CURLOPT_FOLLOWLOCATION, value: 1);
	curl_setopt( handle: $ch, option: CURLOPT_HEADER, value: 0);
	curl_setopt( handle: $ch, option: CURLOPT_RETURNTRANSFER, value: 1);

	$response = curl_exec( handle: $ch );
	// If you need to debug, or find out why you can't send message uncomment line below, and execute script.
	echo "Response: ".$response."\n";
	curl_close( handle: $ch );
	return $response === "ok";
}


function stringExists(string $s): bool {
	return isset($s) && is_string(value: $s);
}

function pretty_print_post_val($name): string {
	return isset($_POST[$name]) ? "$name: " . $_POST[$name] . "\n" : "";
}

function getPostStringOrEmpty(string $key_name) : string {
	return stringExists(s: $_POST[$key_name]) ? $_POST[$key_name] : "";
}

function userIsExcellentHacker(): bool {
	$verification_expected = "be excellent";
	$verification = "";
	if(stringExists(s: $_POST["verification"])){
		$verification = $_POST["verification"];
	}
	$verification = strtolower(string: $verification);
	return strcmp(string1: $verification_expected,string2: $verification) == 0;
}

$isPost = $_SERVER['REQUEST_METHOD'] === 'POST';

$version = 3;
$result;
$prepend = "";


if ($isPost) {
	if (!userIsExcellentHacker()) {
		$prepend .= "Sorry, that's not the guiding principle of noisebridge. Please check the wiki for a short phrase.<br><br><strong>Offers of professional services should be sent to devnull@noisebridge.net, they are not welcome here.</strong>";
	} elseif (isset($_POST["message"])) {
		$result = "message present";
		
		// if(print_r(value: post_to_slack(msg: pretty_print(n: "name") . pretty_print(n: "contact") . $_POST["message"]))) {
		if(print_r(value: post_to_discord(
							msg: $_POST["message"],
							name_or_empty: getPostStringOrEmpty(key_name: "name"),
							contact_or_empty: getPostStringOrEmpty(key_name: "contact"),
							location_or_empty: getPostStringOrEmpty(key_name:"location"),
							wants_to_be_private: isset($_POST["send_to_public_incidents"]) ? !$_POST["send_to_public_incidents"] : true
							)
					)
			) {
			$result = "Message Sent.";
		} else {
			$result = "We encountered an error while trying to send your message.  If you see this, it would be appreciated if you contacted Roy (@rizend on slack or horsy4nbs.7.pcao@spamgourmet.com) so they can try and fix the issue.";
		}
	} else {
		$result = "Error in POST, message not present";
	}
	$prepend = "<div class=resp>" . $prepend;
	$prepend .= "<style> .resp { background-color: rgba(196, 64, 64, .1) ; } </style>";
	$prepend .= "</div><br>";
}


?>
-->
<html>
<head>
	<title>Safespace Reporting Tool</title>
	<style>
input[type=text] { margin-left: 3em; }
textarea { width: 75%; }
	</style>
</head>
<body>
	<h2>Noisebridge safe space reporting tool</h2>
	<p>Please be aware that this form sends a message to the #safety-incidents-{<a href="https://discord.com/channels/720514857094348840/1346730707250184202">public</a>,<a href="https://discord.com/channels/720514857094348840/1346730706453397605">private</a>} channel on the noisebridge discord the former which is potentially viewable by anyone.</p>
	<hr/>
	<i><?php echo($prepend); ?></i>
	<?php $form = <<<FORM
	<form method="post">
		Name (optional):<br/>
			<input type="text" name="name" placeholder="Kate Libby"></input><br/>
		Contact Info (optional):<br/>
			<input type="text" name="contact" placeholder="ac1d.burn@protonmail.ch"></input><br/><br/>
		Location (optional):<br/>
			<input type="text" name="location" placeholder="Hackitorium"></input><br/><br/>
		<textarea name="message" placeholder="I'm having trouble leaving a conversation in front of the noise-square table.  Could someone intervene so I can leave?"></textarea><br/><br/>
		<a href="https://www.noisebridge.net/wiki/Excellence">Guiding principle of noisebridge</a> (spam bot verification):<br/>
		<input type="text" name="verification" value="be automated"></input><br/><br/>
		Post this publicly? 
			<input type="checkbox" name="send_to_public_incidents" checked><br/><br/>
		<input type="submit" value="Send Message"></input>
	</form>
FORM
?>
	<?php echo( isset($result) ? $result : $form); ?>
         <noscript>
	<!--
	<i>Version <?php echo($version); ?></i>
	<p>Posted:<tt><?php foreach($_POST as $key=>$value) { echo "$key=$value"; echo "<br>\n"; }
	?></tt></p>
	-->
	</noscript>
</body>
</html>
