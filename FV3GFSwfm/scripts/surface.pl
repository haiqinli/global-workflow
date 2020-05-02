#!/usr/bin/perl
#

use strict;
my $DEBUG=1;
#
# set up to call locally (from the command prompt)


my $data_source = $ARGV[0];
my $start_time = $ARGV[1];
my $end_time = $ARGV[2];
my $thisDir = $ARGV[3];
my $logDir = $ARGV[4];
my $FV3GFS_RUN = $ARGV[5];
my $FV3GFS_SURFACE = $ARGV[6];
my $PSLOT = $ARGV[7];
my $CDUMP = $ARGV[8];

my $qsubbed=1;
unless($thisDir) {
    # we've been called locally instead of qsubbed
    $qsubbed=0;
    use File::Basename;
    my ($basename,$thisDir2) = fileparse($0);
    $thisDir = $thisDir2;
}
my $output_id = $ENV{SLURM_JOB_ID} || $$;

#change to the proper directory
use Cwd 'chdir'; #use perl version so this isn't unix-dependent
chdir ("$thisDir") ||
          die "Content-type: text/html\n\nCan't cd to $thisDir: $!\n";

print "Xue current path is $thisDir\n";




use Time::Local;
use DBI;

$|=1;  #force flush of buffers after each print
open (STDERR, ">&STDOUT") || die "can't dup stdout ($!)\n";
$ENV{'PATH'}="/bin";
$ENV{CLASSPATH} =
    "/misc/ihome/moninger/javalibs/mysql/mysql-connector-java-3.1.13-bin.jar:".
    ".";

$SIG{ALRM} = \&my_timeout;
my %month_num = (Jan => 1, Feb => 2, Mar => 3, Apr => 4, May => 5, Jun => 6,
                 Jul => 7, Aug => 8, Sep => 9, Oct =>10, Nov =>11, Dec =>12);

my $start_secs = time();
$ENV{'TZ'}="GMT";
my ($aname,$aid,$alat,$alon,$aelev,@description);
my ($found_airport,$lon,$lat,$lon_lat,$time);
my ($location);
my ($startSecs,$endSecs);
my ($file,$type,$fcst_len,$elev,$name,$id,$data,$bad_data);
my ($good_data,$found_sounding_data,$maps_coords,$title,$logFile);
my ($dist,$dir,$differ);
my ($loaded_soundings);
my $n_zero_ceilings=0;;
my $n_stations_loaded=0;



use lib "./";
require "./jy2mdy.pl";
require "./update_sfc_summaries.pl";
require "./get_grid.pl";

#my $data_source = $ARGV[0];
#my $start_time = $ARGV[1];
#my $end_time = $ARGV[2];
#my $startSecs = $ARGV[1];
#my $endSecs = $ARGV[2];
# xue

print "find start and end seconds\n";
my $year = substr($start_time,0,2);
my $day_of_year = substr($start_time,2,3);
my $shour =  substr($start_time,-2);

(my $in_wday, my $in_mday,my $in_month, my $in_year ) = jy2mdy($day_of_year,$year);

my $eyear = substr($end_time,0,2);
my $eday_of_year = substr($end_time,2,3);
my $ehour =  substr($end_time,-2);

(my $e_wday, my $e_mday,my $e_month, my $e_year ) = jy2mdy($eday_of_year,$eyear);



my $startSecs=timegm(0,0,$shour,$in_mday,$in_month,$in_year);
my $endSecs=timegm(0,0,$ehour,$e_mday,$e_month,$e_year);

print "startSecs = $startSecs\n";
print "endSecs = $endSecs\n";


# end of xue
print "connect to database\n";
my $reprocess=0;
if(defined $ARGV[4] && $ARGV[4] > 0) {
    $reprocess=1;
}
$ENV{DBI_DSN} = "DBI:mysql:madis3:host=137.75.133.134;port=3306";
$ENV{DBI_USER} = "sfc_retro";
$ENV{DBI_PASS} = "EricHaidao";
my $dbh = DBI->connect(undef,undef,undef, {RaiseError => 1});
my $query;

#$thisDir = $ENV{PWD};  

print "output file stuff\n";
print "qsubbed = $qsubbed\n";
if($qsubbed == 1) {
    my $output_file = "$logDir/verif/$data_source.sfc_drq.$output_id.out";
    print "output = $output_file\n";
# send standard out (and stderr) to $output_File
    use IO::Handle;
    *STDERR = *STDOUT;          # send standard error to standard out
    open (OUTPUT, '+>',"$output_file") or die $!;
    STDOUT->fdopen( \*OUTPUT, 'w' ) or die $!; # send stdout to output file
}
# see if we should use the obs_retro table for obs
my $res = $dbh->selectrow_array("select max(time) from obs_retro where time >= $startSecs and time <= $endSecs");
my $retro_flag = 1;
unless($res) {
  # no obs found for the time period in the retro table. Assuming realtime
  $retro_flag = 0;
  print "No obs in the retro database for this run. Assuming realtime\n";
}
print "retro_flag is $retro_flag\n";

my $db_machine = "137.75.133.134";
my $db_name = "madis3";
my $tmp_file = "$logDir/verif/${data_source}.$$.tmp";
my $data_file = "$logDir/verif/${data_source}.$$.data";
my $data_1f_file = "$logDir/verif/${data_source}.$$.data_1f";
my $coastal_file = "$logDir/verif/${data_source}.$$.coastal";
my $coastal_station_file = "$logDir/verif/${data_source}.$$.coastal_stations";

my @regions;
my @fcst_lens;
my $WRF;
@regions = qw[ALL_RR1 ALL_RUC E_RUC W_RUC ALL_HRRR E_HRRR W_HRRR AK Global HWT NHX_E NHX_W NHX SHX TRO];
#@fcst_lens = (0,12,24,36,48,72,96,120);
@fcst_lens = (0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,102,108,114,120);

# see if the needed tables exist
$dbh->do("use madis3");
$query = qq(show tables like "${data_source}qp");
my $result = $dbh->selectrow_array($query);
print "$query\n";

unless($result) {
    print "create needed tables\n";
    $query = "create table madis3.${data_source}qp like madis3.FIM_4qp";
    $dbh->do($query);
    print "create p\n";
    $query = "create table madis3.${data_source}qp1f like madis3.FIM_4qp1f";
    $dbh->do($query);
    print "create p1f\n";
    $query = "create table madis3.${data_source}_coastal5 like madis3.FIM_4_coastal5";
    $dbh->do($query);
    print "create coastal\n";
    $query = "create table madis3.stations_${data_source}_coastal5 ".
        "like madis3.stations_FIM_4_coastal5";
    $dbh->do($query);
    $dbh->do("use surface_sums2");
    print "create sum tables\n";
    foreach my $region (@regions) {
       print "region = $region\n";
       my $table = "${data_source}_metar_v2_${region}";
       $query = qq(create table $table like FIM_4_metar_v2_ALL_HRRR);
       print "$query\n";
       $dbh->do($query);
    }
}

$WRF=1;
#for(my $valid_time=$startSecs;$valid_time<=$endSecs;$valid_time+=1*3600) {
for(my $valid_time=$startSecs;$valid_time<=$endSecs;$valid_time+=12*3600) {
foreach my $fcst_len (@fcst_lens) {
my $valid_str = gmtime($valid_time);
my $run_time = $valid_time - $fcst_len * 3600;
my $valid_date = sql_datetime($valid_time);
my ($dym,$dym,$hour,$mday,$month,$year,$wday,$yday) =
    gmtime($run_time);
my $jday=$yday+1;

if($reprocess == 0 &&
   already_processed($data_source,$valid_time,$fcst_len,$regions[0],$DEBUG)) {
    print "\nALREADY LOADED: $data_source $fcst_len h fcst valid at $valid_str\n";
    next;
} else {
    print "\nTO PROCESS: $fcst_len h fcst valid at $valid_str\n";
}

my $start = "";                 # not looking for 'latest'

    my $dir = sprintf("$FV3GFS_RUN/$PSLOT/$CDUMP.%4d%2.2d%2.2d/%2.2d/",
                    $year+1900,$month+1,$mday,$hour);

my $base_file;
#if($fcst_len == 0) {
#    $base_file = sprintf("wrfprs_rr_%02d.al00",$fcst_len);
#} else {
#    $base_file = sprintf("wrfprs_rr_%02d.grib1",$fcst_len);
#}

#$base_file = sprintf("%02d%03d%02d%02d%01d%03d",$year+1900-2000,$yday+1,$hour,0,0,$fcst_len);
$base_file = sprintf("$CDUMP.t%02dz.pgrb2.0p50.f%03d",$hour,$fcst_len);

$file = "$dir/$base_file";

my($run_year,$run_month_num,$run_mday,$run_hour,$run_fcst_len);

unless(-r $file) {
    print "file $file not found for $data_source $fcst_len h fcst valid at $valid_str.\n";
    next;
} else {
    print "FILE FOUND $data_source $fcst_len h fcst valid at $valid_str\n";
}
# get grid details
my($la1,$lo1,$lov,$latin1,$nx,$ny,$dx,$grib_type,$grid_type,$valid_date_from_file,$fcst_proj)
    = get_grid($file,$thisDir,$DEBUG);
# change 'undef' to zeros for use in the $arg_unsafe argument list
$la1+=0;
$lo1+=0;
$lov+=0;
$latin1+=0;
$nx+=0;
$ny+=0;
$dx+=0;
if(1) {
    print "grib_type is $grib_type. |$la1| |$lo1| |$lov| |$latin1| ".
        "|$nx| |$ny| |$dx|\n";
    print ("valid times from get_grid: $valid_date_from_file,$fcst_proj\n");
}
if($valid_date_from_file != $valid_date) {
    print "BAD VALID DATE from file: $valid_date_from_file\n";
    exit(1);
}
my $arg_unsafe;
#if($grib_type == 1 && $WRF == 1) {
if($WRF == 1) {
    $arg_unsafe = "${FV3GFS_SURFACE} ".
        "$data_source $valid_time $file $grib_type $fcst_len ".
        "$la1 $lo1 $lov $latin1 $dx ".
        "$nx $ny 1 $retro_flag ".
        "$tmp_file $data_file $data_1f_file $coastal_file $coastal_station_file ".
        "$DEBUG";
    $arg_unsafe =~ /([a-zA-Z0-9\.\/\~\_\-\, ]*)/;
    my $arg = $1;
    if($DEBUG) {
        print "arg is $arg\n";
    }
    open(CEIL,"$arg |") ||
        die "cannot execute $arg: $!";
    while(<CEIL>) {
        if($DEBUG) {print;}
        if(/(\d+) stations loaded/) {
            $n_stations_loaded = $1;
        }
    }
    print "zeros: $n_zero_ceilings, loaded: $n_stations_loaded\n";
    close CEIL;
    my $exit_code = $? >> 8;
    if($exit_code != 0) {
        printf("\n\nTROUBLE EXECUTING $arg\n");
        printf("exit code is $exit_code\n");
        #exit($exit_code);
    }
}
if($n_stations_loaded > 0) {
    foreach my $region (@regions) {
        my $valid_time_string = gmtime($valid_time);
        print "GENERATING SUMMARIES for $data_source,$valid_time_string,$fcst_len,$region\n";
        update_sfc_summaries($data_source,$valid_time,$fcst_len,$region,
                                $retro_flag,$dbh,$db_name,0);
    }
} else {
    print "NOT GENERATING SUMMARIES\n\n";
}
}}

#finish up
$dbh->disconnect();

# clean up tmp directory
#opendir(DIR,"tmp") ||
#    die "cannot open tmp/: $!\n";
#my @allfiles = grep !/^\.\.?$/,readdir DIR;
#foreach my $file (@allfiles) {
#    $file = "tmp/$file";
#    #print "file is $file\n";
#    # untaint
#    $file =~ /(.*)/;
#    $file = $1;
#    if(-M $file > 1) {
#        print "unlinking $file\n";
#        unlink "$file" || print "Can't unlink $file $!\n";
#    }
#}
#closedir DIR;
#unlink($tmp_file) ||
#    print "could not unlink $tmp_file: $!";
#unlink($data_file) ||
#    print "could not unlink $data_file: $!";
#unlink($data_1f_file) ||
#    print "could not unlink $data_1f_file: $!";
#unlink($coastal_file) ||
#    print "could not unlink $coastal_file: $!";
#unlink($coastal_station_file) ||
#    print "could not unlink $coastal_station_file: $!";

my $end_secs = time();
my $diff_secs = $end_secs - $start_secs;
print "NORMAL TERMINATION after $diff_secs secs\n";


sub already_processed {
    my ($data_source,$valid_time,$fcst_len,$region,$DEBUG) = @_;
    my $sec_of_day = $valid_time%(24*3600);
    my $desired_hour = $sec_of_day/3600;
    my $desired_valid_day = $valid_time - $sec_of_day;
    my $query =<<"EOI"
select count(*) from surface_sums2.${data_source}_metar_v2_${region}
where valid_day = $desired_valid_day and hour = $desired_hour and fcst_len = $fcst_len
EOI
;
    #if($DEBUG) {print "query is $query\n";}
        my $sth = $dbh->prepare($query);
    $sth->execute();
    my($n);
    $sth->bind_columns(\$n);
    $sth->fetch();
    $sth->finish();
    # for debugging:
    #$n=0;
    #print "n returned is $n\n";
    return $n;
}
