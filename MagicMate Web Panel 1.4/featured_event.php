<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
require "filemanager/evconfing.php";
if (!isset($_SESSION["evename"]) || ($_SESSION["stype"] ?? "") !== "mowner") {
    header("Location: dashboard.php");
    exit;
}
include "filemanager/head.php";
$featuredRow = $evmulti->query("SELECT * FROM `tbl_featured_event` ORDER BY id DESC LIMIT 1")->fetch_assoc();
$featuredId = $featuredRow["id"] ?? "";
$featuredType = $featuredRow["type"] ?? "event";
$featuredEventId = $featuredRow["event_id"] ?? "";
$featuredPageId = $featuredRow["page_id"] ?? "";
$featuredTitle = $featuredRow["title"] ?? "";
$featuredDescription = $featuredRow["description"] ?? "";
$featuredButton = $featuredRow["button_title"] ?? "";
$featuredPill = $featuredRow["pill_name"] ?? "";
$featuredImage = $featuredRow["image"] ?? "";
$selectEvents = $evmulti->query(
    "SELECT id,title FROM `tbl_event` WHERE status=1 AND event_status='Pending' ORDER BY sdate DESC"
);
$selectPages = $evmulti->query(
    "SELECT id,title FROM `tbl_page` WHERE status=1 ORDER BY id DESC"
);
?>
<!-- Page Wrapper Start-->
<!-- loader ends-->
<div class="tap-top"><i data-feather="chevrons-up"></i></div>
<div class="page-wrapper compact-wrapper" id="pageWrapper">
   <!-- Page Header Start-->
   <?php include "filemanager/navbar.php"; ?>
   <!-- Page Header Ends-->
   <div class="page-body-wrapper">
      <?php include "filemanager/sidebar.php"; ?>
      <div class="page-body">
         <div class="container-fluid">
            <div class="page-title">
               <div class="row">
                  <div class="col-sm-6">
                     <h3>Featured Section</h3>
                  </div>
               </div>
            </div>
         </div>
         <div class="container-fluid">
            <div class="row">
               <div class="col-12">
                  <div class="card">
                     <div class="card-body">
                        <form id="featuredForm" class="theme-form" method="post" enctype="multipart/form-data">
                           <input type="hidden" name="type" value="save_featured_event">
                           <input type="hidden" name="featured_id" value="<?php echo $featuredId; ?>">
                           <input type="hidden" name="existing_image" value="<?php echo htmlspecialchars($featuredImage); ?>">
                           <div class="row">
                              <div class="col-lg-6">
                                 <div class="mb-3">
                                    <label class="form-label">Featured Type</label>
                                    <select class="form-control" name="featured_type" required>
                                       <option value="event" <?php echo $featuredType === "event" ? "selected" : ""; ?>>Event</option>
                                       <option value="page" <?php echo $featuredType === "page" ? "selected" : ""; ?>>Custom Page</option>
                                    </select>
                                 </div>
                                 <div class="mb-3" id="event-select">
                                    <label class="form-label">Select Event</label>
                                    <select class="form-control" name="event_id">
                                       <option value="">Choose event</option>
                                       <?php while ($row = $selectEvents->fetch_assoc()) { ?>
                                          <option value="<?php echo $row["id"]; ?>" <?php echo $row["id"] == $featuredEventId ? "selected" : ""; ?>><?php echo htmlspecialchars($row["title"]); ?></option>
                                       <?php } ?>
                                    </select>
                                    <small class="text-muted">Only one event can be highlighted at a time.</small>
                                 </div>
                                 <div class="mb-3" id="page-select">
                                    <label class="form-label">Custom Page</label>
                                    <select class="form-control" name="page_id">
                                       <option value="">Choose page</option>
                                       <?php while ($row = $selectPages->fetch_assoc()) { ?>
                                          <option value="<?php echo $row["id"]; ?>" <?php echo $row["id"] == $featuredPageId ? "selected" : ""; ?>><?php echo htmlspecialchars($row["title"]); ?></option>
                                       <?php } ?>
                                    </select>
                                    <small class="text-muted">When a page is selected, the app will navigate to that page instead of an event.</small>
                                 </div>
                                 <div class="mb-3">
                                    <label class="form-label">Special Image</label>
                                    <input class="form-control" type="file" name="featured_image">
                                    <?php if (!empty($featuredImage)) { ?>
                                       <div class="mt-3">
                                          <img src="<?php echo $base . '/' . $featuredImage; ?>" alt="Featured" class="img-thumbnail" style="max-height: 140px;">
                                       </div>
                                    <?php } ?>
                                    <small class="text-muted">Optional. Falls back to the event image when blank.</small>
                                 </div>
                              </div>
                              <div class="col-lg-6">
                                 <div class="mb-3">
                                    <label class="form-label">Pill Label</label>
                                    <input class="form-control" type="text" name="pill_name" value="<?php echo htmlspecialchars($featuredPill); ?>">
                                    <small class="text-muted">Text that appears in the pill. Defaults to "Featured Event".</small>
                                 </div>
                                 <div class="mb-3">
                                    <label class="form-label">Banner Title</label>
                                    <input class="form-control" type="text" name="title" value="<?php echo htmlspecialchars($featuredTitle); ?>">
                                    <small class="text-muted">Leave blank to use the event or page title.</small>
                                 </div>
                                 <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea class="form-control" rows="4" name="description"><?php echo htmlspecialchars($featuredDescription); ?></textarea>
                                    <small class="text-muted">Optional subtitle (fallbacks to location/time or page content).</small>
                                 </div>
                                 <div class="mb-3">
                                    <label class="form-label">Button Title</label>
                                    <input class="form-control" type="text" name="button_title" value="<?php echo htmlspecialchars($featuredButton); ?>">
                                    <small class="text-muted">Leave blank to show the default "Explore Event".</small>
                                 </div>
                              </div>
                           </div>
                       <div class="text-end">
                           <button class="btn btn-secondary me-2" type="button" id="resetFeatured">Reset Section</button>
                           <button class="btn btn-primary" type="submit">Save Featured Event</button>
                       </div>
                    </form>
                 </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
   </div>
</div>
<?php include "filemanager/script.php"; ?>
<script>
   (function () {
      var typeField = $('select[name="featured_type"]');
      function toggleBlock() {
         if (typeField.val() === 'page') {
            $('#event-select').hide();
            $('#page-select').show();
         } else {
            $('#event-select').show();
            $('#page-select').hide();
         }
      }
      typeField.on('change', toggleBlock);
      toggleBlock();
   })();
</script>
<script>
  $('#resetFeatured').on('click', function () {
    if (!confirm('Resetting will remove the current featured configuration and fall back to the default event. Continue?')) {
      return;
    }
    $.ajax({
      url: '<?php echo $base; ?>/filemanager/manager.php',
      method: 'POST',
      data: {
        type: 'reset_featured_event',
      },
      dataType: 'json',
    }).done(function (res) {
      if (res && res.Result == 'true') {
        alert(res.message || 'Featured section reset.');
        window.location.reload();
      } else {
        alert(res.message || res.title || 'Reset failed.');
      }
    }).fail(function () {
      alert('Server error while resetting featured section.');
    });
  });
</script>
</body>
</html>
