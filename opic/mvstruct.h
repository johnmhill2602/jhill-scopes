/* MVSTRUCT.H */
/*----------------------------------------------------------------------------*/
struct	command			/* SKYVOS command structure */
{
	struct	command	*C;	/* next command link */
	struct	command	*MC;	/* macro command chain */
	int	count;		/* repeat count */
	int	index;		/* command index */
	int	numb;		/* number of arguments */
	char	name[61];	/* command name */
	
	char    narg1[12];	/* argument names */
	char    narg2[12];
	char    narg3[12];
	char    narg4[12];
	char    narg5[12];

	char    rarg1[12];	/* argument ranges */
	char    rarg2[12];
	char    rarg3[12];
	char    rarg4[12];
	char    rarg5[12];

	char    arg1[12];	/* arguments (defaults) */
	char    arg2[12];
	char    arg3[12];
	char    arg4[12];
	char    arg5[12];

} *C,*TC,*PC;

/*----------------------------------------------------------------------------*/
struct	vsc			/* TI VSC register images */
{
	struct	vsc	*vp;	/* pointer to next vsc image */
	struct	camera	*camhead;/* pointer to camera list */
	struct	film	*flmhead;/* pointer to film list */
	struct	display	*dsphead;/* pointer to display list */
	char	name[8];	/* board name */
	unsigned short	pub;	/* public bit */
	unsigned short	hes;	/* horizontal end sync */
	unsigned short	heb;	/* horizontal end blank */
	unsigned short	hsb;	/* horizontal start blank */
	unsigned short	ht;	/* horizontal total */
	unsigned short	ves;	/* vertical end sync */
	unsigned short	veb;	/* vertical end blank */
	unsigned short	vsb;	/* vertical start blank */
	unsigned short	vt;	/* vertical total */
	unsigned short	du;	/* display update */
	unsigned short	ds;	/* display start */
	unsigned short	vi;	/* vertical interrupt */
	unsigned short	cr1;	/* control register 1 */
	unsigned short	cr2;	/* control register 2 */
	unsigned short	sr;	/* status register */
	unsigned short	xyo;	/* x-y offset register */
	unsigned short	xya;	/* x-y address register */
	unsigned short	da;	/* display address register */
	unsigned short	vc;	/* vertical count register */

				/* MB MV1 register images */

	unsigned char	impub;	/* image of current pub bit */
	unsigned char	imxfer;	/* image of transfer control reg */
	unsigned char	imvid;	/* image of video control reg */
	unsigned char	imoff;	/* image of offset control reg */
	unsigned char	imdsyn;	/* display image of sync control reg */
	unsigned char	imasyn;	/* acquisition image of sync control reg */
	unsigned char	immask;	/* image of mask register */
	unsigned char	imxtra;	/* image of xtra register */
	unsigned char	imluta;	/* image of lut address reg */
	unsigned char	imlutc;	/* image of lut control reg */
	unsigned char	imfg;	/* image of current foreground color */
	unsigned char	imbg;	/* image of current background color */

} *vp,*wp;

/*----------------------------------------------------------------------------*/
struct	lca			/* Xenix Logic Cell Array structure */
{
	struct	lca	*lp;	/* pointer to next lca image */
	unsigned char	mc;	/* mode control */
	unsigned char	vc;	/* video control */
	unsigned char	oc;	/* offset control */
	unsigned char	sc;	/* sync control */
	unsigned char	mr;	/* mask register */
	unsigned char	la;	/* lut address */
	unsigned char	lc;	/* lut control */
	unsigned char	vld;	/* vlut data port */
	unsigned char	rld;	/* rlut data port */
	unsigned char	gld;	/* glut data port */
	unsigned char	bld;	/* blut data port */

} *lp; 

