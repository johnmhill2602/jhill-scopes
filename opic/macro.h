/* MACRO.H */
/******************************************************************************/
/* print character string */
#define printat(row,col,mess)\
printf("\x1B[%u;%uH%s",row,col,mess)

/******************************************************************************/
/* scan for parameters */
#define scanfor\
while	(!kbhit());\
inregs.h.ah = 1;\
if	(int86(0x16,&inregs,&outregs) == 0x011B)\
{	getch();\
	fflush(stdin);\
	break;\
}\
scanf

/******************************************************************************/
/* search message list */
#define mlsearch\
for	(mlp = (struct mlist *)&mhead; mlp->mlp != NULL; mlp = mlp->mlp)

/******************************************************************************/
/* search open file list */
#define flsearch\
for	(flp = (struct flist *)&fhead; flp->flp != NULL; flp = flp->flp)

/******************************************************************************/
/* search current types list */
#define tlsearch\
for	(tlp = (struct tlist *)&thead; tlp->tlp != NULL; tlp = tlp->tlp)

/******************************************************************************/
/* search active objects of given type */
#define olsearch(curt)\
for	(olp = (struct olist *)&curt; olp->olp != NULL; olp = olp->olp)

/******************************************************************************/
/* find given type */
#define tlfind(otype)\
tlsearch\
{	if	(otype[0] == '\\' && otype[1] == '\\')			break;\
	if	(strcmp((tlp->tlp)->type,otype) == 0)			break;\
	if	(otype[0] == '\\' && otype[1] == '\0')\
		if	(strcmp((tlp->tlp)->type,curtype) == 0)		break;\
	if	(otype[0] == '\\' && otype[1] == '+')\
		if	(tlp->tlp != NULL &&\
			strcmp(tlp->type,curtype) == 0)			break;\
	if	(otype[0] == '\\' && otype[1] == '-')\
		if	(strcmp(((tlp->tlp)->tlp)->type,curtype) == 0)	break;\
}
/******************************************************************************/
/* find object of given type */
#define olfind(oname)\
olsearch((tlp->tlp)->head)\
{	if	(oname[0] == '\\' && oname[1] == '\\')			break;\
	if	(strcmp((olp->olp)->name,oname) == 0)			break;\
	if	(oname[0] == '\\' && oname[1] == '\0')\
		if	(strcmp((olp->olp)->name,curname) == 0)		break;\
	if	(oname[0] == '\\' && oname[1] == '+')\
		if	(olp->olp != NULL &&\
			strcmp(olp->name,curname) == 0)			break;\
	if	(oname[0] == '\\' && oname[1] == '-')\
		if	(strcmp(((olp->olp)->olp)->name,curname) == 0)	break;\
}
/******************************************************************************/
/* search vertices of given polygon */
#define	vlsearch(vert)\
for	(vlp = (struct vlist *)&vert; vlp->vlp != NULL; vlp = vlp->vlp)

/******************************************************************************/
/* define Bresenham parameters */
#define	breset(r0,c0,r1,c1)\
short	r=r0,c=c0;\
short	*indval,*depval;\
register int	i,brtest,adddep,subind,indadj,depadj,indlen;

/******************************************************************************/
/* Bresenham line drawing algorithm */
#define	bresen\
if	(abs(r1-r0) < abs(c1-c0))\
{	indval = &c;\
	depval = &r;\
	indadj = (c0<c1)?1:-1;\
	depadj = (r0<r1)?1:-1;\
	indlen = abs(c1-c0);\
	adddep = abs(r1-r0)<<1;\
}\
else\
{	indval = &r;\
	depval = &c;\
	indadj = (r0<r1)?1:-1;\
	depadj = (c0<c1)?1:-1;\
	indlen = abs(r1-r0);\
	adddep = abs(c1-c0)<<1;\
}\
subind = indlen<<1;\
brtest = adddep-indlen;\
for	(i=0; i<indlen; i++)\
{	if	(brtest > 0)\
	{	brtest -= subind;\
		*depval += depadj;\
	}\
	brtest += adddep;\
	*indval += indadj;

