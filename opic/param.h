/* PARAM.H */
struct	vsc	*conf;		/* configuration file pointer */
struct	flist	*fhead;		/* open file list */
struct	mlist	*mhead;		/* message list */
struct	tlist	*thead;		/* current types list */
struct	vlist	*curpoly;	/* current polygon vertex list */
struct	vlist	*curvert;	/* current polygon vertex */
struct	vlist	*snapw;		/* defined window sequence */
struct	vlist	*sw;		/* index into window sequence */
struct	glist	*snapg;		/* defined polygon sequence */
struct	glist	*sg;		/* index into polygon sequence */
char	curfile[64];		/* current file name */
char	curtype[32];		/* current object type */
char	curname[32];		/* current object name */
char	curbmap[32];		/* current bitmap */
char	curkern[32];		/* current kernel */
char	curpat[32];		/* current pattern */
char	curfont[32];		/* current text font */
char	curboard[8];		/* current MV1 board */
char	camname[8];		/* current camera name */
char	filmname[8];		/* current film name */
char	dispname[8];		/* current display name */
char	temp[6];		/* temporary object name list */
short	cr,cc;			/* current (row,column) cursor position */
short	lr,lc;			/* last (row,column) cursor position */
short	textht,textwd;		/* default text character size */
short	mode,disp;		/* cursor mode, displacement */
short	move,poly;		/* move window, poly defined */
short	pix,view;		/* pixel modification mode, view mode */
unsigned short	bank;		/* draw image/graphics */
unsigned short	base;		/* MV1 base address */
unsigned short	intlev;		/* MV1 interrupt level */
int	acq_mode,help_mode;	/* acquisition mode, help level */
int	lut_mode,bank_mode;	/* lookup table mode, bank mode */
int	pen_mode,color_mode;	/* pen mode, color mode */
int	config_mode,mix_mode;	/* configuration mode, mix mode */
int	pal_mode,disp_mode;	/* palette mode, display mode */
int	exit_mode,extra_mode;	/* exit mode, extra mode */
int	vwin;			/* non-interlaced window into 1024x256 image */
int	status;			/* report status */
short	lrow,lnum;		/* line acq row number & number of rows */
short	track,text;		/* track mode, text mode */
short	chan,gain,lace;		/* channel, gain, TV standard */
short	path,ilut;		/* path, ILUT section */
short	win,gon;		/* predefined windows, polygons sequence no. */
unsigned char	fcolor;		/* foreground color */
unsigned char	bcolor;		/* background color */
unsigned char	rest;		/* DC restoration */
unsigned char	offs;		/* DC offset */
unsigned char	xfer;		/* xfer register */
unsigned char	auxb;		/* aux bit */
unsigned char	sync;		/* sync source */
