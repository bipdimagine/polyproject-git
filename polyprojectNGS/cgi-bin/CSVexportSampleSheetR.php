<?
  $time = time();
  $name = "SampleSheet_" . $_POST['name']."_".$time;
  header("Pragma: public");
  header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
  header("Content-type: application/csv;charset=utf-8");
  header("Content-Disposition: attachment; filename=$name.csv");
  $today = date("j/n/Y");
  $header = "[Header]"."\r\n"."IEMFileVersion,4"."\r\n"."Date,".$today."\r\n"."Workflow,GenerateFASTQ"."\r\n"."Application,HiSeq FASTQ Only"."\r\n"."Assay"."\r\n"."Description"."\r\n"."Chemistry,Default"."\r\n".""."\r\n"."[Reads]"."\r\n"."101"."\r\n"."101"."\r\n".""."\r\n"."[Settings]"."\r\n"."ReverseComplement,0"."\r\n".""."\r\n"."[Data]"."\r\n";
  $exportedData = $_POST['exp'];
  echo $header;
  echo $exportedData;
?>
