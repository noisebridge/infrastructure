<!DOCTYPE html>
{{ ansible_managed | comment('xml') }}
<!--
<?php

function file_post_contents($url, $data, $username = null, $password = null): bool|string // from https://stackoverflow.com/questions/11319520/php-posting-json-via-file-get-contents
{
    $postdata = http_build_query($data);
    $opts = array('http' =>
        array(
            'method'  => 'POST',
            'header'  => 'Content-type: application/x-www-form-urlencoded',
            'content' => $postdata
        )
    );
    if($username && $password)
    {
        $opts['http']['header'] = "Authorization: Basic " . base64_encode(string: "$username:$password");
    }
    $context = stream_context_create(options: $opts);
    return file_get_contents(filename: $url, use_include_path: false, context: $context);
}


// payload={\"channel\": \"#hook-testing\", \"username\": \"webhookbot\", \"text\": \"This is posted to #hook-testing and comes from a bot named webhookbot.\", \"icon_emoji\": \":ghost:\"}"
define(constant_name: 'WEBHOOK_URL', value: 'https:/' . '/hooks.slack.com/services/{{ safespace_slack_token }}');
define(constant_name: 'SLACK_CHANNEL', value: '{{ safespace_slack_channel }}');
define(constant_name: 'SLACK_USERNAME', value: '{{ safespace_slack_username }}');
define(constant_name: 'SLACK_ICON', value: ':heart:');
function send_msg($msg): bool {
	$replaces = 1;
	while ($replaces) {
		$msg = str_replace(search: ["@channel", "@everyone"], replace: "-AT-", subject: $msg, count: $replaces);
	}
	$payload = json_encode(value: array(
		'channel' => SLACK_CHANNEL,
		'username' => SLACK_USERNAME,
		'text' => $msg . "_(This message was filled out on safespace.noisebridge.net by someone who may not have slack access and who may wish to remain anonymous)._",
		'icon_emoji' => SLACK_ICON
	));
	$ret="";
	try {
		$ret = file_post_contents(url: WEBHOOK_URL, data: array('payload' => $payload));
	} catch(Exception $e) {
		echo($e . "\n");
		return false;
	}
	return $ret === "ok";
}

function p($n): string {
	return (isset($_POST[$n]) && is_string(value: $_POST[$n])) ? "$n: " . $_POST[$n] . "\n" : "";
}

function stringExists($s): bool {
	return isset($verification) && is_string(value: $verification);
}

$isPost = $_SERVER['REQUEST_METHOD'] === 'POST';

$version = 2;
$result;
$prepend = "";
$verification_expected = "be excellent";
$verification = $_POST["verification"];
$verification = strtolower(string: $verification);
if ($isPost) {
	if (strcmp(string1: $verification_expected, string2: $verification) !== 0) {
		$prepend .= "Sorry, that's not the guiding principle of noisebridge. Please check the wiki for a short phrase.<br><br><strong>Offers of professional services should be sent to devnull@noisebridge.net, they are not welcome here.</strong>";
	} elseif (isset($_POST["message"])) {
		$result = "message present";
		if(print_r(value: send_msg(msg: p(n: "name") . p(n: "contact") . $_POST["message"]))) {
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
	<p>Please be aware that this form sends a message to the #space-guardians channel on the noisebridge slack which is viewable by anyone on our slack.</p>
	<hr/>
	<i><?php echo($prepend); ?></i>
	<?php $form = <<<FORM
	<form method="post">
		Name (optional):<br/>
			<input type="text" name="name" placeholder="Kate Libby"></input><br/>
		Contact Info (optional):<br/>
			<input type="text" name="contact" placeholder="ac1d.burn@protonmail.ch"></input><br/><br/>
		<textarea name="message" placeholder="I'm having trouble leaving a conversation in front of the noise-square table.  Could someone intervene so I can leave?"></textarea><br/><br/>
		<a href="https://www.noisebridge.net/wiki/Excellence">Guiding principle of noisebridge</a> (spam bot verification):<br/>
		<input type="text" name="verification" value="be automated"></input><br/><br/>
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
