<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");

$name = isset($_POST["name"]) ? trim($_POST["name"]) : "";
$email = isset($_POST["email"]) ? trim($_POST["email"]) : "";
$title = isset($_POST["script_title"]) ? trim($_POST["script_title"]) : "";
$userId = isset($_POST["user_id"]) ? (int)$_POST["user_id"] : 0;

if ($name === "" || $email === "" || $title === "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "All fields are required.",
    ];
} elseif (!isset($_FILES["script_file"]) || $_FILES["script_file"]["error"] !== UPLOAD_ERR_OK) {
    $returnArr = [
        "ResponseCode" => "402",
        "Result" => "false",
        "ResponseMsg" => "Please upload a valid script file.",
    ];
} else {
    $fileInfo = $_FILES["script_file"];
    $originalName = basename($fileInfo["name"]);
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $allowed = ["pdf", "doc", "docx"];

    if (!in_array($extension, $allowed, true)) {
        $returnArr = [
            "ResponseCode" => "403",
            "Result" => "false",
            "ResponseMsg" => "Only PDF, DOC, and DOCX are allowed.",
        ];
    } else {
        $targetDir = dirname(dirname(__FILE__)) . "/uploads/tenally_scripts/";
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0755, true);
        }

        $safeFileName = uniqid("tenally_script_") . "." . $extension;
        $targetPath = $targetDir . $safeFileName;

        if (!move_uploaded_file($fileInfo["tmp_name"], $targetPath)) {
            $returnArr = [
                "ResponseCode" => "404",
                "Result" => "false",
                "ResponseMsg" => "Unable to save the uploaded file.",
            ];
        } else {
            $filePath = "uploads/tenally_scripts/" . $safeFileName;
            $escapedName = mysqli_real_escape_string($evmulti, $name);
            $escapedEmail = mysqli_real_escape_string($evmulti, $email);
            $escapedTitle = mysqli_real_escape_string($evmulti, $title);
            $escapedOriginal = mysqli_real_escape_string($evmulti, $originalName);
            $escapedFilePath = mysqli_real_escape_string($evmulti, $filePath);
            $escapedExtension = mysqli_real_escape_string($evmulti, $extension);

            $sql = "INSERT INTO tenally_script_submissions 
                (user_id, name, email, script_title, file_name, file_path, file_type, status, created_at) 
                VALUES 
                ($userId, '$escapedName', '$escapedEmail', '$escapedTitle', '$escapedOriginal', '$escapedFilePath', '$escapedExtension', 'Pending', NOW())";

            if ($evmulti->query($sql)) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "ResponseMsg" => "Script submitted successfully.",
                    "SubmissionId" => $evmulti->insert_id,
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "500",
                    "Result" => "false",
                    "ResponseMsg" => "Database error.",
                ];
            }
        }
    }
}

echo json_encode($returnArr);
