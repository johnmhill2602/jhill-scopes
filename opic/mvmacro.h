/* MVMACRO.H */
/******************************************************************************/
/* search config list */
#define vsearch for	(vp = (struct vsc *)&conf; vp->vp != NULL; vp = vp->vp)

/******************************************************************************/
/* read in config file */
#define	confin\
if	(conf == NULL)\
	if	((fp = fopen("config.vsc","rb")) != NULL)\
	{	for	(wp = (struct vsc *)&conf; 1; wp = vp)\
		{	if	((vp = (struct vsc *)_fmalloc(\
				sizeof(*vp))) == NULL)\
			{	mv_queue("out of memory"," ");\
				return;\
			}\
			if	(fread(vp,sizeof(*vp),1,fp) == 0)	break;\
			wp->vp = vp;\
			vp->vp = NULL;\
		}\
		wp->vp = NULL;\
		_ffree(vp);\
		fclose(fp);\
	}\
	else	mv_queue("CONFIG.VSC file not found"," ")

/******************************************************************************/
/* write out config file */
#define	confout()\
{	fp = fopen("config.vsc","wb");\
	vsearch\
		fwrite(vp->vp,sizeof(*vp),1,fp);\
	fclose(fp);\
}
/******************************************************************************/
/* output & save register image */	
#define	mvout(port,val,mask,bits)\
{	val &= mask;\
	val |= bits;\
	outp(port,val);\
}
/******************************************************************************/
/* position MV1 image & graphics cursor */
#define mvset(row,col)\
if	(lace < 2)\
{	outp(base|PUBIT|VSCXYO,0x20);\
	outp(base|PUBIT|VSCXYO+2,8|col&3);\
	outp(base|PUBIT|VSCXYA,row<<7|col>>2);\
	outp(base|PUBIT|VSCXYA+2,row>>1);\
}\
else\
{	outp(base|PUBIT|VSCXYO,0x40);\
	outp(base|PUBIT|VSCXYO+2,8|col&3);\
	outp(base|PUBIT|VSCXYA,col>>2);\
	outp(base|PUBIT|VSCXYA+2,row);\
}
/******************************************************************************/
/* write pixel to MV1 screen */
#define	mvpixout(inport,outport,value)\
if	(pix == 0)			outp(outport,value);\
else	if	(pix > 2)		outp(outport,value^inp(inport));\
	else	if	(pix > 1)	outp(outport,value&inp(inport));\
		else			outp(outport,value|inp(inport))

/******************************************************************************/
/* read pixel from MV1 screen */
#define	mvpixin(value,inport)\
value = inp(inport)

/******************************************************************************/
/* track cursor position */
#define mvtrack\
switch(mode)\
{	case 0:	mv_cursor(cr,cc);		break;\
	case 1: mv_arrow(cr,cc);		break;\
	case 2:	mv_xline(lr,lc,cr,cc);		break;\
	case 3:	mv_window(lr,lc,cr,cc);		break;\
	case 4:	if	(curpoly==NULL)	mv_cursor(cr,cc);\
		else	if	(poly)	mv_xpoly(curpoly);\
			else		mv_xline(lr,lc,cr,cc);\
}
/******************************************************************************/
/* draw line or fill polygon */
#define	mvdraw\
switch(mode)\
{	case 0:\
	case 1:\
	case 2:	mv_line(lr,lc,cr,cc);		break;\
	case 3:	mv_area(curtype,curname,NULL);	break;\
	case 4:	if	(poly)	mv_area(curtype,curname,curpoly);\
		else	{	if	(curpoly!=NULL)	mv_xline(lr,lc,cr,cc);\
				mv_polygon(cr,cc);	}\
}
/******************************************************************************/
/* grab polygon vertex */
#define	mvgrab\
vlsearch(curpoly)\
	if	((vlp->vlp)->row == cr && (vlp->vlp)->col == cc)\
		curvert = vlp->vlp

