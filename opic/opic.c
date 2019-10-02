/* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *    File: c:\opus\oven\video\opic.c  
 *    Date: 09/06/91
 *  Author: D. A. Harvey
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#include <vcstdio.h>
#include <math.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <dos.h>
#include <io.h>
#include <direct.h>
#include <sys\types.h>
#include <sys\utime.h>
#include <sys\stat.h>
#include <fcntl.h>          /* O_ constant definitions */
#include <malloc.h>
#include <memory.h>
#include <errno.h>
#include <math.h>


#include "mvregs.h"  /* MV1 register definitions */
#include "mvstruct.h"   /* Structures for VSC, LCA */
#include "mvmacro.h" /* Macro used in software libraries */
#include "struct.h"
#include "macro.h"
#include "param.h"   /* Parameter data types */
#include "mvboard.h"

#include "\esgraph\es30\eg_proto.h"

#define MAIN

#include "opic.h"
VCMENU *menunew(), *menuxnew();

static TEXT *netvar;
static TEXT *localvar;

/*********************************************************/
/*                          CODE                         */
/*********************************************************/



main(argc,argv)
int argc;
char **argv;
{
    COUNT vcmhf3();
    COUNT opic_loop();
    COUNT mv;
    int i;
    void ctc_setup();
    PFI setloop();


    if (argc > 1) 
        frame_delay= atoi(argv[1]);
        
    if (argc > 2)
        port_index= atoi(argv[2]);

    /* get data path */
    netvar = getenv("OPIC_NET");
    localvar= getenv("OPIC_LOCAL");
    
    if (netvar != NULL)
        strcpy(net_path,netvar);
        
    if (localvar != NULL)
        strcpy(local_path,localvar);
      

    do_vga_mode();
    vcstart(CLRSCRN);
    set_colors();
    mouse= mset(YES,x_mouse,y_mouse,RET,F10,ESC);
    init_structs();
    com_init(port_index);
    ctc_setup(); 
    mv_begin();

    prep_menus();
    vcmhook3=vcmhf3;         /* auto-pull-down from horizontal menu */

    status_wdo_func();
    setswdo(status_wdo);
    statlin(0,3);
    strobe_stat_wdo_func();
    camera_stat_wdo_func();
    mv_check();
    set_shutter(0);
    setloop(opic_loop);
    if (local)
        strcpy(data_path,local_path);
    else
        strcpy(data_path,net_path);
    forever 
        vcmenu(main_menu);   
}

prep_menus()
{

   main_menu=menuxnew(0,0,80,"[ OPIC  version 2.5 ]",
                         HORIZONTAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   show_menu=menuxnew(1,5,-1,"Show",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   file_menu=menuxnew(1,0,-1,"File",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   select_menu=menuxnew(1,11,-1,"Select",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   image_menu=menuxnew(1,18,-1,"Image",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"");
   calibrate_menu=menuxnew(1,30,-1,"Calibrate",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   shutter_menu=menuxnew(4,38,-1,"Shutter Speed ",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   camera_menu=menuxnew(1,38,-1,"Camera",
                         VERTICAL|TITLECENTER,
                         vc.cyan+vc.bold+(vc.bg*vc.blue),
                         vc.blue+(vc.bg*vc.white),
                         vc.cyan+(vc.bg*vc.blue),
                         vc.white+(vc.bg*vc.blue),
                         0,"NO HELP");
   menuxitem(main_menu,"   File",NULL,0,NULLFUNC,(char *)file_menu," Output File management","",MENU);
   menuxitem(main_menu,"Show",NULL,0,NULLFUNC,(char *)show_menu,"Select Display 1 image plane","",MENU);
   menuxitem(main_menu,"Select",NULL,0,NULLFUNC,(char *)select_menu," Select Camera/ Strobes","",MENU);
   menuxitem(main_menu,"Image",NULL,0,NULLFUNC,(char *)image_menu,"Image Management","",MENU);
   menuxitem(main_menu,"Calibrate",NULL,0,NULLFUNC,(char *)calibrate_menu,"Strobe testing and calibration","",MENU);
   menuxitem(main_menu,"Camera",NULL,0,NULLFUNC,(char *)camera_menu,"Set Camera Parameters","",MENU);
   menuxitem(file_menu,"Save Dis 1",NULL,0,save_dis_1,NULL,"Save Display 1 image to Disk","",STRPARM|HIDE);
   menuxitem(file_menu,"Save Dis 2",NULL,0,save_dis_2,NULL,"Save Display 2 image to Disk","",STRPARM|HIDE);
   menuxitem(file_menu,"Save Dis 3",NULL,0,save_dis_3,NULL,"Save Display 3 image to Disk","",STRPARM|HIDE);
/*
   menuxitem(file_menu,"Save Dis 4",NULL,0,save_dis_4,NULL,"Save Display 4 imageto Disk","",STRPARM|HIDE);
*/
   menuxitem(file_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(file_menu,"Retrieve dis 1",NULL,0,get_pic1,NULL,"Retrieve a previously saved picture","",STRPARM|HIDE);
   menuxitem(file_menu,"Retrieve dis 2",NULL,0,get_pic2,NULL,"Retrieve a previously saved picture","",STRPARM|HIDE);
   menuxitem(file_menu,"Retrieve dis 3",NULL,0,get_pic3,NULL,"Retrieve a previously saved picture","",STRPARM|HIDE);
   menuxitem(file_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(file_menu,"Shell ",NULL,0,do_shell,NULL,NULL,NULL,STRPARM|HIDE);
   menuxitem(file_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(file_menu,"Quit",NULL,0,exit_opic,NULL,"Exit OPIC Program","",STRPARM);
   menuxitem(show_menu,"Live",NULL,0,show_live,NULL,"Show Live Video from selected camera on display 1","",STRPARM|HIDE);
   menuxitem(show_menu,"Acquired",NULL,0,show_acquired,NULL,"Show Previously acquired image(s)","",STRPARM|HIDE);
   menuxitem(show_menu,"Retrieved",NULL,0,show_saved,NULL,"Show previously retrieved image(s)","",STRPARM|HIDE);
   menuxitem(show_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(show_menu,"Histogram  1",NULL,0,show_histo1,NULL,"Show histogram of current display 1 image","",STRPARM|HIDE|UNAVAILABLE);
   menuxitem(show_menu,"Histogram  2",NULL,0,show_histo2,NULL,"Show histogram of current display 2 image","",STRPARM|HIDE|UNAVAILABLE);
   menuxitem(show_menu,"Histogram  3",NULL,0,show_histo3,NULL,"Show histogram of current display 3 image","",STRPARM|HIDE|UNAVAILABLE);
   menuxitem(show_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(show_menu,"Odd Frame",NULL,0,show_odd,NULL,"Show previously acquired ODD frame for calibration","",STRPARM|HIDE);

   menuxitem(camera_menu,"Gain",NULL,0,camera_gain,NULL,"Adjust Live Camera Gain","",STRPARM|HIDE);
   menuxitem(camera_menu,"Offset",NULL,0,camera_offset,NULL,"Adjust Live Camera Video Offset","",STRPARM|HIDE);
   menuxitem(camera_menu,"Shutter Speed",NULL,0,NULLFUNC,(char *)shutter_menu,"Select Shutter Speed","",MENU);


   menuxitem(select_menu,"Camera/ Strobe",NULL,0,sel_cam_strobe,NULL,"Select Camera and Strobe Combination","",STRPARM);
   menuxitem(select_menu,"Local Disk",NULL,0,sel_disk,(char *)&local,"Select Local Disk/ Net Disk Path","",CHECKED|INTEGER);
   menuxitem(image_menu,"Acquire Disp 1",NULL,0,acq_image1,NULL,"Acquire and image from selected camera","",STRPARM|HIDE);
   menuxitem(image_menu,"Acquire Disp 2",NULL,0,acq_image2,NULL,"Acquire and image from selected camera","",STRPARM|HIDE);
   menuxitem(image_menu,"Acquire Disp 3",NULL,0,acq_image3,NULL,"Acquire and image from selected camera","",STRPARM|HIDE);
   menuxitem(image_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(image_menu,"Auto",NULL,0,auto_image,(char *)&auto_mode,"Automatically acquire and save images at a specified interval","",CHECKED|INTEGER|HIDE);
   menuxitem(calibrate_menu,"Set Delay",NULL,0,set_delay,NULL,"Set Strobe delay time","",STRPARM);
   menuxitem(calibrate_menu,"Flash A",NULL,0,flash_strobe_one,NULL,"Discharge Strobe number 1","",STRPARM);
   menuxitem(calibrate_menu,"Flash B",NULL,0,flash_strobe_two,NULL,"Discharge Strobe number 2","",STRPARM);
   menuxitem(calibrate_menu,"Flash C",NULL,0,flash_strobe_three,NULL,"Discharge Strobe number 3","",STRPARM);
   menuxitem(calibrate_menu,"Flash D",NULL,0,flash_strobe_four,NULL,"Discharge Strobe number 4","",STRPARM);
   menuxitem(calibrate_menu,NULL,NULL,0,NULLFUNC,NULL,NULL,NULL,SEPARATOR);
   menuxitem(calibrate_menu,"Reinitialize",NULL,0,reinitialize,NULL,"Reinitialize Display boards","",STRPARM|HIDE);

   menuxitem(shutter_menu,"        60",NULL,0,set60,(char *) &shutter[0],"Set Shutter Speed to 1/60","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"       125",NULL,0,set125,(char *) &shutter[1],"Set Shutter Speed to 1/125","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"       250",NULL,0,set250,(char *) &shutter[2],"Set Shutter Speed to 1/250","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"       500",NULL,0,set500,(char *) &shutter[3],"Set Shutter Speed to 1/500","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"     1,000",NULL,0,set1000,(char *) &shutter[4],"Set Shutter Speed to 1/1000","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"     2,000",NULL,0,set2000,(char *) &shutter[5],"Set Shutter Speed to 1/2000","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"     4,000",NULL,0,set4000,(char *) &shutter[6],"Set Shutter Speed to 1/4000","",CHECKED|INTEGER|REFRESH);
   menuxitem(shutter_menu,"    10,000",NULL,0,set10000,(char *) &shutter[7],"Set Shutter Speed to 1/10000","",CHECKED|INTEGER|REFRESH);


}


status_wdo_func()
{
   status_wdo=wxxopen(22,0,24,79,"",
                     ACTIVE|BORDER|BD1|CENTER,
                     78,1,1,32);
   if( status_wdo == -1 )
      terror("Unable to open status_wdo.  Aborting");
}

strobe_stat_wdo_func()
{
   strobe_stat_wdo=wxxopen(11,0,21,32,"[ Strobe Status ]",
                     ACTIVE|BORDER|BD1|CENTER,
                     31,9,0,32);
   if( strobe_stat_wdo == -1 )
      terror("Unable to open strobe_stat_wdo.  Aborting");
   xatsay(1,4,"Strobe A:",vc.dflt);
   xatsay(2,4,"Strobe B:",vc.dflt);
   xatsay(3,4,"Strobe C:",vc.dflt);
   xatsay(4,4,"Strobe D:",vc.dflt);
   xatsay(6,4," Odd Delay:",vc.dflt);
   xatsay(7,4,"Even Delay:",vc.dflt);
   xatsay(6,25,"ms",vc.white+vc.bold+(vc.bg*vc.white));
   sprintf(tempstr,"%5u",delay.odd[active_shutter]);
   xatsay(6,17,tempstr,vc.white+vc.bold+(vc.bg*vc.white));
   xatsay(7,25,"ms",vc.white+vc.bold+(vc.bg*vc.white));
   sprintf(tempstr,"%5u",delay.even[active_shutter]);
   xatsay(7,17,tempstr,vc.white+vc.bold+(vc.bg*vc.white));
}

camera_stat_wdo_func()
{
   camera_stat_wdo=wxxopen(11,33,21,79,"[ Display/ Camera Status ]",
                     ACTIVE|BORDER|BD1|CURSOR|CENTER,
                     45,9,9,32);
   if( camera_stat_wdo == -1 )
      terror("Unable to open camera_stat_wdo.  Aborting");
   xatsay(1,2,"Selected: ",vc.dflt);
   xatsay(3,2,"Display 1:",vc.dflt);
   xatsay(4,2,"Display 2:",vc.dflt);
   xatsay(5,2,"Display 3:",vc.dflt);
/*   xatsay(5,2,"Display 4:",vc.dflt);
*/
   xatsay(7,2,"Shutter:",vc.dflt);
   xatsay(7,18,"th",vc.white+vc.bold+(vc.bg*vc.blue));
   xatsay(7,22,"Gain:",vc.dflt);
   xatsay(7,31,"Offset:",vc.dflt);
/*
   xatsay(3,34,"Camera A",vc.white+vc.bold+(vc.bg*vc.cyan)); 
   xatsay(4,34,"Camera B",vc.white+vc.bold+vc.blink+(vc.bg*vc.red)); 
   xatsay(5,34,"Camera C",vc.white+vc.bold+(vc.bg*vc.green)); 
   xatsay(6,34,"Camera D",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta)); 

   xatsay(3,14,"Live (Selected)  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.cyan));
   xatsay(4,14,"08/29 10:13 Frame",vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
   xatsay(5,14,"08/29 09:45 Frame",vc.white+vc.bold+(vc.bg*vc.green));
   xatsay(6,14,"Acquiring field 1",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta));
*/
}

save_dis_1(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    save_it(0,data_path);
    auto_blocked= NO;
    return(REFRESH);

}


save_dis_2(mp)
VCMENU *mp;
{
    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    save_it(1,data_path);
    auto_blocked= NO;
    return(REFRESH);
}


save_dis_3(mp)
VCMENU *mp;
{
    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    save_it(2,data_path);
    auto_blocked= NO;
    return(REFRESH);
}


COUNT
get_pic1(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!get_files ( "*.FTS")) {
        error_func (NULL, " No files on disk ", NULL );
        return (REFRESH);
    }

    retrieve_it(0);

    close_file_wdo(numfiles);
    wdokey(F2);
    auto_blocked= NO;
    return(REFRESH);
}

COUNT
get_pic2(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!get_files ( "*.FTS")) {
        error_func (NULL, " No files on disk ", NULL );
        return (REFRESH);
    }

    retrieve_it(1);

    close_file_wdo(numfiles);
    wdokey(F2);
    auto_blocked= NO;
    return(REFRESH);
}

COUNT
get_pic3(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!get_files ( "*.FTS")) {
        error_func (NULL, " No files on disk ", NULL );
        return (REFRESH);
    }

    retrieve_it(2);
    
    close_file_wdo(numfiles);
    wdokey(F2);
    auto_blocked= NO;
    return(REFRESH);
}


exit_opic(mp)
VCMENU *mp;
{

    put_camera_params();
    outp(CTC_OPORT,0);
    vcend(CLOSE);
    exit(0);

}


sel_cam_strobe(mp)
VCMENU *mp;
{

    int left,center,right;
    int x,y;
    int iscamera,num;


    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    hide_wdo= wxxopen(0,0,24,79,nullstr,CENTER|ACTIVE,0,0,5,32);
    auto_blocked= YES;
    wdokey(NO);
    initgraf(gmode,0,0);
    if (!do_show_map()) { 
        graph_error ();
        auto_blocked= NO;
        return(REFRESH);
    }

    mset(NO,x_mouse,y_mouse,RET,F10,ESC);
        
    if (minstal ()) {
WAITUSER:
        mcuron();
        while (YES) {
            check_strobes();
            if (keyrdy() || (mgetone() != 0))
                if (getone() == ESC) 
                    break;
            mposbut(&x, &y, &left, &center, &right);
            if (left || right || center)
                break;
        }
        wait_rel(2);
        wait_rel(1);
        wait_rel(0);
        mcuroff();
        if (left) {
            if (find_cam_strobe(x,y,&iscamera,&num)) {
                if (iscamera) {
                    cam_select(num,num);
                    goto WAITUSER;
                } else {
                    strobe_select(num);
                    goto WAITUSER;
                }
            }
            bell();
            goto WAITUSER;
        }
        if (center) {
            if (find_cam_strobe(x,y,&iscamera,&num)) {
                if (iscamera) {
                    activate_cam(num);
                    goto WAITUSER;
                } else {
                    activate_strobe(num);
                    goto WAITUSER;
                }
            }
            bell();
            goto WAITUSER;
        }
    } else {
       bell();
       getone();
    }
    graphing= NO;
    fontquit();
    initgraf(tmode,0,0);
    wclose(hide_wdo);
    mset(YES,x_mouse,y_mouse,RET,F10,ESC);
    wdokey(F2);
    while (keyrdy())
        getone();
 
    auto_blocked= NO;
    return(REFRESH);   
}

set60(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    camera[active_camera].shutter= 0;
    set_shutter(0);
    auto_blocked= NO;
    return(REFRESH);       

}

set125(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    camera[active_camera].shutter= 1;
    set_shutter(1);
    auto_blocked= NO;
    return(REFRESH);       

}

set250(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    camera[active_camera].shutter= 2;
    set_shutter(2);
    auto_blocked= NO;
    return(REFRESH);       

}

set500(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    
    camera[active_camera].shutter= 3;
    set_shutter(3);
    auto_blocked= NO;
    return(REFRESH);       

}

set1000(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    
    camera[active_camera].shutter= 4;
    set_shutter(4);
    auto_blocked= NO;
    return(REFRESH);       

}

set2000(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    
    camera[active_camera].shutter= 5;
    set_shutter(5);
    auto_blocked= NO;
    return(REFRESH);       

}

set4000(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    
    camera[active_camera].shutter= 6;
    set_shutter(6);
    auto_blocked= NO;
    return(REFRESH);       

}

set10000(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera== -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        return(REFRESH);
    }
    
    camera[active_camera].shutter= 7;
    set_shutter(7);
    auto_blocked= NO;
    return(REFRESH);       

}


acq_image1(mp)
VCMENU *mp;
{
    int i;
    char d[20],t[20];
    char filename[20];
    

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!display[0].available) {
        error_func(NULL," Primary Display Device is Unavailable ",NULL);
        return(REFRESH);
    }

    if (display[0].image && !display[0].saved) {
        if (!info_func(" The previously acquired frame has NOT been saved! ",
                       NULL,
                       " Do you wish to OVERWRITE the Unsaved Frame? ")) {
            auto_blocked= NO;
            return(REFRESH);
        }
    }
    
    if (active_camera >= 0) {
        if (!enable_dis(0)) {
            auto_blocked= NO;
            return(REFRESH);
        }
        auto_blocked= YES;
        cam_select(active_camera,active_camera);
        wxatsay(camera_stat_wdo,3,14,"Acquiring Frame  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta));
        syspause(0,0,0,70);
        if (!getframe(d,t)) {
            auto_blocked= NO;
            cam_select(active_camera,active_camera);
            error_func(NULL," Frame Acquistion Aborted ",NULL);
            return(REFRESH);
        } 
        mv_view1(G_PLANE);
        display[0].image= YES;
        display[0].saved= NO;
        make_fname(filename,d,t);
        strcpy(display[0].data_name,"");
        strcat(display[0].data_name,filename);
        strcat(display[0].data_name,".FTS");
        wxatsay(camera_stat_wdo,3,2,"Display 1:",vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"%5.5s %5.5s Frame",d,t);
        wxatsay(camera_stat_wdo,3,14,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"Camera %c",(char) (active_camera+65));
        wxatsay(camera_stat_wdo,3,34,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red)); 
        display[0].strobes= active_strobes;
        strcpy(display[0].frame_date,d);
        strcpy(display[0].frame_time,t);
        display[0].cam= active_camera;
        display[0].cam_gain= camera[active_camera].gain;
        display[0].cam_offset= camera[active_camera].offset;
        display[0].cam_shutter= camera[active_camera].shutter;
        saved[0].available= NO;
        saved[0].image= NO;
        auto_blocked= NO;
        disable_dis(0);
        display[0].plane= G_PLANE;
        for (i=0;i<NUMBOARDS;i++)
            show_dis(i,display[i].plane);
        auto_blocked= NO;
        return(REFRESH);
    }
    
    error_func(NULL," No Camera Selected - Aborted. ",NULL);
    auto_blocked= NO;
    return(REFRESH);


}

acq_image2(mp)
VCMENU *mp;
{
    int i;
    char d[20],t[20];
    char filename[20];
    

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!display[1].available) {
        error_func(NULL," Primary Display Device is Unavailable ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }

    if (display[1].image && !display[1].saved) {
        if (!info_func(" The previously acquired frame has NOT been saved! ",
                       NULL,
                       " Do you wish to OVERWRITE the Unsaved Frame? ")) {
            auto_blocked= NO;
            return(REFRESH);
        }
    }
    
    if (active_camera >= 0) {
        if (!enable_dis(1)) {
            auto_blocked= NO;
            return(REFRESH);
        }
        auto_blocked= YES;
        cam_select(active_camera,active_camera);
        wxatsay(camera_stat_wdo,4,14,"Acquiring Frame  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta));
        syspause(0,0,0,70);
        if (!getframe(d,t)) {
            auto_blocked= NO;
            cam_select(active_camera,active_camera);
            error_func(NULL," Frame Acquistion Aborted ",NULL);
            return(REFRESH);
        } 
        mv_view1(G_PLANE);
        display[1].image= YES;
        display[1].saved= NO;
        make_fname(filename,d,t);
        strcpy(display[1].data_name,"");
        strcat(display[1].data_name,filename);
        strcat(display[1].data_name,".FTS");
        wxatsay(camera_stat_wdo,4,2,"Display 2:",vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"%5.5s %5.5s Frame",d,t);
        wxatsay(camera_stat_wdo,4,14,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"Camera %c",(char) (active_camera+65));
        wxatsay(camera_stat_wdo,4,34,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red)); 
        display[1].strobes= active_strobes;
        strcpy(display[1].frame_date,d);
        strcpy(display[1].frame_time,t);
        display[1].cam= active_camera;
        display[1].cam_gain= camera[active_camera].gain;
        display[1].cam_offset= camera[active_camera].offset;
        display[1].cam_shutter= camera[active_camera].shutter;
        saved[1].available= NO;
        saved[1].image= NO;
        auto_blocked= NO;
        disable_dis(1);
        display[1].plane= G_PLANE;
        for (i=0;i<NUMBOARDS;i++)
            show_dis(i,display[i].plane);
        auto_blocked= NO;
        return(REFRESH);
    }
    
    error_func(NULL," No Camera Selected - Aborted. ",NULL);
    auto_blocked= NO;
    return(REFRESH);


}

acq_image3(mp)
VCMENU *mp;
{
    int i;
    char d[20],t[20];
    char filename[20];
    

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!display[2].available) {
        error_func(NULL," Primary Display Device is Unavailable ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }

    if (display[2].image && !display[2].saved) {
        if (!info_func(" The previously acquired frame has NOT been saved! ",
                       NULL,
                       " Do you wish to OVERWRITE the Unsaved Frame? ")) {
            auto_blocked= NO;
            return(REFRESH);
        }
    }

            
    if (active_camera >= 0) {
        if (!enable_dis(2)) {
            auto_blocked= NO;
            return(REFRESH);
        }
        auto_blocked= YES;
        cam_select(active_camera,active_camera);
        wxatsay(camera_stat_wdo,5,14,"Acquiring Frame  ",vc.white+vc.bold+vc.blink+(vc.bg*vc.magenta));
        syspause(0,0,0,70);
        if (!getframe(d,t)) {
            auto_blocked= NO;
            cam_select(active_camera,active_camera);
            error_func(NULL," Frame Acquistion Aborted ",NULL);
            return(REFRESH);
        } 
        mv_view1(G_PLANE);
        display[2].image= YES;
        display[2].saved= NO;
        make_fname(filename,d,t);
        strcpy(display[2].data_name,"");
        strcat(display[2].data_name,filename);
        strcat(display[2].data_name,".FTS");
        wxatsay(camera_stat_wdo,5,2,"Display 3:",vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"%5.5s %5.5s Frame",d,t);
        wxatsay(camera_stat_wdo,5,14,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red));
        sprintf(tempstr,"Camera %c",(char) (active_camera+65));
        wxatsay(camera_stat_wdo,5,34,tempstr,vc.white+vc.bold+vc.blink+(vc.bg*vc.red)); 
        display[2].strobes= active_strobes;
        strcpy(display[2].frame_date,d);
        strcpy(display[2].frame_time,t);
        display[2].cam= active_camera;
        display[2].cam_gain= camera[active_camera].gain;
        display[2].cam_offset= camera[active_camera].offset;
        display[2].cam_shutter= camera[active_camera].shutter;
        saved[2].available= NO;
        saved[2].image= NO;
        auto_blocked= NO;
        disable_dis(2);
        display[2].plane= G_PLANE;
        for (i=0;i<NUMBOARDS;i++)
            show_dis(i,display[i].plane);
        auto_blocked= NO;
        return(REFRESH);
    }
    
    error_func(NULL," No Camera Selected - Aborted. ",NULL);
    auto_blocked= NO;
    return(REFRESH);


}

auto_image(mp)
VCMENU *mp;
{
    int i;
    char stime[20];
    int delmin= 60;
    int sh,sm,ss;
    int dw;
    int ctrl;
    void close_data_wdo();
    

    if (auto_mode) {
        auto_mode= NO;
        close_data_wdo(auto_wdo,&auup,&aulf,&aulo,&aurt);
        return(REFRESH);
    }

/*
    if (!display[0].available) {
        error_func(NULL," Primary Display Device is Unavailable ",NULL);
        return(REFRESH);
    }

    if (active_camera < 0) {
        error_func(NULL," No Camera Selected - Aborted. ",NULL);
        return(REFRESH);
    }

*/    

    if ((num_auto_commands= get_auto_params()) == 0) {
        error_func(NULL," No Automatic Parameters found - abort. ",NULL);
        return(REFRESH);
    }

    dw= data_wdo_func(acup,aclf,aclo,acrt,"[ Auto Acquire Info ]",5);
    
    wxatsay(status_wdo,1,0,"RET = done   F10 = done   ESC = done                          ",vc.dflt);

    wxatsay(dw,2,5,"Enter picture interval in minutes of time:",vc.dflt);
    xatgetc(2,50,(char *) &delmin,"##",NULLFUNC,"Enter picture acquistion interval in minutes - ESC aborts.",NULL,vc.dflt,vc.dflt,DEFAULT,INTEGER|FLDBLANK,NULL);

    if (readgets() == vckey.abort) {
        close_data_wdo(dw,&acup,&aclf,&aclo,&acrt);
        return(REFRESH);
    }

    close_data_wdo(dw,&acup,&aclf,&aclo,&acrt);

    auto_delta= ((long) delmin) * 60L;

    vcgettim(stime);
    sscanf(stime,"%2d%*c%2d%*c%2d",&sh, &sm, &ss);
    auto_start= ((long) sh) * 3600L + ((long) sm) * 60L + ((long) ss) - auto_delta;
    
    auto_mode= YES;
    
    
/*
    for (i=0;i<AUTOCOMMANDS;i++) 
        auto_shutter[i]= camera[auto_camera[i]].shutter;
*/
    auto_wdo= data_wdo_func(auup,aulf,aulo,aurt,"[ Auto Acquire Status ]",2);
    wctrl(auto_wdo,&ctrl,GET);
    ctrl^= CURSOR;
    wctrl(auto_wdo,&ctrl,SET);

    wxatsay(auto_wdo,0,5,"Auto Mode Active           Seconds to next retrieval: ",vc.dflt);
    
    return(REFRESH);
}

set_delay(mp)
VCMENU *mp;
{

    char nodd[10];
    char neven[10];
    COUNT ctrl;


    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera == -1) {
        error_func(NULL," No Active Camera Selected - abort. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }

    wselect(strobe_stat_wdo);
    sprintf(nodd,"%5u",delay.odd[camera[active_camera].shutter]);
    sprintf(neven,"%5u",delay.even[camera[active_camera].shutter]);
    xatgetc(6,17,nodd,"#####",NULLFUNC,"Enter odd field strobe delay in micro seconds",NULL,vc.dflt,vc.dflt,DEFAULT,STRING|FLDBLANK,NULL);
    xatgetc(7,17,neven,"#####",NULLFUNC,"Enter even field strobe delay in micro seconds",NULL,vc.dflt,vc.dflt,DEFAULT,STRING|FLDBLANK,NULL);

    if (readgets() != vckey.abort) {
        sscanf(nodd,"%5u",&delay.odd[camera[active_camera].shutter]);
        sscanf(neven,"%5u",&delay.even[camera[active_camera].shutter]);
    }
    
    auto_blocked= NO;
    return(REFRESH);
}


flash_strobe_one(mp)
VCMENU *mp;
{
    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
     if (!strobe[0].available) {
         error_func(NULL," Strobe Unavailable - abort. ",NULL);
         auto_blocked= NO;
         return(REFRESH);
     }

     save_strobes();
     strobe_select(0);
     
     load_delay(delay.odd[0]);
     acq_in_progress= YES;
     
     while (!check_strobes())
         if (keyrdy()) {
             if (getone() == ESC) {
                 acq_in_progress= NO;
                 bell();
                 restore_strobes();
                 auto_blocked= NO;
                 return(REFRESH);
             }
         }
          
     trigger_strobes();
     disable_strobes();
     restore_strobes();
     acq_in_progress= NO;
     auto_blocked= NO;
     return(REFRESH);
}


flash_strobe_two(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
     if (!strobe[1].available) {
         error_func(NULL," Strobe Unavailable - abort. ",NULL);
         auto_blocked= NO;
         return(REFRESH);
     }

     save_strobes();
     strobe_select(1);
     
     load_delay(delay.odd[0]);
     acq_in_progress= YES;

     while (!check_strobes())
         if (keyrdy()) {
             if (getone() == ESC) {
                 bell();
                 acq_in_progress= NO;
                 restore_strobes();
                 auto_blocked= NO;
                 return(REFRESH);
             }
         }
          
     trigger_strobes();
     disable_strobes();
     restore_strobes();
     acq_in_progress= NO;
     auto_blocked= NO;
     return(REFRESH);
     
}


flash_strobe_three(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
     if (!strobe[2].available) {
         error_func(NULL," Strobe Unavailable - abort. ",NULL);
         auto_blocked= NO;
         return(REFRESH);
     }

     save_strobes();
     strobe_select(2);
     
     load_delay(delay.odd[0]);
     acq_in_progress= YES;

     while (!check_strobes())
         if (keyrdy()) {
             if (getone() == ESC) {
                 bell();
			     acq_in_progress= NO;
                 restore_strobes();
                 auto_blocked= NO;
                 return(REFRESH);
             }
         }
          
     trigger_strobes();
     disable_strobes();
     restore_strobes();
     acq_in_progress= NO;
     auto_blocked= NO;
     return(REFRESH);
     

}


flash_strobe_four(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (!strobe[3].available) {
        error_func(NULL," Strobe Unavailable - abort. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }

    save_strobes();
    strobe_select(3);
     
    load_delay(delay.odd[0]);
    acq_in_progress= YES;

    while (!check_strobes())
        if (keyrdy()) {
            if (getone() == ESC) {
                bell();
                acq_in_progress= NO;
                restore_strobes();
                auto_blocked= NO;
                return(REFRESH);
            }
        }
         
    trigger_strobes();
    disable_strobes();
    restore_strobes();
    acq_in_progress= NO;
    auto_blocked= NO;
    return(REFRESH);
}


show_live(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera < 0) {
        error_func(NULL," No Camera Selected ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }
    
    cam_select(active_camera,active_camera);
    show_dis(0,LIVE);

    auto_blocked= NO;
    return(REFRESH);

}


show_acquired(mp)
VCMENU *mp;
{

    int attrib;
    int i;

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    for (i=0;i<NUMBOARDS;i++) {
        if (!display[i].image) 
            continue;
            
        show_dis(i,G_PLANE);

        if (!display[i].saved) 
            attrib= vc.white+vc.bold+vc.blink+(vc.bg*vc.red);
        else
            attrib= vc.white+vc.bold+(vc.bg*vc.green);
        sprintf(tempstr,"Display %1d:",i+1);
        wxatsay(camera_stat_wdo,3+i,2,tempstr,attrib);
        sprintf(tempstr,"%5.5s %5.5s Frame",display[i].frame_date,display[i].frame_time);
        wxatsay(camera_stat_wdo,3+i,14,tempstr,attrib);
        sprintf(tempstr,"Camera %c",(char) (display[i].cam+65));
        wxatsay(camera_stat_wdo,3+i,34,tempstr,attrib); 
        set_shutter(display[i].cam_shutter);
        set_gain(display[i].cam_gain);
        set_offset(display[i].cam_offset);
        disable_dis(i);
    }
    
    auto_blocked= NO;
    return(REFRESH);
    
}

show_saved(mp)
VCMENU *mp;
{
    int i;


    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    for (i=0;i<NUMBOARDS;i++) {
        if (!saved[i].available) {
            continue;
        }

        show_dis(i,I_PLANE);

        sprintf(tempstr,"Display %1d:",i+1);
        wxatsay(camera_stat_wdo,3+i,2,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta));
        sprintf(tempstr,"%5.5s %5.5s Frame",saved[i].frame_date,saved[i].frame_time);
        wxatsay(camera_stat_wdo,3+i,14,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta));
        sprintf(tempstr,"Camera %c",(char) (saved[i].cam+65));
        wxatsay(camera_stat_wdo,3+i,34,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta)); 
        set_shutter(saved[i].cam_shutter);
        set_gain(saved[i].cam_gain);
        set_offset(saved[i].cam_offset);
        disable_dis(i);
    }

    auto_blocked= NO;
    return(REFRESH);
    
}

show_odd(mp)
VCMENU *mp;
{


    int attrib;

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (saved[0].available) {
        error_func(NULL," An image has been retrieved - no odd frame available. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }
    if (!display[0].image) {
        error_func(NULL," No Acquired Image Available. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }
    show_dis(0,I_PLANE);
    attrib= vc.white+vc.bold+(vc.bg*vc.brown);
    wxatsay(camera_stat_wdo,3,2,"Display 1:",vc.white+vc.bold+(vc.bg*vc.brown));
    sprintf(tempstr,"%5.5s %5.5s Odd  ",display[0].frame_date,display[0].frame_time);
    wxatsay(camera_stat_wdo,3,14,tempstr,attrib);
    sprintf(tempstr,"Camera %c",(char) (display[0].cam+65));
    wxatsay(camera_stat_wdo,3,34,tempstr,attrib); 
    set_shutter(display[0].cam_shutter);
    set_gain(display[0].cam_gain);
    set_offset(display[0].cam_offset);
    auto_blocked= NO;
    return(REFRESH);
    
}


camera_gain(mp)
VCMENU *mp;
{

    int gain;
    int key;
    int last_plane;

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera < 0) {
        error_func(NULL," No Camera Selected - abort. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }
    last_plane= display[0].plane;
    
    show_dis(0,LIVE);
    if (!enable_dis(0)) {
        auto_blocked= NO;
        return(REFRESH);
    }
        
    cam_select(active_camera,active_camera);
    gain= camera[active_camera].gain;
    
    
    forever {
        key= getone();
        
        switch (key) {
        
            case UPARROW:
                gain+= 1;
                if (gain > 3) {
                    bell();
                    gain= 3;
                }
                break;

            case DOWNARROW:
                gain-= 1;
                if (gain < 0) {
                    bell();
                    gain= 0;
                }
                break;
                
            case ESC:
                camera[active_camera].gain= gain;
                display[0].plane= last_plane;
                disable_dis(0);
                auto_blocked= NO;
                return(REFRESH);
                
            default:
                break;
        }
        set_gain(gain);
    }

}

camera_offset(mp)
VCMENU *mp;
{

    int offset;
    int key;
    int last_plane;

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    if (active_camera < 0) {
        error_func(NULL," No Camera Selected - abort. ",NULL);
        auto_blocked= NO;
        return(REFRESH);
    }
    
    show_dis(0,LIVE);
    if (!enable_dis(0)) {
        auto_blocked= NO;
        return(REFRESH);
    }
    cam_select(active_camera,active_camera);
    offset= camera[active_camera].offset;
    
    
    forever {
        key= getone();
        
        switch (key) {
        
            case UPARROW:
                offset+= 1;
                if (offset > 255) {
                    bell();
                    offset= 255;
                }
                break;

            case DOWNARROW:
                offset-= 1;
                if (offset < 0) {
                    bell();
                    offset= 0;
                }
                break;
                
            case ESC:
                camera[active_camera].offset= offset;
                display[0].plane= last_plane;
                disable_dis(0);
                auto_blocked= NO;
                return(REFRESH);
                
            default:
                break;
        }
        set_offset(offset);
    }

}


COUNT set_colors()
{

	/* Color Set 0 */
	wtable[0].bd_t   =  vc.white+vc.bold+(vc.bg*vc.white);
	wtable[0].bg_t   =  vc.white+vc.bold+(vc.bg*vc.white);
	wtable[0].say_t  =  vc.black+(vc.bg*vc.white);
	wtable[0].nget_t =  vc.white+vc.bold+(vc.bg*vc.white);
	wtable[0].get_t  =  vc.white+vc.bold+(vc.bg*vc.red);
	wtable[0].tit_t  =  vc.white+vc.bold+(vc.bg*vc.white);

	/* Color Set 1 */
	wtable[1].bd_t   =  vc.white+vc.bold+(vc.bg*vc.blue);
	wtable[1].bg_t   =  vc.white+vc.bold+(vc.bg*vc.white);
	wtable[1].say_t  =  vc.black+(vc.bg*vc.white);
	wtable[1].nget_t =  vc.black+(vc.bg*vc.white);
	wtable[1].get_t  =  vc.white+vc.bold+(vc.bg*vc.white);
	wtable[1].tit_t  =  vc.white+vc.bold+(vc.bg*vc.blue);

	/* Color Set 2 */
	wtable[2].bd_t   =  vc.white+vc.bold+(vc.bg*vc.brown);
	wtable[2].bg_t   =  vc.white+vc.bold+(vc.bg*vc.red);
	wtable[2].say_t  =  vc.brown+vc.bold+(vc.bg*vc.red);
	wtable[2].nget_t =  vc.black+(vc.bg*vc.red);
	wtable[2].get_t  =  vc.white+vc.bold+(vc.bg*vc.red);
	wtable[2].tit_t  =  vc.white+vc.bold+(vc.bg*vc.red);

	/* Color Set 3 */
	wtable[3].bd_t   =  vc.cyan+vc.bold+(vc.bg*vc.red);
	wtable[3].bg_t   =  vc.red+(vc.bg*vc.white);
	wtable[3].say_t  =  vc.black+(vc.bg*vc.white);
	wtable[3].nget_t =  vc.black+(vc.bg*vc.white);
	wtable[3].get_t  =  vc.white+vc.bold;
	wtable[3].tit_t  =  vc.brown+vc.bold;

	/* Color Set 4 */
	wtable[4].bd_t   =  vc.black+(vc.bg*vc.cyan);
	wtable[4].bg_t   =  vc.blue+(vc.bg*vc.cyan);
	wtable[4].say_t  =  vc.blue+(vc.bg*vc.cyan);
	wtable[4].nget_t =  vc.black+(vc.bg*vc.cyan);
	wtable[4].get_t  =  vc.white+vc.bold;
	wtable[4].tit_t  =  vc.blue+(vc.bg*vc.cyan);

	/* Color Set 5 */
	wtable[5].bd_t   =  vc.red+vc.bold+(vc.bg*vc.red);
	wtable[5].bg_t   =  vc.white+vc.bold+(vc.bg*vc.red);
	wtable[5].say_t  =  vc.white+vc.bold+(vc.bg*vc.red);
	wtable[5].nget_t =  vc.brown+vc.bold+(vc.bg*vc.red);
	wtable[5].get_t  =  vc.brown+vc.bold;
	wtable[5].tit_t  =  vc.white+vc.bold+(vc.bg*vc.red);

	/* Color Set 6 */
	wtable[6].bd_t   =  vc.red+(vc.bg*vc.brown);
	wtable[6].bg_t   =  vc.brown+vc.bold+(vc.bg*vc.brown);
	wtable[6].say_t  =  vc.white+vc.bold+(vc.bg*vc.brown);
	wtable[6].nget_t =  vc.white+vc.bold+(vc.bg*vc.brown);
	wtable[6].get_t  =  vc.green+vc.bold;
	wtable[6].tit_t  =  vc.brown+vc.bold+(vc.bg*vc.brown);

	/* Color Set 7 */
	wtable[7].bd_t   =  vc.brown+vc.bold+(vc.bg*vc.brown);
	wtable[7].bg_t   =  vc.black+(vc.bg*vc.green);
	wtable[7].say_t  =  vc.black+(vc.bg*vc.green);
	wtable[7].nget_t =  vc.white+vc.bold+(vc.bg*vc.green);
	wtable[7].get_t  =  vc.brown+vc.bold;
	wtable[7].tit_t  =  vc.black+(vc.bg*vc.brown);

	/* Color Set 8 */
	wtable[8].bd_t   =  vc.brown+vc.bold+(vc.bg*vc.white);
	wtable[8].bg_t   =  vc.white+vc.bold+(vc.bg*vc.magenta);
	wtable[8].say_t  =  vc.white+vc.bold+(vc.bg*vc.magenta);
	wtable[8].nget_t =  vc.brown+vc.bold+(vc.bg*vc.magenta);
	wtable[8].get_t  =  vc.brown+vc.bold;
	wtable[8].tit_t  =  vc.magenta+(vc.bg*vc.white);

	/* Color Set 9 */
	wtable[9].bd_t   =  vc.white+vc.bold+(vc.bg*vc.cyan);
	wtable[9].bg_t   =  vc.white+(vc.bg*vc.blue);
	wtable[9].say_t  =  vc.white+(vc.bg*vc.blue);
	wtable[9].nget_t =  vc.white+vc.bold+(vc.bg*vc.blue);
	wtable[9].get_t  =  vc.white;
	wtable[9].tit_t  =  vc.white+vc.bold+(vc.bg*vc.cyan);
}

/* for vcmhook3 */

COUNT
vcmhf3(m)
VCMENU *m;
{
    if ((m->style & VERTICAL) && (m->calledby->style & HORIZONTAL) ) {
        if ( m->keyhit == CUR_RIGHT ) {
            m->result=ESCAPE;
            ungetone( CUR_RIGHT );
            ungetone( RET );
            return(!0);
        } else 
            if (m->keyhit == CUR_LEFT ) {
                m->result=ESCAPE;
                ungetone( CUR_LEFT );
                ungetone( RET );
                return(!0);
            }
    }
    return(0);
}

COUNT
data_wdo_func(up,lf,lo,rt,title,lines)
int up;
int lf;
int lo;
int rt;
char *title;
int lines;
{
    int w;
 
    w =wxxopen(up,lf,lo,rt,title,
                     ACTIVE|BORDER|BD1|CURSOR,
                     lines+5,0,6,32);
     
    if (w == -1 )
        m_error();

    return(w);
    
}

int
init_structs()
{
    int i;

    if (!get_camera_params()) {
        error_func(NULL," No camera Parameters File - Using Defaults ",NULL);
        camera[0].cenx= 945;
        camera[0].ceny= 326;
        camera[0].selected= NO;
        camera[0].available= NO;
        camera[0].gain= 1;
        camera[0].offset= 128;
        camera[0].shutter= 0;
        camera[1].cenx= 326;
        camera[1].ceny= -946;
        camera[1].selected= NO;
        camera[1].available= NO;
        camera[1].gain= 1;
        camera[1].offset= 128;
        camera[1].shutter= 0;
        camera[2].cenx= -191;
        camera[2].ceny= -982;
        camera[2].selected= NO;
        camera[2].available= NO;
        camera[2].gain= 1;
        camera[2].offset= 128;
        camera[2].shutter= 0;
        camera[3].cenx= -829;
        camera[3].ceny= 559;
        camera[3].selected= NO;
        camera[3].available= NO;
        camera[3].gain= 1;
        camera[3].offset= 128;
        camera[3].shutter= 0;
        camera[4].cenx= 1400;
        camera[4].ceny= 998;
        camera[4].selected= NO;
        camera[4].available= NO;
        camera[4].gain= 1;
        camera[4].offset= 128;
        camera[4].shutter= 0;
        camera[5].cenx= 1400;
        camera[5].ceny= 798;
        camera[5].selected= NO;
        camera[5].available= NO;
        camera[5].gain= 1;
        camera[5].offset= 128;
        camera[5].shutter= 0;
        camera[6].cenx= 1400;
        camera[6].ceny= 598;
        camera[6].selected= NO;
        camera[6].available= NO;
        camera[6].gain= 1;
        camera[6].offset= 128;
        camera[6].shutter= 0;
        camera[7].cenx= 1400;
        camera[7].ceny= 398;
        camera[7].selected= NO;
        camera[7].available= NO;
        camera[7].gain= 1;
        camera[7].offset= 128;
        camera[7].shutter= 0;
        delay.even[0]= 33000;
        delay.odd[0]= 49666;
        delay.even[1]= 33000;
        delay.odd[1]= 49666;
        delay.even[2]= 33000;
        delay.odd[2]= 49666;
        delay.even[3]= 33000;
        delay.odd[3]= 49666;
        delay.even[4]= 33000;
        delay.odd[4]= 49666;
        delay.even[5]= 33000;
        delay.odd[5]= 49666;
        delay.even[6]= 33000;
        delay.odd[6]= 49666;
        delay.even[7]= 33000;
        delay.odd[7]= 49666;
        strobe[0].cenx= 998;
        strobe[0].ceny= 70;
        strobe[0].selected= NO;
        strobe[0].ready= NO;
        strobe[0].available= NO;
        strobe[1].cenx= 70;
        strobe[1].ceny= -998;
        strobe[1].selected= NO;
        strobe[1].ready= NO;
        strobe[1].available= NO;
        strobe[2].cenx= -998;
        strobe[2].ceny= -70;
        strobe[2].selected= NO;
        strobe[2].ready= NO;
        strobe[2].available= NO;
        strobe[3].cenx= -70;
        strobe[3].ceny= 998;
        strobe[3].selected= NO;
        strobe[3].ready= NO;
        strobe[3].available= NO;
    } else {    
        for (i=0;i<NUMCAMERAS;i++)
            camera[i].selected= NO;
        for (i=0;i<NUMSTROBES;i++)
            strobe[i].selected= NO;
    }
    
    for (i=0;i<NUMBOARDS;i++) {
        display[i].available= YES;
        display[i].enabled= NO;
        display[i].image= NO;
        display[i].saved= NO;
        display[i].plane= LIVE;
        saved[i].available= NO;
        saved[i].image= NO;
    }

}

retrieve_it(n)
int n;
{
    int file;
    int i,header;
    char filename[60];

    if ((file= files_wdo_proc()) != -1) {
        strcpy(filename,data_path);
        strcat(filename,scanfile[file]);
        strcat(filename,".FTS");
        if (!enable_dis(n))
            return(REFRESH);
        mv_fclear(I_PLANE);
        mv_bank(I_PLANE);
        mv_view1(I_PLANE);
        if (!opic_infile(filename,&saved[n])) {
            error_func(NULL," Header/Image File Read Error - abort. ",NULL);
            saved[n].available= NO;
            saved[n].image= NO;
            disable_dis(n);
            return(NO);
        } else {
            sprintf(tempstr,"Display %1d:",n+1);
            wxatsay(camera_stat_wdo,3+n,2,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta));
            sprintf(tempstr,"%5.5s %5.5s Frame",saved[n].frame_date,saved[n].frame_time);
            wxatsay(camera_stat_wdo,3+n,14,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta));
            sprintf(tempstr,"Camera %c",(char) (saved[n].cam+65));
            wxatsay(camera_stat_wdo,3+n,34,tempstr,vc.white+vc.bold+(vc.bg*vc.magenta)); 
            set_shutter(saved[n].cam_shutter);
            set_gain(saved[n].cam_gain);
            set_offset(saved[n].cam_offset);
            saved[n].available= YES;
            saved[n].image= YES;
            display[n].plane= G_PLANE;
        }            
        disable_dis(n);
        return(YES);
    }
}


save_it(n,path)
int n;
char *path;
{
    if (!display[n].image || !display[n].available) {
        error_func(NULL," No Image to store - aborted ",NULL);
        return(REFRESH);
    }
    if (!display_to_disk(n,path))
        error_func(NULL," Error Writing Data to Disk ",NULL);
    sprintf(tempstr,"Display %1d:",n+1);
    wxatsay(camera_stat_wdo,3+n,2,tempstr,vc.white+vc.bold+(vc.bg*vc.green));
    sprintf(tempstr,"%5.5s %5.5s Frame",display[n].frame_date,display[n].frame_time);
    wxatsay(camera_stat_wdo,3+n,14,tempstr,vc.white+vc.bold+(vc.bg*vc.green));
    sprintf(tempstr,"Camera %c",(char) (display[n].cam+65));
    wxatsay(camera_stat_wdo,3+n,34,tempstr,vc.white+vc.bold+(vc.bg*vc.green)); 
}


COUNT
sel_disk(mp)
VCMENU *mp;
{

    if (auto_in_progress) {
        bell();
        return(REFRESH);
    }
    if (auto_mode)
        auto_blocked= YES;
    local= !local;
    if (local)
        strcpy(data_path,local_path);
    else
        strcpy(data_path,net_path);
    
    auto_blocked= NO;
    return(REFRESH);
}


/*
 * End Of File c:\opus\oven\video\opic.c  
*/

