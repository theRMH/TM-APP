<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
define('DATE_FORMAT', 'g:i A');
define('NEW_FORMAT', 'D ,M d');
// Decode input and supply safe defaults. Allow guest uid = 0 and make lats/longs optional.
$data = json_decode(file_get_contents("php://input"), true);
$uid = isset($data["uid"]) ? (string)$data["uid"] : '';
$lats = isset($data["lats"]) && $data["lats"] !== '' ? (float)$data["lats"] : null;
$longs = isset($data["longs"]) && $data["longs"] !== '' ? (float)$data["longs"] : null;

// Require uid to be present (empty string = missing). Accept uid '0' as guest.
if ($uid === '') {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Missing uid",
    ];
} else {
    $cp = [];
    $d = [];
    $pop = [];
   $popss = [];
    $cato = $evmulti->query("select * from tbl_category where status=1");
    $cat = [];
    while ($row = $cato->fetch_assoc()) {
        $cat["id"] = $row["id"];
        $cat["title"] = $row["title"];
        $cat["cat_img"] = $row["img"];
        $cat["cover_img"] = $row["cover"];
        $cat["total_event"] = $evmulti->query(
            "select * from tbl_event where event_status='Pending'"
        )->num_rows;
        $cp[] = $cat;
    }

    $event = $evmulti->query(
        "select id,title,img,place_name,sdate,stime,etime from tbl_event
 where event_status='Pending'
  and status=1 order by sdate desc"
    );
    $ev = [];
    while ($row = $event->fetch_assoc()) {
        $ev["event_id"] = $row["id"];
        $ev["event_title"] = $row["title"];
        $ev["event_img"] = $row["img"];
        $date = date_create($row["sdate"]);
        $ev["event_sdate"] =
            date_format($date, NEW_FORMAT) .
            "-" .
            date(DATE_FORMAT, strtotime($row["stime"])) .
            "-" .
            date(DATE_FORMAT, strtotime($row["etime"]));
        $ev["event_place_name"] = $row["place_name"];
        $d[] = $ev;
    }

    $event = $evmulti->query(
        "select id,title,img,place_name,sdate,stime,etime from tbl_event
 where event_status='Pending'
  and status=1 order by sdate desc"
    );
    $ev = [];
    while ($row = $event->fetch_assoc()) {
        $ev["event_id"] = $row["id"];
        $ev["event_title"] = $row["title"];
        $ev["event_img"] = $row["img"];
        $date = date_create($row["sdate"]);
        $ev["event_sdate"] =
            date_format($date, NEW_FORMAT) .
            "-" .
            date(DATE_FORMAT, strtotime($row["stime"])) .
            " TO " .
            date(DATE_FORMAT, strtotime($row["etime"]));
        $ev["event_place_name"] = $row["place_name"];
        $pop[] = $ev;
    }
    $month = date("m");
    $year = date("Y");
    $events = $evmulti->query(
        "select id,title,img,place_name,sdate,stime,etime from tbl_event
 where event_status='Pending'
  and status=1 and MONTH(sdate) = '" .
            $month .
            "' and YEAR(sdate) = '" .
            $year .
            "' order by sdate desc"
    );
    $ev = [];
    $pops = [];
    while ($row = $events->fetch_assoc()) {
        $ev["event_id"] = $row["id"];
        $ev["event_title"] = $row["title"];
        $ev["event_img"] = $row["img"];
        $date = date_create($row["sdate"]);
        $ev["event_sdate"] =
            date_format($date, NEW_FORMAT) .
            "-" .
            date(DATE_FORMAT, strtotime($row["stime"])) .
            "-" .
            date(DATE_FORMAT, strtotime($row["etime"]));
        $ev["event_place_name"] = $row["place_name"];
        $pops[] = $ev;
    }

    if ($lats === null || $longs === null) {
        // No location provided (guest or missing). Return nearby list ordered by date instead.
        $eventlists = $evmulti->query(
            "select id,title,img,place_name,sdate,stime,etime,latitude,longtitude from tbl_event where status=1 and event_status='Pending' order by sdate desc"
        );
    } else {
        $eventlists = $evmulti->query(
            "SELECT (((acos(sin((" . $lats . "*pi()/180)) * sin((`latitude`*pi()/180))+cos((" . $lats . "*pi()/180)) * cos((`latitude`*pi()/180)) * cos(((" . $longs . "-`longtitude`)*pi()/180))))*180/pi())*60*1.1515*1.609344) as distance,id,title,img,place_name,sdate,stime,etime,latitude,longtitude FROM tbl_event where status=1 and event_status='Pending' order by distance"
        );
    }
    $evs = [];
    while ($row = $eventlists->fetch_assoc()) {
        $evs["event_id"] = $row["id"];
        $evs["event_title"] = $row["title"];
        $evs["event_img"] = $row["img"];
        $date = date_create($row["sdate"]);
        $evs["event_sdate"] =
            date_format($date, NEW_FORMAT) .
            "-" .
            date(DATE_FORMAT, strtotime($row["stime"])) .
            "-" .
            date(DATE_FORMAT, strtotime($row["etime"]));
        $evs["event_place_name"] = $row["place_name"];
        $evs["event_latitude"] = (isset($row["latitude"]) && is_numeric($row["latitude"])) ? (float)$row["latitude"] : "";
        $evs["event_longtitude"] = (isset($row["longtitude"]) && is_numeric($row["longtitude"])) ? (float)$row["longtitude"] : "";
        $popss[] = $evs;
    }

    $pols = [];
    $main_data = $evmulti->query("select * from tbl_setting")->fetch_assoc();
    $pols["id"] = $main_data["id"];
    $pols["currency"] = $main_data["currency"];
    $pols["scredit"] = $main_data["scredit"];
    $pols["rcredit"] = $main_data["rcredit"];
    $pols["tax"] = $main_data["tax"];

    $tbwallet = $evmulti
        ->query("select wallet from tbl_user where id=" . $uid . "")
        ->fetch_assoc();
    if ($uid == 0) {
        $wallet = 0;
    } else {
        $wallet = $tbwallet["wallet"];
    }

    $featured = null;
    $featuredRow = $evmulti
        ->query("SELECT * FROM `tbl_featured_event` ORDER BY id DESC LIMIT 1")
        ->fetch_assoc();
    if ($featuredRow) {
        $featureType = $featuredRow["type"] ?? "event";
        $eventPlace = "";
        $eventDate = "";
        $title = $featuredRow["title"] ?? "";
        $description = $featuredRow["description"] ?? "";
        $image = $featuredRow["image"] ?? "";
        if ($featureType === "event" && !empty($featuredRow["event_id"])) {
            $eventRecord = $evmulti
                ->query(
                    "select title,img,place_name,sdate,stime,etime from tbl_event where id=" .
                        intval($featuredRow["event_id"])
                )
                ->fetch_assoc();
            if ($eventRecord) {
                $eventPlace = $eventRecord["place_name"];
                $eventDate =
                    date_format(
                        date_create($eventRecord["sdate"]),
                        NEW_FORMAT
                    ) .
                    "-" .
                    date(DATE_FORMAT, strtotime($eventRecord["stime"])) .
                    "-" .
                    date(DATE_FORMAT, strtotime($eventRecord["etime"]));
                if (empty($image)) {
                    $image = $eventRecord["img"];
                }
                if (empty($title)) {
                    $title = $eventRecord["title"];
                }
                if (empty($description)) {
                    $description = trim($eventPlace . " • " . $eventDate);
                }
            }
        } elseif (
            $featureType === "page" &&
            !empty($featuredRow["page_id"])
        ) {
            $pageRecord = $evmulti
                ->query(
                    "select title,description from tbl_page where id=" .
                        intval($featuredRow["page_id"])
                )
                ->fetch_assoc();
            if ($pageRecord) {
                if (empty($title)) {
                    $title = $pageRecord["title"];
                }
                if (empty($description)) {
                    $description = $pageRecord["description"];
                }
            }
        }
        $featured = [
            "type" => $featureType,
            "event_id" => $featuredRow["event_id"] ?? "",
            "page_id" => $featuredRow["page_id"] ?? "",
            "title" => $title,
            "description" => $description,
            "button_title" => $featuredRow["button_title"] ?? "",
            "pill_name" => $featuredRow["pill_name"] ?? "",
            "image" => $image,
            "status" => intval($featuredRow["status"] ?? 1),
            "event_place_name" => $eventPlace,
            "event_sdate" => $eventDate,
        ];
    }

    $kp = [
        "Catlist" => $cp,
        "Main_Data" => $pols,
        "latest_event" => $d,
        "wallet" => $wallet,
        "upcoming_event" => $pop,
        "nearby_event" => $popss,
        "this_month_event" => $pops,
        "featured" => $featured,
    ];

    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Home Data Get Successfully!",
        "HomeData" => $kp,
    ];
}
echo json_encode($returnArr);
