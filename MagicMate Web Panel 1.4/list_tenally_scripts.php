<?php
include "filemanager/head.php"; ?>
<!-- loader ends-->
<!-- tap on top starts-->
<div class="tap-top"><i data-feather="chevrons-up"></i></div>
<!-- tap on tap ends-->
<!-- page-wrapper Start-->
<div class="page-wrapper compact-wrapper" id="pageWrapper">
   <!-- Page Header Start-->
   <?php include "filemanager/navbar.php"; ?>
   <!-- Page Header Ends                              -->
   <!-- Page Body Start-->
   <div class="page-body-wrapper">
      <!-- Page Sidebar Start-->
      <?php include "filemanager/sidebar.php"; ?>
      <!-- Page Sidebar Ends-->
      <div class="page-body">
         <div class="container-fluid">
            <div class="page-title">
               <div class="row">
                  <div class="col-6">
                     <h3>Tenally Script Submissions</h3>
                  </div>
                  <div class="col-6">
                  </div>
               </div>
            </div>
         </div>
         <!-- Container-fluid starts-->
         <div class="container-fluid">
            <div class="row size-column">
               <div class="col-sm-12">
                  <div class="card">
                     <div class="card-body">
                        <div class="table-responsive">
                           <table class="display" id="basic-1">
                              <thead>
                                 <tr>
                                    <th>Sr No.</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Script Title</th>
                                    <th>Submitted On</th>
                                    <th>File</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                 </tr>
                              </thead>
                              <tbody>
                                 <?php
                                    $results = $evmulti->query("SELECT * FROM tenally_script_submissions ORDER BY id DESC");
                                    $counter = 0;
                                    while ($row = $results->fetch_assoc()) {
                                        $counter++;
                                        ?>
                                 <tr>
                                    <td><?php echo $counter; ?></td>
                                    <td><?php echo $row["name"]; ?></td>
                                    <td><?php echo $row["email"]; ?></td>
                                    <td><?php echo $row["script_title"]; ?></td>
                                    <td><?php echo date("d M Y, h:i A", strtotime($row["created_at"])); ?></td>
                                    <td>
                                       <a class="badge badge-info" target="_blank" href="<?php echo $row["file_path"]; ?>">Download</a>
                                    </td>
                                    <td>
                                       <?php if ($row["status"] === "Pending") { ?>
                                          <span class="badge badge-danger">Pending</span>
                                       <?php } else { ?>
                                          <span class="badge badge-success"><?php echo $row["status"]; ?></span>
                                       <?php } ?>
                                    </td>
                                    <td>
                                       <a class="badge badge-primary" target="_blank" href="<?php echo $row["file_path"]; ?>">View</a>
                                    </td>
                                 </tr>
                                 <?php } ?>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
         <!-- Container-fluid Ends-->
      </div>
      <!-- footer start-->
   </div>
</div>
<?php include "filemanager/script.php"; ?>
<!-- Plugin used-->
</body>
</html>
