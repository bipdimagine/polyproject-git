<?
  $time = time();
  header("Pragma: public");
  header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
  header("Content-type: application/csv;charset=utf-8");
  header("Content-Disposition: attachment; filename=gridCSV_$time.csv");
  $exportedData = $_POST['exp'];
  echo $exportedData;
?>
