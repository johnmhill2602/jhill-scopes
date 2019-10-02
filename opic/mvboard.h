struct BOARD {
	char		*name;
	unsigned short	ins;	/* =1 if installed and working */
	unsigned short	act;    /* =1 if activated */
	unsigned short  err;	/* =0 if no error */
	unsigned short  syn;	/* sync control */
	unsigned short  txf;	/* tranfer control */
	unsigned short  dsp;	/* display control */
}	board[3];

