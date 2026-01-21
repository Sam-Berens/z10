<?php
header('Content-Type: application/json');
$Result = array();
if( !isset($_POST['FunctionCall']) ) { $Result['Error'] = 'No function name!'; }
if( !isset($_POST['Args']) ) { $Result['Error'] = 'No function arguments!'; }

if( !isset($Result['Error']) ) {
    switch($_POST['FunctionCall']) {
        case 'GetDateTime':
            $Now = new DateTime('now', new DateTimeZone('Europe/London'));
            $Result['DateTime'] = $Now -> format("Ymd_His");
           break;
		   
        default:
           $Result['Error'] = 'Not found function '.$_POST['FunctionCall'].'!';
           break;
    }
}
echo json_encode($Result);
?>