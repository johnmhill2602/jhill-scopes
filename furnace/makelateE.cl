!rm ftsE
!ls -1tr /net/crater/d1/pilot/video/lsst*e.fts | awk '/lsst0264e.fts/, /EOF/' > ftsE
!rm *e.gif
fexport @ftsE
!rm gifE
!ls -1 *e.gif > gifE
!mpeg_encode LSST_lateE.param
