<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");

$payload = json_decode(file_get_contents("php://input"), true);
$name = isset($payload["name"]) ? trim($payload["name"]) : "";
$email = isset($payload["email"]) ? trim($payload["email"]) : "";
$role = isset($payload["role"]) ? trim($payload["role"]) : "";
$userId = isset($payload["user_id"]) ? (int)$payload["user_id"] : 0;

if ($name === "" || $email === "" || $role === "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Name, email and role are required.",
    ];
} else {
    $escapedName = mysqli_real_escape_string($evmulti, $name);
    $escapedEmail = mysqli_real_escape_string($evmulti, $email);
    $escapedRole = mysqli_real_escape_string($evmulti, $role);

    $sql = "INSERT INTO tenally_artist_submissions (user_id, name, email, role, status, created_at) 
        VALUES ($userId, '$escapedName', '$escapedEmail', '$escapedRole', 'Pending', NOW())";

    if ($evmulti->query($sql)) {
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Artist submission sent successfully.",
            "SubmissionId" => $evmulti->insert_id,
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "500",
            "Result" => "false",
            "ResponseMsg" => "Unable to save submission.",
        ];
    }
}

echo json_encode($returnArr);
