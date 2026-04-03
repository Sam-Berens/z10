<?php
header('Content-Type: application/json');
require __DIR__ . '/Credentials.php';

$Conn = new mysqli($Servername, $Username, $Password, $Dbname);
if ($Conn->connect_error) {
	die("Database connection failed: " . $Conn->connect_error);
}

function StringOrEmpty($Value)
{
	if ($Value === null) {
		return '';
	}

	return strval($Value);
}

function GetTaskIO($SubjectId) {
	global $Conn;
	$Sql = "SELECT * FROM TaskIO WHERE SubjectId='$SubjectId'";
	$QueryRes = mysqli_query($Conn, $Sql);
	while ($Row = mysqli_fetch_assoc($QueryRes)) {
		$DateTime_Train = StringOrEmpty($Row["DateTime_Write"]);
		$TaskIO = StringOrEmpty($Row["JsonString"]);
	}
	$Data = array();
	$Data["DateTime_Train"] = $DateTime_Train;
	$Data["TaskIO"] = $TaskIO;
	return $Data;
}

$Sql = "SELECT * FROM QuestionsIO;";
$QueryRes = mysqli_query($Conn, $Sql);
$Data = array(
	'SubjectId' => array(),
	'DoB' => array(),
	'Gender' => array(),
	'UkPrimary' => array(),
	'UkSecondary' => array(),
	'ThinkDyscalculia' => array(),
	'DyscalculiaDiagnosis' => array(),
	'EnjoyMaths' => array(),
	'ThinkDyslexia' => array(),
	'DyslexiaDiagnosis' => array(),
	'Chess' => array(),
	'Football' => array(),
	'Golf' => array(),
	'Jigsaw' => array(),
	'Monopoly' => array(),
	'Riding' => array(),
	'Rugby' => array(),
	'Swimming' => array(),
	'Tennis' => array(),
	'Trivia' => array(),
	'DateTime_Train' => array(),
	'DateTime_Questions' => array(),
	'ClientTimeZone' => array(),
	'TaskIO' => array()
);
if (!$QueryRes) {
	$Conn->close();
	die("Query Sql failed to execute successfully");
}

while ($Row = mysqli_fetch_assoc($QueryRes)) {
	$SubjectId = StringOrEmpty($Row["SubjectId"]);
	$DoB = StringOrEmpty($Row["DoB"]);
	$Gender = StringOrEmpty($Row["Gender"]);
	$UkPrimary = StringOrEmpty($Row["UkPrimary"]);
	$UkSecondary = StringOrEmpty($Row["UkSecondary"]);
	$ThinkDyscalculia = StringOrEmpty($Row["ThinkDyscalculia"]);
	$DyscalculiaDiagnosis = StringOrEmpty($Row["DyscalculiaDiagnosis"]);
	$EnjoyMaths = StringOrEmpty($Row["EnjoyMaths"]);
	$ThinkDyslexia = StringOrEmpty($Row["ThinkDyslexia"]);
	$DyslexiaDiagnosis = StringOrEmpty($Row["DyslexiaDiagnosis"]);
	$Games = StringOrEmpty($Row["Games"]);
	$Chess = (($Games >> 0) & 1) ? "Yes" : "No";
	$Football = (($Games >> 1) & 1) ? "Yes" : "No";
	$Golf = (($Games >> 2) & 1) ? "Yes" : "No";
	$Jigsaw = (($Games >> 3) & 1) ? "Yes" : "No";
	$Monopoly = (($Games >> 4) & 1) ? "Yes" : "No";
	$Riding = (($Games >> 5) & 1) ? "Yes" : "No";
	$Rugby = (($Games >> 6) & 1) ? "Yes" : "No";
	$Swimming = (($Games >> 7) & 1) ? "Yes" : "No";
	$Tennis = (($Games >> 8) & 1) ? "Yes" : "No";
	$Trivia = (($Games >> 9) & 1) ? "Yes" : "No";
	$DateTime_Questions = StringOrEmpty($Row["DateTime_Write"]);
	$ClientTimeZone = StringOrEmpty($Row["ClientTimeZone"]);

	$FromTaskIO = GetTaskIO($SubjectId);

	$Data['SubjectId'][] = $SubjectId;
	$Data['DoB'][] = $DoB;
	$Data['Gender'][] = $Gender;
	$Data['UkPrimary'][] = $UkPrimary;
	$Data['UkSecondary'][] = $UkSecondary;
	$Data['ThinkDyscalculia'][] = $ThinkDyscalculia;
	$Data['DyscalculiaDiagnosis'][] = $DyscalculiaDiagnosis;
	$Data['EnjoyMaths'][] = $EnjoyMaths;
	$Data['ThinkDyslexia'][] = $ThinkDyslexia;
	$Data['DyslexiaDiagnosis'][] = $DyslexiaDiagnosis;
	$Data['Chess'][] = $Chess;
	$Data['Football'][] = $Football;
	$Data['Golf'][] = $Golf;
	$Data['Jigsaw'][] = $Jigsaw;
	$Data['Monopoly'][] = $Monopoly;
	$Data['Riding'][] = $Riding;
	$Data['Rugby'][] = $Rugby;
	$Data['Swimming'][] = $Swimming;
	$Data['Tennis'][] = $Tennis;
	$Data['Trivia'][] = $Trivia;
	$Data['DateTime_Train'][] = $FromTaskIO["DateTime_Train"];
	$Data['DateTime_Questions'][] = $DateTime_Questions;
	$Data['ClientTimeZone'][] = $ClientTimeZone;
	$Data['TaskIO'][] = $FromTaskIO["TaskIO"];
}

$Conn->close();
echo json_encode($Data);