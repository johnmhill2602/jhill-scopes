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

#include "mvregs.h"  /* MV1 register definitions */
#include "mvstruct.h"   /* Structures for VSC, LCA */
#include "mvmacro.h" /* Macro used in software libraries */
#include "struct.h"
#include "macro.h"
#include "param.h"   /* Parameter data types */
#include "mvboard.h"

#include "opic.h"




COUNT 
do_show_map()
{

    int i=0;

    fontinit();
    if (font_load(0,"ibmrom") != 0)
        return(NO);


    graphing= YES;
    setview(0,0,viewx,viewy);
    setaspec (1000,1000); 
    setworld(-1600,1200,1600,-1200); 
    worldon(1);

    cheight = (int) ((2400.0/((double) viewy)) * 8.0);
    clen = (int) ((3200.0/((double) viewx)) * 8.0);

    fhatsay(0,"OVEN - Top View",color[15],-1500,1100-cheight);
   
    eg_circle(0,0,900,color[0],1);
    eg_circle(0,0,700,color[1],1);
    eg_circle(0,0,900,color[15],0);
    eg_circle(0,0,700,color[15],0);
    eg_circle(0,0,150,color[0],1);
    eg_circle(0,0,150,color[15],0);
    eg_line(0,-1000,0,1000,color[15]);
    eg_line(-1000,0,1000,0,color[15]);

    fhatsay(0,"0",color[15],900-clen*2,20);
    fhatsay(0,"90",color[15],0+clen,-900+cheight);
    fhatsay(0,"180",color[15],-1000+clen*4,20);
    fhatsay(0,"270",color[15],0+clen,850-cheight);
    
    put_camera(-1450,-800,0,'A');
    put_strobe(-1450,-1000,0,'A');
    fhatsay(0,"Strobes",color[15],-1300-clen/2,-1000-cheight/2);
    fhatsay(0,"Cameras",color[15],-1300-clen/2,-800-cheight/2);


    put_strobe(1000,-600,SELCOLOR,' ');
    fhatsay(0,"Selected",color[15],1150-clen/2,-600-cheight/2);
    put_strobe(1000,-800,NOSELCOLOR,' ');
    fhatsay(0,"Unselected",color[15],1150-clen/2,-800-cheight/2);
    put_strobe(1000,-1000,NOTAVAIL,' ');
    fhatsay(0,"Unavailable",color[15],1150-clen/2,-1000-cheight/2);



    for (i=0;i<NUMCAMERAS;i++) {
        if (camera[i].selected)
            put_camera(camera[i].cenx,camera[i].ceny,SELCOLOR,(char)(i+65));
        else 
            if (camera[i].available) 
                put_camera(camera[i].cenx,camera[i].ceny,NOSELCOLOR,(char)(i+65));
            else
                put_camera(camera[i].cenx,camera[i].ceny,NOTAVAIL,(char)(i+65));
    }
    for (i=0;i<NUMSTROBES;i++) {
        if (strobe[i].selected)
            put_strobe(strobe[i].cenx,strobe[i].ceny,SELCOLOR,(char)(i+65));
        else
            if (strobe[i].available)
                put_strobe(strobe[i].cenx,strobe[i].ceny,NOSELCOLOR,(char)(i+65));
            else
                put_strobe(strobe[i].cenx,strobe[i].ceny,NOTAVAIL,(char)(i+65));
    }

    return(YES);

}

COUNT
do_vga_mode(void)
{

    int i;
    
    tmode= 3;
    gmode= 18;
    viewx= 639;
    viewy= 479;
    setvga();
    for (i=1;i<16;i++)
        color[i]= i;


    return (REFRESH);
    
}

COUNT
graph_error ()
{

    initgraf(tmode,0,0);
    wclose(hide_wdo);
    error_func(NULL," Error Loading Map - graphics unavailable. ",NULL);
    graphing= NO;
    wdokey(F2);

}


int 
minstal()
{
    _asm \
    {
        mov ax,0
        int 0x33
    }
}

int
mcuron()
{

    _asm \
    {
        mov ax,1
        int 0x33
    }
    
}

int
mcuroff()
{
    _asm \
    {
        mov ax,2
        int 0x33
    }
    
}


mpress(button)
int button;
{

    _asm \
    {
        mov ax,5
        mov bx,button
        int 0x33
    }
}

int
wait_rel(button)
int button;
{
    int status;
    int presses;

    _asm \
    {
        mov ax,5
        mov bx,button
        int 0x33
        mov presses,bx
    }

    do {
    _asm \
    {
        mov ax,6
        mov bx,button
        int 0x33
        mov status,bx
    }
    } while (status != presses);
    
}

mposbut(x,y,left,center,right)
int *x;
int *y;
int *left;
int *center;
int *right;
{
    int button;
    int xx,yy;

    _asm \
    {
        mov ax,3
        int 0x33
        mov button,bx
        mov xx,cx
        mov yy,dx
    }
    
    *left = NO;
    *center = NO;
    *right = NO;

    scrnpts(xx,yy,x,y);
    
    if (button & 1)
        *left= YES;
    if (button & 2)
        *right= YES;
    if (button & 4)
        *center= YES;
        
        
}


msetcur(x,y)
int x;
int y;
{

    int sx,sy;
    
    worldpts(x,y,&sx,&sy);
    
    _asm \
    {
        mov ax,4
        mov cx,sx
        mov dx,sy
        int 0x33
    }
    
}

int
put_camera(x,y,colr,label)
int x;
int y;
int colr;
char label;
{

    if (graphing) {
        eg_circle(x,y,90,colr,1);
        eg_circle(x,y,90,color[15],0);
        fontch(0,label,x-clen/2,y-cheight/2,color[15],0);
    }
}

int
put_strobe(x,y,colr,label)
int x;
int y;
int colr;
char label;
{

   if (graphing) {
       eg_rectangle(x-2*clen,y+2*cheight,x+2*clen,y-2*cheight,colr,1,-1);
       eg_rectangle(x-2*clen,y+2*cheight,x+2*clen,y-2*cheight,color[15],0,-1);
       fontch(0,label,x-clen/2,y-cheight/2,color[15],0);
   }


}

show_histo1(mp)
VCMENU *mp;
{

    if (display[0].plane >= LIVE) {
        error_func(NULL," Can't acquire histogram of live video - aborted. ",NULL);
        return(REFRESH);
    }
    const_histo(0);

}

show_histo2(mp)
VCMENU *mp;
{

    if (display[1].plane >= LIVE) {
        error_func(NULL," Can't acquire histogram of live video - aborted. ",NULL);
        return(REFRESH);
    }
    const_histo(1);

}
show_histo3(mp)
VCMENU *mp;
{
    if (display[2].plane >= LIVE) {
        error_func(NULL," Can't acquire histogram of live video - aborted. ",NULL);
        return(REFRESH);
    }
    const_histo(2);

}
