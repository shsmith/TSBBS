long crc32val;

/* update running CRC calculation with contents of a buffer */

#ifndef	OLDC
void UpdateCRC(unsigned char *s, register int len);
#else
void UpdateCRC();
#endif	/* OLDC */
