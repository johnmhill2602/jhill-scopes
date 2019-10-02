
#define YES				1
#define NO				0

#define UPARROW			328
#define DOWNARROW		336
#define RIGHTARROW		333
#define LEFTARROW		331
#define ENTER			13
#define MAX_NUM_COMMANDS	5000
#define MAXTIMEIN 32000L			/* maximum number of retries for Char Input*/
#define MAXTIMEC  32500L			/* maximum number of retries for CTS wiggle*/
#define MAXTIMEOUT 32000L			/* maximum number of retries for Char output */
#define BFMASK	0x1			/* receive buffer full mask */
#define CR			13
#define LF			10
#define BLANK		32
#define TEMASK	0x20			/* Transmitter Empty Mask */
#define RTSHIGH	0x3			/* Request to Send Mask */
#define CTSHIGH	0x10			/* Clear to Send Mask */
#define MAXCHARS  16			/* Maximum number of characters in a command string */
#define COM1		0
#define COM2		1
#define RETRIES		3
#define T_INDEX		1
#define G_PLANE		1
#define I_PLANE		0
#define LIVE		2
#define NUMBOARDS	3
#define NUMSTROBES	4
#define NUMDISPLAYS NUMBOARDS
#define NUMCAMERAS	8
#define AUTOCOMMANDS 20
#define CTC_BASE	0x250
#define CTC_CMD		CTC_BASE+1
#define CTC_OPORT	CTC_BASE+3
#define CTC_IPORT	CTC_BASE+2
#define MAXFILES	300
#define SELCOLOR color[2]
#define NOSELCOLOR color[7]
#define NOTAVAIL color[4]
#define NUM_SHUTTER_SPEEDS 8
#define SHUTTER60	 0
#define SHUTTER125	 1
#define SHUTTER250	 2
#define SHUTTER500	 3
#define SHUTTER1000	 4
#define SHUTTER2000	 5
#define SHUTTER4000	 6
#define SHUTTER10000 7
#define FITS_REC_SIZE 2880
#define NOSAVE 0
#define SAVELOCAL 1
#define SAVENET 2
#define forever		while(YES)

void error_func(char *, char *, char *);

int centery;
int centerx;
int hide_wdo;
COUNT gmode,tmode;
COUNT viewx,viewy;
COUNT color[16];
COUNT wintest;

char *scanfile[MAXFILES];

#ifdef MAIN
COUNT mouse= NO;
TEXT cur_workdir[_MAX_PATH];
TEXT *nullstr = "";
TEXT *blank_proc= "                                  ";
COUNT cur_drive;
TEXT *blank_file= "        ";
long x_mouse= 100L;
long y_mouse= 50L;
COUNT cheight= 50;
COUNT clen= 50;
COUNT graphing= NO;
COUNT port_index= 0;
COUNT lsr[2]= {0x3fd,0x2fd};
COUNT rbr[2]= {0x3f8,0x2f8};
COUNT msr[2]= {0x3fe,0x2fe};
COUNT mcr[2]= {0x3fc,0x2fc};
COUNT thr[2]= {0x3f8,0x2f8};
char tempstr[200];
int fwup= 3;
int fwlf= 0;
int fwlo= 10;
int fwrt= 79;
int numfiles;
int hdup= 11;
int hdlf= 0;
int hdlo= 19;
int hdrt= 79;
int auup= 8;
int aulf= 0;
int aulo= 10;
int aurt= 79;
int acup= 11;
int aclf= 0;
int aclo= 18;
int acrt= 79;
int shutter[8]= {YES,NO,NO,NO,NO,NO,NO,NO};
char data_path[60]= "";
char net_path[60]= "";
char local_path[60]= "";
int local= YES;
int active_camera= -1;
int active_shutter= 0;
int active_strobes= 0;
int auto_camera[AUTOCOMMANDS]= {0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
int auto_shutter[AUTOCOMMANDS]= {SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000,SHUTTER4000,
                                 SHUTTER4000,SHUTTER4000};
int auto_strobes[AUTOCOMMANDS]= {0x08,0x10,0x20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int auto_display[AUTOCOMMANDS]= {0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};
int auto_dest[AUTOCOMMANDS]= {NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,
                              NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,
                              NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,NOSAVE,
                              NOSAVE,NOSAVE};
int auto_mode= NO;
int auto_wdo;
int auto_blocked= NO;
int auto_in_progress= NO;
int num_auto_commands= 0;
unsigned int delay_counts= 32000;
int out_port= 0;
int acq_in_progress= NO;
int frame_delay= 3;
long auto_delta;
long auto_start;
#else
COUNT mouse;
extern TEXT *cur_workdir;
extern TEXT *nullstr;
extern TEXT *blank_proc;
extern COUNT cur_drive;
extern TEXT *blank_file;
long x_mouse;
long y_mouse;
COUNT cheight;
COUNT clen;
COUNT graphing;
COUNT port_index;
COUNT lsr[2];
COUNT rbr[2];
COUNT msr[2];
COUNT mcr[2];
COUNT thr[2];
long histo[256];
char tempstr[200];
int fwup,fwlf,fwlo,fwrt;
int numfiles;
int hdup,hdlf,hdlo,hdrt;
int auup,aulf,aulo,aurt;
int acup,aclf,aclo,acrt;
int shutter[8];
char data_path[60];
char net_path[60];
char local_path[60];
int local;
int active_camera;
int active_shutter;
int active_strobes;
int auto_camera[AUTOCOMMANDS];
int auto_shutter[AUTOCOMMANDS];
int auto_strobes[AUTOCOMMANDS];
int auto_display[AUTOCOMMANDS];
int auto_dest[AUTOCOMMANDS];
int auto_mode;
int auto_wdo;
int auto_blocked;
int auto_in_progress;
int num_auto_commands;
unsigned int delay_counts;
int out_port;
int acq_in_progress;
int frame_delay;
long auto_delta;
long auto_start;
#endif


typedef struct STROBE {
    int selected;
    int available;
    int ready;
    int cenx;
    int ceny;
};

typedef struct CAMERA {
    int selected;
    int available;
    int shutter;
    int gain;
    int offset;
    int cenx;
    int ceny;
};

typedef struct DISPLAY {
    int available;
    int image;
    int saved;
    int cam;
    int cam_gain;
    int cam_offset;
    int cam_shutter;
    int strobes;
    int enabled;
    int plane;
    char frame_date[14];
    char frame_time[12];
    char data_name[60];
};


typedef struct DELAY {
    unsigned int odd[NUM_SHUTTER_SPEEDS];
    unsigned int even[NUM_SHUTTER_SPEEDS];
};

struct STROBE strobe[NUMSTROBES];
struct CAMERA camera[NUMCAMERAS];
struct DISPLAY display[NUMDISPLAYS];
struct DISPLAY saved[NUMDISPLAYS];
struct DELAY delay;

/* * * * * * * * * *  Window Variables   * * * * * * * * */
COUNT status_wdo;
COUNT strobe_stat_wdo;
COUNT camera_stat_wdo;
COUNT file_wdo;
/* * * * * * * * * Other Variables * * * * * * * * */
COUNT save_dis_1();
COUNT save_dis_2();
COUNT save_dis_3();
COUNT set60();
COUNT set125();
COUNT set250();
COUNT set500();
COUNT set1000();
COUNT set2000();
COUNT set4000();
COUNT set10000();
COUNT get_pic1();
COUNT get_pic2();
COUNT get_pic3();
COUNT show_histo1();
COUNT show_histo2();
COUNT show_histo3();
COUNT exit_opic();
COUNT sel_cam_strobe();
COUNT acq_image1();
COUNT acq_image2();
COUNT acq_image3();
COUNT auto_image();
COUNT set_delay();
COUNT flash_strobe_one();
COUNT flash_strobe_two();
COUNT flash_strobe_three();
COUNT flash_strobe_four();
COUNT show_live();
COUNT sel_disk();
COUNT show_acquired();
COUNT show_saved();
COUNT show_odd();
COUNT camera_gain();
COUNT camera_offset();
COUNT do_shell();
COUNT reinitialize();
VCMENU *main_menu;
VCMENU *file_menu;
VCMENU *select_menu;
VCMENU *image_menu;
VCMENU *calibrate_menu;
VCMENU *shutter_menu;
VCMENU *show_menu;
VCMENU *camera_menu;

