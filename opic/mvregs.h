/* MVREGS.H */
#define	VSCHES	0xC000		/* vsc horizontal end sync */
#define	VSCHEB	0xC004		/* vsc horizontal end blank */
#define	VSCHSB	0xC008		/* vsc horizontal start blank */
#define	VSCHT	0xC00C		/* vsc horizontal total */
#define	VSCVES	0xC400		/* vsc vertical end sync */
#define	VSCVEB	0xC404		/* vsc vertical end blank */
#define	VSCVSB	0xC408		/* vsc vertical start blank */
#define	VSCVT	0xC40C		/* vsc vertical total */
#define	VSCDU	0xC800		/* vsc display update */
#define	VSCDS	0xC804		/* vsc display start */
#define	VSCVI	0xC808		/* vsc vertical interrupt */
#define	VSCCR1	0xC80C		/* vsc control register 1 */
#define	VSCCR2	0xCC00		/* vsc control register 2 */
#define	VSCSR	0xCC04		/* vsc status register */
#define	VSCXYO	0xCC08		/* vsc x-y offset register */
#define	VSCXYA	0xCC0C		/* vsc x-y address register */
#define	VSCDA	0xD000		/* vsc display address */
#define	VSCVC	0xD004		/* vsc vertical count register */
#define	VSCXYI	0x8000		/* vsc x-y indirect addressing */

#define MVXFER	0x9000		/* mv transfer control register */
#define MVVID	0x9001		/* mv video control register */
#define MVOFF	0x9002		/* mv offset control register */
#define MVSYNC	0x9003		/* mv sync control register */
#define MVMASK	0x9004		/* mv mask register */
#define MVXTRA	0x9005		/* mv xtra address register */
#define MVLUTA	0x9006		/* mv lut address register */
#define MVLUTC	0x9007		/* mv lut control register */
#define MVVLUT	0x9008		/* mv vlut data port */
#define MVRLUT	0x9009		/* mv rlut data port */
#define MVGLUT	0x900A		/* mv glut data port */
#define MVBLUT	0x900B		/* mv blut data port */
#define	MVRES	0x9C00		/* mv reset vsc and lca */
#define	MVPUB	0xB00F		/* mv set public */
#define	MVLCA	0xB804		/* mv lca configure */

#define PUBIT	0x2000		/* mv public/private broadcast bit */
#define	FIXFIX	0x0000		/* r/w pixel/leave cursor there */
#define	FIXINC	0x0002		/* r/w pixel/cursor right */
#define	FIXDEC	0x0004		/* r/w pixel/cursor left */
#define	FIXCLR	0x0006		/* r/w pixel/cursor this line */
#define	INCFIX	0x0008		/* r/w pixel/cursor down */
#define	INCINC	0x000A		/* r/w pixel/cursor down-right */
#define	INCDEC	0x000C		/* r/w pixel/cursor down-left */
#define	INCCLR	0x000E		/* r/w pixel/cursor next line */
#define	DECFIX	0x0400		/* r/w pixel/cursor up */
#define	DECINC	0x0402		/* r/w pixel/cursor up-right */
#define	DECDEC	0x0404		/* r/w pixel/cursor up-left */
#define	DECCLR	0x0406		/* r/w pixel/cursor last line */
#define	CLRFIX	0x0408		/* r/w pixel/cursor this column */
#define	CLRINC	0x040A		/* r/w pixel/cursor next column */
#define	CLRDEC	0x040C		/* r/w pixel/cursor last column */
#define	CLRCLR	0x040E		/* r/w pixel/cursor home */
#define	XYGRIM	0x0001		/* x-y indirect graphics/image bit */
#define ROWSR	0x4000		/* xfer row from shift reg to memory */
#define ROWRS	0x0000		/* xfer row from memory to shift reg */
