<?php
header('Content-Type: application/json');
require __DIR__ . '/Credentials.php';
$Result = array();

if(!isset($_POST['FunctionCall'])) {
	die('No function name!');
}
if(!isset($_POST['Args'])) {
	die('No function arguments!');
}

function FormatDateTimeStr($Str){
	$OutStr = substr($Str,0,4)
		.'-'.substr($Str,4,2)
		.'-'.substr($Str,6,2)
		.'T'.substr($Str,9,2)
		.':'.substr($Str,11,2)
		.':'.substr($Str,13,2);
	return $OutStr;
}

// Connect to the database:
$Conn = new mysqli($Servername, $Username, $Password, $Dbname);
if($Conn->connect_error) {
	die("Connection failed: " . $Conn->connect_error);
}

// Get the input variables:
$Input = $_POST['Args'];
$SubjectId = $Input['SubjectId'];
$SubjectId = mysqli_real_escape_string($Conn,$SubjectId);
$Now = new DateTimeImmutable("now", new DateTimeZone('Europe/London'));
$DateTime_Write = $Now->format('Y-m-d\TH:i:s');

switch($_POST['FunctionCall']) {
	case 'WriteTaskIO':
	    
		$ClientTimeZone = $Input['ClientTimeZone'];
        $ClientTimeZone = mysqli_real_escape_string($Conn,$ClientTimeZone);
		$TaskIO = $Input["TaskIO"];
		$TaskIO = mysqli_real_escape_string($Conn,$TaskIO);
		
		$Sql = "INSERT INTO TaskIO (SubjectId, DateTime_Write, ClientTimeZone, JsonString) VALUES ('$SubjectId', '$DateTime_Write', '$ClientTimeZone', '$TaskIO')";
			
		// Run and set the result:
		if($Conn->query($Sql)===true) {
			$Result['TargetUrl'] = "./Questions.html?SubjectId=$SubjectId#";
		} else {
			$Conn->close();
			die('Query Sql failed to execute successfully;');
		}
		break;
		
	case 'WriteQuestionsIO':
	    
		// Set ClientTimeZone
		$ClientTimeZone = $Input['ClientTimeZone'];
        $ClientTimeZone = mysqli_real_escape_string($Conn,$ClientTimeZone);
        
	    // Set DoB
		$DoB = $Input['DoB'];
		$DateTime_DoB = new DateTime($DoB, new DateTimeZone('Europe/London'));
		$DateTime_DoB = $DateTime_DoB->format('Y-m-d');
		
		// Set Gender
		$Gender = $Input['Gender'];
		$Gender = mysqli_real_escape_string($Conn,$Gender);
		
		// Set Primary
        $Primary = $Input['Primary'];
        $Primary = mysqli_real_escape_string($Conn,$Primary);
        
        // Set Secondary
        $Secondary = $Input['Secondary'];
        $Secondary = mysqli_real_escape_string($Conn,$Secondary);
        
        // Set ThinkDyscalculia
        $ThinkDyscalculia = $Input['ThinkDyscalculia'];
        $ThinkDyscalculia = mysqli_real_escape_string($Conn,$ThinkDyscalculia);
        
        // Set DyscalculiaDiagnosis
        $DyscalculiaDiagnosis = $Input['DyscalculiaDiagnosis'];
        $DyscalculiaDiagnosis = mysqli_real_escape_string($Conn,$DyscalculiaDiagnosis);
        
        // Set EnjoyMaths
        $EnjoyMaths = $Input['EnjoyMaths'];
        $EnjoyMaths = mysqli_real_escape_string($Conn,$EnjoyMaths);
        
        // Set ThinkDyslexia
        $ThinkDyslexia = $Input['ThinkDyslexia'];
        $ThinkDyslexia = mysqli_real_escape_string($Conn,$ThinkDyslexia);
        
        // Set DyslexiaDiagnosis
        $DyslexiaDiagnosis = $Input['DyslexiaDiagnosis'];
        $DyslexiaDiagnosis = mysqli_real_escape_string($Conn,$DyslexiaDiagnosis);
        
        // Set Games
        $Games = $Input['Games'];
		$Games = mysqli_real_escape_string($Conn,$Games);
		$Games = intval($Games);
		
		$Sql = "INSERT INTO QuestionsIO (SubjectId, DateTime_Write, ClientTimeZone, DoB, Gender, UkPrimary, UkSecondary, ThinkDyscalculia, DyscalculiaDiagnosis, EnjoyMaths, ThinkDyslexia, DyslexiaDiagnosis, Games) VALUES ('$SubjectId', '$DateTime_Write', '$ClientTimeZone', '$DateTime_DoB', '$Gender', '$Primary', '$Secondary', '$ThinkDyscalculia', '$DyscalculiaDiagnosis', '$EnjoyMaths', '$ThinkDyslexia', '$DyslexiaDiagnosis', $Games)";
			
		// Run and set the result:
		if($Conn->query($Sql)===true) {
			$Result['TargetUrl'] = "./End.html?SubjectId=$SubjectId#";
		} else {
			$Conn->close();
			die('Query Sql failed to execute successfully;');
		}
		break;
		
	default:
		// Kill it if the function call is bad:
		$Conn->close();
		die('Bad function call.');
		break;
}

$Conn->close();
echo json_encode($Result);
?>