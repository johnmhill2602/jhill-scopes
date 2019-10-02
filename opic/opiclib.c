#include <vcstdio.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include <time.h>
#include <bios.h>
#include <process.h>
#include <string.h>
#include <fcntl.h>          /* O_ constant definitions */
#include <sys\types.h>
#include <sys\stat.h>       /* S_ constant definitions */
#include <malloc.h>
#include <memory.h>
#include <errno.h>
#include <math.h>

#define INCROWS	16
#define NCOLS	512
#define NROWS	512

#include "mvregs.h"  /* MV1 register definitions */
#include "mvstruct.h"   /* Structures for VSC, LCA */
#include "mvmacro.h" /* Macro used in software libraries */
#include "struct.h"
#include "macro.h"
#include "param.h"   /* Parameter data types */
#include "mvboard.h"

#include "opic.h"

struct STROBE tmpstrobe[NUMSTROBES];
int last_active_strobes;
static unsigned char pix_array[NCOLS*INCROWS]; /* data array for a row or a column of image */
static unsigned char header_array[FITS_REC_SIZE];
static unsigned char nullfits[FITS_REC_SIZE];


int
getframe(d,t)
char *d;
char *t;
{
    char timestr[60];
    char temp[60];
    char strobes[10];
    int l_enabled= NO;
    
/* Number of microseconds after beginning of frame                         */
/* This needs to be changed with different shutter speeds on camera        */
/* Use program DELAY.C to experiment                                       */
    l_enabled= display[0].enabled;
    enable_dis(0);
    mv_view1(LIVE);                     /* Look at live video             */
    if (!l_enabled)
        disable_dis(0);
    acq_in_progress= YES;
    opic_loop();
    syspause(0,0,frame_delay,0);
    
	/* Set gate delay for odd field goes here */
    load_delay(delay.odd[camera[active_camera].shutter]);

    /* wait for strobe recharge goes here */
    while (!check_strobes()) {
        opic_loop();
        if (keyrdy() || (mgetone() != 0)) {
            if (getone() == ESC) {
                bell();
                acq_in_progress= NO;
                return(NO);
            }
        }
    }
    
    mmv_xferp(I_PLANE);                 /* frame aquisition routine to image plane */
    disable_strobes();
    mv_format1(I_PLANE);                /* Reformat so data can be read/write */
   
    /* Set gate delay for even field */
    load_delay(delay.even[camera[active_camera].shutter]);
 
    /* wait for strobe recharge goes here */
    while (!check_strobes()) {
        opic_loop();
        if (keyrdy() || (mgetone() != 0)) {
            if (getone() == ESC) {
                acq_in_progress= NO;
                bell();
                return(NO);
            }
        }
    }
   
    mmv_xferp(G_PLANE);                 /* frame aquisition routine to graphics plane */
    disable_strobes();
    acq_in_progress= NO;
    opic_loop();
    mv_format1(G_PLANE);
    
    combine();
    mv_bank(G_PLANE);                   /* Set frame bank for writing text    */
    mv_tsize(20,15);
    mv_textpos(10,476);
    strcpy(timestr," ");
    vcgetdat(temp);
    strcpy(d,temp);
    strcat(timestr,temp);
    vcgettim(temp);
    temp[8]= 0;
    strcpy(t,temp);
    temp[5]= 0;
    strcat(timestr," ");
    strcat(timestr,temp);
    sprintf(temp," Cam: %c ",(char) (active_camera+65));
    strcat(timestr,temp);
    strcpy(strobes,"    ");
    if (active_strobes & 0x08)
        strobes[0]= 'A';
        
    if (active_strobes & 0x10)
        strobes[1]= 'B';
        
    if (active_strobes & 0x20)
        strobes[2]= 'C';
        
    if (active_strobes & 0x40)
        strobes[3]= 'D';
    sprintf(temp," Fl: %s ",strobes);
    strcat(timestr,temp);
    mv_text(timestr);
    return(YES);
}

mmv_xferp(n)                     /* frame aquisition routine */
unsigned char  n;
{
   unsigned char  xreg= 0x82;
   unsigned char  pab=0;

   if(n == 1) xreg = 0x41;
   if(n == 2) xreg = 0x33;

   mv_setmv1("board1",5,00);        /* clear auxbit  added by TJB  */


   if (conf != NULL) {

      vsearch  pab |= (vp->vp)->impub;
      outp(base|MVPUB,pab);
      outp(base|VSCDU,8);     /* update by 2 lines */
      outp(base|VSCDU+2,conf->du>>8);
      outp(base|VSCCR1,conf->cr1&0xFF|0x41);
      /* update every other line, sam -> ram, update enable */
      outp(base|MVPUB,conf->pub&0xFF);
      outp(base|VSCCR1+2,conf->cr1>>8|0x07);
      /* vert interrupt enable, interlace enable, extsync enable */
      inp(base|VSCSR);  /* clear any existing interrupt */

      outp(base|VSCVI,0x80);  /* set VI to interrupt mid frame */
      outp(base|VSCVI+2,0x00);
      wait_vi();
          
      outp(base|VSCVI,0x00);  /* set VI to interrupt at start of frame */
      outp(base|VSCVI+2,0x00);
      wait_vi();

      outp(base|MVPUB,pab);
      outp(base|PUBIT|MVXFER,xreg); /* start acquisition window */
      outp(base|MVPUB,conf->pub&0xFF);

      outp(base|VSCVI,0x00);  /* set VI to interrupt at */
      outp(base|VSCVI+2,0x00);   /* start of frame */

      /* FLASH THE LAMP */
      trigger_strobes();

      /* Start delay one vertical sync pulse from MV1 */
      wait_vi();


      outp(base|VSCVI,(conf->veb-1)&0xFF);/* set VI to interrupt */
      outp(base|VSCVI+2,(conf->veb-1)>>8);/* at end of vert blank */
      wait_vi();

      outp(base|MVPUB,pab);
      outp(base|PUBIT|MVLUTC,conf->imlutc|0x40);   /* enable writes */
      outp(base|VSCCR1,conf->cr1&0xFF|0x41);


      outp(base|MVPUB,conf->pub&0xFF);
      outp(base|VSCVI,(conf->vsb-1)&0xFF);/* set VI to interrupt */
      outp(base|VSCVI+2,(conf->vsb-1)>>8);/* at start of vert blank */


      wait_vi();
      outp(base|MVPUB,pab);
      outp(base|PUBIT|MVLUTC,conf->imlutc);     /* disable writes */
      outp(base|VSCCR1,conf->cr1&0xFF|0x61);

      outp(base|MVPUB,conf->pub&0xFF);
      outp(base|VSCVI,(conf->veb-1)&0xFF);
      outp(base|VSCVI+2,(conf->veb-1)>>8);
      wait_vi();

      outp(base|MVPUB,pab);
      outp(base|PUBIT|MVLUTC,conf->imlutc|0x40);   /* enable writes */
      outp(base|VSCCR1,conf->cr1&0xFF|0x41); /* enable updates */

      outp(base|MVPUB,conf->pub&0xFF);
      outp(base|VSCVI,(conf->vsb)&0xFF); /* set VI to interrupt at */
      outp(base|VSCVI+2,(conf->vsb)>>8); /* end of vertical blank */
      wait_vi();
      
      /* DISABLE FLASH ! */
      disable_strobes();

      /* end of acquisition, reset to board1 defaults */
      outp(base|MVPUB,pab);
      outp(base|PUBIT|MVLUTC,conf->imlutc);
      outp(base|VSCCR1+2,conf->cr1>>8);
      inp(base|VSCSR);

      outp(base|VSCCR1,conf->cr1&0xFF);
      outp(base|PUBIT|MVXFER,conf->imxfer);
      outp(base|VSCDU,conf->du&0xFF);
      outp(base|VSCDU+2,conf->du>>8);

   }
}

/*  Routine to combine even and odd fields into one frame */
combine()
{
    int i,ibank; /* i=pixel index; ibank=0 for image bank */
         /* ibank=1 for graph bank */
    int ix,iy,length;     /* ix=image column index, 0-511, left to rightÿ*/
         /* iy=image row index, 0-511, top to bottom */
    int ipixv;      /* individual pixel value */

    length = 512;
   /* read even rows of image bank(0) and write to graphics bank(1) */
    for (iy = 0; iy<512;iy += 2 ) {
        opic_read_rc(I_PLANE,1,0,iy,length,pix_array);
        opic_writ_rc (G_PLANE,1,0,iy,length,pix_array);
    }

}

mv_begin()
{
			/* The initilization sequence is very important */
	mv_base();	/* read BASE.ADR and set the base address of MV1 */
	mv_intlev();	/* read INTR.LEV and set MV1 interrupt level */
	mv_param();	/* read PARAM.RUN and set parameter defaults */
   	mv_loadlca();	/* read DEFAULT.LCA and program the LCA */
    mv_resetaf();

	mv_lutinit();   /* read DEFAULT.LUT and initialize lookup tables */
	mv_sysinit();   /* read CONFIG.VSC and set configuration */
}

mv_check()
{

    int i;

    wclose(camera_stat_wdo);
    camera_stat_wdo_func();
    if (active_camera != -1)
        cam_select(active_camera,active_camera);

    /* make sure the boards are alive and kicking */
    mv_board(0);
    for (i=0; i<NUMBOARDS; i++) {
        wxatsay(camera_stat_wdo,3+i,34,"        ",vc.dflt); 
        if (board[i].ins == 1) {
            display[i].available= YES;
            enable_dis(i);
            if (board[i].err != 0) {
                board_err(i);
            } else {
                mv_fclear(I_PLANE);
                mv_fclear(G_PLANE);
                mv_view1(LIVE);
                wxatsay(camera_stat_wdo,3+i,14,"                 ",vc.dflt);
            }
        } else {
            board_err(i);
        }
    }
    
         
    /* load kernal, fonts and image processing support stuff */   
    mv_openfile("autofile");
    while (mv_readfile("autofile","\\\\","\\\\") != 0)
        ;

    for (i=0; i<NUMBOARDS; i++) {
        disable_dis(i);
        display[i].image= NO;
        display[i].saved= NO;
        display[i].plane= LIVE;
        saved[i].available= NO;
        saved[i].image= NO;
    }

}


wait_vi()
{
    while ((inp(base|VSCSR) & 1) == 0)
        ;
}

int getchr (value)
char *value;				/* value of received character */

/*	A subroutine callable from MS-DOS FORTRAN-77 that will attempt to
 *	read the COM1 serial input ports, determine if a character is
 *	avialable - retrieve it if there is - or try up to 32000 times if
 *	there isn't.  If a failure on the read is encoutered the error 
 *	flag is set and control returns to the caller.  If a character is
 * 	available it is read from the data port, the error flag is reset 
 *	and control is returned to the caller.
 *
 */
{
	long timeout;

	*value = 0;			/* reset character value */

	for (timeout = 0; timeout < MAXTIMEIN; timeout++)
	    if (inp (lsr[port_index]) & BFMASK) {	/* character available? */
	        *value = inp (rbr[port_index]);	/*  - yes! Get it */
		    return(YES);
	    }
	return(NO);				/* return to caller */
}


/*	A subroutine callable from MS-DOS FORTRAN-77 which will send a 
 *	passed MCP command out the COM1 (or COM2) serial port.  If an error
 *	is encountered during transmission - the proceedure is aborted and
 *	the error flag is set.  Subroutine verify's the transmission by
 *	waiting for the CTS wiggle.
 *
 */

int cmdout (cmd)
char	*cmd;				/* the command string array */
{
	int	ioerr;			/* internal I/O error flag for
					   function outchr */
	long timeout;		/* the retry counter */
	int	outchr (char);		/* a function to output characters */
	int	loop;			/* a loop counter for outputing 
					   characters of the command string */

	outp (mcr[port_index], RTSHIGH);		/* raise the RTS flag */


	for (loop = 0; loop < MAXCHARS; loop++) {
	    if (!outchr (cmd[loop]))
		    return(NO);
	    if ((int) cmd[loop] == 0)
            break;
	}

	return(YES);
}

/*	A function to send a character out the COM1 serial port.  
 *	The function returns an error only if it could not send the
 *	character.
 */

outchr (value)
char	value;

{
	long timer;			/* the retry counter */
	int	bval;

	bval = value;

	/* wait for transmitter to be emptied */

	for (timer = 0; timer < MAXTIMEOUT; timer++) 
	    if (inp (lsr[port_index]) & TEMASK) {
		    outp (thr[port_index], bval);	 	/* its empty - send char */
		    return(YES);
    }
	return (NO);
}


com_init(comport)
{

    _bios_serialcom(_COM_INIT,comport,_COM_CHR7 | _COM_STOP1 | _COM_ODDPARITY | _COM_9600);
   
    outp(mcr[port_index],3);     /* raise DTR and RTS */

}

int
cam_select(cam,audio)
int cam;
int audio;
{
    char cmd[10];

    if (!camera[cam].available || (camera[cam].selected && graphing)) {
        bell();
        return(NO);
    }
    
    reset_sel_cam();
    camera[cam].selected= YES;
    put_camera(camera[cam].cenx,camera[cam].ceny,SELCOLOR,(char) (cam+65));
    
    cmd[0]= 2;
    cmd[1]= '0';
    cmd[2]= '0';
    cmd[3]= cam+0x30;
    cmd[4]= audio+0x30;
    cmd[5]= 0;
    if (!cmdout(cmd)) {
        error_func(NULL,"Serial Command Communications Error - No Select Possible",NULL);
        return(NO);
    }

    sprintf(tempstr,"Camera %c",cam+65);
    wxatsay(camera_stat_wdo,1,14,tempstr,vc.white+vc.bold+(vc.bg*vc.cyan)); 
/*
    wxatsay(camera_stat_wdo,3,2,"Display 1:",vc.dflt);
    wxatsay(camera_stat_wdo,3,14,"Live (Selected)  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.cyan));
*/
    active_camera= cam;
    set_shutter(camera[cam].shutter);
    set_gain(camera[cam].gain);
    set_offset(camera[cam].offset);
    return(YES);
    
}


int
strobe_select(strob)
int strob;
{

    int strobe_mask;

    if (!strobe[strob].available) {
        bell();
        return(NO);
    }
    strobe_mask= ((1 << strob) << 3);

    if (!strobe[strob].selected) {
        strobe[strob].selected= YES;
        active_strobes|= strobe_mask;    
        put_strobe(strobe[strob].cenx,strobe[strob].ceny,SELCOLOR,(char) (strob+65));
    } else {
        strobe[strob].selected= NO;    
        active_strobes^= strobe_mask;
        put_strobe(strobe[strob].cenx,strobe[strob].ceny,NOSELCOLOR,(char) (strob+65));
    }
    
    out_port&= 0x87;
    out_port|= active_strobes;
    
    return(YES);
}

int
activate_cam(cam)
int cam;
{

    char cmd[10];


    if (camera[cam].selected) {
        bell();
        return(NO);
    }
    
    if (camera[cam].available) {
        camera[cam].available= NO;
        put_camera(camera[cam].cenx,camera[cam].ceny,NOTAVAIL,(char) (cam+65));
    } else {
        camera[cam].available= YES;
        put_camera(camera[cam].cenx,camera[cam].ceny,NOSELCOLOR,(char) (cam+65));
    }

    return(YES);
    
}


int
activate_strobe(strob)
int strob;
{


    if (strobe[strob].selected) {
        bell();
        return(NO);
    }

    if (strobe[strob].available) {
        strobe[strob].available= NO;
        put_strobe(strobe[strob].cenx,strobe[strob].ceny,NOTAVAIL,(char) (strob+65));
    } else {
        strobe[strob].available= YES;    
        put_strobe(strobe[strob].cenx,strobe[strob].ceny,NOSELCOLOR,(char) (strob+65));
    }
    
    return(YES);
}


void error_func(msg1,msg2,msg3)
char *msg1,*msg2,*msg3;
{
    COUNT error_wdo;
    COUNT center1,center2,center3;
      
    bell();

      
    error_wdo=wxxopen(3,0,10,79,"[ Error ]",
                      ACTIVE|BORDER|BD1|CENTER,
                      0,0,5,32);
    if (error_wdo == -1 ) {
        m_error();
    }
    
    if (msg1 != NULL) {
        center1= (76-strlen(msg1))/2;
        xatsay(1,center1,msg1,vc.white+vc.bold);
    }
      
    if (msg2 != NULL) {
        center2= (76-strlen(msg2))/2;
       xatsay(2,center2,msg2,vc.white+vc.bold);
    }
      
    if (msg3 != NULL) {
        center3= (76-strlen(msg3))/2;
        xatsay(3,center3,msg3,vc.white+vc.bold);
    }
      
    xatsay(5,24," Hit any key to continue . . .",vc.dflt);
    getone();
   
    wclose (error_wdo);
    return;
}


int
info_func(msg1,msg2,msg3)
char *msg1,*msg2,*msg3;
{
    COUNT info_wdo;
    COUNT center1,center2,center3;
    COUNT key;
      
    bell();

      
    info_wdo=wxxopen(3,0,10,79,"[ Confirm ]",
                      ACTIVE|BORDER|BD1|CENTER,
                      0,0,7,32);
    if (info_wdo == -1 ) 
        m_error();
    
    if (msg1 != NULL) {
        center1= (76-strlen(msg1))/2;
        xatsay(1,center1,msg1,vc.white+vc.bold);
    }
      
    if (msg2 != NULL) {
        center2= (76-strlen(msg2))/2;
       xatsay(2,center2,msg2,vc.white+vc.bold);
    }
      
    if (msg3 != NULL) {
        center3= (76-strlen(msg3))/2;
        xatsay(3,center3,msg3,vc.white+vc.bold);
    }
      
    xatsay(5,15," 'Y' key Confirms - any other key aborts . . .",vc.dflt);
    key= getone();
    wclose (info_wdo);

    if (toupper(key) != 'Y')
        return(NO);

    return(YES); 
}


COUNT
m_error(void)
{

    vcend(CLOSE);
    printf("\n Insufficent Memory - Program terminated.\n");
    exit(1);


}


#define CHARGING   "  Charging  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.red)
#define READY      "   Ready    ",vc.white+vc.bold+(vc.bg*vc.green)
#define NOTUSED    "Not Selected",vc.white+vc.bold+(vc.white*vc.bg)
#define NOTHERE    "Unavailable ",vc.black+(vc.white*vc.bg)
#define STANDBY    "  Standby   ",vc.white+vc.bold+vc.blink+(vc.bg*vc.white)
#define STROBE_MASK 0x78

COUNT
check_strobes()
{
   int strobe_status= 0;
   int ready_mask= 0xff;
   int charged;
   int i;
   
   strobe_status= (inp(CTC_IPORT)) & STROBE_MASK;

   
   for (i=0; i<NUMSTROBES; i++) {
        charged= strobe_status & (1 << i+3);

        if (!strobe[i].available) {
            wxatsay(strobe_stat_wdo,1+i,15,NOTHERE);
        } else {
            if (strobe[i].selected) {
                if (charged) {
                    if (acq_in_progress)
                        wxatsay(strobe_stat_wdo,1+i,15,READY);
                    else
                        wxatsay(strobe_stat_wdo,1+i,15,STANDBY);
                } else {
                    if (acq_in_progress)
                        wxatsay(strobe_stat_wdo,1+i,15,CHARGING);
                    else
                        wxatsay(strobe_stat_wdo,1+i,15,STANDBY);
                }
            } else
                wxatsay(strobe_stat_wdo,1+i,15,NOTUSED);
        }
    }

    if (!acq_in_progress)
        ready_mask= 0x87;
    
    outp(CTC_OPORT,out_port & ready_mask);

    return((strobe_status & active_strobes) == ((out_port & ready_mask) & STROBE_MASK)); 

}

file_wdo_func(files, numfiles)
char *files[];
int numfiles;
{
    COUNT row;
    COUNT col;
    COUNT file;
    COUNT filesacross;
    

    if ((filesacross= (fwrt-fwlf-2)/10) <= 0)
        filesacross= 1;


    file_wdo=wxxopen(fwup,fwlf,fwlo,fwrt,"[ File Selection ]",
                     ACTIVE|BORDER|BD1,
                     MAXFILES/filesacross+1,78,3,32);
    if ( file_wdo == -1 )
        m_error();

    for (file = 0; file < numfiles; file++) {
        row= file / filesacross;
        col= (file % filesacross)*10 +2;
        xatsay(row, col, files[file], vc.dflt);
    }
    return(filesacross);
}

int
files_wdo_adjust()
{

    wadjust(file_wdo);
    wcoord (file_wdo,&fwup,&fwlf,&fwlo,&fwrt);
    wclose(file_wdo);
    return(file_wdo_func(scanfile, numfiles));

}


int
files_wdo_proc()
{

    int row,col;
    int file,oldfile;
    int filesacross;

    wdokey(NO);
    
    filesacross= file_wdo_func(scanfile, numfiles);

    wxatsay(status_wdo,1,0,"RET = select File   F10 = Show file Header data    ESC = abort       ",vc.dflt);

    for (file = 0; file < numfiles;) {
    
        row= file / filesacross;
        col= (file % filesacross)*10 +2;
        wxatsay(file_wdo,row,col,scanfile[file],vc.white+vc.bold+(vc.bg*vc.green));
        
        oldfile= file;

        
        switch (getone()) {
        
            case UPARROW:
                file-= filesacross;
                if (file < 0)
                    file= numfiles-1;
                break;
                 
            case DOWNARROW:
                file+= filesacross;
                if (file >= numfiles) 
                   file= 0;
                break;
                 
            case RIGHTARROW:
                file++;
                if (file >= numfiles) {
                   file= 0;
                   bell();
                }
                break;
                
            case LEFTARROW:
                file--;
                if (file < 0)
                    file= numfiles-1;
                break;
                
            case ESC:
                close_file_wdo(numfiles);
                wdokey(F2);
                return(-1);
                
            case ENTER:
                return(file);
                
            case F2:
                filesacross= files_wdo_adjust();
                row= file / filesacross;
                col= (file % filesacross)*10 +2;
                wxatsay(file_wdo,row,col,scanfile[file],vc.white+vc.bold+(vc.bg*vc.green));
                break;
                
            case F10:
                show_file_data(scanfile[file]);
                wxatsay(status_wdo,1,0,"RET = select File   F10 = Show file Header data    ESC = abort       ",vc.dflt);
                break;

            default:
                bell();
                break;
        }
        
        wxatsay(file_wdo,row,col,scanfile[oldfile],vc.dflt);
    }
    return(-1);
}

COUNT
get_files (pattern)
char *pattern;
{

    struct find_t find;
    void make_name();
    char fullpath[60];
    char *sptr;
    
    numfiles= 0;

       
    strcpy(fullpath,data_path);
    strcat(fullpath,pattern);
    
    if (!_dos_findfirst( fullpath, _A_NORMAL | _A_ARCH, &find)) {
        if ((sptr= (char *) calloc (strlen(find.name)+1, sizeof (char))) == NULL) 
            m_error ();
        strcpy(sptr,find.name);
        scanfile[numfiles]= sptr;
        make_name (scanfile[numfiles]);
        numfiles++;
    } else 
        return (NO);

    while( !_dos_findnext( &find ) && (numfiles < MAXFILES)) {
        if ((sptr= (char *) calloc (strlen(find.name)+1, sizeof (char))) == NULL) 
            m_error ();
        strcpy(sptr,find.name);
        scanfile[numfiles]= sptr;
        make_name (scanfile[numfiles]);
        numfiles++;
    }

    sortfiles(); 

    return (YES);
    
}


void
make_name (name)
char *name;
{

    int i;

    for (i=0; i<strlen(name); i++) {
        if (name[i] == '.') {
            name[i] = (char) NULL;
            break;
        }
    }
    return;
    
}

COUNT
close_file_wdo(numfiles)
int numfiles;
{

    int file;

    for (file= 0; file < numfiles; file++) 
        free (scanfile[file]);

    wcoord (file_wdo,&fwup,&fwlf,&fwlo,&fwrt);
    wclose(file_wdo);
    
}

COUNT
show_file_data(name)
char *name;
{

    int dw;
    int ctrl;
    int header;
    char filename[60];
    char shutter[20];
    char strobes[10];
    struct DISPLAY temdis;
    void close_data_wdo();
    
    strcpy(filename,data_path);
    strcat(filename,name);
    strcat(filename,".FTS");


    header = open( filename, O_BINARY | O_RDONLY );
    if (header == -1 ) 
        return(NO);

    read (header,header_array,FITS_REC_SIZE*sizeof(char));
    close(header);
    
    if (!rip_header(&temdis))
        return(NO);

    dw= data_wdo_func(hdup,hdlf,hdlo,hdrt,"[ Header Info ]",5);
    wctrl(dw,&ctrl,GET);
    ctrl^= CURSOR;
    wctrl(dw,&ctrl,SET);


    switch (temdis.cam_shutter) {
    
        case 0:
            strcpy(shutter,"60 th    ");
            break;
            
        case 1:
            strcpy(shutter,"125 th   ");
            break;
            
        case 2:
            strcpy(shutter,"250 th   ");
            break;
            
        case 3:
            strcpy(shutter,"500 th   ");
            break;
            
        case 4:
            strcpy(shutter,"1,000 th ");
            break;
            
        case 5:
            strcpy(shutter,"2,000 th ");
            break;
            
        case 6:
            strcpy(shutter,"4,000 th ");
            break;
            
        case 7:
            strcpy(shutter,"10,000 th");
            break;
            
        default:
            strcpy(shutter,"?????????");
            break;
    }
    
    strcpy(strobes,"       ");
    
    if (temdis.strobes & 0x08)
        strobes[0]= 'A';
        
    if (temdis.strobes & 0x10)
        strobes[2]= 'B';
        
    if (temdis.strobes & 0x20)
        strobes[4]= 'C';
        
    if (temdis.strobes & 0x40)
        strobes[6]= 'D';
        
    
    
    sprintf(tempstr,"Date: %s     Time: %s",temdis.frame_date,temdis.frame_time);
    wxatsay(dw,1,10,tempstr,vc.dflt);
    sprintf(tempstr,"Camera: %c   Shutter: %s   Gain: %d   Offset: %d",(char) (temdis.cam+65),shutter,temdis.cam_gain,temdis.cam_offset);
    wxatsay(dw,3,10,tempstr,vc.dflt);
    sprintf(tempstr,"Strobes: %s",strobes);
    wxatsay(dw,5,10,tempstr,vc.dflt);

    wxatsay(status_wdo,1,0,"RET = done   F10 = done   ESC = done                          ",vc.dflt);

    getone();
    close_data_wdo(dw,&hdup,&hdlf,&hdlo,&hdrt);
    return(YES);
    
}

 
void
close_data_wdo (dw,up,lf,lo,rt)
int dw;
int *up;
int *lf;
int *lo;
int *rt;
{

    wcoord(dw,up,lf,lo,rt);
    wclose(dw);
    
    
}

int
reset_sel_cam()
{

    int i;
    
    for (i=0;i<NUMCAMERAS;i++) {
        if (camera[i].selected) {
            camera[i].selected= NO;
            put_camera(camera[i].cenx,camera[i].ceny,NOSELCOLOR,(char) (i+65));
        }
    }
}

int
find_cam_strobe(x,y,iscamera,num)
int x;
int y;
int *iscamera;
int *num;
{


    int i;
    
    
    for (i=0;i<NUMCAMERAS;i++) {
        if ((abs(x-camera[i].cenx)) < 90 && (abs(y-camera[i].ceny) < 90)) {
            *iscamera= YES;
            *num= i;
            return(YES);
        }
    }

    for (i=0;i<NUMSTROBES;i++) {
        if ((abs(x-strobe[i].cenx) < 90) && (abs(y-strobe[i].ceny) < 90)) {
            *iscamera= NO;
            *num= i;
            return(YES);
        }
    }
    
    return(NO);
    
}

    
int
set_shutter(num)
int num;
{

   reset_shutters();

   switch (num) {
   
       case 0:
           strcpy(tempstr,"    60");
           break;
           
       case 1:
           strcpy(tempstr,"   125");
           break;
           
       case 2:
           strcpy(tempstr,"   250");
           break;
           
       case 3:
           strcpy(tempstr,"   500");
           break;
           
       case 4:
           strcpy(tempstr," 1,000");
           break;
           
       case 5:
           strcpy(tempstr," 2,000");
           break;
           
       case 6:
           strcpy(tempstr," 4,000");
           break;
           
       case 7:
           strcpy(tempstr,"10,000");
           break;
           
       default:
           error_func(NULL,"Unable to set shutter speed",NULL);
           break;
   }
   wxatsay(camera_stat_wdo,7,11,tempstr,vc.white+vc.bold+(vc.bg*vc.blue));

   shutter[num]= YES;
   active_shutter= num;
   sprintf(tempstr,"%5u",delay.odd[active_shutter]);
   wxatsay(strobe_stat_wdo,6,17,tempstr,vc.white+vc.bold+(vc.bg*vc.white));
   sprintf(tempstr,"%5u",delay.even[active_shutter]);
   wxatsay(strobe_stat_wdo,7,17,tempstr,vc.white+vc.bold+(vc.bg*vc.white));
   if (active_camera != -1) {
       out_port&= 0xf8;
       out_port|= camera[active_camera].shutter;
   }

}


make_fname(dest,d,t)
char *dest;
char *d;
char *t;
{

    int month;

    month= atoi(d);

    
    dest[0]= month+64;
    dest[1]= d[3];
    dest[2]= d[4];
    dest[3]= t[0];
    dest[4]= t[1];
    dest[5]= t[3];
    dest[6]= t[4];
    dest[7]= t[6];
    dest[8]= 0;
    
}

int
display_to_disk(num,path)
int num;
char *path;
{

    int header;
    char name[60];

    strcpy(name,path);
    strcat(name,display[num].data_name);
    if (!opic_outfile(name,num))
        return(NO);

    display[num].saved= YES;
    return(YES);


}

reset_shutters()
{
    int i;
    
    for (i=0;i<8;i++) 
        shutter[i]= NO;

}

set_gain(gain)
int gain;
{
    mv_gain(gain);
    sprintf(tempstr,"%1d",gain);
    wxatsay(camera_stat_wdo,7,28,tempstr,vc.white+vc.bold+(vc.bg*vc.blue));
}

set_offset(offset)
int offset;
{

    mv_offset(offset);
    sprintf(tempstr,"% 3.3d",offset);
    wxatsay(camera_stat_wdo,7,38,tempstr,vc.white+vc.bold+(vc.bg*vc.blue));

}

int
get_camera_params()
{
    int header;
    int i;
    
    header = open ("camera.prm", O_BINARY | O_RDONLY);

    if (header == -1 ) 
        return(NO);

    lseek(header, 0L, SEEK_SET);
    
    for (i=0;i<NUMCAMERAS;i++) {
        if (read (header, (char *) &camera[i], sizeof(struct CAMERA)) < 0) {
            close(header);
            return(NO);
        }
    }
    if (read (header, (char *) &delay, sizeof(struct DELAY)) < 0) {
        close(header);
        return(NO);
    }
    for (i=0;i<NUMSTROBES;i++) {
        if (read (header, (char *) &strobe[i], sizeof(struct STROBE)) < 0) {
            close(header);
            return(NO);
        }
    }
    for (i=0;i<NUMCAMERAS;i++) {
        if (read (header, (char *) &auto_camera[i], sizeof(int)) < 0) {
            close(header);
            return(NO);
        }
        if (read (header, (char *) &auto_strobes[i], sizeof(int)) < 0) {
            close(header);
            return(NO);
        }
        if (read (header, (char *) &auto_display[i], sizeof(int)) < 0) {
            close(header);
            return(NO);
        }
        if (read (header, (char *) &auto_shutter[i], sizeof(int)) < 0) {
            close(header);
            return(NO);
        }
    }
    
    close(header);
    return(YES);


}


int
put_camera_params()
{

    int header;
    int i;

    header = open( "camera.prm", O_BINARY | O_WRONLY | O_CREAT | O_TRUNC,
                                 S_IREAD | S_IWRITE );
    if (header == -1 ) 
        return(NO);


    for (i=0;i<NUMCAMERAS;i++) {
        if (write( header, (char *) &camera[i], sizeof(struct CAMERA)) == - 1 ) {
            close(header);
            return(NO);
        }
    }
    if (write( header, (char *) &delay, sizeof(struct DELAY)) == - 1 ) {
        close(header);
        return(NO);
    }
    
    for (i=0;i<NUMSTROBES;i++) {
        if (write( header, (char *) &strobe[i], sizeof(struct STROBE)) == - 1 ) {
            close(header);
            return(NO);
        }
    }
    for (i=0;i<NUMCAMERAS;i++) {
        if (write( header, (char *) &auto_camera[i], sizeof(int)) == - 1 ) {
            close(header);
            return(NO);
        }
        if (write( header, (char *) &auto_strobes[i], sizeof(int)) == - 1 ) {
            close(header);
            return(NO);
        }
        if (write( header, (char *) &auto_display[i], sizeof(int)) == - 1 ) {
            close(header);
            return(NO);
        }
        if (write( header, (char *) &auto_shutter[i], sizeof(int)) == - 1 ) {
            close(header);
            return(NO);
        }
    }
    close(header);
    return(YES);
}

int
get_auto_params()
{
    FILE *pfstream;
    int i;
    COUNT line= 0;
    int cam,shutter,strobe,disp,dest;
	    
    if ((pfstream= fopen("auto.prm","rt")) == NULL)
        return(line);
        
    fseek(pfstream,0L,SEEK_SET);

    for (i=0;i<AUTOCOMMANDS;i++)     
        auto_camera[i]= -1;

    for (i=0;i<AUTOCOMMANDS;i++) {    
        if (fscanf(pfstream,"%d %d %d %d %d\n",&cam, &strobe, &disp, &dest, &shutter) != 5) 
            break;

        if ((cam > NUMCAMERAS) || (cam <= 0)) {
            line++;
            continue;
        }
        if (!camera[cam-1].available) {
            line++;
            continue;
        }
        auto_camera[i]= cam-1;
        auto_strobes[i]= strobe << 3;
        if ((disp > NUMDISPLAYS) || (disp <= 0)) {
            auto_camera[i]= -1;
            line++;
            continue;
        }
        if (!display[disp-1].available) {
            auto_camera[i]= -1;
            line++;
            continue;
        }
        auto_display[i]= disp-1;
        if (dest > 2 || dest < 0) {
            auto_camera[i]= -1;
            line++;
            continue;
        }
        auto_dest[i]= dest;
        if (shutter > 7 || shutter < 0)
            shutter= 0;
        auto_shutter[i]= shutter;
        line++;
    }

    fclose(pfstream);
    return(line);
}


void 
ctc_setup()
{
    int i,loop= 1;


/*		This routine works by setting up two counters - counter 1 running as
 *		a down counter with a 1 Mhz input clock will count down when its  
 *		associated gate goes high (set by the MSB of the output port).  The
 *		terminal count of counter 1 should be connected the gate input of
 *		counter 2.  Counter two is set up as a hardware triggered one shot,
 *		counting down from a 1 megahertz input source and producing a 1 
 *      millisecond output pulse.  The gate input is used as the trigger 
 *      (from counter 1 output).  The output of counter 2 should be connected 
 *      to the strobe hardware.  Both counters will disarm and reload upon 
 *      reaching they're respective TC.
 */



/*		counter card setup - Master Reset - clear counters - valid
 *      data pointer register set.
 */

    for (i=0;i<loop;i++) {
	    outp(CTC_CMD,0xff);						
	    nop();
	    outp(CTC_CMD,0x05f);
	    nop();
	    outp(CTC_CMD,0x01);
	    nop();
    }

/*		Initialize Master Mode Register 
 *      No TOD, Compare1 Disabled, Compare2 Disabled
 *		FOUT source is F1
 *		FOUT Divider is 1 (1 Megahertz)
 *		FOUT is on
 *		Data Bus width is 8
 *		Data pointer control enabled
 *		Scaler control is BCD
 */
    for (i=0;i<loop;i++) {
	    outp(CTC_CMD,0x17);						
	    nop();
	    outp(CTC_BASE,0);	
	    nop();
	    outp(CTC_BASE,0xC1);
	    nop();
    }	

/*		Initialize Counter 1 - Mode is C
 *      Gate Control   -> Active High edge gate 1 (110)
 *      Count Source   -> count on rising edge, Source F1 (01011) (1 megahertz)
 *      Count Control  -> Disable Special Gate, Reload from Load,
 *                        Count Once, in Binary, Down (00000)
 *      Output Control -> Active High TC Pulse (001)
 */	
 
    for (i=0;i<loop;i++) {
	    outp(CTC_CMD,0x1);							
	    nop();
	    outp(CTC_BASE,0x01);
	    nop();
        outp(CTC_BASE,0xcb);
	    nop();
	    load_delay(delay_counts);
	}


/*		Initialize Counter 2 - Mode is I
 *      Gate Control   -> Active High edge gate 2 (110)
 *      Count Source   -> count on rising edge, Source F1 (01011) (1 megahertz)
 *      Count Control  -> disable Special Gate, Reload from Hold/ Load,
 *                        Count Once, in Binary, Down (01000)
 *      Output Control -> Toggled TC  (010)
 */	
 
    for (i=0;i<loop;i++) {
	    outp(CTC_CMD,0x2);							
	    nop();
	    outp(CTC_BASE,0x42);
	    nop();
        outp(CTC_BASE,0xcb);
	    nop();
    /*  Load the load register with minimal delay  */
        outp(CTC_CMD,0x0a);
        nop();
        outp(CTC_BASE,2);
        nop();
        outp(CTC_BASE,0);
        nop();
    /*  Load the hold register with 1 millisecond delay  */
        outp(CTC_CMD,0x12);
        nop();
        outp(CTC_BASE,0xe8);
        nop();
        outp(CTC_BASE,3);
        nop();
    /*  Load the counter from load register */
        outp(CTC_CMD,0x42);
        nop();
    /*  Drive the output low */
        outp(CTC_CMD,0xe2);
        nop();
	}
    
/*		Disarm rate all counters
 */
    outp(CTC_CMD,0xdf);
    nop();


} 


load_delay(num)
unsigned int num;
{

    int lowbyte;
    int highbyte;

    highbyte= (num >> 8) & 0xff;
    lowbyte= num & 0xff;


    /*  Load the load register with delay  */
	outp(CTC_CMD,0x09);
	nop();
	outp(CTC_BASE,lowbyte);
	nop();
	outp(CTC_BASE,highbyte);
	nop();
	/* load counter from load register */
	outp(CTC_CMD,0x41);
	nop();
}

trigger_strobes()
{

/*		Arm counter 2 - load and Arm Counter 1 
 */ 
    outp(CTC_CMD,0x22);
    nop();
    outp(CTC_CMD,0x61);
    nop();
    
    
/*		Rise the counter 1 gate - and go!
 */
    out_port|= 0x80;
    outp(CTC_OPORT,out_port);
    
}

disable_strobes()
{

/*		Lower the counter 1 gate
 */
    out_port&= 0x7f;
    outp(CTC_OPORT,out_port);
    
}


nop()
{
}


int 
save_strobes()
{


    int i;
    
    for (i=0;i<NUMSTROBES;i++) {
        memcpy(&tmpstrobe[i],&strobe[i],sizeof(struct STROBE));
        strobe[i].selected= NO;
    }
    
    last_active_strobes= active_strobes;
    active_strobes= 0;
    out_port&= 0x87;
}

int restore_strobes()
{

    int i;
    
    for (i=0;i<NUMSTROBES;i++) 
        memcpy(&strobe[i],&tmpstrobe[i],sizeof(struct STROBE));
    
    active_strobes= last_active_strobes;

}

COUNT
opic_loop()
{

    int i;
    char d[20],t[20];
    char stime[20];
    char filename[60];
    char temprem[20];
    long now,diff;
    int sh,sm,ss,j;
    int last_camera,last_shutter,temp_shutter;
    char data_path[60];
    void close_data_wdo();
    
    check_strobes();
    vcgettim(stime);
    stime[8]= 0;
    wxatsay(camera_stat_wdo,0,35,stime,vc.white+vc.bold+(vc.bg*vc.blue));

    if (!auto_mode) 
        return(NO);


    sscanf(stime,"%2d%*c%2d%*c%2d",&sh, &sm, &ss);
    now= ((long) sh) * 3600L + ((long) sm) * 60L + ((long) ss);
    diff = now-auto_start;
    if (diff < 0L) 
        diff+= 86400L;

/* show diff value here */
    sprintf(temprem,"% 4.4ld",auto_delta-diff);
    wxatsay(auto_wdo,0,58,temprem,vc.dflt);

    if (diff < auto_delta)
        return(NO);

    if (auto_blocked)
        return(NO);

    if (auto_in_progress)
        return(NO);
        
    auto_start= now;
    
    if (active_camera == -1)
        active_camera= 0;
        
    last_camera= active_camera;
    last_shutter= camera[active_camera].shutter;

    for (i=0;i<num_auto_commands;i++) {
    
        auto_in_progress= YES;
            
        if (auto_camera[i] < 0)
            continue;

        if (!enable_dis(auto_display[i])) {
            auto_in_progress= NO;
            bell();
            auto_mode= NO;
            close_data_wdo(auto_wdo,&auup,&aulf,&aulo,&aurt);
            error_func(NULL,"Auto Mode display enable error - abort. ",NULL);
            return(NO);
        } 

        save_strobes();
        check_strobes();
        temp_shutter= camera[auto_camera[i]].shutter;
        camera[auto_camera[i]].shutter= auto_shutter[i];
        cam_select(auto_camera[i],auto_camera[i]);
    
        if (auto_strobes[i] & 0x08)
            strobe_select(0);
        
        if (auto_strobes[i] & 0x10)
            strobe_select(1);
        
        if (auto_strobes[i] & 0x20)
            strobe_select(2);
        
        if (auto_strobes[i] & 0x40)
            strobe_select(3);

        check_strobes();
        syspause(0,0,frame_delay,0);    

          
        wxatsay(camera_stat_wdo,3+auto_display[i],14,"Acquiring Frame  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta));
        syspause(0,0,0,70);
        if (!getframe(d,t)) {
            auto_in_progress= NO;
            restore_strobes();
            cam_select(last_camera,last_camera);
            bell();
            auto_mode= NO;
            close_data_wdo(auto_wdo,&auup,&aulf,&aulo,&aurt);
            disable_dis(auto_display[i]);
            error_func(NULL,"Auto Mode frame acquire error - abort. ",NULL);
            return(NO);
        } 
        show_dis(auto_display[i],G_PLANE);
        display[auto_display[i]].image= YES;
        display[auto_display[i]].saved= NO;
        make_fname(filename,d,t);
        strcpy(data_path,"");
        if (auto_dest[i] == SAVENET)
            strcpy(data_path,net_path);
        if (auto_dest[i] == SAVELOCAL)
            strcpy(data_path,local_path);
        strcpy(display[auto_display[i]].data_name,"");
        strcat(display[auto_display[i]].data_name,filename);
        strcat(display[auto_display[i]].data_name,".FTS");
        sprintf(tempstr,"Display %1d:",auto_display[i]+1);
        wxatsay(camera_stat_wdo,3+auto_display[i],2,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"%5.5s %5.5s Frame",d,t);
        wxatsay(camera_stat_wdo,3+auto_display[i],14,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"Camera %c",(char) (auto_camera[i]+65));
        wxatsay(camera_stat_wdo,3+auto_display[i],34,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red)); 
        display[auto_display[i]].strobes= auto_strobes[i];
        strcpy(display[auto_display[i]].frame_date,d);
        strcpy(display[auto_display[i]].frame_time,t);
        display[auto_display[i]].cam= auto_camera[i];
        display[auto_display[i]].cam_gain= camera[auto_camera[i]].gain;
        display[auto_display[i]].cam_offset= camera[auto_camera[i]].offset;
        display[auto_display[i]].cam_shutter= camera[auto_camera[i]].shutter;
        saved[auto_display[i]].available= NO;
        saved[auto_display[i]].image= NO;
        check_strobes();
        if (auto_dest[i] != NOSAVE) {
            switch (auto_display[i]) {
    
                case 0:
                    save_it(0,data_path);
                    break;
            
                case 1:
                    save_it(1,data_path);
                    break;
            
                case 2:
                    save_it(2,data_path);
                    break;
            
                default:
                    break;
            
            }
        }
        restore_strobes();
        display[auto_display[i]].plane= G_PLANE;
        for (j=0;j<NUMBOARDS;j++)
            show_dis(j,display[j].plane);
        camera[auto_camera[i]].shutter= temp_shutter;
    }
    camera[last_camera].shutter= last_shutter;
    cam_select(last_camera,last_camera);
    auto_in_progress= NO;
    check_strobes();
    return(YES);
    
}


COUNT
opic_outfile(name,num)
char *name;
int num;
{

    int datafile;
    int row,i;

    datafile = open( name, O_BINARY | O_WRONLY | O_CREAT | O_TRUNC, S_IWRITE );
    if (datafile == -1 ) 
        return(NO);

    sew_header(num);

    write (datafile,header_array,FITS_REC_SIZE*sizeof(char));

    show_dis(num,G_PLANE);

    if (!enable_dis(num))
        return(NO);

    for (row = NROWS-1; row>=INCROWS-1; row-= INCROWS ) {
        for (i=0;i<INCROWS;i++) 
            opic_read_rc(G_PLANE,1,0,row-i,NCOLS,&pix_array[NCOLS*i]);
        write (datafile,pix_array,INCROWS*NCOLS*sizeof(char));
    }

    write(datafile,nullfits,2816*sizeof(char));
    disable_dis(num);

    close(datafile);
    return(YES);
}

COUNT
opic_infile(name,disstruct)
char *name;
struct DISPLAY *disstruct;
{

    int datafile;
    int row,i;     
    

    datafile = open( name, O_BINARY | O_RDONLY );
    if (datafile == -1 ) 
        return(NO);

    read (datafile,header_array,FITS_REC_SIZE*sizeof(char));
    
    if (!rip_header(disstruct))
        return(NO);
/*
    for (row = 511; row>=0; row-- ) {
        read (datafile,pix_array,512*sizeof(char));
        opic_writ_rc(I_PLANE,1,0,row,512,pix_array);
    }
*/
    for (row = NROWS-1; row>=INCROWS-1; row-= INCROWS ) {
        read (datafile,pix_array,INCROWS*NCOLS*sizeof(char));
        for (i=0;i<INCROWS;i++)
            opic_writ_rc(I_PLANE,1,0,row-i,NCOLS,&pix_array[NCOLS*i]);
    }
    close(datafile);
    return(YES);
}


COUNT
sortfiles()
{


    int i,j;
    char tempfile[20];
    
    
    for (i=0; i<numfiles-1; i++)
        for (j=i+1; j<numfiles; j++) 
            if (strcmp(scanfile[i],scanfile[j]) > 0) {
                strcpy(tempfile,scanfile[i]);
                strcpy(scanfile[i],scanfile[j]);
                strcpy(scanfile[j],tempfile);
            }
}


opic_writ_rc(ibank, r_c, col_x, row_y, length, pix_array)
/* write a row or a column of pixel value to
   image_panel or graphic_panel
	ibank		= 0 : image panel
			= 1 : graphics panel 
	r_c:		= 1 to write row (x-direction)
			= 0 to write column (y-direction)
	col_x, row_y:	starting point 
	length:		length of data array
	pix_array:	data array */
int r_c, row_y, col_x, length;
unsigned short ibank;
unsigned char pix_array[];
{
int i,ix,iy;
 int pixv,inport;
    vsearch 
		if( (vp->vp)->impub != 0)
    {
	outp(base|MVPUB,(vp->vp)->pub&0xFF);
	outp(base|MVPUB,(vp->vp)->impub&0xFF);
	ibank = ibank&0x01;
	iy = row_y;
	ix = col_x;
	if (r_c == 0) goto writ_col;
/* writ row */
	inport = base|VSCXYI|FIXINC|ibank;	
	mvset(iy,ix);
	for (i=0; i<length; i++) {
		outp(inport,pix_array[i]);		
	}
	return(YES);
writ_col:	
	inport = base|VSCXYI|INCFIX|ibank;	
	mvset(iy,ix);
	for (i=0; i<length; i++) {
		outp(inport,pix_array[i]);		
	}
	return(YES);
    }
}



opic_read_rc(ibank, r_c, col_x, row_y, length, pix_array)
int r_c, row_y, col_x, length;
unsigned short ibank;
unsigned char pix_array[];
{
    int i,ix,iy;
    int pixv,inport;

	vsearch
    if( (vp->vp)->impub != 0) {
		outp(base|MVPUB,(vp->vp)->pub&0xFF);
		outp(base|MVPUB,(vp->vp)->impub&0xFF);
		ibank = ibank&0x01;
		iy = row_y;
		ix = col_x;
		if (r_c == 0) goto read_col;
		inport = base|VSCXYI|FIXINC|ibank;	
		mvset(iy,ix);
		for (i=0; i<length; i++) {
			pix_array[i] = inp(inport);
		}
		return(YES);
read_col:
		inport = base|VSCXYI|INCFIX|ibank;	
		mvset(iy,ix);
		for (i=0; i<length; i++) {
			pix_array[i] = inp(inport);
		}
	return(YES);
	}
}


COUNT
sew_header(num)
int num;
{
    int i;
    
    sprintf(&(header_array[0]),  "SIMPLE  =                    T /                                                ");
    sprintf(&(header_array[80]), "BITPIX  =                    8 /                                                ");
    sprintf(&(header_array[160]),"NAXIS   =                    2 /                                                ");
    sprintf(&(header_array[240]),"NAXIS1  =                  512 /                                                ");
    sprintf(&(header_array[320]),"NAXIS2  =                  512 /                                                ");
    sprintf(&(header_array[400]),"CAMERA  =                    %c /                                                ",(char)(display[num].cam+65));
    sprintf(&(header_array[480]),"SHUTTER =                    %1d /                                                ",display[num].cam_shutter);
    sprintf(&(header_array[560]),"GAIN    =                    %1d /                                                ",display[num].cam_gain);
    sprintf(&(header_array[640]),"OFFSET  =                  %3d /                                                ",display[num].cam_offset);
    sprintf(&(header_array[720]),"STROBES =                  %3d /                                                ",display[num].strobes);
    sprintf(&(header_array[800]),"DATE    = \'%8s\'           /                                                ",display[num].frame_date);
    sprintf(&(header_array[880]),"TIME    = \'%8s\'           /                                                ",display[num].frame_time);
    sprintf(&(header_array[960]),"CARD    =                  %3d /                                                ",num);
    sprintf(&(header_array[1040]),"END                                                                            ");

    for (i=1120; i<FITS_REC_SIZE; i++)
        header_array[i]= ' ';

}


COUNT
rip_header(disstruct)
struct DISPLAY *disstruct;
{
    char *ptr,*token;
    char buf[80];
    
    if ((ptr= strstr(header_array,"CAMERA")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =/");
    if ((token=strtok(NULL," =/")) == NULL)
        return(NO);
    disstruct->cam= (*token)-65;
    
    if ((ptr= strstr(header_array,"SHUTTER")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =/");
    if ((token=strtok(NULL," =/")) == NULL)
        return(NO);
    disstruct->cam_shutter= atoi(token);
    
    if ((ptr= strstr(header_array,"GAIN")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =/");
    if ((token=strtok(NULL," =/")) == NULL)
        return(NO);
    disstruct->cam_gain= atoi(token);
    
    if ((ptr= strstr(header_array,"OFFSET")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =/");
    if ((token=strtok(NULL," =/")) == NULL)
        return(NO);
    disstruct->cam_offset= atoi(token);

    if ((ptr= strstr(header_array,"STROBES")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =/");
    if ((token=strtok(NULL," =/")) == NULL)
        return(NO);
    disstruct->strobes= atoi(token);
    
    if ((ptr= strstr(header_array,"DATE")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =");
    if ((token=strtok(NULL," ='")) == NULL)
        return(NO);
    strcpy(disstruct->frame_date,token);
    
    if ((ptr= strstr(header_array,"TIME")) == NULL)
        return(NO);
    
    strncpy(buf,ptr,80);
    buf[79]= 0;
        
    strtok(buf," =");
    if ((token=strtok(NULL," ='")) == NULL)
        return(NO);
    strcpy(disstruct->frame_time,token);

    return(YES);
}

board_err(i)
int i;
{
    display[i].available= NO;
    sprintf(tempstr,"MV1 board #%d is nonfunctional (%d %d %x)",i,board[i].ins,board[i].err,base);
    error_func(NULL,tempstr,NULL);
    wxatsay(camera_stat_wdo,3+i,14,"Unavailable      ",vc.dflt);
}

enable_dis(n)
int n;
{

    
    if (!display[n].available) {
        return(NO);
    }
    mv_actbrd1(board[n].name,&board[n].err);
    if (board[n].err != 0) {
        board_err(n);
        display[n].enabled= NO;
        return(NO);
    }
    display[n].enabled= YES;
    return(YES);
}

disable_dis(n)
int n;
{
    if (!display[n].available) {
        return(NO);
    }
    mv_disbrd1(board[n].name,&board[n].err);
    if (board[n].err != 0) {
        board_err(n);
        return(NO);
    }
    display[n].enabled= NO;        
    return(YES);
}


show_dis(dis,plane)
int dis;
int plane;
{

    if (!display[dis].available)
        return(NO);
        
    if (!enable_dis(dis))
        return(NO);
        
    mv_view1(plane);
    display[dis].plane= plane;
    disable_dis(dis);
}

const_histo(dis)
int dis;
{
    int row;
    int col,i;

    show_dis(dis,display[dis].plane);

    if (!enable_dis(dis))
        return(NO);
     
    for (i=0;i<256;i++)
        histo[i]= 0;

    for (row = 455; row>=0; row-- ) {
        opic_read_rc(G_PLANE,1,0,row,512,pix_array);
        for (col=0;col<512;col++)
             if (!((pix_array[col] <0) || (pix_array[col] > 255)))
                 histo[pix_array[col]]++;
    }
    disable_dis(dis);
    return(YES);
}

COUNT do_shell(mp)
VCMENU *mp;
{
    COUNT w,test;
      
    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;   
 
    w= wxxopen(0,0,24,79,nullstr,
               CENTER|ACTIVE|CURSOR,0,0,9,32);
           

    if (w == -1) 
        m_error();
       
    erase();
   
    if (spawnlp(P_WAIT, "command.com","command ",NULL) == -1)
        error_func(NULL,"Can not shell to DOS - aborted.",NULL);   
   

    wclose(w);
    auto_blocked= NO;
    return(REFRESH);
}


COUNT
reinitialize(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;   
 
    mv_begin();
    mv_check();
    
    auto_blocked= NO;
    
}
