/* STRUCT.H */
/*----------------------------------------------------------------------------*/
struct	mlist			/* message list */
{
	struct	mlist	*mlp;	/* pointer to next message */
	char	message[80];	/* message */
} *mlp;

/*----------------------------------------------------------------------------*/
struct	flist			/* open file list */
{
	struct	flist	*flp;	/* pointer to next file */
	FILE	*fp;		/* file handle */
	char	name[64];	/* file name */
	char	type;		/* reserved */
	char	format;		/* reserved */
	char	header[64];	/* file header */
} *flp;

/*----------------------------------------------------------------------------*/
struct	tlist			/* current types list */
{
	struct	tlist	*tlp;	/* pointer to next type */
	char	type[32];	/* type name */
	char	curname[32];	/* current object name */
	struct	olist	*head;	/* object list pointer */
} *tlp;

/*----------------------------------------------------------------------------*/
struct	olist			/* defined object list */
{
	struct	olist	*olp;	/* pointer to next object */
	char	name[32];	/* object name */
	char	type[32];	/* type name */
	char	class;		/* reserved */
	char	format;		/* reserved */
	short	top,left;	/* position */
	short	ht,wd;		/* size */
	struct	vlist	*vlp;	/* vertex list pointer */
	char huge	*data;	/* 8-bit data array */
} *olp;

/*----------------------------------------------------------------------------*/
struct	vlist			/* polygon vertex list */
{
	struct	vlist	*vlp;	/* pointer to next vertex */
	short	row,col;	/* coordinates */
} *vlp;

/*----------------------------------------------------------------------------*/
struct	glist			/* polygon list */
{
	struct	glist	*glp;	/* pointer to next polygon */
	struct	vlist	*vlp;	/* pointer to polygon vertex list */
} *glp;

/*----------------------------------------------------------------------------*/
FILE	*fp,*fopen();
