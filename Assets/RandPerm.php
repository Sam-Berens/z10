<?php
$Min = $_GET['min'];
$Max = $_GET['max'];
$Perm = range($Min,$Max,1);
shuffle($Perm);
echo(json_encode($Perm));
?>